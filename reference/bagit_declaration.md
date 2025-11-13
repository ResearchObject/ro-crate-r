# Generate BagIt declaration

Generate BagIt declaration

Validate BagIt declaration

## Usage

``` r
bagit_declaration(path, version = "1.0")

.validate_bagit_declaration(path, algo = "sha512", bagit_version = "1.0")
```

## Source

https://www.rfc-editor.org/rfc/rfc8493.html#section-2.2.2

## Arguments

- path:

  String with path where the BagIt declaration will be stored.

- version:

  String with BagIt version (default: `"1.0"`)/

- algo:

  String with algorithm used to generate the RO-Crate bag (default:
  `"sha512"`). See [digest](https://rdrr.io/pkg/digest/man/digest.html)
  for more details.

- bagit_version:

  String with version of BagIt used to generate the RO-Crate bag
  (default: `"1.0"`). See
  [doi:10.17487/RFC8493](https://doi.org/10.17487/RFC8493) for more
  details.

## Value

A list with `status` and `errors` identified.
