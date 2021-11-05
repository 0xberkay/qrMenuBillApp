package main

import (
	"QRcodeBillApi/database"
	"QRcodeBillApi/routes"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
)

func main() {

	app := fiber.New()
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
	}))

	// static files
	app.Static("/api/qrcodes", "./qrcodes")
	app.Static("/api/images", "./images")
	app.Static("/", "./web")

	routes.Setup(app)

	database.Connect()

	app.Listen("127.0.0.1:3000")
}
