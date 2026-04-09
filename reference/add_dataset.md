# Add a dataset to an RO-Crate

This helper converts an R object (typically a `data.frame`) into a
dataset inside the RO-Crate. The object is stored in the `content` field
and written to disk when calling
[`extract_content()`](https://github.com/ResearchObject/ro-crate-r/reference/extract_content.md)
or `bag_rocrate(write_content = TRUE)`.

## Usage

``` r
add_dataset(
  rocrate,
  file_id,
  data = NULL,
  name = NULL,
  description = NULL,
  encodingFormat = "text/csv"
)
```

## Arguments

- rocrate:

  RO-Crate object, see
  [rocrate](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md).

- file_id:

  Filename for the dataset file.

- data:

  R object to store (typically a `data.frame`).

- name:

  Dataset name.

- description:

  Optional dataset description.

- encodingFormat:

  MIME type (default `"text/csv"`).

## Value

Updated RO-Crate object.

## Details

Use this when you want to register a dataset file or directory as a
formal Dataset entity inside the RO-Crate metadata.
