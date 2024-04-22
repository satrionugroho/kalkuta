package handler

import (
	"fmt"

	"github.com/gofiber/fiber/v2"
	"github.com/satrionugroho/bordeux/generated"
)

func (i *Interface) BadRequest(c *fiber.Ctx, err error) error {
	var errorResponse generated.ErrorResponse
	errorResponse.Message = err.Error()

	return c.Status(fiber.StatusBadRequest).JSON(errorResponse)
}

func (i *Interface) NotFoundRequest(c *fiber.Ctx, err error) error {
	var errorResponse generated.ErrorResponse
	errorResponse.Message = err.Error()

	return c.Status(fiber.StatusNotFound).JSON(errorResponse)
}

func (i *Interface) BadRequestMany(c *fiber.Ctx, msg interface{}) error {
	var errorResponse generated.ErrorResponse
	errorResponse.Message = fmt.Sprintf("%+v", msg)

	return c.Status(fiber.StatusBadRequest).JSON(errorResponse)
}
