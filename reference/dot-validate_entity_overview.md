# Entity validation overview

Entity validation overview

## Usage

``` r
.validate_entity_overview(has_elements, required, ent_name = NULL)
```

## Arguments

- required:

  Vector with list of keys required for the entity to be valid.
  (default: `c("@id", "@type")`)

- ent_name:

  String with the name of the entity.

## Value

Boolean flag with result of entity validation
