# Wrapper for [jsonlite::read_json](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html)

Wrapper for
[jsonlite::read_json](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html).
Enforces that the object read is an RO-Crate.

## Usage

``` r
read_rocrate(path, simplifyVector = FALSE, ...)
```

## Arguments

- path:

  file on disk

- simplifyVector:

  simplifies nested lists into vectors and data frames. See
  [`fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html).

- ...:

  Arguments passed on to
  [`jsonlite::fromJSON`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)

  `txt`

  :   a JSON string, URL or file

  `simplifyDataFrame`

  :   coerce JSON arrays containing only records (JSON objects) into a
      data frame

  `simplifyMatrix`

  :   coerce JSON arrays containing vectors of equal mode and dimension
      into matrix or array

  `flatten`

  :   automatically
      [`flatten()`](https://jeroen.r-universe.dev/jsonlite/reference/flatten.html)
      nested data frames into a single non-nested data frame

## Value

Invisibly the RO-Crate stored in `path`.
