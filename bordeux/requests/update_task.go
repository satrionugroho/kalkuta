package requests

import (
	validator "github.com/go-playground/validator/v10"
	"github.com/google/uuid"
)

type UpdateTaskRequest struct {
	Name        string    `json:"name" validate:"omitempty,min=4,max=255"`
	Description string    `json:"description" validate:"-"`
	AncestorID  uuid.UUID `json:"ancestor_id" validate:"omitempty,uuid"`
}

func (c *UpdateTaskRequest) Validate() error {
	validate := validator.New(validator.WithRequiredStructEnabled())
	return validate.Struct(c)
}
