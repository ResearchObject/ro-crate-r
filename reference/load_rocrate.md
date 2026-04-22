# Load an RO-Crate from various input types

High-level loader that can read:

- A `ro-crate-metadata.json` file

- A directory containing an RO-Crate

- A BagIt-wrapped RO-Crate directory

- A zipped BagIt RO-Crate archive

## Usage

``` r
load_rocrate(x, ...)

# S3 method for class 'rocrate'
load_rocrate(x, ..., verbose = FALSE)

# S3 method for class 'character'
load_rocrate(
  x,
  ...,
  verbose = FALSE,
  bagit_version = "1.0",
  load_content = FALSE,
  max_file_size = 10 * 1024^2
)
```

## Arguments

- x:

  A path (character) or an existing
  [rocrate](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md)
  object.

- ...:

  Reserved for future extensions.

- verbose:

  Logical. If `TRUE`, emit diagnostic messages.

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

An RO-Crate object.

## Examples

``` r
# -------- SETUP --------
basic_crate <- rocrateR::rocrate()
# temp file
tmp_dir <- file.path(tempdir(), digest::digest(basename(tempfile())))
tmp <- file.path(tmp_dir, "ro-crate-metadata.json")
dir.create(tmp_dir)

# -------- INPUT: RO-Crate --------
rocrateR::load_rocrate(basic_crate, verbose = TRUE)
#> Input is already a rocrate object.
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
#>       "datePublished": "2026-04-22",
#>       "license": {
#>         "@id": "http://spdx.org/licenses/CC-BY-4.0"
#>       }
#>     }
#>   ]
#> }

# -------- INPUT: Path --------
# save RO-Crate
rocrateR::write_rocrate(basic_crate, path = tmp)

# load RO-Crate
## with file name
rocrateR::load_rocrate(tmp, verbose = TRUE)
#> Detecting RO-Crate input type...
#> Detected metadata JSON file.
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
#>       "datePublished": "2026-04-22",
#>       "license": {
#>         "@id": "http://spdx.org/licenses/CC-BY-4.0"
#>       }
#>     }
#>   ]
#> }

## with directory
rocrateR::load_rocrate(tmp_dir, verbose = TRUE)
#> Detecting RO-Crate input type...
#> Detected plain RO-Crate directory.
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
#>       "datePublished": "2026-04-22",
#>       "license": {
#>         "@id": "http://spdx.org/licenses/CC-BY-4.0"
#>       }
#>     }
#>   ]
#> }

# delete temp directory
unlink(tmp_dir, recursive = TRUE)
```
