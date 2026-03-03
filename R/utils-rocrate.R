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
