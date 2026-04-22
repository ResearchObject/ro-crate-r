# Internal profile registry ----------------------------------------------

.rocrate_profiles <- list(
  # RO-Crate 1.2 ----------------------------------------------------------
  "https://w3id.org/ro/crate/1.2" = list(
    id = "https://w3id.org/ro/crate/1.2",
    name = "RO-Crate 1.2",
    rules = list(
      list(type = "require_root_type", value = "Dataset"),
      list(type = "require_entity", id = "ro-crate-metadata.json"),
      list(type = "require_root_property", property = "conformsTo")
    )
  ),

  # 5S Crate 0.4 ----------------------------------------------------------
  "https://w3id.org/5s-crate/0.4" = list(
    id = "https://w3id.org/5s-crate/0.4",
    name = "5S Crate 0.4",
    rules = list(
      list(type = "require_root_type", value = "Dataset"),
      list(type = "require_root_property", property = "license"),
      list(type = "require_root_property", property = "conformsTo")
    )
  )
)
