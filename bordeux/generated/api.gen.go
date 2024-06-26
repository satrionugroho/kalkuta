// Package generated provides primitives to interact with the openapi HTTP API.
//
// Code generated by github.com/deepmap/oapi-codegen/v2 version v2.1.0 DO NOT EDIT.
package generated

import (
	"bytes"
	"compress/gzip"
	"encoding/base64"
	"fmt"
	"net/url"
	"path"
	"strings"
	"time"

	"github.com/getkin/kin-openapi/openapi3"
	"github.com/gofiber/fiber/v2"
	"github.com/oapi-codegen/runtime"
	openapi_types "github.com/oapi-codegen/runtime/types"
)

// ErrorResponse defines model for ErrorResponse.
type ErrorResponse struct {
	Message string `json:"message"`
}

// ListTask defines model for ListTask.
type ListTask struct {
	AncestorId  *openapi_types.UUID `json:"ancestor_id"`
	Deadline    *string             `json:"deadline"`
	Description *string             `json:"description"`
	Id          openapi_types.UUID  `json:"id"`
	Name        string              `json:"name"`
	UserId      openapi_types.UUID  `json:"user_id"`
}

// MetaResponse defines model for MetaResponse.
type MetaResponse struct {
	Count   uint8 `json:"count"`
	HasNext bool  `json:"has_next"`
	HasPrev bool  `json:"has_prev"`
	Limit   uint8 `json:"limit"`
	Page    uint8 `json:"page"`
}

// SuccessResponse defines model for SuccessResponse.
type SuccessResponse struct {
	Data interface{}  `json:"data"`
	Meta MetaResponse `json:"meta"`
}

// TaskModel defines model for TaskModel.
type TaskModel struct {
	AncestorId  *openapi_types.UUID `json:"ancestor_id"`
	Deadline    *time.Time          `json:"deadline"`
	Description *string             `json:"description"`
	Id          openapi_types.UUID  `json:"id"`
	InsertedAt  time.Time           `json:"inserted_at"`
	Name        string              `json:"name"`
	ResolvedAt  *time.Time          `json:"resolved_at"`
	Type        string              `json:"type"`
	UpdatedAt   time.Time           `json:"updated_at"`
	UserId      openapi_types.UUID  `json:"user_id"`
}

// TaskResponseList defines model for TaskResponseList.
type TaskResponseList = []ListTask

// ListTaskParams defines parameters for ListTask.
type ListTaskParams struct {
	Limit *int    `form:"limit,omitempty" json:"limit,omitempty"`
	Page  *int    `form:"page,omitempty" json:"page,omitempty"`
	Q     *string `form:"q,omitempty" json:"q,omitempty"`
}

// ServerInterface represents all server handlers.
type ServerInterface interface {
	// This path used to get list of task
	// (GET /tasks)
	ListTask(c *fiber.Ctx, params ListTaskParams) error
	// This path used to create a task
	// (POST /tasks)
	Create(c *fiber.Ctx) error
	// This path used to update a task
	// (POST /tasks/{id})
	UpdateTask(c *fiber.Ctx, id openapi_types.UUID) error
	// This path used to resolve a task
	// (POST /tasks/{id}/resolve)
	ResolveTask(c *fiber.Ctx, id openapi_types.UUID) error
}

// ServerInterfaceWrapper converts contexts to parameters.
type ServerInterfaceWrapper struct {
	Handler ServerInterface
}

type MiddlewareFunc fiber.Handler

// ListTask operation middleware
func (siw *ServerInterfaceWrapper) ListTask(c *fiber.Ctx) error {

	var err error

	// Parameter object where we will unmarshal all parameters from the context
	var params ListTaskParams

	var query url.Values
	query, err = url.ParseQuery(string(c.Request().URI().QueryString()))
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, fmt.Errorf("Invalid format for query string: %w", err).Error())
	}

	// ------------- Optional query parameter "limit" -------------

	err = runtime.BindQueryParameter("form", true, false, "limit", query, &params.Limit)
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, fmt.Errorf("Invalid format for parameter limit: %w", err).Error())
	}

	// ------------- Optional query parameter "page" -------------

	err = runtime.BindQueryParameter("form", true, false, "page", query, &params.Page)
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, fmt.Errorf("Invalid format for parameter page: %w", err).Error())
	}

	// ------------- Optional query parameter "q" -------------

	err = runtime.BindQueryParameter("form", true, false, "q", query, &params.Q)
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, fmt.Errorf("Invalid format for parameter q: %w", err).Error())
	}

	return siw.Handler.ListTask(c, params)
}

