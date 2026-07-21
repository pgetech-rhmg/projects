package engine

import "testing"

func TestResolveRepoName(t *testing.T) {
	tests := []struct {
		name     string
		explicit string
		path     string
		want     string
	}{
		{
			// The regression: scanning <appName>/<codePath> made the path base the
			// codePath subdir ("app"). An explicit repo name must win.
			name:     "explicit wins over subdir path base",
			explicit: "backstage",
			path:     "/home/adoagent/_work/1/s/backstage/app",
			want:     "backstage",
		},
		{
			name:     "explicit is trimmed",
			explicit: "  backstage  ",
			path:     "/whatever/app",
			want:     "backstage",
		},
		{
			name:     "empty explicit falls back to path base",
			explicit: "",
			path:     "/home/adoagent/_work/1/s/epic-web",
			want:     "epic-web",
		},
		{
			name:     "whitespace-only explicit falls back to path base",
			explicit: "   ",
			path:     "/home/adoagent/_work/1/s/epic-web",
			want:     "epic-web",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := resolveRepoName(tt.explicit, tt.path); got != tt.want {
				t.Errorf("resolveRepoName(%q, %q) = %q, want %q", tt.explicit, tt.path, got, tt.want)
			}
		})
	}
}
