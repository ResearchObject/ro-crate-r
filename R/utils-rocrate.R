#' Check if object is an RO-Crate
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#' @param strict Boolean to indicate if JSON-LD compliance should be checked.
#'
#' @returns Boolean flag with RO-Crate validity.
#' @export
#'
#' @examples
#' basic_crate <- rocrateR::rocrate()
#'
#' # check if the new crate is valid
#' basic_crate |>
#'   rocrateR::is_rocrate()
is_rocrate <- function(rocrate, strict = FALSE) {
  # call internal helper to identify errors
  errors <- .validate_rocrate(rocrate, strict = strict)

  if (length(errors)) {
    stop(
      paste("Invalid RO-Crate:\n", paste(" - ", errors, collapse = "\n")),
      call. = FALSE
    )
  }

  return(TRUE)
}

#' Load an RO-Crate from various input types
#'
#' High-level loader that can read:
#' - A `ro-crate-metadata.json` file
#' - A directory containing an RO-Crate
#' - A BagIt-wrapped RO-Crate directory
#' - A zipped BagIt RO-Crate archive
#'
#' @param x A path (character) or an existing \link[rocrateR]{rocrate} object.
#' @param bagit_version String with version of BagIt used to generate the
#'     RO-Crate bag (default: `"1.0"`).
#'     See \doi{10.17487/RFC8493} for more details.
#' @param verbose Logical. If TRUE, emit diagnostic messages.
#' @param ... Reserved for future extensions.
#'
#' @return A `rocrate` object.
#' @export
load_rocrate <- function(x, ...) {
  UseMethod("load_rocrate")
}

#' @rdname load_rocrate
#' @export
load_rocrate.rocrate <- function(x, ..., verbose = FALSE) {
  if (verbose) {
    message("Input is already a rocrate object.")
  }

  return(x)
}

#' @rdname load_rocrate
#' @export
load_rocrate.character <- function(
  x,
  ...,
  bagit_version = "1.0",
  verbose = FALSE
) {
  if (!file.exists(x)) {
    stop("The provided path does not exist.", call. = FALSE)
  }

  if (verbose) {
    message("Detecting RO-Crate input type...")
  }

  # case 1: direct metadata file
  if (grepl("ro-crate-metadata\\.json$", x)) {
    if (verbose) {
      message("Detected metadata JSON file.")
    }

    rocrate <- read_rocrate(x)

    return(rocrate)
  }

  # case 2: zip archive
  if (!dir.exists(x) && grepl("\\.zip$", x, ignore.case = TRUE)) {
    if (verbose) {
      message("Detected ZIP archive. Extracting...")
    }

    return(load_rocrate_bag(x, bagit_version = bagit_version))
  }

  # case 3: directory
  if (dir.exists(x)) {
    # BagIt directory
    if (file.exists(file.path(x, "bagit.txt"))) {
      if (verbose) {
        message("Detected BagIt directory.")
      }

      return(load_rocrate_bag(x, bagit_version = bagit_version))
    }

    # Plain RO-Crate directory
    metadata_path <- file.path(x, "ro-crate-metadata.json")

    if (file.exists(metadata_path)) {
      if (verbose) {
        message("Detected plain RO-Crate directory.")
      }

      rocrate <- read_rocrate(metadata_path)

      return(rocrate)
    }
  }

  stop(
    "Could not determine how to load RO-Crate from provided input.",
    call. = FALSE
  )
}

#' Validate an RO-Crate
#'
#' Performs structural, semantic and profile validation.
#'
#' @param x A path (character) or an existing \link[rocrateR]{rocrate} object.
#' @param mode Either `"stop"` or `"report"`.
#' @param strict Logical. Enable profile validation.
#'
#' @return A `rocrate_validation` object (in report mode).
#' @export
validate_rocrate <- function(
  x,
  mode = c("stop", "report"),
  strict = FALSE
) {
  # validation reporting mode
  mode <- match.arg(mode)

  # load the RO-Crate
  rocrate <- load_rocrate(x, strict = strict)

  # validate the RO-Crate
  errors <- .validate_rocrate(rocrate, strict = strict)

  # create validation report
  result <- new_rocrate_validation(errors = errors)

  if (mode == "stop" && length(result$error) != 0) {
    stop(paste(result$errors, collapse = "\n"), call. = FALSE)
  }

  result
}

#' Validate minimal RO-Crate structure
#'
#' Ensures required top-level fields are present.
#'
#' @param rocrate A parsed RO-Crate object.
#'
#' @return Character vector of errors.
#' @keywords internal
.validate_structure <- function(rocrate) {
  errors <- character()

  if (!inherits(rocrate, "rocrate")) {
    errors <- c(errors, "Object is not of class 'rocrate'.")
  }

  if (is.null(rocrate$`@context`)) {
    errors <- c(errors, "Missing '@context'.")
  }

  if (is.null(rocrate$`@graph`)) {
    errors <- c(errors, "Missing '@graph'.")
  }

  errors
}

#' Validate RO-Crate semantic structure
#'
#' Performs semantic checks on the `@graph`.
#'
#' @param rocrate A parsed RO-Crate object.
#'
#' @return Character vector of errors.
#' @keywords internal
.validate_semantics <- function(rocrate) {
  errors <- character()

  graph <- rocrate$`@graph`

  if (!is.list(graph)) {
    return(c(errors, "'@graph' must be a list."))
  }

  ids <- vapply(graph, function(x) x$`@id`, character(1), USE.NAMES = FALSE)

  # check root dataset exists
  if (!"./" %in% ids) {
    errors <- c(errors, "Missing root Dataset with '@id' = './'.")
  }

  # check duplicated IDs
  if (any(duplicated(ids))) {
    errors <- c(errors, "Duplicate '@id' values detected in '@graph'.")
  }

  # check there's an RO-Crate Metadata descriptor entity
  if (!"ro-crate-metadata.json" %in% ids) {
    errors <- c(
      errors,
      paste0(
        "Missing the entity for the RO-Crate Metadata descriptor, ",
        "@id = 'ro-crate-metadata.json'.\n"
      )
    )
  }

  errors
}

#' Validate RO-Crate and return list of errors identied
#'
#' @inheritParams is_rocrate
#'
#' @returns Vector of strings with errors identified
#' @keywords internal
.validate_rocrate <- function(rocrate, strict = FALSE) {
  errors <- character()

  errors <- c(errors, .validate_structure(rocrate))
  errors <- c(errors, .validate_semantics(rocrate))

  if (strict) {
    errors <- c(errors, .validate_rocrate_profile(rocrate))
  }

  errors
}

#' Validate RO-Crate profile
#'
#' Performs profile-specific validation if `conformsTo` is declared.
#'
#' @param rocrate A parsed RO-Crate object.
#'
#' @return Character vector of errors.
#' @keywords internal
.validate_rocrate_profile <- function(rocrate) {
  errors <- character()

  graph <- rocrate$`@graph`
  ids <- vapply(graph, function(x) x$`@id`, character(1))

  # get root index
  root_idx <- which(ids == "./")

  # check if root (./) entity is missing
  if (length(root_idx) == 0) {
    return(errors)
  }

  root <- graph[[root_idx]]

  if (is.null(root$conformsTo)) {
    return(errors)
  }

  # Placeholder for future profile-specific logic

  errors
}
