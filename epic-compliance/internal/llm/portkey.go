// Package llm provides the reasoning backend for interpretive controls.
//
// It talks to the PG&E Portkey AI gateway, which exposes an OpenAI-compatible
// /chat/completions endpoint that fronts Bedrock (Claude). The client is a thin
// net/http implementation — no third-party SDK — so the tool stays a single
// static binary.
//
// Credentials and model are supplied by the caller (from flags/env); nothing is
// hardcoded. When no client is configured, the engine injects nil and
// interpretive rules fall back to their deterministic heuristic.
package llm

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/pgetech/epic-compliance/internal/model"
)

// Config configures the Portkey client.
type Config struct {
	BaseURL string // e.g. https://aws-ai-gateway.nonprod.pge.com/v1
	APIKey  string // Portkey API key
	Model   string // e.g. @bedrock-dev/us.anthropic.claude-opus-4-8...
	// MaxTokens defaults to a sensible CI value if zero.
	MaxTokens int
	// Temperature is sent only when non-nil. Some Bedrock models (e.g. Opus
	// 4.8) reject the parameter outright, so leave it nil for those.
	Temperature *float64
	Timeout     time.Duration
	// MaxRetries is the number of retry attempts on transient (429/503/502/504)
	// gateway errors. Defaults to 3.
	MaxRetries int
	// RetryBaseDelay is the base backoff between retries (exponential). Defaults
	// to 500ms.
	RetryBaseDelay time.Duration
	// Pacing is a minimum delay enforced between successive requests, to avoid
	// tripping the gateway's guardrail rate limit. Defaults to 250ms.
	Pacing time.Duration
}

// Client is a Portkey-backed llm implementation satisfying rules.LLM.
type Client struct {
	cfg      Config
	http     *http.Client
	lastCall time.Time // for request pacing
}

// New builds a client. Returns an error if required config is missing.
func New(cfg Config) (*Client, error) {
	if cfg.BaseURL == "" || cfg.APIKey == "" || cfg.Model == "" {
		return nil, fmt.Errorf("llm: BaseURL, APIKey and Model are all required")
	}
	if cfg.MaxTokens == 0 {
		cfg.MaxTokens = 1024
	}
	if cfg.Timeout == 0 {
		cfg.Timeout = 60 * time.Second
	}
	if cfg.MaxRetries == 0 {
		cfg.MaxRetries = 3
	}
	if cfg.RetryBaseDelay == 0 {
		cfg.RetryBaseDelay = 500 * time.Millisecond
	}
	if cfg.Pacing == 0 {
		cfg.Pacing = 250 * time.Millisecond
	}
	return &Client{cfg: cfg, http: &http.Client{Timeout: cfg.Timeout}}, nil
}

// chat request/response shapes (OpenAI-compatible subset).
// Temperature is a pointer with omitempty: some Bedrock models (e.g. Opus 4.8)
// reject the parameter entirely, so we only send it when explicitly set.
type chatReq struct {
	Model       string    `json:"model"`
	Messages    []message `json:"messages"`
	MaxTokens   int       `json:"max_tokens"`
	Temperature *float64  `json:"temperature,omitempty"`
}

type message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type chatResp struct {
	Choices []struct {
		Message message `json:"message"`
	} `json:"choices"`
	Error *struct {
		Message string `json:"message"`
	} `json:"error"`
}

// verdictReply is the strict JSON we ask the model to return.
type verdictReply struct {
	Verdict   string `json:"verdict"` // PASS|PARTIAL|FAIL|N/A|MANUAL
	Reasoning string `json:"reasoning"`
}

// Judge asks the model to evaluate a control against the supplied evidence and
// return a verdict + reasoning. It satisfies rules.LLM.
func (c *Client) Judge(ctx context.Context, control model.Control, evidence []model.Evidence, question string) (model.Verdict, string, error) {
	system := "You are a PG&E compliance reviewer. Evaluate a single security control " +
		"against code evidence extracted from a repository. Be strict and conservative: " +
		"if the evidence does not clearly satisfy the control, do not pass it. Respond ONLY " +
		"with a compact JSON object: {\"verdict\":\"PASS|PARTIAL|FAIL|N/A|MANUAL\",\"reasoning\":\"one or two sentences\"}. " +
		"Use N/A when the control's precondition is absent from the app; MANUAL when only human/runtime attestation can confirm it."

	var b strings.Builder
	fmt.Fprintf(&b, "Control %s — %s\nRequirement: %s\n\nQuestion: %s\n\nEvidence:\n",
		control.NISTID, control.Title, control.Requirement, question)
	if len(evidence) == 0 {
		b.WriteString("(no matching code evidence found)\n")
	}
	for _, e := range evidence {
		if e.Line > 0 {
			fmt.Fprintf(&b, "- %s:%d  %s\n", e.File, e.Line, e.Snippet)
		} else {
			fmt.Fprintf(&b, "- %s  %s\n", e.File, e.Snippet)
		}
	}

	body, err := c.complete(ctx, system, b.String())
	if err != nil {
		return "", "", err
	}
	raw, err := extractContent(body)
	if err != nil {
		return "", "", err
	}
	v, reason := parseVerdict(raw)
	return v, reason, nil
}

