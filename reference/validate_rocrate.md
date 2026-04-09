# Validate an RO-Crate

Performs structural, semantic and profile validation.

## Usage

``` r
validate_rocrate(x, mode = c("stop", "report"), strict = FALSE)
```

## Arguments

- x:

  A path (character) or an existing
  [rocrate](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md)
  object.

- mode:

  Either `"stop"` or `"report"`.

- strict:

  Logical. Enable profile validation.

## Value

A `rocrate_validation` object (in report mode).

## Examples

``` r
# -------- SETUP --------
basic_crate <- rocrateR::rocrate()
# temp file
tmp_dir <- file.path(tempdir(), digest::digest(basename(tempfile())))
tmp <- file.path(tmp_dir, "ro-crate-metadata.json")
dir.create(tmp_dir)

# -------- INPUT: RO-Crate --------
rocrateR::validate_rocrate(basic_crate)
#> <RO-Crate validation>
#> ✔ Valid RO-Crate

# -------- INPUT: Path --------
# save RO-Crate
rocrateR::write_rocrate(basic_crate, path = tmp)

## with file name
rocrateR::validate_rocrate(tmp)
#> <RO-Crate validation>
#> ✔ Valid RO-Crate

## with directory
rocrateR::validate_rocrate(tmp_dir)
#> <RO-Crate validation>
#> ✔ Valid RO-Crate

# -------- INPUT: Invalid RO-Crate --------
structure(list(), class = "rocrate") |>
  rocrateR::validate_rocrate(mode = "report")
#> <RO-Crate validation>
#> ✖ Invalid RO-Crate
#> 
#> Errors:
#>  - Missing '@context'.
#>  - Missing '@graph'.
#>  - '@graph' must be a list.

# delete temp directory
unlink(tmp_dir, recursive = TRUE)
```
