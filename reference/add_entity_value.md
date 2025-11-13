# Add entity value to RO-Crate

Add entity value to RO-Crate, under entity with `@id` = `{id}`, using
the pair `{key}`-`{value}` within `@graph`.

## Usage

``` r
add_entity_value(rocrate, id, key, value, overwrite = TRUE)
```

## Arguments

- rocrate:

  RO-Crate object, see [rocrate](rocrate.md).

- id:

  String with the ID of the RO-Crate entity within `@graph`.

- key:

  String with the `key` of the entity with `id` to be modified.

- value:

  String with the `value` for `key`.

- overwrite:

  Boolean flag to indicate if the existing value (if any), should be
  overwritten (default: `TRUE`).

## Value

RO-Crate object.

## Examples

``` r
basic_crate <- rocrate()

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
  rocrateR::add_entity_value(id = "./", key = "author", value = list(`@id` = person_rvd$`@id`))
```