// Create operation middleware
func (siw *ServerInterfaceWrapper) Create(c *fiber.Ctx) error {

	return siw.Handler.Create(c)
}

// UpdateTask operation middleware
func (siw *ServerInterfaceWrapper) UpdateTask(c *fiber.Ctx) error {

	var err error

	// ------------- Path parameter "id" -------------
	var id openapi_types.UUID

	err = runtime.BindStyledParameterWithOptions("simple", "id", c.Params("id"), &id, runtime.BindStyledParameterOptions{Explode: false, Required: true})
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, fmt.Errorf("Invalid format for parameter id: %w", err).Error())
	}

	return siw.Handler.UpdateTask(c, id)
}

// ResolveTask operation middleware
func (siw *ServerInterfaceWrapper) ResolveTask(c *fiber.Ctx) error {

	var err error

	// ------------- Path parameter "id" -------------
	var id openapi_types.UUID

	err = runtime.BindStyledParameterWithOptions("simple", "id", c.Params("id"), &id, runtime.BindStyledParameterOptions{Explode: false, Required: true})
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, fmt.Errorf("Invalid format for parameter id: %w", err).Error())
	}

	return siw.Handler.ResolveTask(c, id)
}

// FiberServerOptions provides options for the Fiber server.
type FiberServerOptions struct {
	BaseURL     string
	Middlewares []MiddlewareFunc
}

// RegisterHandlers creates http.Handler with routing matching OpenAPI spec.
func RegisterHandlers(router fiber.Router, si ServerInterface) {
	RegisterHandlersWithOptions(router, si, FiberServerOptions{})
}

// RegisterHandlersWithOptions creates http.Handler with additional options
func RegisterHandlersWithOptions(router fiber.Router, si ServerInterface, options FiberServerOptions) {
	wrapper := ServerInterfaceWrapper{
		Handler: si,
	}

	for _, m := range options.Middlewares {
		router.Use(m)
	}

	router.Get(options.BaseURL+"/tasks", wrapper.ListTask)

	router.Post(options.BaseURL+"/tasks", wrapper.Create)

	router.Post(options.BaseURL+"/tasks/:id", wrapper.UpdateTask)

	router.Post(options.BaseURL+"/tasks/:id/resolve", wrapper.ResolveTask)

}

