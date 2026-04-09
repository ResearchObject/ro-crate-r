# Print RO-Crate

Print RO-Crate, S3 method for class 'rocrate'. Creates a temporal JSON
file, which then is displayed with the
[message](https://rdrr.io/r/base/message.html) function.

## Usage

``` r
# S3 method for class 'rocrate'
print(x, ..., max_lines = getOption("max_lines", 100))
```

## Arguments

- x:

  RO-Crate object, see
  [rocrate](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md).

- ...:

  Optional arguments, not used.

- max_lines:

  Max number of lines to display.

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
#>       "datePublished": "2026-04-09",
#>       "license": {
#>         "@id": "http://spdx.org/licenses/CC-BY-4.0"
#>       }
#>     }
#>   ]
#> }
```
