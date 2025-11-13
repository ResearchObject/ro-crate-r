# Find `@id` index in RO-Crate

Find `@id` index in RO-Crate. Useful to update a component of an entity
in the RO-Crate, add new component (e.g., author + corresponding `@id`).

## Usage

``` r
.find_id_index(rocrate, id)
```

## Arguments

- rocrate:

  RO-Crate object, see [rocrate](rocrate.md).

- id:

  String with the ID of the RO-Crate entity within `@graph`.

## Value

Boolean vector with index for entity with `@id`.
