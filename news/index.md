# Changelog

## rocrateR (development version)

## rocrateR 0.1.0

CRAN release: 2026-04-08

- Added higher level function to load RO-Crates from various inputs,
  `load_rocrate`.
- Added higher level function to validate RO-Crate and display report
  with errors and warnings (if any was found), `validate_rocrate`.
- Defined new checks for RO-Crate validation to ignore system specific
  directories (e.g., `__MACOSX` on macOS).
- Refactored functions to streamline checks, including `is_rocrate`.
- Updated `get_entity` so it takes a vector for `id` and `type`, reuses
  the shorter vector (only if the length 1), or errors if vectors have
  different lengths.
- Updated `is_rocrate_bag` so it returns a boolean value, indicating the
  validity of the given RO-Crate bag. Previously, it returned a path to
  the root of the RO-Crate.
- Updated `unbag_rocrate` to return the path to RO-Crate root *visibly*.
- [`add_entities()`](https://github.com/ResearchObject/ro-crate-r/reference/add_entity.md)
  is deprecated. Use
  [`add_entity()`](https://github.com/ResearchObject/ro-crate-r/reference/add_entity.md)
  instead.
- [`load_rocrate_bag()`](https://github.com/ResearchObject/ro-crate-r/reference/load_rocrate_bag.md)
  is deprecated. Use
  [`load_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/load_rocrate.md)
  instead. Note that validation must be done as a separate step using
  [`validate_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/validate_rocrate.md).
- [`read_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/read_rocrate.md)
  is deprecated. Use
  [`load_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/load_rocrate.md)
  instead.
- [`remove_entities()`](https://github.com/ResearchObject/ro-crate-r/reference/remove_entity.md)
  is deprecated. Use
  [`remove_entity()`](https://github.com/ResearchObject/ro-crate-r/reference/remove_entity.md)
  instead.
- `entity(x=)` renamed to `entity(id=)`.

## rocrateR 0.0.1

CRAN release: 2025-11-07

- Initial CRAN submission.
