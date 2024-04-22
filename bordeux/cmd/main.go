package main

import (
	"flag"
	"fmt"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/compress"
	"github.com/gofiber/fiber/v2/middleware/healthcheck"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/pprof"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/gofiber/fiber/v2/middleware/requestid"

	"github.com/satrionugroho/bordeux/config"
	"github.com/satrionugroho/bordeux/generated"
	"github.com/satrionugroho/bordeux/handler"
	"github.com/satrionugroho/bordeux/repository"
)

func main() {
	var err error
	var conf *config.Config
	var file string

	flag.StringVar(&file, "config", "./config.yaml", "your config file")
	flag.Parse()

	if conf, err = config.Load(file); err != nil {
		panic("Load config error")
	}

	serverConfig := fiber.Config{
		Prefork:      conf.Server.Prefork,
		ServerHeader: conf.Server.ServerName,
	}
	server := fiber.New(serverConfig)
	server.Use(requestid.New())
	server.Use(recover.New())
	server.Use(compress.New(compress.Config{
		Level: compress.Level(conf.Server.CompressionLevel),
	}))
	server.Use(logger.New(logger.Config{
		Format: "${white}${time} - ${red}${latency} - ${magenta}${status} - ${cyan}${method} ${url}\n",
	}))

	if conf.Server.HealthCheck {
		server.Use(healthcheck.New())
	}

	if conf.Server.Profiling {
		server.Use(pprof.New())
	}

	handlerInterface := newHandlerInterface(conf)
	generated.RegisterHandlers(server, handlerInterface)
	server.Listen(fmt.Sprintf(":%d", conf.Server.Port))
}

func newHandlerInterface(conf *config.Config) generated.ServerInterface {
	var re repository.ConnectionInterface
	var err error

	if re, err = repository.New(&conf.Database); err != nil {
		panic("cannot connect to database")
	}

	return handler.New(re, &conf.Server)
}
