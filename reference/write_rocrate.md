# Wrapper for [jsonlite::write_json](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html)

Wrapper for
[jsonlite::write_json](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html).
Enforces that the input object is an RO-Crate.

## Usage

``` r
write_rocrate(x, path, ...)
```

## Arguments

- x:

  RO-Crate object, see [rocrate](rocrate.md).

- path:

  file on disk

- ...:

  Arguments passed on to
  [`jsonlite::toJSON`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)

  `dataframe`

  :   how to encode data.frame objects: must be one of 'rows', 'columns'
      or 'values'

  `matrix`

  :   how to encode matrices and higher dimensional arrays: must be one
      of 'rowmajor' or 'columnmajor'.

  `Date`

  :   how to encode Date objects: must be one of 'ISO8601' or 'epoch'

  `POSIXt`

  :   how to encode POSIXt (datetime) objects: must be one of 'string',
      'ISO8601', 'epoch' or 'mongo'

  `factor`

  :   how to encode factor objects: must be one of 'string' or 'integer'

  `complex`

  :   how to encode complex numbers: must be one of 'string' or 'list'

  `raw`

  :   how to encode raw objects: must be one of 'base64', 'hex' or
      'mongo'

  `null`

  :   how to encode NULL values within a list: must be one of 'null' or
      'list'

  `na`

  :   how to print NA values: must be one of 'null' or 'string'.
      Defaults are class specific

  `digits`

  :   max number of decimal digits to print for numeric values. Use
      [`I()`](https://rdrr.io/r/base/AsIs.html) to specify significant
      digits. Use `NA` for max precision.

  `force`

  :   unclass/skip objects of classes with no defined JSON mapping

## Value

Invisibly the input RO-Crate, `x`.
