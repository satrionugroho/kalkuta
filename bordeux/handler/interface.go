package handler

import (
	"github.com/satrionugroho/bordeux/config"
	"github.com/satrionugroho/bordeux/repository"
)

type Interface struct {
	re repository.ConnectionInterface
	s  *config.Server
}

func New(re repository.ConnectionInterface, s *config.Server) *Interface {
	return &Interface{re: re, s: s}
}
