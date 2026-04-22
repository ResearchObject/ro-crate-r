#' Print RO-Crate
#'
#' Print RO-Crate, S3 method for class 'rocrate'. Creates a temporal JSON file,
#' which then is displayed with the [message] function.
#'
#' @param x RO-Crate object, see [rocrateR::rocrate].
#' @param ... Optional arguments, not used.
#' @param max_lines Max number of lines to display.
#'
#' @returns Invisibly the input RO-Crate, `x`.
#' @export
#'
#' @examples
#' rocrateR::rocrate()
print.rocrate <- function(x, ..., max_lines = getOption("max_lines", 100)) {
  # check the `x` object
  is_rocrate(x)
  # reformat the input to JSON style
  x_json <- jsonlite::toJSON(x, pretty = TRUE, auto_unbox = TRUE)
  x_json_lines <- strsplit(x_json, "\n")[[1]]
  # check if max_lines is finite
  if (is.finite(max_lines) && max_lines > 2) {
    # check if number of lines is bigger than (max_lines - 2)
    if (length(x_json_lines) > (max_lines - 2)) {
      x_json_lines <- c(
        x_json_lines[seq_len(max_lines - 2)],
        "  \U2757 <file truncated, set `options(max_lines = Inf)` to display all>",
        x_json_lines[length(x_json_lines) - c(1, 0)]
      )
    }
  }

  x_json_lines |>
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
    "<RO-Crate entity>",
    sprintf("\n @id = '%s'", getElement(x, "@id")),
    sprintf("\n @type = '%s'", getElement(x, "@type"))
  )
  # return (invisibly) the input object
  invisible(x)
}

#' @export
print.rocrate_validation <- function(x, ...) {
  msg <- "<RO-Crate validation>"

  is_valid <- function(x) {
    inherits(x, "rocrate_validation") &&
      length(x$errors) == 0
  }

  if (is_valid(x)) {
    msg <- c(msg, "\U2714 Valid RO-Crate")
  } else {
    msg <- c(msg, "\U2716 Invalid RO-Crate")
  }

  if (length(x$errors)) {
    msg <- c(msg, "\nErrors:")
    msg <- c(msg, paste0(" - ", x$errors, collapse = "\n"))
  }

  if (length(x$warnings)) {
    msg <- c(msg, "\nWarnings:")
    msg <- c(msg, paste0(" - ", x$warnings, collapse = "\n"))
  }

  message(paste0(msg, collapse = "\n"))

  invisible(x)
}

#' @export
print.summary.entity <- function(x, ...) {
  msg <- c(
    "<RO-Crate Entity Summary>",
    paste(" ID:", x$id),
    paste(" Type:", x$type)
  )

  if (!is.na(x$name)) {
    msg <- c(msg, paste(" Name:", x$name))
  }

  msg <- c(msg, paste(" Metadata fields:", x$n_fields))

  message(paste0(msg, collapse = "\n"))
  invisible(x)
}

#' @export
print.summary.rocrate <- function(x, ...) {
  msg <- c(
    "<RO-Crate Summary>",
    paste(" Entities:", x$n_entities),
    paste(" Files:", x$n_files)
  )

  if (!is.na(x$root_name) && nchar(x$root_name) > 0) {
    msg <- c(msg, paste(" Root dataset:", x$root_name))
  } else {
    msg <- c(msg, " Root dataset: <unnamed>")
  }
  message(paste0(msg, collapse = "\n"))
  invisible(x)
}
