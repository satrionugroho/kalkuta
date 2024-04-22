package handler

import (
	"errors"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	openapi_types "github.com/oapi-codegen/runtime/types"
	"github.com/satrionugroho/bordeux/generated"
	"github.com/satrionugroho/bordeux/models"
	"github.com/satrionugroho/bordeux/requests"
)

func (i *Interface) UpdateTask(c *fiber.Ctx, id openapi_types.UUID) (err error) {
	var task models.Task
	var resp generated.SuccessResponse
	var params requests.UpdateTaskRequest
	var userId uuid.UUID

	if err = c.BodyParser(&params); err != nil {
		return i.BadRequest(c, err)
	}

	if uid := c.Get("x-user-id"); uid == "" {
		return i.BadRequest(c, errors.New("user id must be present"))
	} else if userId, err = uuid.Parse(uid); err != nil {
		return i.BadRequest(c, err)
	}

	if err = params.Validate(); err != nil {
		return i.BadRequest(c, err)
	}

	if task, err = i.re.GetTask(id, userId); err != nil {
		return i.NotFoundRequest(c, err)
	}

	if params.Name != "" && params.Name != task.Name {
		task.Name = params.Name
	}

	if params.Description != "" && params.Description != task.DescriptionText {
		task.DescriptionText = params.Description
	}

	if err = i.re.UpdateTask(&task); err != nil {
		return i.BadRequest(c, err)
	}

	resp.Data = task.ToModel()

	return c.JSON(resp)
}
