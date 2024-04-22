package utils

import "github.com/satrionugroho/bordeux/generated"

func DefaultQueryParams(params *generated.ListTaskParams) error {
	if params.Page == nil {
		params.Page = new(int)
		*params.Page = 1
	}

	if params.Limit == nil {
		params.Limit = new(int)
		*params.Limit = 10
	}

	return nil
}
