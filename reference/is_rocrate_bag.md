# Check if path points to a valid RO-Crate bag

Check if path points to a valid RO-Crate bag

## Usage

``` r
is_rocrate_bag(path, algo = NULL, bagit_version = "1.0")
```

## Arguments

- path:

  String with full path to a compressed file contain an RO-Crate bag,
  see
  [bag_rocrate](https://github.com/ResearchObject/ro-crate-r/reference/bag_rocrate.md)
  for details. Alternatively, a path to a directory containing an
  RO-Crate bag.

- algo:

  String with algorithm used to generate the RO-Crate bag (default:
  `NULL`, which auto detects the algorithm from the
  `manifest-<algo>.txt` file, inside the bag). See
  [digest](https://eddelbuettel.github.io/digest/man/digest.html) for
  more details on valid algorithms.

- bagit_version:

  String with version of BagIt used to generate the RO-Crate bag
  (default: `"1.0"`). See
  [doi:10.17487/RFC8493](https://doi.org/10.17487/RFC8493) for more
  details.

## Value

Returns a boolean flag to indicate if the given RO-Crate bag is valid.

## See also

Other RO-Crate BagIt archive functions:
[`bag_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/bag_rocrate.md),
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

# bag RO-Crate
path_to_roc_bag <- rocrateR::bag_rocrate(basic_crate, path = tmp_dir)
#> RO-Crate successfully 'bagged'!
#> For details, see: /tmp/Rtmp8YBzuX/a1389cf74b2ea90f93e566368feee84e/rocrate-a1592d742a2d61a3771df48ef8203d68.zip

# -------- INPUT: RO-Crate BagIt archive --------
rocrateR::is_rocrate_bag(path_to_roc_bag)
#> [1] TRUE

# -------- INPUT: Path --------
rocrateR::unbag_rocrate(path_to_roc_bag) |>
  rocrateR::is_rocrate_bag()
#> RO-Crate bag successfully extracted! For details, see:
#> Root directory: /tmp/Rtmp8YBzuX/a1389cf74b2ea90f93e566368feee84e
#> [1] TRUE

# delete temp directory
unlink(tmp_dir, recursive = TRUE)
```
