# Remove entity

Remove entity

## Usage

``` r
remove_entity(rocrate, entity)
```

## Arguments

- rocrate:

  RO-Crate object, see [rocrate](rocrate.md).

- entity:

  Entity object (list) that contains at least the following components:
  `@id` and `@type`. Or, scalar value with entity `@id`.

## Value

Updated RO-Crate object.

## Examples

``` r
basic_crate <- rocrateR::rocrate()

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
  name = "Roberto Villegas-Diaz",
  affiliation = list(`@id` = organisation_uol$`@id`)
)

basic_crate_v2 <- basic_crate |>
  rocrateR::add_entity(person_rvd) |>
  rocrateR::add_entity_value(id = "./", key = "author", value = list(`@id` = person_rvd$`@id`)) |>
  rocrateR::add_entity(organisation_uol) |>
  rocrateR::remove_entity(person_rvd)
#> Removing the entity with @id = 'https://orcid.org/0000-0001-5036-8661'.
```
