package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/satrionugroho/bordeux/generated"
	"gorm.io/gorm"
)

type Task struct {
	ID              uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	Name            string    `json:"name" gorm:"name;not null"`
	UserID          uuid.UUID `json:"user_id" gorm:"user_id;type:uuid;not null"`
	DescriptionText string    `json:"description" gorm:"-"`
	Description     []byte    `json:"-" gorm:"description"`
	Type            uint8     `json:"type" gorm:"type;not null"`
	AncestorID      uuid.UUID `json:"ancestor_id" gorm:"ancestor_id"`
	Deadline        time.Time `json:"deadline" gorm:"deadline"`
	ResolvedAt      time.Time `json:"resolved_at" gorm:"resolved_at"`
	InsertedAt      time.Time `json:"inserted_at" gorm:"autoCreateTime"`
	UpdatedAt       time.Time `json:"updated_at" gorm:"autoCreateTime;autoUpdateTime"`
}

func (u *Task) BeforeSave(tx *gorm.DB) (err error) {
	u.UpdatedAt = time.Now()

	if u.DescriptionText != "" {
		u.Description = []byte(u.DescriptionText)
	}

	return
}

func (u *Task) BeforeCreate(tx *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}

	if u.Type == 0 {
		u.Type = 1
	}

	u.InsertedAt = time.Now()

	return nil
}

func (u *Task) AfterFind(tx *gorm.DB) (err error) {
	u.DescriptionText = string(u.Description)
	return
}

func (u *Task) TypeName() string {
	switch u.Type {
	case 1:
		return "ticket"
	case 2:
		return "bug"
	case 3:
		return "task"
	case 4:
		return "board"
	default:
		return "board"
	}
}

func (u *Task) ToModel() (task generated.TaskModel) {
	task.Id = u.ID
	task.UserId = u.UserID
	task.Name = u.Name
	task.InsertedAt = u.InsertedAt
	task.UpdatedAt = u.UpdatedAt
	task.Type = u.TypeName()

	if !u.ResolvedAt.IsZero() {
		task.ResolvedAt = &u.ResolvedAt
	}

	if !u.Deadline.IsZero() {
		task.Deadline = &u.Deadline
	}

	if u.DescriptionText != "" {
		task.Description = &u.DescriptionText
	}

	if u.AncestorID != uuid.Nil {
		task.AncestorId = &u.AncestorID
	}

	return
}
