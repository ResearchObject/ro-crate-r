
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rocrateR: RO-Crate R Package Wrapper

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rocrateR)](https://CRAN.R-project.org/package=rocrateR)
[![R-CMD-check](https://github.com/ResearchObject/ro-crate-r/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ResearchObject/ro-crate-r/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/ResearchObject/ro-crate-r/graph/badge.svg)](https://app.codecov.io/gh/ResearchObject/ro-crate-r)
<!-- badges: end -->

The goal of `{rocrateR}` is to provide an R package for creating,
manipulating and reading RO-Crates. Latest supported version of the
specification: <https://w3id.org/ro/crate/1.2>.

## 0. Installation

You can install the released version of `{rocrateR}` from
[CRAN](https://cran.r-project.org/package=rocrateR) with:

``` r
install.packages("rocrateR")
```

And the development version from
[GitHub](https://github.com/ResearchObject/ro-crate-r/) with:

``` r
# install.packages("pak")
pak::pkg_install("ResearchObject/ro-crate-r@dev")
```

## 1. First RO-Crate

The following command creates an RO-Crate Metadata descriptor
(`ro-crate-metadata.json`). This should be stored inside the root (`./`)
of your RO-Crate.

``` r
# library(rocrateR)
my_first_ro_crate <- rocrateR::rocrate()
```

This object is a list with the basic components of an RO-Crate. It can
be visualised in the console with the `print` command:

``` r
print(my_first_ro_crate)
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
#>       "datePublished": "2025-10-06",
#>       "license": {
#>         "@id": "http://spdx.org/licenses/CC-BY-4.0"
#>       }
#>     }
#>   ]
#> }
```

This object can be saved to disk using the following command:

``` r
my_first_ro_crate |>
  rocrateR::write_rocrate("/path/to/ro-crate/ro-crate-metadata.json")
```

For example, using a temporary directory:

``` r
tmp <- file.path(tempdir(), "ro-crate-metadata.json")
my_first_ro_crate |>
  rocrateR::write_rocrate(tmp)

# load lines / flat file
readLines(tmp)
#>  [1] "{"                                                         
#>  [2] "  \"@context\": \"https://w3id.org/ro/crate/1.2/context\","
#>  [3] "  \"@graph\": ["                                           
#>  [4] "    {"                                                     
#>  [5] "      \"@id\": \"ro-crate-metadata.json\","                
#>  [6] "      \"@type\": \"CreativeWork\","                        
#>  [7] "      \"about\": {"                                        
#>  [8] "        \"@id\": \"./\""                                   
#>  [9] "      },"                                                  
#> [10] "      \"conformsTo\": {"                                   
#> [11] "        \"@id\": \"https://w3id.org/ro/crate/1.2\""        
#> [12] "      }"                                                   
#> [13] "    },"                                                    
#> [14] "    {"                                                     
#> [15] "      \"@id\": \"./\","                                    
#> [16] "      \"@type\": \"Dataset\","                             
#> [17] "      \"name\": \"\","                                     
#> [18] "      \"description\": \"\","                              
#> [19] "      \"datePublished\": \"2025-10-06\","                  
#> [20] "      \"license\": {"                                      
#> [21] "        \"@id\": \"http://spdx.org/licenses/CC-BY-4.0\""   
#> [22] "      }"                                                   
#> [23] "    }"                                                     
#> [24] "  ]"                                                       
#> [25] "}"

# delete temporal file
unlink(tmp)
```

## 2. Including additional entities

In the previous section we created a very basic RO-Crate with the
`rocrateR::rocrate()` function; however, you are likely to include
additional entities in your RO-Crate. Entities must contain at least two
components `@id` and `@type` (see <https://w3id.org/ro/crate/1.2> for
details).

For example, a contextual entity can be defined as follows:

``` r
# create entity for an organisation
organisation_uol <- rocrateR::entity(
  x = "https://ror.org/04xs57h96",
  type = "Organization",
  name = "University of Liverpool",
  url = "http://www.liv.ac.uk"
)

# create an entity for a person
person_rvd <- rocrateR::entity(
  x = "https://orcid.org/0000-0001-5036-8661",
  type = "Person",
  name = "Roberto Villegas-Diaz"
)
```

These two can be linked to each other via the `@id` field:

``` r
person_rvd$affiliation <- list(`@id` = organisation_uol$`@id`)
```

These entities can be attached to an RO-Crate using the
`rocrateR::add_entity()` function:

``` r
my_second_ro_crate <- rocrateR::rocrate() |>
  rocrateR::add_entity(person_rvd) |>
  rocrateR::add_entity_value(id = "./", key = "author", value = list(`@id` = person_rvd$`@id`)) |>
  rocrateR::add_entity(organisation_uol)
```

Alternatively, the same result can be achieved with the following code:

``` r
my_second_ro_crate <- rocrateR::rocrate(person_rvd, organisation_uol) |>
  rocrateR::add_entity_value(id = "./", key = "author", value = list(`@id` = person_rvd$`@id`))
```

``` r
print(my_second_ro_crate)
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
#>       "datePublished": "2025-10-06",
#>       "license": {
#>         "@id": "http://spdx.org/licenses/CC-BY-4.0"
#>       },
#>       "author": {
#>         "@id": "https://orcid.org/0000-0001-5036-8661"
#>       }
#>     },
#>     {
#>       "@id": "https://orcid.org/0000-0001-5036-8661",
#>       "@type": "Person",
#>       "name": "Roberto Villegas-Diaz",
#>       "affiliation": {
#>         "@id": "https://ror.org/04xs57h96"
#>       }
#>     },
#>     {
#>       "@id": "https://ror.org/04xs57h96",
#>       "@type": "Organization",
#>       "name": "University of Liverpool",
#>       "url": "http://www.liv.ac.uk"
#>     }
#>   ]
#> }
```

## 3. Validation (experimental)

As you develop your RO-Crates, you might want to validate them. There
are few validators online (some of which can be found at
<https://www.researchobject.org/ro-crate/tools>), here we will explore
the Python package
[`rocrate-validator`](https://github.com/crs4/rocrate-validator). For
installation details, please visit
<https://github.com/crs4/rocrate-validator>.

Note that we will rely on
[`{reticulate}`](https://cran.r-project.org/package=reticulate) to
install and execute the validator within R:

### 3.1. Install [`{reticulate}`](https://cran.r-project.org/package=reticulate)

``` r
pak::pkg_install("reticulate")
```

### 3.2. Install [`rocrate-validator`](https://github.com/crs4/rocrate-validator)

``` r
reticulate::py_install("roc-validator", env = "rocrateR")
```

### 3.3. Create example RO-Crate and validate it

``` r
basic_ro_crate <- rocrateR::rocrate()

# store crate inside temporal directory
tmp <- file.path(tempdir(), "ro-crate-metadata.json")
basic_ro_crate |>
  rocrateR::write_rocrate(tmp)
# wrap crate into zip file (expected by validator)
tmp_zip <- paste(tmp, ".zip")
zip(tmp_zip, tmp)

# validate (note the name of the module: rocrate_validator)
reticulate::use_virtualenv("rocrateR")
rocrate_validator <- reticulate::import("rocrate_validator")
status <- rocrate_validator$utils$validate_rocrate_uri(tmp_zip)

if (status) {
  message("RO-Crate is valid!")
} else {
  message("RO-Crate is invalid!")
}
#> RO-Crate is valid!

# delete temporal files
unlink(tmp)
unlink(tmp_zip)
```
