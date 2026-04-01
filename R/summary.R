#' Summary of an RO-Crate entity
#'
#' Provides a summary of a single RO-Crate entity.
#'
#' @param object An entity object (list).
#' @param ... Additional arguments (unused).
#'
#' @return An object of class "summary.entity".
#' @export
summary.entity <- function(object, ...) {
  if (!inherits(object, "entity")) {
    stop("Object must be of class 'entity'", call. = FALSE)
  }

  id <- object$`@id` %||% NA_character_
  type <- object$`@type` %||% NA_character_
  name <- object$name %||% NA_character_

  # count metadata fields (excluding @id, @type)
  n_fields <- length(setdiff(names(object), c("@id", "@type")))

  result <- list(
    id = id,
    type = type,
    name = name,
    n_fields = n_fields
  )

  class(result) <- "summary.entity"
  result
}

#' Summary of an RO-Crate
#'
#' Provides a summary of the contents of an RO-Crate, including the
#' number of entities, files and basic metadata information.
#'
#' @param object An object of class "rocrate".
#' @param ... Additional arguments (unused).
#'
#' @return An object of class "summary.rocrate".
#' @export
summary.rocrate <- function(object, ...) {
  if (!inherits(object, "rocrate")) {
    stop("Object must be of class 'rocrate'", call. = FALSE)
  }

  graph <- object$`@graph`

  # count entities
  n_entities <- length(graph)

  # count file entities (has type = 'File', has encodingFormat or file path)
  n_files <- sum(vapply(
    graph,
    function(x) {
      x$`@type` == "File" ||
        !is.null(x$encodingFormat) ||
        !is.null(x$contentUrl)
    },
    logical(1)
  ))

  # root dataset
  root <- .get_root_entity(object)
  root_name <- if (!is.null(root$name)) root$name else NA_character_

  result <- list(
    n_entities = n_entities,
    n_files = n_files,
    root_name = root_name
  )

  class(result) <- "summary.rocrate"
  result
}
