package handler

import (
	"errors"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/satrionugroho/bordeux/generated"
	"github.com/satrionugroho/bordeux/models"
	"github.com/satrionugroho/bordeux/utils"
)

func (i *Interface) ListTask(c *fiber.Ctx, params generated.ListTaskParams) (err error) {
	var tasks []models.Task
	var listTask generated.TaskResponseList
	var taskSummary generated.ListTask
	var resp generated.SuccessResponse
	var meta generated.MetaResponse
	var countTask int64
	var userId uuid.UUID

	_ = utils.DefaultQueryParams(&params)

	if uid := c.Get("x-user-id"); uid == "" {
		return i.BadRequest(c, errors.New("user id must be present"))
	} else if userId, err = uuid.Parse(uid); err != nil {
		return i.BadRequest(c, err)
	}

	if params.Q == nil {
		countTask, _ = i.re.CountAllTask(userId)
	} else {
		countTask, _ = i.re.CountTask(*params.Q, userId)
	}

	if tasks, err = i.re.ListTaskByUserID(userId, &params); err != nil {
		return i.BadRequest(c, err)
	}

	for _, task := range tasks {
		taskSummary.Id = task.ID
		taskSummary.Name = task.Name
		taskSummary.UserId = task.UserID
		if task.AncestorID != uuid.Nil {
			*taskSummary.AncestorId = task.AncestorID
		}

		if task.DescriptionText != "" {
			taskSummary.Description = &task.DescriptionText
		}

		if !task.Deadline.IsZero() {
			*taskSummary.Deadline = task.Deadline.String()
		}
		listTask = append(listTask, taskSummary)
	}

	// configure meta
	meta.Page = uint8(*params.Page)
	meta.Limit = uint8(*params.Limit)
	meta.Count = uint8(len(tasks))

	if countTask > int64(meta.Count) && meta.Count != 0 {
		meta.HasNext = true
	}

	if meta.Count > 0 && meta.Page != 1 {
		meta.HasPrev = true
	}

	// configure response
	resp.Data = listTask
	resp.Meta = meta

	return c.JSON(resp)
}
