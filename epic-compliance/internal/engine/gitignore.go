package engine

import (
	"bufio"
	"os"
	"path/filepath"
	"strings"
)

// gitignore is a minimal .gitignore matcher — enough to decide, for a
// checked-out tree with no .git dir, which files git would NOT track. It exists
// because the compliance scanner must review exactly what is in source control:
// a gitignored local-dev artifact (e.g. .certs/localhost-key.pem) is not a
// committed secret, while a force-un-ignored file (e.g. `!production.env`) IS
// tracked and must still be scanned.
//
// Supported (the cases that occur in real repos): comments/blank lines, `!`
// negation with last-match-wins, directory-only patterns (trailing `/`),
// anchored patterns (leading `/` or an embedded `/`), floating basename
// patterns, and `**`. Not a full git implementation — no per-directory
// re-rooting beyond prefixing nested .gitignore locations — but sufficient to
// avoid both false positives (local artifacts) and false negatives (negated
// re-includes) for secret scanning.
type gitignore struct {
	rules []ignoreRule
}

type ignoreRule struct {
	pattern  string // normalized glob, relative to repo root
	negate   bool   // `!` — re-includes a previously ignored path
	dirOnly  bool   // trailing `/` — matches directories only
}

// loadGitignore reads all .gitignore files under root (root-level + nested) and
// builds an ordered rule set. Nested .gitignore patterns are re-rooted to their
// directory so matching is done consistently against repo-relative paths.
func loadGitignore(root string) *gitignore {
	gi := &gitignore{}
	_ = filepath.WalkDir(root, func(p string, d os.DirEntry, err error) error {
		if err != nil {
			return nil
		}
		if d.IsDir() {
			if ignoredDirs[d.Name()] {
				return filepath.SkipDir
			}
			return nil
		}
		if d.Name() != ".gitignore" {
			return nil
		}
		dir, _ := filepath.Rel(root, filepath.Dir(p))
		if dir == "." {
			dir = ""
		}
		gi.addFile(p, dir)
		return nil
	})
	return gi
}

func (gi *gitignore) addFile(path, dir string) {
	f, err := os.Open(path)
	if err != nil {
		return
	}
	defer f.Close()
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		line := strings.TrimRight(sc.Text(), " ")
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		r := ignoreRule{}
		if strings.HasPrefix(line, "!") {
			r.negate = true
			line = line[1:]
		}
		if strings.HasSuffix(line, "/") {
			r.dirOnly = true
			line = strings.TrimSuffix(line, "/")
		}
		// Anchored (leading / or embedded /) patterns are relative to the
		// .gitignore's directory; floating patterns match any path segment.
		anchored := strings.HasPrefix(line, "/") || strings.Contains(strings.TrimSuffix(line, "/"), "/")
		line = strings.TrimPrefix(line, "/")
		if dir != "" {
			line = dir + "/" + line
			anchored = true
		}
		if !anchored {
			// Floating: match the basename anywhere in the tree.
			line = "**/" + line
		}
		r.pattern = line
		gi.rules = append(gi.rules, r)
	}
}

// Ignored reports whether a repo-relative path would be excluded by git.
// Last matching rule wins (so a later `!negate` re-includes). isDir narrows
// dir-only rules.
func (gi *gitignore) Ignored(rel string, isDir bool) bool {
	rel = filepath.ToSlash(rel)
	ignored := false
	for _, r := range gi.rules {
		matched := matchGitPattern(r.pattern, rel)
		// A dir-only rule (`foo/`) ignores the directory AND everything beneath
		// it. For a file, that means matching when an ancestor dir matches the
		// pattern — not the file path itself.
		if r.dirOnly && !isDir && !matched {
			matched = matchDirAncestor(r.pattern, rel)
		}
		if matched {
			ignored = !r.negate
		}
	}
	return ignored
}

// matchDirAncestor reports whether any ancestor directory of path matches the
// (dir-only) pattern — so `foo/` ignores `foo/a/b`.
func matchDirAncestor(pattern, path string) bool {
	segs := strings.Split(path, "/")
	for i := 1; i < len(segs); i++ {
		if matchGitPattern(pattern, strings.Join(segs[:i], "/")) {
			return true
		}
	}
	return false
}

// matchGitPattern matches a normalized gitignore glob against a slash path.
// Handles `**` (any path depth) plus filepath.Match's `*`/`?`/`[]` per segment.
// A pattern also matches when it names an ancestor directory of the path (git
// ignores everything under an ignored dir).
func matchGitPattern(pattern, path string) bool {
	if matchDoublestar(pattern, path) {
		return true
	}
	// Directory-prefix match: pattern `a/b` ignores `a/b/c/d`.
	if strings.HasPrefix(path, strings.TrimPrefix(pattern, "**/")+"/") {
		return true
	}
	// `**/x` should also match `x` at the root and any ancestor dir of the path.
	if strings.HasPrefix(pattern, "**/") {
		base := strings.TrimPrefix(pattern, "**/")
		for _, seg := range ancestorsAndSelf(path) {
			if ok, _ := filepath.Match(base, seg); ok {
				return true
			}
		}
	}
	return false
}

// matchDoublestar matches a `**`-bearing (or plain) pattern against a path by
// splitting on `**` and anchoring the literal segments in order.
func matchDoublestar(pattern, path string) bool {
	if !strings.Contains(pattern, "**") {
		if ok, _ := filepath.Match(pattern, path); ok {
			return true
		}
		return false
	}
	parts := strings.Split(pattern, "**")
	pos := 0
	for i, part := range parts {
		part = strings.Trim(part, "/")
		if part == "" {
			continue
		}
		idx := strings.Index(path[pos:], part)
		if idx < 0 {
			return false
		}
		if i == 0 && !strings.HasPrefix(pattern, "**") && idx != 0 {
			return false
		}
		pos += idx + len(part)
	}
	return true
}

// ancestorsAndSelf returns each path segment and the full basename chain so a
// floating pattern can match a directory anywhere in the path.
func ancestorsAndSelf(path string) []string {
	segs := strings.Split(path, "/")
	out := make([]string, 0, len(segs))
	out = append(out, segs...)          // each segment (matches a dir/base name)
	out = append(out, filepath.Base(path)) // basename (redundant but explicit)
	return out
}
