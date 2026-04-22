# rocrateR (development version)

# rocrateR 0.1.0

* Added higher level function to load RO-Crates from various inputs, 
`load_rocrate`.
* Added higher level function to validate RO-Crate and display report with 
errors and warnings (if any was found), `validate_rocrate`.
* Defined new checks for RO-Crate validation to ignore system specific
directories (e.g., `__MACOSX` on macOS).
* Refactored functions to streamline checks, including `is_rocrate`.
* Updated `get_entity` so it takes a vector for `id` and `type`, reuses the
shorter vector (only if the length 1), or errors if vectors have different 
lengths.
* Updated `is_rocrate_bag` so it returns a boolean value, indicating the 
validity of the given RO-Crate bag. Previously, it returned a path to the 
root of the RO-Crate.
* Updated `unbag_rocrate` to return the path to RO-Crate root _visibly_.
* `add_entities()` is deprecated. Use `add_entity()` instead.
* `load_rocrate_bag()` is deprecated. Use `load_rocrate()` instead. Note that
validation must be done as a separate step using `validate_rocrate()`.
* `read_rocrate()` is deprecated. Use `load_rocrate()` instead.
* `remove_entities()` is deprecated. Use `remove_entity()` instead.
* `entity(x=)` renamed to `entity(id=)`.

# rocrateR 0.0.1

* Initial CRAN submission.
