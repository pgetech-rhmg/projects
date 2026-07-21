// Command epic-compliance is the EPIC Compliance Reviewer CLI.
//
// It scans a checked-out repository against the enforceable subset of the PG&E
// T&S R&C Unified Controls Framework (app-applicable) and emits findings keyed
// to NIST control IDs. It is designed to run as an EPIC pipeline stage between
// `download` and `build`: the pipeline gates on this process's EXIT CODE.
//
//	Usage:
//	  epic-compliance <repoPath> [flags]
//
//	Flags:
//	  --app-type   appType from .pipeline/epic.json (dispatches rule packs)
//	  --out        native JSON report path (default: stdout only)
//	  --sarif      SARIF 2.1.0 report path (for ADO Advanced Security)
//	  --fail-on    gate policy: hard-fail (default) | any-fail | never
//	  --quiet      suppress the human-readable text summary
//
//	Exit codes:
//	  0  gate passed (proceed with pipeline)
//	  1  gate failed (a gating finding was raised) -> pipeline should stop
//	  2  usage / runtime error (could not complete the scan)
package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"time"

	"github.com/pgetech/epic-compliance/internal/engine"
	"github.com/pgetech/epic-compliance/internal/llm"
	"github.com/pgetech/epic-compliance/internal/output"
	"github.com/pgetech/epic-compliance/internal/profile"
	"github.com/pgetech/epic-compliance/internal/rules"
)

// version is set at build time via -ldflags "-X main.version=v1.2.3".
var version = "dev"

const (
	exitPass  = 0
	exitGate  = 1
	exitError = 2
)

func main() {
	os.Exit(run())
}

func run() int {
	appType := flag.String("app-type", "", "appType from .pipeline/epic.json")
	repoName := flag.String("repo-name", "", "repository name for the report (defaults to the base of repoPath; pass the real repo when scanning a subdir like codePath)")
	outPath := flag.String("out", "", "write native JSON report to this path")
	sarifPath := flag.String("sarif", "", "write SARIF 2.1.0 report to this path")
	mdPath := flag.String("md", "", "write Markdown report to this path")
	failOn := flag.String("fail-on", "hard-fail", "gate policy: hard-fail | any-fail | never")
	quiet := flag.Bool("quiet", false, "suppress the text summary")
	showVersion := flag.Bool("version", false, "print version and exit")

	// LLM (Portkey gateway) config. Secrets default to env so they never appear
	// on the command line. --llm turns on interpretive review; without it the
	// tool runs deterministic-only.
	useLLM := flag.Bool("llm", false, "enable LLM review of interpretive controls (Portkey gateway)")
	llmBase := flag.String("llm-base-url", os.Getenv("PORTKEY_BASE_URL"), "Portkey base URL (env PORTKEY_BASE_URL)")
	llmModel := flag.String("llm-model", os.Getenv("PORTKEY_MODEL"), "model id (env PORTKEY_MODEL)")
	llmRetries := flag.Int("llm-retries", 3, "retry attempts on transient gateway errors (429/502/503/504)")
	llmPacingMs := flag.Int("llm-pacing-ms", 250, "minimum delay between gateway requests (ms), avoids guardrail rate limits")
	llmKey := os.Getenv("PORTKEY_API_KEY") // key only via env, never a flag

	// Permute args so flags may appear before OR after the positional repo path
	// (Go's flag package otherwise stops parsing at the first positional).
	positionals := parsePermuted(os.Args[1:])

	if *showVersion {
		fmt.Println("epic-compliance", version)
		return exitPass
	}

	if len(positionals) != 1 {
		fmt.Fprintln(os.Stderr, "usage: epic-compliance <repoPath> [flags]")
		return exitError
	}
	repoPath := positionals[0]
	if info, err := os.Stat(repoPath); err != nil || !info.IsDir() {
		fmt.Fprintf(os.Stderr, "error: repo path %q is not a readable directory\n", repoPath)
		return exitError
	}

	// Build the LLM client if requested. Interpretive controls AND the profiling
	// ("evaluate") step escalate to it; without it both run deterministic-only.
	var judge rules.LLM
	var profJudge profile.LLM
	if *useLLM {
		client, err := llm.New(llm.Config{
			BaseURL:    *llmBase,
			APIKey:     llmKey,
			Model:      *llmModel,
			MaxRetries: *llmRetries,
			Pacing:     time.Duration(*llmPacingMs) * time.Millisecond,
			// Temperature omitted: Opus 4.8 rejects the parameter, and the
			// gateway/model default is already low-variance enough for a gate.
		})
		if err != nil {
			fmt.Fprintf(os.Stderr, "error: --llm requires PORTKEY_API_KEY (env), --llm-base-url and --llm-model: %v\n", err)
			return exitError
		}
		judge = client
		profJudge = client
		fmt.Fprintf(os.Stderr, "LLM review enabled (model=%s)\n", *llmModel)
	}

	report, err := engine.Scan(context.Background(), engine.Options{
		RepoPath:   repoPath,
		RepoName:   *repoName,
		AppType:    *appType,
		Version:    version,
		ScannedAt:  time.Now().UTC().Format(time.RFC3339),
		LLM:        judge,
		ProfileLLM: profJudge,
	})
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: scan failed: %v\n", err)
		return exitError
	}

	if !*quiet {
		output.WriteText(os.Stdout, report)
	}
	if *outPath != "" {
		if err := writeFile(*outPath, func(f *os.File) error { return output.WriteJSON(f, report) }); err != nil {
			fmt.Fprintf(os.Stderr, "error: writing JSON report: %v\n", err)
			return exitError
		}
	}
	if *sarifPath != "" {
		if err := writeFile(*sarifPath, func(f *os.File) error { return output.WriteSARIF(f, report) }); err != nil {
			fmt.Fprintf(os.Stderr, "error: writing SARIF report: %v\n", err)
			return exitError
		}
	}
	if *mdPath != "" {
		if err := writeFile(*mdPath, func(f *os.File) error { output.WriteMarkdown(f, report); return nil }); err != nil {
			fmt.Fprintf(os.Stderr, "error: writing Markdown report: %v\n", err)
			return exitError
		}
	}

	if report.GateFailed(*failOn) {
		fmt.Fprintln(os.Stderr, "GATE: FAIL — a gating compliance finding was raised.")
		return exitGate
	}
	fmt.Fprintln(os.Stderr, "GATE: PASS")
	return exitPass
}

// parsePermuted feeds args to the flag package in an order that tolerates
// positionals appearing before, after, or between flags. It repeatedly parses,
// collecting non-flag args, until all args are consumed. Returns the collected
// positional arguments.
func parsePermuted(args []string) []string {
	var positionals []string
	for len(args) > 0 {
		if err := flag.CommandLine.Parse(args); err != nil {
			// flag.Parse already printed usage; surface as no positionals so
			// the caller emits the usage line and exits with an error.
			return nil
		}
		rest := flag.Args()
		if len(rest) == 0 {
			break
		}
		positionals = append(positionals, rest[0])
		args = rest[1:]
	}
	return positionals
}

func writeFile(path string, fn func(*os.File) error) error {
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()
	return fn(f)
}
