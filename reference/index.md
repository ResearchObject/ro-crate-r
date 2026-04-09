# Package index

## Core functions

Core functions to handle RO-Crates with R.

- [`is_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/is_rocrate.md)
  : Check if object is an RO-Crate

- [`load_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/load_rocrate.md)
  : Load an RO-Crate from various input types

- [`print(`*`<entity>`*`)`](https://github.com/ResearchObject/ro-crate-r/reference/print.entity.md)
  : Print RO-Crate entity

- [`print(`*`<rocrate>`*`)`](https://github.com/ResearchObject/ro-crate-r/reference/print.rocrate.md)
  : Print RO-Crate

- [`read_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/read_rocrate.md)
  :

  Wrapper for
  [jsonlite::read_json](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html)

- [`rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md)
  : Create a new RO-Crate object

- [`rocrate_5s()`](https://github.com/ResearchObject/ro-crate-r/reference/rocrate_5s.md)
  : Create a new 5 Safes RO-Crate object

- [`summary(`*`<entity>`*`)`](https://github.com/ResearchObject/ro-crate-r/reference/summary.entity.md)
  : Summary of an RO-Crate entity

- [`summary(`*`<rocrate>`*`)`](https://github.com/ResearchObject/ro-crate-r/reference/summary.rocrate.md)
  : Summary of an RO-Crate

- [`validate_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/validate_rocrate.md)
  : Validate an RO-Crate

- [`write_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/write_rocrate.md)
  :

  Wrapper for
  [jsonlite::write_json](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html)

### BagIt functions

- [`bag_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/bag_rocrate.md)
  : Bag the contents of an RO-Crate
- [`is_rocrate_bag()`](https://github.com/ResearchObject/ro-crate-r/reference/is_rocrate_bag.md)
  : Check if path points to a valid RO-Crate bag
- [`load_rocrate_bag()`](https://github.com/ResearchObject/ro-crate-r/reference/load_rocrate_bag.md)
  : Load an RO-Crate BagIt archive
- [`unbag_rocrate()`](https://github.com/ResearchObject/ro-crate-r/reference/unbag_rocrate.md)
  : 'Unbag' (extract) RO-Crate packed with BagIt

### Entity functions

- [`entity()`](https://github.com/ResearchObject/ro-crate-r/reference/entity.md)
  : Create a data entity

- [`extract_content()`](https://github.com/ResearchObject/ro-crate-r/reference/extract_content.md)
  :

  Extract `File` entities content to files

- [`get_entity()`](https://github.com/ResearchObject/ro-crate-r/reference/get_entity.md)
  : Get entity(ies)

- [`remove_entity()`](https://github.com/ResearchObject/ro-crate-r/reference/remove_entity.md)
  [`remove_entities()`](https://github.com/ResearchObject/ro-crate-r/reference/remove_entity.md)
  : Remove entity

## Utilitarian functions

Utilitarian functions to add specific entity types to an RO-Crate.

- [`add_author()`](https://github.com/ResearchObject/ro-crate-r/reference/add_author.md)
  : Add an author to an RO-Crate
- [`add_dataset()`](https://github.com/ResearchObject/ro-crate-r/reference/add_dataset.md)
  : Add a dataset to an RO-Crate
- [`add_entity()`](https://github.com/ResearchObject/ro-crate-r/reference/add_entity.md)
  [`add_entities()`](https://github.com/ResearchObject/ro-crate-r/reference/add_entity.md)
  : Add entity to RO-Crate
- [`add_entity_value()`](https://github.com/ResearchObject/ro-crate-r/reference/add_entity_value.md)
  : Add entity value to RO-Crate
- [`add_notebook()`](https://github.com/ResearchObject/ro-crate-r/reference/add_notebook.md)
  : Add a notebook to an RO-Crate
- [`add_project()`](https://github.com/ResearchObject/ro-crate-r/reference/add_project.md)
  : Add project metadata
- [`add_readme()`](https://github.com/ResearchObject/ro-crate-r/reference/add_readme.md)
  : Add README file to an RO-Crate
- [`add_software()`](https://github.com/ResearchObject/ro-crate-r/reference/add_software.md)
  : Add software application entity
- [`add_workflow()`](https://github.com/ResearchObject/ro-crate-r/reference/add_workflow.md)
  : Add a workflow to an RO-Crate
- [`crate_project()`](https://github.com/ResearchObject/ro-crate-r/reference/crate_project.md)
  : Automatically create an RO-Crate from a project directory
