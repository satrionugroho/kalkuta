package handler

import (
	"errors"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	openapi_types "github.com/oapi-codegen/runtime/types"
	"github.com/satrionugroho/bordeux/generated"
	"github.com/satrionugroho/bordeux/models"
)

func (i *Interface) ResolveTask(c *fiber.Ctx, id openapi_types.UUID) (err error) {
	var task models.Task
	var resp generated.SuccessResponse
	var userId uuid.UUID

	if uid := c.Get("x-user-id"); uid == "" {
		return i.BadRequest(c, errors.New("user id must be present"))
	} else if userId, err = uuid.Parse(uid); err != nil {
		return i.BadRequest(c, err)
	}

	if task, err = i.re.GetTask(id, userId); err != nil {
		return i.NotFoundRequest(c, err)
	}

	if err = i.re.ResolveTask(&task); err != nil {
		return i.BadRequest(c, err)
	}

	resp.Data = task.ToModel()

	return c.JSON(resp)
}
