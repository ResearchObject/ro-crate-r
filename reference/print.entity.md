# Print RO-Crate entity

Print RO-Crate entity, S3 method for class 'entity'.

## Usage

``` r
# S3 method for class 'entity'
print(x, ...)
```

## Arguments

- x:

  RO-Crate entity object, see
  [entity](https://github.com/ResearchObject/ro-crate-r/reference/entity.md).

- ...:

  Optional arguments, not used.

## Value

Invisibly the input RO-Crate entity, `x`.

## Examples

``` r
rocrateR::rocrate() |>
  rocrateR::get_entity("./")
#> [[1]]
#> <RO-Crate entity>
#>  @id = './'
#>  @type = 'Dataset'
#> 
```