// Base64 encoded, gzipped, json marshaled Swagger object
var swaggerSpec = []string{

	"H4sIAAAAAAAC/+xXUW/bRgz+KwK3Rzly1z0Meh32UGDZgDZ7KoKA0dH2tdLdhUcZMQz99+FOsiU7ku10",
	"yYoCebN05Ecev4+kvIXCVs4aMuIh34IvVlRh/PkHs+WP5J01nsILx9YRi6Z4XJH3uIwHsnEEOXhhbZbQ",
	"NCkwPdSaSUH+eW94m+4M7f0XKgSaFP7UXm7Qf30Kj6YgL5bvtAqPC8sVCuRQ11pBehQyhceZRadnhVW0",
	"JDOjR2GcCS4j1hdvDeQHkCFJRahKbegAX6GQ6Iq+McYesw3gC9ZOdDjafiNeDxEgL6lGk4LBaoyZFGpP",
	"l5X0mMVoEmF7kDFGr0lwWjSFrY0cBtdGfuujayO0JA5IK/R3hh5lcI97a0tCszt1TOvx01JX+tI4rlPx",
	"WdOjirQxOv+0u9og7UGOY4X6VBcFeT9dK4WCg9t1nkE2Szsb5MYLLGjbBMyKWpefmRaQw09Z39xZ19nZ",
	"AUFPe1UQ0jb0WNKhV6+tovIHadi+UsHk6qa1+4EaWRtPLKTuUP7brU8NBSZvy/ULBLmsFMNwoRQtzNiw",
	"ciGDF7n7i869zueQnYN0p3pn13hh74VctFDlz3XsfknuawXIjBtoopDMwgaEUhfUzZGWaLj+cBNdtJTh",
	"MUAkn4jXugi5r4l91DO8u5pfzYOldWTQacjhfXwVZpusYn6ZoP8afy0pZh5aH4OaPyjI+z0eXBgrEmIP",
	"+ect6BDhoSbe7OqY7ydne8E462iBdSmQv5uPzd1xmG7wjqFcDvJwgHCshdvYHJGyePlf5vN2jRmhdpGh",
	"c6UuYiWyVt/bAR6azd+LWIdTBD9RRkj2MkXcNk/mU7tZSCVikyVJUmoviV0kEh2aFHxdVcibIImV9kng",
	"OKn9lEMKzvoRyn9nQqEJwu+tGtS4a5++rYRrOlX2dBRmP5Kf7zrcJN+f7+PVf47ufuue5JtJao6fP7/O",
	"3z8r7VPBD/8GjIT/y0qysHyvlSJzVmBFlE2CvRzb0ZJttWriV8Wo2v6Js/XEiAlBer4jzdN6O7sCXlfG",
	"ffWeg/amzdfWZrvAJ7SZdZ8t0xr92Br8XyJ908Nr66FjvBdEsCde7zituYQcViIuz7LSFliugjCa2+bf",
	"AAAA//+s6INqVxEAAA==",
}

// GetSwagger returns the content of the embedded swagger specification file
// or error if failed to decode
func decodeSpec() ([]byte, error) {
	zipped, err := base64.StdEncoding.DecodeString(strings.Join(swaggerSpec, ""))
	if err != nil {
		return nil, fmt.Errorf("error base64 decoding spec: %w", err)
	}
	zr, err := gzip.NewReader(bytes.NewReader(zipped))
	if err != nil {
		return nil, fmt.Errorf("error decompressing spec: %w", err)
	}
	var buf bytes.Buffer
	_, err = buf.ReadFrom(zr)
	if err != nil {
		return nil, fmt.Errorf("error decompressing spec: %w", err)
	}

	return buf.Bytes(), nil
}

var rawSpec = decodeSpecCached()

// a naive cached of a decoded swagger spec
func decodeSpecCached() func() ([]byte, error) {
	data, err := decodeSpec()
	return func() ([]byte, error) {
		return data, err
	}
}

// Constructs a synthetic filesystem for resolving external references when loading openapi specifications.
func PathToRawSpec(pathToFile string) map[string]func() ([]byte, error) {
	res := make(map[string]func() ([]byte, error))
	if len(pathToFile) > 0 {
		res[pathToFile] = rawSpec
	}

	return res
}

// GetSwagger returns the Swagger specification corresponding to the generated code
// in this file. The external references of Swagger specification are resolved.
// The logic of resolving external references is tightly connected to "import-mapping" feature.
// Externally referenced files must be embedded in the corresponding golang packages.
// Urls can be supported but this task was out of the scope.
func GetSwagger() (swagger *openapi3.T, err error) {
	resolvePath := PathToRawSpec("")

	loader := openapi3.NewLoader()
	loader.IsExternalRefsAllowed = true
	loader.ReadFromURIFunc = func(loader *openapi3.Loader, url *url.URL) ([]byte, error) {
		pathToFile := url.String()
		pathToFile = path.Clean(pathToFile)
		getSpec, ok := resolvePath[pathToFile]
		if !ok {
			err1 := fmt.Errorf("path not found: %s", pathToFile)
			return nil, err1
		}
		return getSpec()
	}
	var specData []byte
	specData, err = rawSpec()
	if err != nil {
		return
	}
	swagger, err = loader.LoadFromData(specData)
	if err != nil {
		return
	}
	return
}
