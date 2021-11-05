package helper

import (
	"QRcodeBillApi/database"
	"QRcodeBillApi/models"

	"github.com/dgrijalva/jwt-go"
	"github.com/gofiber/fiber/v2"
)

// Return menu and authorization information
func MenuView(c *fiber.Ctx) error {

	cookie := c.Cookies("jwt")

	token, err := jwt.ParseWithClaims(cookie, &jwt.StandardClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(SecretKey), nil
	})

	if err != nil {
		c.Status(fiber.StatusUnauthorized)
		return c.JSON(fiber.Map{
			"message": "unauthenticated",
		})
	}

	claims := token.Claims.(*jwt.StandardClaims)

	var user models.User

	database.DB.Where("id = ?", claims.Issuer).First(&user)

	var menus []models.Food

	// Get all menus
	database.DB.Table("foods").Find(&menus)

	return c.JSON(fiber.Map{
		"menu": menus,
		"user": user,
	})

}
