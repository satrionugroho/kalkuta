package repository

import (
	"fmt"
	"strconv"
	"time"

	"github.com/allegro/bigcache/v3"
	"github.com/google/uuid"
	"github.com/satrionugroho/bordeux/generated"
	"github.com/satrionugroho/bordeux/models"
)

func (c *Conn) InsertTask(data *models.Task) error {
	return c.db.Create(&data).Error
}

func (c *Conn) GetTask(id, userId uuid.UUID) (data models.Task, err error) {
	err = c.db.Where("id = ? and user_id = ?", id, userId).First(&data).Error
	return
}

func (c *Conn) ListTaskByUserID(userId uuid.UUID, params *generated.ListTaskParams) (data []models.Task, err error) {
	offset := *params.Limit * (*params.Page - 1)
	query := c.db.Limit(*params.Limit).Offset(offset)

	if params.Q != nil {
		query = query.Where("name like ?", fmt.Sprintf("%%%s%%", *params.Q))
	}

	err = query.Where("user_id = ?", userId).Find(&data).Error
	return
}

func (c *Conn) ResolveTask(data *models.Task) error {
	data.ResolvedAt = time.Now()
	return c.UpdateTask(data)
}

func (c *Conn) AddParentTask(data *models.Task, parentID uuid.UUID) error {
	data.AncestorID = parentID
	return c.UpdateTask(data)
}

func (c *Conn) RemoveParentTask(data *models.Task, parentID uuid.UUID) error {
	data.AncestorID = uuid.Nil
	return c.UpdateTask(data)
}

func (c *Conn) UpdateTask(data *models.Task) error {
	return c.db.Save(&data).Error
}

func (c *Conn) CountAllTask(userId uuid.UUID) (int64, error) {
	return c.CountTask("", userId)
}

func (c *Conn) CountTask(q string, userId uuid.UUID) (count int64, err error) {
	key := fmt.Sprintf("count:%s:all", userId.String())

	query := c.db.Model(&models.Task{})

	if q != "" {
		key = fmt.Sprintf("count:%s:%s", userId.String(), q)
		query = query.Where("name like ?", fmt.Sprintf("%%%s%%", q))
	}

	if counter, cacheErr := c.c.Get(key); cacheErr == bigcache.ErrEntryNotFound {
		if err = query.Where("user_id = ?", userId).Count(&count).Error; err == nil {
			bs := []byte(strconv.Itoa(int(count)))
			c.c.Set(key, bs)
		}
	} else {
		countRetrieval, _ := strconv.Atoi(string(counter))
		count = int64(countRetrieval)
	}
	return
}
