#' Wrapper for [jsonlite::read_json]
#'
#' Wrapper for [jsonlite::read_json]. Enforces that the object read is an
#'     RO-Crate.
#'
#' @inheritParams jsonlite::read_json
#' @inheritDotParams jsonlite::fromJSON
#'
#' @returns Invisibly the RO-Crate stored in `path`.
#' @export
read_rocrate <- function(path, simplifyVector = FALSE, ...) {
  lifecycle::deprecate_warn(
    "0.1.0",
    "read_rocrate()",
    "load_rocrate()"
  )

  load_rocrate(x = path, ...)
}

#' Wrapper for [jsonlite::write_json]
#'
#' Wrapper for [jsonlite::write_json]. Enforces that the input object is an
#'     RO-Crate.
#'
#' @inheritParams print.rocrate
#' @inheritParams jsonlite::write_json
#' @inheritDotParams jsonlite::toJSON -pretty -auto_unbox
#'
#' @returns Invisibly the input RO-Crate, `x`.
#' @export
write_rocrate <- function(x, path, ...) {
  # check the `x` object
  is_rocrate(x)

  # store RO-Crate in JSON format
  jsonlite::write_json(
    x = x,
    path = path,
    pretty = TRUE,
    auto_unbox = TRUE,
    ...
  )

  # return (invisibly) the input object
  invisible(x)
}

#' Wrapper for [jsonlite::read_json]
#'
#' Wrapper for [jsonlite::read_json]. Enforces that the object read is an
#'     RO-Crate.
#'
#' @inheritParams jsonlite::read_json
#' @inheritDotParams jsonlite::fromJSON
#'
#' @returns Invisibly the RO-Crate stored in `path`.
#' @keywords internal
#' @noRd
.read_rocrate_json <- function(path, simplifyVector = FALSE, ...) {
  # reads the input file as a JSON file
  rocrate <- jsonlite::read_json(path, simplifyVector = simplifyVector, ...)
  # assigns it the 'rocrate' class
  class(rocrate) <- c("rocrate", class(rocrate))
  # assign the entity class to each element in the `@graph`
  for (i in seq_along(rocrate$`@graph`)) {
    class(rocrate$`@graph`[[i]]) <- c("entity", class(rocrate$`@graph`[[i]]))
  }
  # checks the object has the basic structure of an RO-Crate
  is_rocrate(rocrate)
  # returns the new object as an RO-crate
  return(invisible(rocrate))
}

#' Validate JSON syntax for RO-Crate metadata file
#'
#' @param metadata_path String with path to RO-Crate metadata file.
#'
#' @returns Boolean indicating if `metadata_path` is valid.
#' @keywords internal
#' @noRd
.validate_json_syntax <- function(metadata_path) {
  tryCatch(
    jsonlite::fromJSON(metadata_path),
    error = function(e) {
      stop("Invalid JSON syntax in ro-crate-metadata.json", call. = FALSE)
    }
  )
  return(TRUE)
}

#' Validate JSON-LD compliance of an RO-Crate
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#'
#' @returns Boolean value with compliance
#' @keywords internal
#' @noRd
.validate_jsonld_compliance <- function(rocrate) {
  # future JSON-LD checks
}
