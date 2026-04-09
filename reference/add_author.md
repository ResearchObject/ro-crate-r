# Add an author to an RO-Crate

This helper creates an author entity and if `affiliation` is provided,
then creates an organisation entity for the user's affiliation.

## Usage

``` r
add_author(
  rocrate,
  name,
  orcid = NULL,
  affiliation = NULL,
  ror = NULL,
  set_author = TRUE
)
```

## Arguments

- rocrate:

  RO-Crate object, see
  [rocrate](https://github.com/ResearchObject/ro-crate-r/reference/rocrate.md).

- name:

  Author's name.

- orcid:

  Optional, ORCID identifier, for details see <https://orcid.org>.

- affiliation:

  Optional, author's organisation.

- ror:

  Optional, ROR identifier for the affiliation, for details see
  <https://ror.org>.

- set_author:

  Logical, used to indicate if the current user should be set as the
  author of the RO-Crate.

## Value

Updated RO-Crate object.
