package helper

// make zip qrcodes folder

import (
	"archive/zip"
	"io"
	"os"
	"path/filepath"

	"github.com/gofiber/fiber/v2"
)

// Create a zip file and return this file
func zipSource(source, target string) error {

	f, err := os.Create(target)
	if err != nil {
		return err
	}
	defer f.Close()

	writer := zip.NewWriter(f)
	defer writer.Close()

	return filepath.Walk(source, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		header, err := zip.FileInfoHeader(info)
		if err != nil {
			return err
		}

		header.Method = zip.Deflate

		header.Name, err = filepath.Rel(filepath.Dir(source), path)
		if err != nil {
			return err
		}
		if info.IsDir() {
			header.Name += "/"
		}

		headerWriter, err := writer.CreateHeader(header)
		if err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

		f, err := os.Open(path)
		if err != nil {
			return err
		}
		defer f.Close()

		_, err = io.Copy(headerWriter, f)
		return err
	})
}

func AllZip(c *fiber.Ctx) error {
	zipSource("qrcodes", "files/qrcodes.zip")
	return c.SendFile("./files/qrcodes.zip")
}
