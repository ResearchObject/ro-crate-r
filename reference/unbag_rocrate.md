# 'Unbag' (extract) RO-Crate packed with BagIt

'Unbag' (extract) RO-Crate packed with BagIt

## Usage

``` r
unbag_rocrate(path, output = dirname(path), quiet = FALSE)
```

## Arguments

- path:

  String with path to compressed file containing an RO-Crate bag.

- output:

  String with target path where the contents will be extracted (default:
  `dirname(path)` - same directory as input `path`).

- quiet:

  Boolean flag to indicate if messages should be suppressed (default:
  `FALSE` - display messages).

## Value

String with path to root of the RO-Crate.

## See also

Other RO-Crate BagIt archive functions:
[`bag_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/bag_rocrate.md),
[`is_rocrate_bag()`](https://github.com/ResearchObject/ro-crate-r/reference/is_rocrate_bag.md),
[`load_rocrate_bag()`](https://github.com/ResearchObject/ro-crate-r/reference/load_rocrate_bag.md)

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
#> For details, see: /tmp/Rtmp8YBzuX/45863482da79a7338f085b39bf525658/rocrate-9f352a1055eeabd2fc8f2faa52b47ce6.zip

# -------- INPUT: Path --------
rocrateR::unbag_rocrate(path_to_roc_bag)
#> RO-Crate bag successfully extracted! For details, see:
#> Root directory: /tmp/Rtmp8YBzuX/45863482da79a7338f085b39bf525658
#> [1] "/tmp/Rtmp8YBzuX/45863482da79a7338f085b39bf525658"

# delete temp directory
unlink(tmp_dir, recursive = TRUE)
```
