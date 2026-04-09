# Load an RO-Crate BagIt archive

Load an RO-Crate BagIt archive

## Usage

``` r
load_rocrate_bag(
  path,
  algo = NULL,
  bagit_version = "1.0",
  load_content = FALSE,
  max_file_size = 10 * 1024^2
)
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

- load_content:

  Logical. If `TRUE` , attempt to load external file contents into the
  `content` field for entities of type `File`.

- max_file_size:

  Maximum file size (bytes) allowed when loading content. Default 10MB.

## Value

An object with the
[rocrate](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md)
class.

## See also

Other RO-Crate BagIt archive functions:
[`bag_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/bag_rocrate.md),
[`is_rocrate_bag()`](https://github.com/ResearchObject/ro-crate-r/reference/is_rocrate_bag.md),
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
#> For details, see: /tmp/Rtmp8YBzuX/dcd849f72b176aa793214f88faec8c0c/rocrate-6c6637f40625740c70c55a454b775455.zip

# -------- INPUT: RO-Crate BagIt archive --------
rocrateR::load_rocrate_bag(path_to_roc_bag)
#> Warning: `load_rocrate_bag()` was deprecated in rocrateR 0.1.0.
#> ℹ Please use `load_rocrate()` instead.
#> {
#>   "@context": "https://w3id.org/ro/crate/1.2/context",
#>   "@graph": [
#>     {
#>       "@id": "ro-crate-metadata.json",
#>       "@type": "CreativeWork",
#>       "about": {
#>         "@id": "./"
#>       },
#>       "conformsTo": {
#>         "@id": "https://w3id.org/ro/crate/1.2"
#>       }
#>     },
#>     {
#>       "@id": "./",
#>       "@type": "Dataset",
#>       "name": "",
#>       "description": "",
#>       "datePublished": "2026-04-09",
#>       "license": {
#>         "@id": "http://spdx.org/licenses/CC-BY-4.0"
#>       }
#>     }
#>   ]
#> }

# -------- INPUT: Path --------
rocrateR::unbag_rocrate(path_to_roc_bag) |>
  rocrateR::load_rocrate_bag()
#> RO-Crate bag successfully extracted! For details, see:
#> Root directory: /tmp/Rtmp8YBzuX/dcd849f72b176aa793214f88faec8c0c
#> {
#>   "@context": "https://w3id.org/ro/crate/1.2/context",
#>   "@graph": [
#>     {
#>       "@id": "ro-crate-metadata.json",
#>       "@type": "CreativeWork",
#>       "about": {
#>         "@id": "./"
#>       },
#>       "conformsTo": {
#>         "@id": "https://w3id.org/ro/crate/1.2"
#>       }
#>     },
#>     {
#>       "@id": "./",
#>       "@type": "Dataset",
#>       "name": "",
#>       "description": "",
#>       "datePublished": "2026-04-09",
#>       "license": {
#>         "@id": "http://spdx.org/licenses/CC-BY-4.0"
#>       }
#>     }
#>   ]
#> }

# delete temp directory
unlink(tmp_dir, recursive = TRUE)
```
