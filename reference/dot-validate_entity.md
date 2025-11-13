# Validate entity

Validate entity

## Usage

``` r
.validate_entity(x, ..., ent_name = NULL, required = c("@id", "@type"))
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

- ent_name:

  String with the name of the entity.

- required:

  Vector with list of keys required for the entity to be valid.
  (default: `c("@id", "@type")`)

## Value

Boolean value to indicate if the given entity is valid.
