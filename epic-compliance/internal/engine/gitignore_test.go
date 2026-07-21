package engine

import (
	"os"
	"path/filepath"
	"testing"
)

// TestGitignoreNegationAndLocalArtifacts is the regression guard for the
// vm-onboarding #22055 / epic-web false-positive pair:
//   - a gitignored local artifact (.certs/localhost-key.pem) must be SKIPPED, and
//   - a force-un-ignored tracked file (`*.env` ignored but `!production.env`)
//     must still be SCANNED — otherwise honoring .gitignore would hide the very
//     secrets the gate exists to catch.
func TestGitignoreNegationAndLocalArtifacts(t *testing.T) {
	root := t.TempDir()
	write := func(rel, body string) {
		p := filepath.Join(root, rel)
		if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(p, []byte(body), 0o644); err != nil {
			t.Fatal(err)
		}
	}

	write(".gitignore", "# ignore env + certs, but re-include committed env files\n*.env\n!production.env\n.certs/\nbuild/\n")
	write(".certs/localhost-key.pem", "-----BEGIN PRIVATE KEY-----\nx\n")   // gitignored → skip
	write("env/production.env", "AZURE=AccountKey=abc\n")                    // !re-included → scan
	write("env/local.env", "SECRET=xyz\n")                                  // ignored → skip
	write("src/app.ts", "const x = 1\n")                                    // tracked → scan
	write("build/out.js", "leaked\n")                                       // ignored dir → skip

	r, err := newRepo(root, "")
	if err != nil {
		t.Fatal(err)
	}
	got := map[string]bool{}
	for _, f := range r.files {
		got[filepath.ToSlash(f)] = true
	}

	mustScan := []string{"env/production.env", "src/app.ts"}
	mustSkip := []string{".certs/localhost-key.pem", "env/local.env", "build/out.js"}
	for _, f := range mustScan {
		if !got[f] {
			t.Errorf("%s must be scanned (tracked/re-included), but was skipped", f)
		}
	}
	for _, f := range mustSkip {
		if got[f] {
			t.Errorf("%s must be skipped (gitignored), but was scanned", f)
		}
	}
}

func TestGitignoreMatching(t *testing.T) {
	gi := &gitignore{}
	gi.addFile(writeTemp(t, "*.env\n!production.env\n.certs/\nfoo/bar\n**/node_modules/\n"), "")
	cases := []struct {
		path  string
		isDir bool
		want  bool
	}{
		{"local.env", false, true},           // *.env
		{"production.env", false, false},      // !negated
		{"env/production.env", false, false},  // !negated, nested
		{".certs", true, true},                // dir-only
		{".certs/key.pem", false, true},       // under ignored dir
		{"foo/bar", false, true},              // anchored path
		{"other/foo/bar", false, false},       // anchored → not floating
		{"a/node_modules", true, true},        // **/ floating dir
		{"src/app.ts", false, false},          // not ignored
	}
	for _, c := range cases {
		if got := gi.Ignored(c.path, c.isDir); got != c.want {
			t.Errorf("Ignored(%q, dir=%v) = %v, want %v", c.path, c.isDir, got, c.want)
		}
	}
}

func writeTemp(t *testing.T, body string) string {
	t.Helper()
	p := filepath.Join(t.TempDir(), ".gitignore")
	if err := os.WriteFile(p, []byte(body), 0o644); err != nil {
		t.Fatal(err)
	}
	return p
}
