# Check if path points to a valid RO-Crate bag

Check if path points to a valid RO-Crate bag

## Usage

``` r
is_rocrate_bag(path, algo = "sha512", bagit_version = "1.0")
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

- bagit_version:

  String with version of BagIt used to generate the RO-Crate bag
  (default: `"1.0"`). See
  [doi:10.17487/RFC8493](https://doi.org/10.17487/RFC8493) for more
  details.

## Value

Returns invisibly the RO-Crate pointed by `path`.

## See also

Other bag_rocrate: [`bag_rocrate()`](bag_rocrate.md),
[`unbag_rocrate()`](unbag_rocrate.md)
