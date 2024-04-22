package handler

import (
	"encoding/json"
	"errors"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/satrionugroho/bordeux/generated"
	"github.com/satrionugroho/bordeux/models"
	"github.com/satrionugroho/bordeux/requests"
)

func (i *Interface) Create(c *fiber.Ctx) (err error) {
	var params requests.CreateTaskRequest
	var resp generated.SuccessResponse
	var task models.Task

	if err = c.BodyParser(&params); err != nil {
		return i.BadRequest(c, err)
	}

	if userId := c.Get("x-user-id"); userId == "" {
		return i.BadRequest(c, errors.New("user id cannot be blank"))
	} else if params.UserID, err = uuid.Parse(userId); err != nil {
		return i.BadRequest(c, err)
	}

	if err = params.Validate(); err != nil {
		return i.BadRequest(c, err)
	}

	data, _ := json.Marshal(params)
	_ = json.Unmarshal(data, &task)

	if err = i.re.InsertTask(&task); err != nil {
		return i.BadRequest(c, err)
	}

	resp.Data = task.ToModel()

	return c.Status(fiber.StatusCreated).JSON(resp)
}
