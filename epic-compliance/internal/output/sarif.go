package output

import (
	"encoding/json"
	"io"
	"strings"

	"github.com/pgetech/epic-compliance/internal/model"
)

// profileProps flattens the app profile into SARIF run properties so the
// classification that drove control disposition travels with the log.
func profileProps(p model.Profile) map[string]string {
	if len(p.Kinds) == 0 {
		return nil
	}
	kinds := make([]string, len(p.Kinds))
	for i, k := range p.Kinds {
		kinds[i] = string(k)
	}
	props := map[string]string{
		"appKinds":  strings.Join(kinds, ","),
		"authModel": string(p.AuthModel),
	}
	if p.IdP != "" {
		props["idp"] = p.IdP
	}
	if p.Narrative != "" {
		props["profileNarrative"] = p.Narrative
	}
	return props
}

// SARIF 2.1.0 emission for ADO Advanced Security.
//
// This is a minimal, correct-shape SARIF log: one run, a rules[] table keyed by
// NIST control ID, and one result per non-N/A finding. It is intentionally
// small; richer fields (fingerprints, code-flow, fixes) can be added later.

type sarifLog struct {
	Schema  string     `json:"$schema"`
	Version string     `json:"version"`
	Runs    []sarifRun `json:"runs"`
}

type sarifRun struct {
	Tool       sarifTool         `json:"tool"`
	Results    []sarifResult     `json:"results"`
	Properties map[string]string `json:"properties,omitempty"`
}

type sarifTool struct {
	Driver sarifDriver `json:"driver"`
}

type sarifDriver struct {
	Name           string      `json:"name"`
	Version        string      `json:"version"`
	InformationURI string      `json:"informationUri,omitempty"`
	Rules          []sarifRule `json:"rules"`
}

type sarifRule struct {
	ID               string            `json:"id"`
	Name             string            `json:"name"`
	ShortDescription sarifText         `json:"shortDescription"`
	FullDescription  sarifText         `json:"fullDescription"`
	Properties       map[string]string `json:"properties,omitempty"`
}

type sarifResult struct {
	RuleID    string          `json:"ruleId"`
	Level     string          `json:"level"` // error | warning | note
	Message   sarifText       `json:"message"`
	Locations []sarifLocation `json:"locations,omitempty"`
}

type sarifText struct {
	Text string `json:"text"`
}

type sarifLocation struct {
	PhysicalLocation sarifPhysical `json:"physicalLocation"`
}

type sarifPhysical struct {
	ArtifactLocation sarifArtifact `json:"artifactLocation"`
	Region           *sarifRegion  `json:"region,omitempty"`
}

type sarifArtifact struct {
	URI string `json:"uri"`
}

type sarifRegion struct {
	StartLine int `json:"startLine"`
}

func boolStr(b bool) string {
	if b {
		return "true"
	}
	return "false"
}

// sarifMessage renders the finding's explanation for SARIF: the normalized
// verdict/why line, plus (for an absent-mechanism finding) the search scope so
// the reason is self-contained in the security-scanning UI.
func sarifMessage(f model.Finding) string {
	msg := reasonLine(f)
	if len(f.Evidence) == 0 && f.SearchScope != nil {
		msg += " (" + searchScopeText(f.SearchScope) + ")"
	}
	return msg
}

// sarifLevel maps a verdict to a SARIF result level. Only findings that
// represent an actionable problem become results; PASS/N/A are omitted.
func sarifLevel(f model.Finding) (string, bool) {
	switch f.Verdict {
	case model.VerdictFail:
		if f.Kind == model.KindHard {
			return "error", true
		}
		return "warning", true
	case model.VerdictPartial:
		return "warning", true
	case model.VerdictManual:
		return "note", true
	default: // PASS, N/A
		return "", false
	}
}

// WriteSARIF writes a SARIF 2.1.0 log for the report.
func WriteSARIF(w io.Writer, r model.Report) error {
	ruleSeen := map[string]bool{}
	var srules []sarifRule
	var results []sarifResult

	for _, f := range r.Findings {
		if !ruleSeen[f.RuleID] {
			ruleSeen[f.RuleID] = true
			srules = append(srules, sarifRule{
				ID:               f.RuleID,
				Name:             f.Control.NISTID + " " + f.Control.Title,
				ShortDescription: sarifText{Text: f.Control.Title},
				FullDescription:  sarifText{Text: f.Control.Requirement},
				Properties: map[string]string{
					"nistId":     f.Control.NISTID,
					"internalId": f.Control.InternalID,
					"kind":       string(f.Kind),
					"coverage":   f.Control.Coverage,
					"mandatory":  boolStr(f.Control.Mandatory),
				},
			})
		}
		level, ok := sarifLevel(f)
		if !ok {
			continue
		}
		res := sarifResult{
			RuleID:  f.RuleID,
			Level:   level,
			Message: sarifText{Text: f.Control.NISTID + ": " + sarifMessage(f)},
		}
		// Emit a location for every match AND anchor, so an absent-mechanism FAIL
		// still lands on the file where the mechanism should live in ADO
		// Advanced Security (rather than showing no location at all).
		for _, e := range f.Evidence {
			loc := sarifLocation{PhysicalLocation: sarifPhysical{
				ArtifactLocation: sarifArtifact{URI: e.File},
			}}
			if e.Line > 0 {
				loc.PhysicalLocation.Region = &sarifRegion{StartLine: e.Line}
			}
			res.Locations = append(res.Locations, loc)
		}
		results = append(results, res)
	}

	log := sarifLog{
		Schema:  "https://json.schemastore.org/sarif-2.1.0.json",
		Version: "2.1.0",
		Runs: []sarifRun{{
			Tool: sarifTool{Driver: sarifDriver{
				Name:    "epic-compliance",
				Version: r.Metadata.Version,
				Rules:   srules,
			}},
			Results:    results,
			Properties: profileProps(r.Profile),
		}},
	}

	enc := json.NewEncoder(w)
	enc.SetIndent("", "  ")
	return enc.Encode(log)
}
