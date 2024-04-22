package requests

import (
	validator "github.com/go-playground/validator/v10"
	"github.com/google/uuid"
)

type CreateTaskRequest struct {
	Name        string    `json:"name" validate:"required,min=4,max=255"`
	Description string    `json:"description" validate:"-"`
	UserID      uuid.UUID `json:"user_id" validate:"required,uuid"`
	AncestorID  uuid.UUID `json:"ancestor_id" validate:"omitempty,uuid"`
}

func (c *CreateTaskRequest) Validate() error {
	validate := validator.New(validator.WithRequiredStructEnabled())
	return validate.Struct(c)
}