// Ask sends a system+user prompt and returns the model's text content. It
// satisfies profile.LLM, letting the profiling ("evaluate") step reuse the same
// paced/retrying gateway client as the interpretive rules.
func (c *Client) Ask(ctx context.Context, system, user string) (string, error) {
	body, err := c.complete(ctx, system, user)
	if err != nil {
		return "", err
	}
	return extractContent(body)
}

func (c *Client) complete(ctx context.Context, system, user string) (string, error) {
	reqBody, _ := json.Marshal(chatReq{
		Model:       c.cfg.Model,
		MaxTokens:   c.cfg.MaxTokens,
		Temperature: c.cfg.Temperature,
		Messages: []message{
			{Role: "system", Content: system},
			{Role: "user", Content: user},
		},
	})

	url := strings.TrimRight(c.cfg.BaseURL, "/") + "/chat/completions"

	var lastErr error
	for attempt := 0; attempt <= c.cfg.MaxRetries; attempt++ {
		// Pace requests to avoid tripping the gateway's guardrail rate limit,
		// and apply exponential backoff on retries.
		if wait := c.nextDelay(attempt); wait > 0 {
			select {
			case <-time.After(wait):
			case <-ctx.Done():
				return "", ctx.Err()
			}
		}

		body, status, err := c.do(ctx, url, reqBody)
		c.lastCall = timeNow()
		if err != nil {
			lastErr = err
			if retriable(status) && attempt < c.cfg.MaxRetries {
				continue
			}
			return "", err
		}
		return body, nil
	}
	return "", lastErr
}

// do performs one request. On a non-2xx it returns the (untruncated) error.
func (c *Client) do(ctx context.Context, url string, reqBody []byte) (string, int, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(reqBody))
	if err != nil {
		return "", 0, err
	}
	req.Header.Set("Content-Type", "application/json")
	// Portkey accepts the API key via either header; set both for compatibility.
	req.Header.Set("Authorization", "Bearer "+c.cfg.APIKey)
	req.Header.Set("x-portkey-api-key", c.cfg.APIKey)

	resp, err := c.http.Do(req)
	if err != nil {
		// Network/transport errors are treated as retriable (status 0).
		return "", 0, fmt.Errorf("llm: request failed: %w", err)
	}
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		// Full body (not truncated) so the real cause — e.g. guardrail rate
		// limit inside hook_results — is visible in the finding/logs.
		return "", resp.StatusCode, fmt.Errorf("llm: gateway returned %d: %s", resp.StatusCode, string(body))
	}
	return string(body), resp.StatusCode, nil
}

// nextDelay returns how long to wait before attempt N: pacing on the first
// call (relative to the previous request), exponential backoff on retries.
func (c *Client) nextDelay(attempt int) time.Duration {
	if attempt == 0 {
		// Enforce minimum spacing since the last request.
		if c.lastCall.IsZero() {
			return 0
		}
		if elapsed := timeSince(c.lastCall); elapsed < c.cfg.Pacing {
			return c.cfg.Pacing - elapsed
		}
		return 0
	}
	// Exponential backoff: base * 2^(attempt-1).
	return c.cfg.RetryBaseDelay << (attempt - 1)
}

// retriable reports whether a status warrants a retry. Status 0 means a
// transport error (connection reset, timeout) which is also retriable.
func retriable(status int) bool {
	switch status {
	case 0, http.StatusTooManyRequests, // 429
		http.StatusBadGateway,         // 502
		http.StatusServiceUnavailable, // 503
		http.StatusGatewayTimeout:     // 504
		return true
	default:
		return false
	}
}

// extractContent decodes a raw chat-completion response body into the message
// content, surfacing gateway-level errors and empty responses.
func extractContent(body string) (string, error) {
	var cr chatResp
	if err := json.Unmarshal([]byte(body), &cr); err != nil {
		return "", fmt.Errorf("llm: decoding response: %w", err)
	}
	if cr.Error != nil {
		return "", fmt.Errorf("llm: %s", cr.Error.Message)
	}
	if len(cr.Choices) == 0 {
		return "", fmt.Errorf("llm: empty response")
	}
	return cr.Choices[0].Message.Content, nil
}

// parseVerdict extracts the verdict JSON from a model reply, tolerating code
// fences or surrounding prose.
func parseVerdict(raw string) (model.Verdict, string) {
	s := raw
	if i := strings.Index(s, "{"); i >= 0 {
		if j := strings.LastIndex(s, "}"); j > i {
			s = s[i : j+1]
		}
	}
	var vr verdictReply
	if err := json.Unmarshal([]byte(s), &vr); err != nil {
		// Could not parse — surface as MANUAL so a human looks, never fake-pass.
		return model.VerdictManual, "LLM reply could not be parsed as a verdict: " + truncate(raw, 160)
	}
	return normalizeVerdict(vr.Verdict), vr.Reasoning
}

func normalizeVerdict(v string) model.Verdict {
	switch model.Verdict(strings.ToUpper(strings.TrimSpace(v))) {
	case model.VerdictPass:
		return model.VerdictPass
	case model.VerdictPartial:
		return model.VerdictPartial
	case model.VerdictFail:
		return model.VerdictFail
	case model.VerdictNA:
		return model.VerdictNA
	default:
		return model.VerdictManual
	}
}

func truncate(s string, n int) string {
	if len(s) > n {
		return s[:n] + "…"
	}
	return s
}

// timeNow/timeSince wrap the clock so pacing logic stays readable.
func timeNow() time.Time                  { return time.Now() }
func timeSince(t time.Time) time.Duration { return time.Since(t) }
