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
  jsonlite::write_json(x = x, path = path, pretty = TRUE, auto_unbox = TRUE, ...)

  # return (invisibly) the input object
  invisible(x)
}
