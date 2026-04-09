# Add entity to RO-Crate

Add entity to RO-Crate

## Usage

``` r
add_entity(rocrate, entity, overwrite = FALSE, verbose = FALSE)

add_entities(rocrate, entity, overwrite = FALSE, verbose = FALSE)
```

## Arguments

- rocrate:

  RO-Crate object, see
  [rocrate](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md).

- entity:

  Entity object (list) that contains at least the following components:
  `@id` and `@type`. Alternatively, a list of entities.

- overwrite:

  Boolean flag to indicate if the entity (if found in the given
  RO-Crate) should be overwritten.

- verbose:

  Boolean flag to indicate if status messages should be hidden (default:
  `FALSE`).

## Value

Updated RO-Crate object.

## Examples

``` r
basic_crate <- rocrateR::rocrate()

# create entity for an organisation
organisation_uol <- rocrateR::entity(
  "https://ror.org/04xs57h96",
  type = "Organization",
  name = "University of Liverpool",
  url = "http://www.liv.ac.uk"
)

# create an entity for a person
person_rvd <- rocrateR::entity(
  "https://orcid.org/0000-0001-5036-8661",
  type = "Person",
  name = "Roberto Villegas-Diaz",
  affiliation = list(`@id` = organisation_uol$`@id`)
)

basic_crate_v2 <- basic_crate |>
  rocrateR::add_entity(person_rvd) |>
  rocrateR::add_entity_value(
    id = "./",
    key = "author",
    value = list(`@id` = person_rvd$`@id`)
  ) |>
  rocrateR::add_entity(organisation_uol)
```
