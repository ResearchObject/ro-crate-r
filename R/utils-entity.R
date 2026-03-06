#' Capture extra entities
#'
#' Capture extra entities, given as inputs to [rocrateR::rocrate] and
#' [rocrateR::rocrate_5s].
#'
#' @inheritParams rocrate
#'
#' @returns List with name additional entities.
#' @keywords internal
#' @noRd
.capture_extra_entities <- function(...) {
  extra_entities_lst <- list(...)
  if (length(extra_entities_lst) == 0) {
    return(extra_entities_lst)
  }
  # extra_entities_names <- names(extra_entities_lst)
  # # extract names for extra entities with missing names
  # idx <- is.null(extra_entities_names)
  new_names <- extra_entities_lst |> #[idx] |>
    sapply(\(x) {
      paste0(tolower(getElement(x, "@type")), "_", getElement(x, "@id"))
    })
  # assign new names
  # names(extra_entities_lst)[idx] <- new_names
  names(extra_entities_lst) <- new_names
  return(extra_entities_lst)
}

#' Find `@id` index in RO-Crate
#'
#' Find `@id` index in RO-Crate. Useful to update a component of an entity in
#' the RO-Crate, add new component (e.g., author + corresponding `@id`).
#'
#' @inheritParams add_entity_value
#'
#' @returns Boolean vector with index for entity with `@id`.
#' @keywords internal
#' @noRd
.find_id_index <- function(rocrate, id) {
  # find the index in `@graph` with the matching {id}
  aux <- vapply(rocrate$`@graph`, \(x) as.character(x[["@id"]]), character(1))
  aux %in% id
}

#' Find `@type` index in RO-Crate
#'
#' Find `@type` index in RO-Crate. Useful to retrieve entities with a particular
#' type in the RO-Crate.
#'
#' @inheritParams add_entity_value
#'
#' @returns Boolean vector with index for entity(ies) with `@type`.
#' @keywords internal
#' @noRd
.find_type_index <- function(rocrate, type) {
  # find the index in `@graph` with the matching {type} (at least one entry)
  aux <- vapply(rocrate$`@graph`, \(x) as.character(x[["@type"]]), character(1))
  aux %in% type
}

#' Validate entity
#'
#' @inheritParams entity
#' @param ent_name String with the name of the entity.
#' @param required Vector with list of keys required for the entity to be valid.
#'     (default: `c("@id", "@type")`)
#'
#' @returns Boolean value to indicate if the given entity is valid.
#' @keywords internal
#' @noRd
.validate_entity <- function(
  x,
  ...,
  ent_name = NULL,
  required = c("@id", "@type")
) {
  UseMethod(".validate_entity", x)
}

#' @method validate_entity entity
#' @keywords internal
#' @noRd
.validate_entity.entity <- function(
  x,
  ...,
  ent_name = NULL,
  required = c("@id", "@type")
) {
  NextMethod()
}

#' @method validate_entity list
#' @keywords internal
#' @noRd
.validate_entity.list <- function(
  x,
  ...,
  ent_name = NULL,
  required = c("@id", "@type")
) {
  has_elements <- required %in% names(x)
  has_elements |>
    .validate_entity_overview(required, ent_name)
}

#' Entity validation overview
#'
#' @inheritParams .validate_entity
#'
#' @returns Boolean flag with result of entity validation
#' @keywords internal
#' @noRd
.validate_entity_overview <- function(has_elements, required, ent_name = NULL) {
  if (all(has_elements)) {
    return(TRUE)
  }

  # In case there are missing elements from those `required`
  msg <- ""
  if (!is.null(ent_name)) {
    msg <- paste0("===== Checking: ", ent_name, " =====\n")
  }
  msg <- paste0(
    msg,
    "Missing: \n",
    paste0(" - ", required[!has_elements], collapse = "\n")
  )
  stop(msg, call. = FALSE)
}
