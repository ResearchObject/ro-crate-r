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

String with path to root of the RO-Crate, invisibly.

## See also

Other bag_rocrate: [`bag_rocrate()`](bag_rocrate.md),
[`is_rocrate_bag()`](is_rocrate_bag.md)
