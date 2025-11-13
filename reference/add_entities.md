# Wrapper for [add_entity](add_entity.md)

Wrapper for [add_entity](add_entity.md), can be use to add multiple
entities.

## Usage

``` r
add_entities(rocrate, entity, overwrite = FALSE, quiet = FALSE)
```

## Arguments

- rocrate:

  RO-Crate object, see [rocrate](rocrate.md).

- entity:

  List with entity objects.

- overwrite:

  Boolean flag to indicate if the entity (if found in the given
  RO-Crate) should be overwritten.

- quiet:

  Boolean flag to indicate if status messages should be hidden (default:
  `FALSE`).

## Value

Updated RO-Crate with the new entities.
