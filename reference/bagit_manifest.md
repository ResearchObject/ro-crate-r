# Validate BagIt declaration

Validate BagIt declaration

## Usage

``` r
.validate_bagit_manifest(path, algo = "sha512", manifest_suffix = "manifest")
```

## Arguments

- path:

  String with full path to a compressed file contain an RO-Crate bag,
  see [bag_rocrate](bag_rocrate.md) for details. Alternatively, a path
  to a directory containing an RO-Crate bag.

- algo:

  String with algorithm used to generate the RO-Crate bag (default:
  `"sha512"`). See [digest](https://rdrr.io/pkg/digest/man/digest.html)
  for more details.

- manifest_suffix:

  String with suffix for the manifest file (default: `"manifest"`).

## Value

A list with `status` and `errors` identified.
