// Package engine walks the target repository, runs the rule registry against
// it, and assembles a Report.
package engine

import (
	"bufio"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/pgetech/epic-compliance/internal/model"
	"github.com/pgetech/epic-compliance/internal/rules"
)

// fsRepo is a filesystem-backed rules.Repo. It indexes the repo's files once,
// then serves Files()/Grep() from that index so rules do not re-walk the tree.
type fsRepo struct {
	root    string
	appType string
	files   []string // repo-relative paths
}

// ignoredDirs are skipped during the walk (vendored code, VCS, build output).
var ignoredDirs = map[string]bool{
	".git": true, "node_modules": true, "dist": true, "build": true,
	"vendor": true, ".terraform": true, "bin": true, "obj": true,
	"__pycache__": true, ".venv": true, "target": true,
	// Build caches and framework scratch dirs: their contents are generated
	// bundles, not the app's own source, and only produce false evidence.
	".angular": true, ".next": true, ".nuxt": true, ".svelte-kit": true,
	".cache": true, "coverage": true, ".gradle": true,
}

// ignoredFiles are dependency lockfiles: machine-generated manifests whose
// contents produce false matches (e.g. a transitive package named "retention")
// rather than evidence about the app's own code.
var ignoredFiles = map[string]bool{
	"package-lock.json": true, "yarn.lock": true, "pnpm-lock.yaml": true,
	"go.sum": true, "Cargo.lock": true, "poetry.lock": true,
	"composer.lock": true, "Gemfile.lock": true,
}

// newRepo indexes the repository rooted at path. It honors .gitignore so the
// scanner reviews exactly what is in source control — a gitignored local
// artifact (e.g. a dev TLS key under .certs/) is not a committed secret, while
// a force-un-ignored file (e.g. `!production.env`) IS tracked and is scanned.
func newRepo(path, appType string) (*fsRepo, error) {
	r := &fsRepo{root: path, appType: appType}
	gi := loadGitignore(path)
	err := filepath.WalkDir(path, func(p string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, rerr := filepath.Rel(path, p)
		if rerr != nil {
			if d.IsDir() {
				return filepath.SkipDir
			}
			return nil // skip unrepresentable path, keep walking
		}
		if d.IsDir() {
			if ignoredDirs[d.Name()] {
				return filepath.SkipDir
			}
			// Prune gitignored directories (but never the root itself).
			if rel != "." && gi.Ignored(rel, true) {
				return filepath.SkipDir
			}
			return nil
		}
		if ignoredFiles[d.Name()] {
			return nil // dependency lockfiles: generated, not app source
		}
		if gi.Ignored(rel, false) {
			return nil // not in source control — not the repo's committed content
		}
		r.files = append(r.files, rel)
		return nil
	})
	return r, err
}

func (r *fsRepo) AppType() string { return r.appType }

// Files returns repo-relative paths whose base name matches any pattern.
func (r *fsRepo) Files(patterns ...string) []string {
	var out []string
	for _, f := range r.files {
		if matchesAny(f, patterns) {
			out = append(out, f)
		}
	}
	return out
}

// Grep scans matching files for a case-insensitive regex, returning evidence.
func (r *fsRepo) Grep(pattern string, filePatterns ...string) []model.Evidence {
	re, err := regexp.Compile("(?i)" + pattern)
	if err != nil {
		return nil // a malformed rule pattern yields no evidence, never panics
	}
	var out []model.Evidence
	for _, rel := range r.Files(filePatterns...) {
		out = append(out, r.grepFile(re, rel)...)
	}
	return out
}

func (r *fsRepo) grepFile(re *regexp.Regexp, rel string) []model.Evidence {
	f, err := os.Open(filepath.Join(r.root, rel))
	if err != nil {
		return nil
	}
	defer f.Close()

	var out []model.Evidence
	sc := bufio.NewScanner(f)
	sc.Buffer(make([]byte, 0, 64*1024), 1024*1024) // tolerate long lines
	line := 0
	for sc.Scan() {
		line++
		text := sc.Text()
		if re.MatchString(text) {
			out = append(out, model.Evidence{
				File:    rel,
				Line:    line,
				Snippet: strings.TrimSpace(truncate(text, 200)),
			})
		}
	}
	return out
}

// matchesAny reports whether the file's base name matches any glob pattern.
// A pattern with no wildcard is treated as a suffix/base match.
func matchesAny(file string, patterns []string) bool {
	if len(patterns) == 0 {
		return true
	}
	base := filepath.Base(file)
	for _, p := range patterns {
		if ok, _ := filepath.Match(p, base); ok {
			return true
		}
	}
	return false
}

func truncate(s string, n int) string {
	if len(s) > n {
		return s[:n]
	}
	return s
}

// ensure fsRepo satisfies the rules.Repo interface at compile time.
var _ rules.Repo = (*fsRepo)(nil)
