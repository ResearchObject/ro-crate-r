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
  # save the input into intermediate JSON file
  tmp_file <- tempfile(fileext = ".json")
  # delete temporary file
  on.exit(unlink(tmp_file, recursive = TRUE, force = TRUE))
  # store RO-Crate in JSON format
  jsonlite::write_json(x, path = tmp_file, pretty = TRUE, auto_unbox = TRUE)
  # load formatted RO-Crate as text
  rocrate_txt <- readLines(tmp_file)
  # display formatted RO-Crate
  rocrate_txt |>
    paste0(collapse = "\n")|>
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
  message("RO-Crate entity:",
          "\n @id = '", getElement(x, "@id"), "'",
          "\n @type = '", getElement(x, "@type"), "'"
          )
  # return (invisibly) the input object
  invisible(x)
}
