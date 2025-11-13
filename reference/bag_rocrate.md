# Bag the contents of an RO-Crate

Bag the contents of an RO-Crate using the BagIt file packaging format
v1.0. For more details see the definition:
[doi:10.17487/RFC8493](https://doi.org/10.17487/RFC8493)

## Usage

``` r
bag_rocrate(x, ...)

# S3 method for class 'character'
bag_rocrate(x, ..., output = x, force_bag = FALSE)

# S3 method for class 'rocrate'
bag_rocrate(x, ..., path, output = path, overwrite = FALSE, force_bag = FALSE)
```

## Arguments

- x:

  A string to a path containing at the very minimum an RO-Crate metadata
  descriptor file, `ro-crate-metadata.json`. Alternatively, an object
  with the [rocrate](rocrate.md) class.

- ...:

  Additional parameters, see below.

- output:

  String with path where the RO-Crate bag will be stored (default: `x` -
  same path as the input value).

- force_bag:

  Boolean flag to indicate whether the force the creation of a 'bag'
  even if not all the files were successfully bagged (default: `FALSE` ~
  check if all the files were copied successfully).

- path:

  String with path to the root of the RO-Crate.

- overwrite:

  Boolean flag to indicate if the RO-Crate metadata descriptor file
  should be overwritten if already inside `path` (default: `FALSE`).

## Value

String with full path to the final RO-Crate bag.

## See also

Other bag_rocrate: [`is_rocrate_bag()`](is_rocrate_bag.md),
[`unbag_rocrate()`](unbag_rocrate.md)
