# Getting started with rocrateR

``` r
library(rocrateR)
```

### Introduction

Reproducible research requires more than sharing files. We also need
structured metadata describing:

- What the files contain
- Who created them
- How they were produced
- What software was used
- How components relate to each other
- RO-Crate is a lightweight standard for packaging research outputs with
  rich, machine-readable metadata.
- [rocrateR](https://github.com/ResearchObject/ro-crate-r/) lets you
  create and manage RO-Crates directly from R.

### What is an RO-Crate?

An RO-Crate is:

- A folder
- Containing research files
- Plus a metadata file: ro-crate-metadata.json

The metadata describes all files and their relationships using a graph
model.

### RO-Crate Structure

Example:

    my_crate/
    ├── ro-crate-metadata.json
    ├── data/
    │   └── results.csv
    └── analysis.R

- Files are the research artefacts
- Metadata links everything together

------------------------------------------------------------------------

### 1. Functions Overview

| Function                                                                                                                                                                                                                                                                                 | Purpose                                                                                                                                                                                                                                                                |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md)                                                                                                                                                                                                         | Create an empty or initialized RO-Crate                                                                                                                                                                                                                                |
| [`entity()`](https://github.com/ResearchObject/ro-crate-r/reference/entity.md)                                                                                                                                                                                                           | Define a new entity (Person, Dataset, etc.)                                                                                                                                                                                                                            |
| [`add_entity()`](https://github.com/ResearchObject/ro-crate-r/reference/add_entity.md) / [`add_entities()`](https://github.com/ResearchObject/ro-crate-r/reference/add_entity.md)                                                                                                        | Add entities to a crate. Note that [`add_entities()`](https://github.com/ResearchObject/ro-crate-r/reference/add_entity.md) is now deprecated and [`add_entity()`](https://github.com/ResearchObject/ro-crate-r/reference/add_entity.md) is preferred.                 |
| [`get_entity()`](https://github.com/ResearchObject/ro-crate-r/reference/get_entity.md)                                                                                                                                                                                                   | Retrieve entities by `@id` or `@type`                                                                                                                                                                                                                                  |
| [`remove_entity()`](https://github.com/ResearchObject/ro-crate-r/reference/remove_entity.md) / [`remove_entities()`](https://github.com/ResearchObject/ro-crate-r/reference/remove_entity.md)                                                                                            | Remove one or more entities. Note that [`remove_entities()`](https://github.com/ResearchObject/ro-crate-r/reference/remove_entity.md) is now deprecated and [`remove_entity()`](https://github.com/ResearchObject/ro-crate-r/reference/remove_entity.md) is preferred. |
| [`load_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/load_rocrate.md)                                                                                                                                                                                               | Higher level function that loads an RO-Crate from metadata file, crate directory or BagIt archive                                                                                                                                                                      |
| [`write_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/write_rocrate.md)                                                                                                                                                                                             | Save RO-Crate to disk                                                                                                                                                                                                                                                  |
| [`bag_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/bag_rocrate.md) / [`is_rocrate_bag()`](https://github.com/ResearchObject/ro-crate-r/reference/is_rocrate_bag.md) / [`unbag_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/unbag_rocrate.md) | Bagging and unbagging RO-Crates                                                                                                                                                                                                                                        |
| [`validate_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/validate_rocrate.md)                                                                                                                                                                                       | Validate RO-Crate and generate report                                                                                                                                                                                                                                  |

### 2. First RO-Crate

The following command creates an RO-Crate Metadata descriptor
(`ro-crate-metadata.json`). This should be stored inside the root (`./`)
of your RO-Crate.

``` r
# library(rocrateR)
my_first_ro_crate <- rocrateR::rocrate()
```

This object is a list with the basic components of an RO-Crate. It can
be visualised in the console as follows:

``` r
my_first_ro_crate
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
#> [19] "      \"datePublished\": \"2026-04-09\","                  
#> [20] "      \"license\": {"                                      
#> [21] "        \"@id\": \"http://spdx.org/licenses/CC-BY-4.0\""   
#> [22] "      }"                                                   
#> [23] "    }"                                                     
#> [24] "  ]"                                                       
#> [25] "}"

# delete temporary file
unlink(tmp)
```

### 3. Including additional entities

In the previous section we created a very basic RO-Crate with the
[`rocrateR::rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md)
function; however, you are likely to include additional entities in your
RO-Crate. Entities must contain at least two components `@id` and
`@type` (see <https://w3id.org/ro/crate/1.2/> for details).

For example, a contextual entity can be defined as follows:

``` r
# create entity for an organisation
organisation_uol <- rocrateR::entity(
  id = "https://ror.org/04xs57h96",
  type = "Organization",
  name = "University of Liverpool",
  url = "http://www.liv.ac.uk"
)

# create an entity for a person
person_rvd <- rocrateR::entity(
  id = "https://orcid.org/0000-0001-5036-8661",
  type = "Person",
  name = "Roberto Villegas-Diaz"
)
```

These entities can be attached to an RO-Crate using the
[`rocrateR::add_entity()`](https://github.com/ResearchObject/ro-crate-r/reference/add_entity.md)
function:

``` r
my_second_ro_crate <- rocrateR::rocrate() |>
  rocrateR::add_entity(person_rvd) |>
  rocrateR::add_entity_value(
    id = "./", 
    key = "author", 
    value = list(`@id` = person_rvd$`@id`)
  ) |>
  rocrateR::add_entity(organisation_uol) |>
  rocrateR::add_entity_value(
    id = "https://orcid.org/0000-0001-5036-8661",
    key = "affiliation",
    value = list(`@id` = organisation_uol$`@id`)
  )
```

Alternatively, the same result can be achieved with the following code:

``` r
my_second_ro_crate <- rocrateR::rocrate(person_rvd, organisation_uol) |>
  rocrateR::add_entity_value(id = "./", key = "author", value = list(`@id` = person_rvd$`@id`))
```

``` r
my_second_ro_crate
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

### 4. Wrangle RO-Crate

Previously, we covered how to include additional entities, other valid
operations are to extract
([`rocrateR::get_entity()`](https://github.com/ResearchObject/ro-crate-r/reference/get_entity.md))
and remove
([`rocrateR::remove_entities()`](https://github.com/ResearchObject/ro-crate-r/reference/remove_entity.md)).

#### 4.1. Set up

``` r
# create basic RO-Crate
basic_ro_crate <- rocrateR::rocrate()

# create some entities for a project and datasets
dataset_entities <- seq_len(2) |>
  lapply(\(x) rocrateR::entity(x, type = "Dataset", name = paste0("Data ", x)))
project_entity <- rocrateR::entity(
  "#proj101", 
  type = "Project", 
  name = "Project 101",
  hasPart = dataset_entities |>
      lapply(\(x) list(`@id` = x[["@id"]]))
  )

# add project and entities to the RO-Crate
basic_ro_crate <- basic_ro_crate |>
  rocrateR::add_entity(project_entity) |>
  # note that here we are using `rocrateR::add_entities` and `rocrateR::add_entity`
  rocrateR::add_entities(dataset_entities)
#> Warning: `add_entities()` was deprecated in rocrateR 0.1.0.
#> ℹ Please use `add_entity()` instead.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.

basic_ro_crate
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
#>     },
#>     {
#>       "@id": "#proj101",
#>       "@type": "Project",
#>       "name": "Project 101",
#>       "hasPart": [
#>         {
#>           "@id": 1
#>         },
#>         {
#>           "@id": 2
#>         }
#>       ]
#>     },
#>     {
#>       "@id": 1,
#>       "@type": "Dataset",
#>       "name": "Data 1"
#>     },
#>     {
#>       "@id": 2,
#>       "@type": "Dataset",
#>       "name": "Data 2"
#>     }
#>   ]
#> }
```

#### 4.2. Extract entity

We can extract entities via the `@id`, `@type` or both:

##### 4.2.1. Extract using `@id`

``` r
basic_ro_crate_project <- basic_ro_crate |>
  rocrateR::get_entity(id = "#proj101")

basic_ro_crate_project
#> [[1]]
#> <RO-Crate entity>
#>  @id = '#proj101'
#>  @type = 'Project'
```

##### 4.2.2. Extract using `@type`

``` r
basic_ro_crate_datasets <- basic_ro_crate |>
  rocrateR::get_entity(type = "Dataset")

basic_ro_crate_datasets
#> [[1]]
#> <RO-Crate entity>
#>  @id = './'
#>  @type = 'Dataset'
#> 
#> [[2]]
#> <RO-Crate entity>
#>  @id = '1'
#>  @type = 'Dataset'
#> 
#> [[3]]
#> <RO-Crate entity>
#>  @id = '2'
#>  @type = 'Dataset'
```

##### 4.2.3. Extract using `@id` and `@type`

``` r
basic_ro_crate_dataset_root <- basic_ro_crate |>
  rocrateR::get_entity(id = "./", type = "Dataset")

basic_ro_crate_dataset_root
#> [[1]]
#> <RO-Crate entity>
#>  @id = './'
#>  @type = 'Dataset'
```

#### 4.3. Remove entity

Similarly, we can remove entities from an RO-Crate:

##### 4.3.1. Remove using scalar `@id`

``` r
basic_ro_crate_alt <- basic_ro_crate |>
  rocrateR::remove_entity("#proj101")
```

##### 4.3.2. Remove using `entity` object

``` r
basic_ro_crate_alt <- basic_ro_crate |>
  rocrateR::remove_entity(project_entity)
```

##### 4.3.3. Remove multiple entities

``` r
basic_ro_crate_alt <- basic_ro_crate |>
  rocrateR::remove_entity(dataset_entities)
```

### 5. Create an RO-Crate Bag

Here we will explore the BagIt file packaging format, which is the
recommended to use for *bagging* RO-Crates. BagIt is described in [RFC
8493](https://doi.org/10.17487/RFC8493):

> \[BagIt is\] … a set of hierarchical file layout conventions for
> storage and transfer of arbitrary digital content. A “bag” has just
> enough structure to enclose descriptive metadata “tags” and a file
> “payload” but does not require knowledge of the payload’s internal
> semantics. This BagIt format is suitable for reliable storage and
> transfer.

In this package, the function
[`rocrateR::bag_rocrate`](https://github.com/ResearchObject/ro-crate-r/reference/bag_rocrate.md)
will take either a `path` pointing to the root of an RO-Crate (must have
at least an RO-Crate metadata descriptor file, `ro-crate-metadata.json`)
or an RO-Crate object created with
[`rocrateR::rocrate`](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md)
(and alternatives), as shown in step 1.

For more details, run the following command:

``` r
?rocrateR::bag_rocrate
```

#### 5.1. `rocrateR::bag_rocrate()`

Here we will create an RO-Crate bag inside temporary directory:

``` r
# create basic RO-Crate
basic_ro_crate <- rocrateR::rocrate()

# create temporary directory
tmp_dir <- file.path(tempdir(), paste0("rocrate-", digest::digest(basename(tempfile()))))
dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)

# then, we can create the RO-Crate bag
path_to_rocrate_bag <- basic_ro_crate |>
  rocrateR::bag_rocrate(path = tmp_dir)
#> RO-Crate successfully 'bagged'!
#> For details, see: /tmp/RtmpgV7p56/rocrate-f23d10902c05c59b2728a9f9a3f724f6/rocrate-ed5c22c1d8eec78b981931a35b68a64a.zip
```

#### 5.2. `rocrateR::is_rocrate_bag()`

We can use the function
[`rocrateR::is_rocrate_bag()`](https://github.com/ResearchObject/ro-crate-r/reference/is_rocrate_bag.md)
to verify that a given path points to a ZIP file or a directory with a
valid RO-Crate bag. The expected files are

- `bagit.txt` with the BagIt
  [definition](https://www.rfc-editor.org/rfc/rfc8493.html#section-2.2.2)
- `data` directory with
  [payload](https://www.rfc-editor.org/rfc/rfc8493.html#section-2.1.2)
  of the RO-Crate
- `manifest-[algorithm].txt` with the checksum for each file inside the
  `data` directory; .

``` r
path_to_rocrate_bag |>
  rocrateR::is_rocrate_bag()
#> [1] TRUE
```

And then, the RO-Crate can be displayed

``` r
path_to_rocrate_bag |>
  rocrateR::load_rocrate()
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

#### 5.3. `rocrateR::unbag_rocrate()`

We can explore the contents of the RO-Crate bag with the following
commands:

``` r
# extract files in temporary directory
path_to_rocrate_bag_contents <- path_to_rocrate_bag |>
  rocrateR::unbag_rocrate(output = file.path(tmp_dir, "ROC"))
#> RO-Crate bag successfully extracted! For details, see:
#> Root directory: /tmp/RtmpgV7p56/rocrate-f23d10902c05c59b2728a9f9a3f724f6/ROC

# create tree with the files
fs::dir_tree(path_to_rocrate_bag_contents)
#> /tmp/RtmpgV7p56/rocrate-f23d10902c05c59b2728a9f9a3f724f6/ROC
#> ├── bag-info.txt
#> ├── bagit.txt
#> ├── data
#> │   └── ro-crate-metadata.json
#> ├── manifest-sha512.txt
#> └── tagmanifest-sha512.txt
```

``` r
# delete temporary directory
unlink(tmp_dir, recursive = TRUE, force = TRUE)
```

### 6. Validation

> Advanced validation using the Python `rocrate-validator` is optional
> and requires [reticulate](https://rstudio.github.io/reticulate/).

## Appendix

### A1. Advanced Validation (experimental)

As you develop your RO-Crates, you might want to validate them. There
are few validators online (some of which can be found at
<https://www.researchobject.org/ro-crate/tools>), here we will explore
the Python package
[`rocrate-validator`](https://github.com/crs4/rocrate-validator). For
installation details, please visit
<https://github.com/crs4/rocrate-validator>.

⚠ The validation workflow depends on Python’s
[`rocrate-validator`](https://github.com/crs4/rocrate-validator). Ensure
you have a working Python installation and
[`{reticulate}`](https://cran.r-project.org/package=reticulate)
configured correctly (`reticulate::py_config()`). On Windows, you may
need to restart R after installation.

#### A1.1. Install [`{reticulate}`](https://cran.r-project.org/package=reticulate)

``` r
pak::pkg_install("reticulate")
```

#### A1.2. Install [`rocrate-validator`](https://github.com/crs4/rocrate-validator)

``` r
reticulate::py_install("roc-validator", env = "rocrateR")
```

#### A1.3. Create example RO-Crate and validate it

``` r
basic_ro_crate <- rocrateR::rocrate()

# store crate inside temporary directory
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

# delete temporary files
unlink(tmp)
unlink(tmp_zip)
```
