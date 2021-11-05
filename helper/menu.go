package helper

import (
	"QRcodeBillApi/database"
	"QRcodeBillApi/models"
	"strconv"
	"time"

	"github.com/gofiber/fiber/v2"
)

// Add a new menu
func Menu(c *fiber.Ctx) error {

	price, _ := strconv.ParseFloat(c.FormValue("fprice"), 64)

	path := key(5)

	if c.FormValue("fname") == "" || c.FormValue("ftype") == "" || c.FormValue("fprice") == "" {
		c.Status(400).JSON(fiber.Map{"error": "Name is empty"})
	}
	file, err := c.FormFile("ffile")
	if err != nil {
		return err
	}
	ext := file.Filename
	ext = ext[len(ext)-3:]

	if ext != "jpg" && ext != "png" {
		return c.Status(400).SendString("error : File is not image")
	}

	menu := models.Food{
		Name:        c.FormValue("fname"),
		Price:       price,
		Type:        c.FormValue("ftype"),
		Description: c.FormValue("fdescription"),
		Path:        path,
		Created:     time.Now(),
	}

	err = c.SaveFile(file, "images/"+path+ext)
	if err != nil {
		return err
	}
	database.DB.Create(&menu)

	return c.Status(200).SendString("Menu added")
}
