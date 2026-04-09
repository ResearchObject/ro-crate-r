# rocrateR: Tools for Creating and Manipulating RO-Crates

[rocrateR](https://github.com/ResearchObject/ro-crate-r/) provides a
native R interface for creating, manipulating, validating and packaging
RO-Crates. RO-Crate is a lightweight approach to packaging research data
with structured metadata using JSON-LD.

## Installation

You can install the released version of
[rocrateR](https://github.com/ResearchObject/ro-crate-r/) from
[CRAN](https://cran.r-project.org/package=rocrateR) with:

``` r
install.packages("rocrateR")
```

And the development version from
[GitHub](https://github.com/ResearchObject/ro-crate-r/) with:

``` r
# install.packages("pak")
pak::pak("ResearchObject/ro-crate-r@dev")
```

## Quick Start

``` r
# create a crate
crate <- rocrateR::rocrate()

crate <- crate |>
  # add a dataset entity
  rocrateR::add_dataset("iris.csv", iris) |>
  # add workflow entity
  rocrateR::add_workflow(
    file_id = "analysis.R",
    name = "Data analysis pipeline",
    content = c(
      "data <- read.csv('iris.csv')",
      "summary(data)"
    )
  ) |>
  # add software entity
  rocrateR::add_software("R", version = R.version.string)

# write to disk
path_to_rocrate_bag <- rocrateR::bag_rocrate(crate, path = "./my_roc")

path_to_rocrate_bag_contents <- path_to_rocrate_bag |>
    rocrateR::unbag_rocrate(output = "ROC")
```

``` R
#> ROC
#> ├── bag-info.txt
#> ├── bagit.txt
#> ├── data
#> │   ├── analysis.R
#> │   ├── iris.csv
#> │   └── ro-crate-metadata.json
#> ├── manifest-sha512.txt
#> └── tagmanifest-sha512.txt
```

## What You Can Do

- 📦 Create RO-Crates from projects or folders
- 📄 Add datasets, software, workflows, notebooks, authors
- ✏️ Edit and enrich metadata
- 🔍 Inspect crate contents
- ✅ Validate structure and metadata
- 🧳 Create RO-Crate Bags for preservation

## Typical Workflow

``` r
roc_bag_path <- rocrateR::crate_project() |>
  rocrateR::add_author("Alice Smith") |>
  rocrateR::add_dataset("data/raw.csv") |>
  rocrateR::add_software("analysis.R") |>
  rocrateR::bag_rocrate(path = ".")
```

## Validation

``` r
rocrateR::validate_rocrate(roc_bag_path)
```

## Learn More

For further details, see the following vignette:

``` r
vignette("getting-started-with-rocrateR")
```

## Why rocrateR?

- Native R interface to RO-Crate
- No external system dependencies
- Supports BagIt packaging (RFC 8493)
- Structural validation tools
- Designed for reproducible research workflows
