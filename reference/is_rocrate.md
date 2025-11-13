# Check if object is an RO-Crate

Check if object is an RO-Crate

## Usage

``` r
is_rocrate(rocrate)
```

## Arguments

- rocrate:

  RO-Crate object, see [rocrate](rocrate.md).

## Value

Returns invisibly the input RO-Crate object.

## Examples

``` r
basic_crate <- rocrateR::rocrate()

# check if the new crate is valid
basic_crate |>
  rocrateR::is_rocrate()
```
