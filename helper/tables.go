package helper

import (
	"QRcodeBillApi/database"
	"QRcodeBillApi/models"
	"fmt"
	"strconv"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/skip2/go-qrcode"
)

// Create a new tables and create they qrcodes
func BringTable(c *fiber.Ctx) error {

	a, _ := strconv.Atoi(c.Params("number"))

	for i := 1; i <= a; i++ {

		tables := models.Table{

			IsEmpty: true,
			Created: time.Now(),
			Key:     key(10),
		}

		database.DB.Create(&tables)

		fName := "table" + strconv.Itoa(int(tables.Id)) + "_" + "qr.png"

		fLink := Url() + "/api/register" + "/" + strconv.Itoa(int(tables.Id)) + "/" + tables.Key

		err := qrcode.WriteFile(fLink, qrcode.Highest, 512, "qrcodes/"+fName)
		if err != nil {
			fmt.Printf("Sorry couldn't create qrcode:,%v", err)

		}

	}
	return c.JSON(fiber.Map{
		"message": "success",
	})
}
