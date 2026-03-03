#' Check if object is an RO-Crate
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#' @param strict Boolean to indicate if JSON-LD compliance should be checked.
#'
#' @returns Returns invisibly the input RO-Crate object.
#' @export
#'
#' @examples
#' basic_crate <- rocrateR::rocrate()
#'
#' # check if the new crate is valid
#' basic_crate |>
#'   rocrateR::is_rocrate()
is_rocrate <- function(rocrate, strict = FALSE) {
  # local bindings
  errors <- character()

  # check `rocrate` class
  if (!inherits(rocrate, "rocrate")) {
    errors <- c(errors, "Missing 'rocrate' class.")
  }

  # check `@context`
  context <- rocrate[["@context"]]

  if (is.null(context)) {
    errors <- c(errors, "Missing '@context'.")
  } else {
    valid_context <- any(
      vapply(context, .is_valid_url, logical(1), suffix = "/context")
    )
    if (!valid_context) {
      errors <- c(
        errors,
        paste0("Invalid '@context': ", paste(context, collapse = "; "))
      )
    }
  }

  # check `@graph`
  graph <- rocrate[["@graph"]]

  if (is.null(graph)) {
    errors <- c(errors, "Missing '@graph'.")
  } else {
    ids <- vapply(graph, function(x) x$`@id`, character(1))

    # Validate entities
    entity_valid <- vapply(
      seq_along(graph),
      function(i) {
        .validate_entity.list(graph[[i]], ent_name = ids[i])
      },
      logical(1)
    )

    if (!all(entity_valid)) {
      errors <- c(errors, "Invalid entity structure detected in '@graph'.")
    }

    if (!"./" %in% ids) {
      errors <- c(errors, "Missing root entity ('./').")
    }

    if (!"ro-crate-metadata.json" %in% ids) {
      errors <- c(
        errors,
        "Missing metadata descriptor entity ('ro-crate-metadata.json')."
      )
    }
  }

  if (length(errors) > 0) {
    stop(
      paste(
        "Invalid RO-Crate object:\n",
        paste0("  - ", errors, collapse = "\n")
      ),
      call. = FALSE
    )
  }

  if (strict) {
    .validate_jsonld_compliance(rocrate)
  }

  # return (invisibly) the input RO-Crate
  return(invisible(rocrate))
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
#' @param strict Logical. If TRUE, perform strict profile validation.
#' @param verbose Logical. If TRUE, emit diagnostic messages.
#' @param ... Reserved for future extensions.
#'
#' @return A validated `rocrate` object.
#' @export
load_rocrate <- function(x, ...) {
  UseMethod("load_rocrate")
}

#' @rdname load_rocrate
#' @export
load_rocrate.rocrate <- function(x, ..., strict = FALSE, verbose = FALSE) {
  if (verbose) {
    message("Input is already a rocrate object.")
  }

  is_rocrate(x, strict = strict)

  return(x)
}

#' @rdname load_rocrate
#' @export
load_rocrate.character <- function(
  x,
  ...,
  bagit_version = "1.0",
  strict = FALSE,
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
    is_rocrate(rocrate, strict = strict)

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

      is_rocrate(rocrate, strict = strict)

      return(rocrate)
    }
  }

  stop(
    "Could not determine how to load RO-Crate from provided input.",
    call. = FALSE
  )
}
