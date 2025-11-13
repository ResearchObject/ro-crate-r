#' Check if object is an RO-Crate
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
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
is_rocrate <- function(rocrate) {
  # has the 'rocrate' class
  has_rocrate_class <- "rocrate" %in% class(rocrate)

  # extract main value for @context
  ro_crate_context <- getElement(rocrate, "@context")

  # check if @context is missing
  missing_context <- is.null(ro_crate_context)

  # has a valid @context
  has_valid_context <- ro_crate_context |>
    sapply(.is_valid_url, suffix = "/context") |>
    any() # at least one entry of the RO-Crate context must be a valid URL

  # extract @graph
  ro_crate_graph <- getElement(rocrate, "@graph")

  # check if @graph is missing
  missing_graph <- is.null(ro_crate_graph)

  # extract @graph elements' @id
  graph_ids <- ro_crate_graph |>
    sapply(`[[`, "@id") |>
    unlist()

  # validate @graph entities
  valid_entities <- seq_along(ro_crate_graph) |>
    sapply(function(i) {
      .validate_entity.list(ro_crate_graph[[i]], ent_name = graph_ids[i])
    })

  # check lengths of @ids and number of entities, must be the same
  valid_length_graph <- length(graph_ids) == sum(valid_entities == TRUE)

  # has an RO-Crate Metadata descriptor entity
  has_rocrate_meta <- "ro-crate-metadata.json" %in% graph_ids

  # has a root entity
  has_root <- "./" %in% graph_ids

  msg <- ""
  if (!has_rocrate_class)
    msg <- "    - Missing 'rocrate' class.\n"
  if (missing_context)
    msg <- paste0(msg, "    - Missing @context.\n")
  if (!missing_context && !has_valid_context)
    msg <- paste0(msg, "    - Invalid value for @context: ", paste0(ro_crate_context, collapse = "; "), ".\n")
  if (missing_graph)
    msg <- paste0(msg, "    - Missing @graph.\n")
  if (!missing_graph && !valid_length_graph)
    msg <- paste0(msg, "    - The entities in @graph are NOT valid (e.g., missing @id and/or @type).\n")
  if (!missing_graph && !has_rocrate_meta)
    msg <- paste0(msg, "    - Missing the entity for the RO-Crate Metadata descriptor, ",
                  "@id = 'ro-crate-metadata.json'.\n")
  if (!missing_graph && !has_root)
    msg <- paste0(msg, "    - Missing the root entity, @id = './'.\n")
  if (nchar(msg) > 0) {
    stop("Invalid RO-Crate object! Try running `rocrateR::rocrate()`, first.\n",
         "  Identified issue(s):\n",
         msg)
  }

  # return (invisibly) the input RO-Crate
  return(invisible(rocrate))
}
