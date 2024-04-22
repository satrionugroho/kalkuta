package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v2"
)

type Config struct {
	Database Database `yaml:"database" json:"database"`
	Server   Server   `yaml:"server" json:"server"`
}

func readFile(file string) ([]byte, error) {
	path, _ := filepath.Abs(file)

	if _, err := os.Stat(path); err != nil {
		return []byte(""), err
	}

	return os.ReadFile(path)
}

func Load(file string) (*Config, error) {
	data, err := readFile(file)
	if err != nil {
		return &Config{}, err
	}
	// unmarshal to a struct
	config := Config{}
	err = yaml.Unmarshal(data, &config)
	if err != nil {
		return &Config{}, err
	}

	config.Server.Default()
	config.Database.Default()

	return &config, nil
}

type Database struct {
	DSN      string `yaml:"dsn"`
	Name     string `yaml:"name"`
	Username string `yaml:"username"`
	Password string `yaml:"password"`
	Hostname string `yaml:"host"`
	Port     uint   `yaml:"port"`
	Log      string `yaml:"log"`
}

func (d *Database) LogLevel() int {
	switch strings.ToLower(d.Log) {
	case "silent":
		return 1
	case "error":
		return 2
	case "warn":
		return 3
	default:
		return 4
	}
}

func (d *Database) Default() {
	if d.Port == 0 {
		d.Port = 5432
	}

	if d.Username == "" {
		d.Username = "postgres"
	}

	if d.Hostname == "" {
		d.Hostname = "localhost"
	}

	if d.Name == "" {
		d.Name = "sawitpro_dev"
	}

	if d.Log == "" {
		d.Log = "info"
	}

	if d.DSN == "" {
		if d.Password == "" {
			d.DSN = fmt.Sprintf("host=%s user=%s dbname=%s port=%d sslmode=disable", d.Hostname, d.Username, d.Name, d.Port)
		} else {
			d.DSN = fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%d sslmode=disable", d.Hostname, d.Username, d.Password, d.Name, d.Port)
		}
	}
}

type Server struct {
	Port             uint   `yaml:"port"`
	Prefork          bool   `yaml:"prefork"`
	ServerName       string `yaml:"name"`
	CompressionLevel int    `yaml:"compression"`
	Profiling        bool   `yaml:"profiling"`
	HealthCheck      bool   `yaml:"health_check"`
}

func (s *Server) Default() {
	if s.Port == 0 {
		s.Port = 1323
	}

	if s.ServerName == "" {
		s.ServerName = "bordeux"
	}

	if s.CompressionLevel < -1 {
		s.CompressionLevel = 0
	}

	if s.CompressionLevel > 2 {
		s.CompressionLevel = 2
	}
}
