package routes

import (
	"QRcodeBillApi/helper"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/monitor"
)

func Setup(app *fiber.App) {
	app.Get("/dashboard", monitor.New())

	app.Get("/api/register/:value/:key", helper.Login)

	app.Get("/api/table/:number", helper.BringTable)

	app.Get("api/allzip", helper.AllZip)

	app.Post("/api/menu", helper.Menu)

	app.Get("/api/menu-view", helper.MenuView)

	app.Get("/api/admin", helper.Admin)

}
