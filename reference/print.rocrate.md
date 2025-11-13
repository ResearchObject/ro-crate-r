# Print RO-Crate

Print RO-Crate, S3 method for class 'rocrate'. Creates a temporal JSON
file, which then is displayed with the
[message](https://rdrr.io/r/base/message.html) function.

## Usage

``` r
# S3 method for class 'rocrate'
print(x, ...)
```

## Arguments

- x:

  RO-Crate object, see [rocrate](rocrate.md).

- ...:

  Optional arguments, not used.

## Value

Invisibly the input RO-Crate, `x`.

## Examples

``` r
rocrateR::rocrate()
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
#>       "datePublished": "2025-11-13",
#>       "license": {
#>         "@id": "http://spdx.org/licenses/CC-BY-4.0"
#>       }
#>     }
#>   ]
#> }
```
