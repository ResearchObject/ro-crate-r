# Create a data entity

Create a data entity

## Usage

``` r
entity(id, type, ...)
```

## Arguments

- id:

  Scalar value with `@id` for the entity (e.g., `character`, `numeric`).

- type:

  String with `@type` for the entity (e.g., `Dataset`, `File`).

- ...:

  Optional additional entity values/properties.

## Value

List with an entity object.

## Examples

``` r
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
```
