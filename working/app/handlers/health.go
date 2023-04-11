package handlers

import (
	"net/http"

	"github.com/hashicorp/go-hclog"
)

type Health struct {
	logger hclog.Logger
}

func NewHealth(l hclog.Logger) *Health {
	return &Health{l}
}

func (h *Health) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	h.logger.Info("Health called")
}
