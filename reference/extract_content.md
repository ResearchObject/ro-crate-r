# Extract `File` entities content to files

Write the `content` field of `File` entities to disk using their `@id`
as the filename.

## Usage

``` r
extract_content(rocrate, path, overwrite = FALSE)
```

## Arguments

- rocrate:

  RO-Crate object, see
  [rocrate](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md).

- path:

  Directory where files will be written. RO-Crate root.

- overwrite:

  Logical. Overwrite existing files.

## Value

Invisibly returns updated `rocrate` without contents.
