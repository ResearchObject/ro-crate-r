#' Print RO-Crate
#'
#' Print RO-Crate, S3 method for class 'rocrate'. Creates a temporal JSON file,
#' which then is displayed with the [message] function.
#'
#' @param x RO-Crate object, see [rocrateR::rocrate].
#' @param ... Optional arguments, not used.
#'
#' @returns Invisibly the input RO-Crate, `x`.
#' @export
#'
#' @examples
#' rocrateR::rocrate()
print.rocrate <- function(x, ...) {
  # check the `x` object
  is_rocrate(x)
  # reformat the input to JSON style
  jsonlite::toJSON(x, pretty = TRUE, auto_unbox = TRUE) |>
    paste0(collapse = "\n") |>
    message()
  # return (invisibly) the input object
  invisible(x)
}

#' Print RO-Crate entity
#'
#' Print RO-Crate entity, S3 method for class 'entity'.
#'
#' @param x RO-Crate entity object, see [rocrateR::entity].
#' @param ... Optional arguments, not used.
#'
#' @returns Invisibly the input RO-Crate entity, `x`.
#' @export
#'
#' @examples
#' rocrateR::rocrate() |>
#'   rocrateR::get_entity("./")
print.entity <- function(x, ...) {
  # check the `x` object
  .validate_entity(x)

  # display formatted RO-Crate entity
  message(
    "RO-Crate entity:",
    "\n @id = '",
    getElement(x, "@id"),
    "'",
    "\n @type = '",
    getElement(x, "@type"),
    "'"
  )
  # return (invisibly) the input object
  invisible(x)
}

#' @export
print.rocrate_validation <- function(x, ...) {
  cat("<rocrate_validation>\n")

  is_valid <- function(x) {
    inherits(x, "rocrate_validation") &&
      length(x$errors) == 0
  }

  if (is_valid(x)) {
    cat("\U2714 Valid RO-Crate\n")
  } else {
    cat("\U2716 Invalid RO-Crate\n")
  }

  if (length(x$errors)) {
    cat("\nErrors:\n")
    cat(paste0(" - ", x$errors, collapse = "\n"), "\n")
  }

  if (length(x$warnings)) {
    cat("\nWarnings:\n")
    cat(paste0(" - ", x$warnings, collapse = "\n"), "\n")
  }

  invisible(x)
}
