package models

import (
	"time"
)

type User struct {
	Id      uint      `json:"id"`
	Table   string    `json:"table"`
	Created time.Time `json:"created"`
}

type Table struct {
	Id      uint      `json:"id"`
	Key     string    `json:"key"`
	IsEmpty bool      `json:"is_empty"`
	Created time.Time `json:"created"`
	Updated time.Time `json:"updated"`
}

type Food struct {
	Id          uint      `json:"id"`
	Name        string    `json:"name"`
	Price       float64   `json:"price"`
	Type        string    `json:"type"`
	Description string    `json:"description"`
	Path        string    `json:"path"`
	Created     time.Time `json:"-"`
}
