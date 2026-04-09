# Get entity(ies)

Get entity(ies)

## Usage

``` r
get_entity(rocrate, id = NULL, type = NULL)
```

## Arguments

- rocrate:

  RO-Crate object, see
  [rocrate](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md).

- id:

  String with the ID of the RO-Crate entity within `@graph` (optional if
  `type` is provided). Alternatively, an entity object / list with `@id`
  and `@type`.

- type:

  String with the type of the RO-Crate entity(ies) within `@graph` to
  retrieve (optional if `id` is provided).

## Value

List with found entity object(s), if any, `NULL` otherwise.

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

basic_crate_person <- basic_crate |>
  rocrateR::add_entity(person_rvd) |>
  rocrateR::add_entity_value(
    id = "./",
    key = "author",
    value = list(`@id` = person_rvd$`@id`)
  ) |>
  rocrateR::add_entity(organisation_uol) |>
  rocrateR::get_entity(person_rvd)

basic_crate_person[[1]]$name == person_rvd$name
#> [1] TRUE
basic_crate_person[[1]]$`@id` == person_rvd$`@id`
#> [1] TRUE
```
