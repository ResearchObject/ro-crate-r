# Add a workflow to an RO-Crate

Register a workflow script (e.g. R, Python, Nextflow) as a
`ComputationalWorkflow` entity inside the RO-Crate.

## Usage

``` r
add_workflow(
  rocrate,
  file_id,
  name = NULL,
  description = NULL,
  language = "R",
  content = NULL
)
```

## Arguments

- rocrate:

  RO-Crate object, see
  [rocrate](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md).

- file_id:

  Filename of the workflow script.

- name:

  Workflow name.

- description:

  Optional description.

- language:

  Programming language (default `"R"`).

- content:

  Optional script contents.

## Value

Updated RO-Crate object.
