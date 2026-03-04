#' Create a \link[rocrateR]{rocrate} validation result
#'
#' Internal constructor for validation results.
#'
#' @param errors Character vector of errors.
#' @param warnings Character vector of warnings.
#' @param info Character vector of informational messages.
#'
#' @return A `rocrate_validation` object.
#' @keywords internal
new_rocrate_validation <- function(
  errors = character(),
  warnings = character(),
  info = character()
) {
  structure(
    list(
      errors = errors,
      warnings = warnings,
      info = info
    ),
    class = "rocrate_validation"
  )
}

#' Validate RO-Crate against profile
#'
#' @inheritParams is_rocrate
#' @param profile List with profile requirements, see `R/profiles.R`
#'
#' @returns Vector with errors (if any).
#' @keywords internal
.validate_against_profile <- function(rocrate, profile) {
  errors <- character()

  root <- .get_root_entity(rocrate)
  ids <- .get_entity_ids(rocrate)

  if (is.null(root)) {
    return(errors) # root absence handled earlier
  }

  for (rule in profile$rules) {
    if (rule$type == "require_root_type") {
      root_type <- root$`@type`

      if (is.null(root_type) || !rule$value %in% root_type) {
        errors <- c(
          errors,
          sprintf(
            "[%s] Root entity must have @type '%s'.",
            profile$name,
            rule$value
          )
        )
      }
    }

    if (rule$type == "require_entity") {
      if (!rule$id %in% ids) {
        errors <- c(
          errors,
          sprintf(
            "[%s] Missing required entity with @id '%s'.",
            profile$name,
            rule$id
          )
        )
      }
    }

    if (rule$type == "require_root_property") {
      if (is.null(root[[rule$property]])) {
        errors <- c(
          errors,
          sprintf(
            "[%s] Root entity missing required property '%s'.",
            profile$name,
            rule$property
          )
        )
      }
    }
  }

  errors
}
