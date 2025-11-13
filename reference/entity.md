# Create a data entity

Create a data entity

## Usage

``` r
entity(x, ...)
```

## Arguments

- x:

  New entity. If a single value (e.g., `character`, `numeric`) is given,
  this is assumed to be the entity's `@id`, if a `list` is given, this
  is assumed to be a complete entity. Other options are objects of type
  `person` and `organisation` (equivalently `organization`).

- ...:

  Optional additional entity values/properties. Used when `x` is a
  single value.

## Value

List with an entity object.

## Examples

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
  name = "Roberto Villegas-Diaz",
  affiliation = list(`@id` = organisation_uol$`@id`)
)
```
