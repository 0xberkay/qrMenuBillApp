package helper

import (
	"QRcodeBillApi/database"
	"QRcodeBillApi/models"
	"strconv"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gofiber/fiber/v2"
)

// Register a new user
const SecretKey = "secret"

func Login(c *fiber.Ctx) error {

	c.Type("html")

	var dataTable = models.Table{}

	params, err2 := strconv.Atoi(c.Params("value"))

	if err2 != nil {
		return err2
	}

	database.DB.Where("id = ?", params).First(&dataTable)

	if c.Params("key") != dataTable.Key {
		return c.SendString("message : invalid key")

	}

	if !dataTable.IsEmpty {
		return c.SendString("message : not empty")
	}
	dataTable.IsEmpty = false

	database.DB.Save(&dataTable)

	user := models.User{

		Table:   c.Params("value"),
		Created: time.Now(),
	}

	database.DB.Create(&user)

	claims := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.StandardClaims{
		Issuer:    strconv.Itoa(int(user.Id)),
		ExpiresAt: time.Now().Add(time.Hour * 2).Unix(), //2 hours
	})

	token, err := claims.SignedString([]byte(SecretKey))

	if err != nil {
		c.Status(fiber.StatusInternalServerError)
		return c.SendString("message : could not login")
	}

	cookie := fiber.Cookie{
		Name:     "jwt",
		Value:    token,
		Expires:  time.Now().Add(time.Hour * 2),
		HTTPOnly: true,
	}

	c.Cookie(&cookie)

	return c.Redirect("/")

}
