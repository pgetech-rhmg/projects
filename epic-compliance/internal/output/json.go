// Package output renders a model.Report into the formats EPIC consumes:
// native JSON (for the EPIC dashboard / audit record) and a human-readable
// text summary (for pipeline logs). SARIF 2.1.0 (for ADO Advanced Security)
// is planned — see sarif.go.
package output

import (
	"encoding/json"
	"io"

	"github.com/pgetech/epic-compliance/internal/model"
)

// WriteJSON writes the native EPIC JSON report (pretty-printed).
func WriteJSON(w io.Writer, r model.Report) error {
	enc := json.NewEncoder(w)
	enc.SetIndent("", "  ")
	return enc.Encode(r)
}
