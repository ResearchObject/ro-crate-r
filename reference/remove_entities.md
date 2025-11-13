# Wrapper for [remove_entity](remove_entity.md)

Wrapper for [remove_entity](remove_entity.md), can be use to remove
multiple entities.

## Usage

``` r
remove_entities(rocrate, entity)
```

## Arguments

- rocrate:

  RO-Crate object, see [rocrate](rocrate.md).

- entity:

  Entity object (list) that contains at least the following components:
  `@id` and `@type`. Or, scalar value with entity `@id`.

## Value

Updated RO-Crate.
