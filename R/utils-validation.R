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
