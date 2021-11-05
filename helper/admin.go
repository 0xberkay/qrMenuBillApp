package helper

import (
	"QRcodeBillApi/database"
	"QRcodeBillApi/models"

	"github.com/gofiber/fiber/v2"
)

//return tables data
func Admin(c *fiber.Ctx) error {

	var tables []models.Table

	database.DB.Table("tables").Find(&tables)

	menuLen := len(tables)

	tableIsEmpty := []bool{}

	for i := 0; i < menuLen; i++ {
		table := tables[i]

		tableIsEmpty = append(tableIsEmpty, table.IsEmpty)

	}
	return c.JSON(fiber.Map{
		"tablesLen": len(tables),

		"tableIsEmpty": tableIsEmpty,
	})
}
