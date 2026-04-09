# Bag the contents of an RO-Crate

Bag the contents of an RO-Crate using the BagIt file packaging format
v1.0. For more details see the definition:
[doi:10.17487/RFC8493](https://doi.org/10.17487/RFC8493)

## Usage

``` r
bag_rocrate(x, ...)

# S3 method for class 'character'
bag_rocrate(x, ..., output = x, force_bag = FALSE, extra_bag_info = NULL)

# S3 method for class 'rocrate'
bag_rocrate(
  x,
  ...,
  path,
  output = path,
  overwrite = FALSE,
  force_bag = FALSE,
  extra_bag_info = NULL,
  write_content = TRUE,
  create_dir = TRUE
)
```

## Arguments

- x:

  A string to a path containing at the very minimum an RO-Crate metadata
  descriptor file, `ro-crate-metadata.json`. Alternatively, an object
  with the
  [rocrate](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md)
  class.

- ...:

  Additional parameters, see below.

- output:

  String with path where the RO-Crate bag will be stored (default: `x` -
  same path as the input value).

- force_bag:

  Boolean flag to indicate whether the force the creation of a 'bag'
  even if not all the files were successfully bagged (default: `FALSE` ~
  check if all the files were copied successfully).

- extra_bag_info:

  Vector of strings to include in the `bag-info.txt` file (e.g.,
  `Contact-Email: first.last@rocrate.org`).

- path:

  String with path to the root of the RO-Crate.

- overwrite:

  Boolean flag to indicate if the RO-Crate metadata descriptor file
  should be overwritten if already inside `path` (default: `FALSE`).

- write_content:

  Logical. If TRUE, write `content` fields of `File` entities to disk
  before bagging.

- create_dir:

  Boolean flag to indicate if the `path` should be created, if it
  doesn't exist.

## Value

String with full path to the RO-Crate bag.

## See also

Other RO-Crate BagIt archive functions:
[`is_rocrate_bag()`](https://github.com/ResearchObject/ro-crate-r/reference/is_rocrate_bag.md),
[`load_rocrate_bag()`](https://github.com/ResearchObject/ro-crate-r/reference/load_rocrate_bag.md),
[`unbag_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/unbag_rocrate.md)

## Examples

``` r
# -------- SETUP --------
basic_crate <- rocrateR::rocrate()
# temp file
tmp_dir <- file.path(tempdir(), digest::digest(basename(tempfile())))
tmp <- file.path(tmp_dir, "ro-crate-metadata.json")
dir.create(tmp_dir)

# -------- INPUT: RO-Crate --------
rocrateR::bag_rocrate(basic_crate, path = tmp_dir)
#> RO-Crate successfully 'bagged'!
#> For details, see: /tmp/Rtmp8YBzuX/c6dd60785b96d07936e4b09221774c0b/rocrate-ada797de162ce3c2002e5e7bd70b75a2.zip

# -------- INPUT: Path --------
rocrateR::bag_rocrate(tmp_dir, output = tmp_dir)
#> RO-Crate successfully 'bagged'!
#> For details, see: /tmp/Rtmp8YBzuX/c6dd60785b96d07936e4b09221774c0b/rocrate-e41d04d9c98cce3c96e3282afeebc3ef.zip

# delete temp directory
unlink(tmp_dir, recursive = TRUE)
```
