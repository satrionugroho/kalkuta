package repository

import (
	"context"
	"time"

	"github.com/allegro/bigcache/v3"
	"github.com/google/uuid"
	"github.com/satrionugroho/bordeux/config"
	"github.com/satrionugroho/bordeux/generated"
	"github.com/satrionugroho/bordeux/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type Conn struct {
	db *gorm.DB
	c  *bigcache.BigCache
}

func (c *Conn) Engine() *gorm.DB {
	return c.db
}

type ConnectionInterface interface {
	Engine() *gorm.DB
	InsertTask(task *models.Task) error
	GetTask(id, userId uuid.UUID) (models.Task, error)
	ListTaskByUserID(userId uuid.UUID, params *generated.ListTaskParams) ([]models.Task, error)
	CountAllTask(userId uuid.UUID) (int64, error)
	CountTask(searchQuery string, userId uuid.UUID) (int64, error)
	ResolveTask(task *models.Task) error
	UpdateTask(task *models.Task) error
}

func New(conf *config.Database) (ConnectionInterface, error) {
	var d *gorm.DB
	var err error

	if d, err = gorm.Open(postgres.Open(conf.DSN()), &gorm.Config{
		Logger: logger.Default.LogMode(logger.LogLevel(conf.LogLevel())),
	}); err != nil {
		return &Conn{}, err
	}

	cache, _ := bigcache.New(context.Background(), bigcache.DefaultConfig(10*time.Minute))

	return &Conn{db: d, c: cache}, nil
}
