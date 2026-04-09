# Check if object is an RO-Crate

Check if object is an RO-Crate

## Usage

``` r
is_rocrate(rocrate, strict = FALSE, error = TRUE)
```

## Arguments

- rocrate:

  RO-Crate object, see
  [rocrate](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md).

- strict:

  Boolean to indicate if stricter checks should be done (e.g., check
  profile specification).

- error:

  Boolean to indicate if the function should throw an error, if any
  errors are found (default: `TRUE`).

## Value

Boolean flag with RO-Crate validity.

## Examples

``` r
basic_crate <- rocrateR::rocrate()

# check if the new crate is valid
basic_crate |>
  rocrateR::is_rocrate()
#> [1] TRUE
```
