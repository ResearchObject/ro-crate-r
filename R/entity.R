#' Add entity to RO-Crate
#'
#' @inheritParams is_rocrate
#' @param entity Entity object (list) that contains at least the following
#'     components: `@id` and `@type`.
#' @param overwrite Boolean flag to indicate if the entity (if found in the
#'     given RO-Crate) should be overwritten.
#'
#' @returns Updated RO-Crate with the new entity.
#' @export
#'
#' @examples
#' basic_crate <- rocrateR::rocrate()
#'
#' # create entity for an organisation
#' organisation_uol <- rocrateR::entity(
#'   x = "https://ror.org/04xs57h96",
#'   type = "Organization",
#'   name = "University of Liverpool",
#'   url = "http://www.liv.ac.uk"
#' )
#'
#' # create an entity for a person
#' person_rvd <- rocrateR::entity(
#'   x = "https://orcid.org/0000-0001-5036-8661",
#'   type = "Person",
#'   name = "Roberto Villegas-Diaz",
#'   affiliation = list(`@id` = organisation_uol$`@id`)
#' )
#'
#' basic_crate_v2 <- basic_crate |>
#'   rocrateR::add_entity(person_rvd) |>
#'   rocrateR::add_entity_value(id = "./", key = "author", value = list(`@id` = person_rvd$`@id`)) |>
#'   rocrateR::add_entity(organisation_uol)
add_entity <- function(rocrate, entity, overwrite = FALSE) {
  # check the `rocrate` object
  is_rocrate(rocrate)

  # validate entity
  .validate_entity(entity)

  # verify if the `entity` exists in the given crate
  idx <- .find_id_index(rocrate, getElement(entity, "@id"))

  if (sum(idx) > 0) {
    if (!overwrite) {
      stop("The entity, `@id = '", getElement(entity, "@id"),
           "'`, is part of the RO-Crate, `rocrate`. \n",
           "Try a different `@id` or set `overwrite = TRUE`.")
    }
    warning("Overwritting the entity with @id = '",
            getElement(entity, "@id"), "'")

    rocrate$`@graph`[idx][[1]] <- entity
  }
  else {
    rocrate$`@graph` <- c(rocrate$`@graph`, list(entity))
  }

  return(rocrate)
}

#' Add entity value to RO-Crate
#'
#' Add entity value to RO-Crate, under entity with `@id` = `{id}`, using the
#' pair `{key}`-`{value}` within `@graph`.
#'
#' @inheritParams is_rocrate
#' @param id String with the ID of the RO-Crate entity within `@graph`.
#' @param key String with the `key` of the entity with `id` to be modified.
#' @param value String with the `value` for `key`.
#' @param overwrite Boolean flag to indicate if the existing value (if any),
#'     should be overwritten (default: `TRUE`).
#'
#' @returns RO-Crate object.
#' @export
#'
#' @examples
#' basic_crate <- rocrate()
#'
#' # create entity for an organisation
#' organisation_uol <- rocrateR::entity(
#'   x = "https://ror.org/04xs57h96",
#'   type = "Organization",
#'   name = "University of Liverpool",
#'   url = "http://www.liv.ac.uk"
#' )
#'
#' # create an entity for a person
#' person_rvd <- rocrateR::entity(
#'   x = "https://orcid.org/0000-0001-5036-8661",
#'   type = "Person",
#'   name = "Roberto Villegas-Diaz",
#'   affiliation = list(`@id` = organisation_uol$`@id`)
#' )
#'
#' basic_crate_v2 <- basic_crate |>
#'   rocrateR::add_entity_value(id = "./", key = "author", value = list(`@id` = person_rvd$`@id`))
add_entity_value <- function(rocrate, id, key, value, overwrite = TRUE) {
  # check the `rocrate` object
  is_rocrate(rocrate)

  # find the index in `@graph` with the matching {id}
  idx <- rocrate$`@graph` |>
    sapply(\(x) getElement(x, "@id") == id && (overwrite || is.null(getElement(x, key))))
  # verify that only one index was found for the matching {id}
  if(sum(idx) != 1) {
    stop("Please, ensure the given {id} is unique and part of the RO-Crate.")
  }
  # set the new {value} for {key} associated to {id}
  rocrate$`@graph`[idx][[1]][key] <- list(value)
  return(rocrate)
}

#' Wrapper for \link[rocrateR]{add_entity}
#' 
#' Wrapper for \link[rocrateR]{add_entity}, can be use to add multiple entities.
#'
#' @inheritParams add_entity
#' @param entity List with entity objects.
#' @param quiet Boolean flag to indicate if status messages should be hidden
#'     (default: `FALSE`).
#'
#' @returns Updated RO-Crate with the new entities.
#' @export
add_entities <- function(rocrate, entity, overwrite = FALSE, quiet = FALSE) {
  for (i in seq_along(entity)) {
    if (!quiet) {
      # extract entity @id, if missing, then use index, `i`
      ent_id <- getElement(entity[[i]], "@id")
      ent_id <- ifelse(is.null(ent_id), 
                       paste0("with index=", i), 
                       paste0("with @id='", ent_id, "'")
                       )
      message("Adding entity ", ent_id, "...\n")
    }
    # call the add_entity function
    rocrate <- rocrate |>
      rocrateR::add_entity(entity[[i]], overwrite = overwrite)
  }
  return(rocrate)
}

#' Create a data entity
#'
#' @param x New entity. If a single value (e.g., `character`, `numeric`) is
#'     given, this is assumed to be the entity's `@id`, if a `list` is given,
#'     this is assumed to be a complete entity. Other options are objects of
#'     type `person` and `organisation` (equivalently `organization`).
#' @param ... Optional additional entity values/properties. Used when `x` is
#'     a single value.
#'
#' @returns List with an entity object.
#' @export
#'
#' @examples
#' # create entity for an organisation
#' organisation_uol <- rocrateR::entity(
#'   x = "https://ror.org/04xs57h96",
#'   type = "Organization",
#'   name = "University of Liverpool",
#'   url = "http://www.liv.ac.uk"
#' )
#'
#' # create an entity for a person
#' person_rvd <- rocrateR::entity(
#'   x = "https://orcid.org/0000-0001-5036-8661",
#'   type = "Person",
#'   name = "Roberto Villegas-Diaz",
#'   affiliation = list(`@id` = organisation_uol$`@id`)
#' )
#'
entity <- function(x, ...) {
  .validate_entity(x, ...)
  UseMethod("entity", x)
}

#' @export
entity.default <- function(x, ...) {
  args <- list(...)
  new_entity <- list(
    `@id` = c(x, getElement(args, "id"))[1],
    `@type` = getElement(args, "type")
  ) |>
    # append any additional properties
    c(suppressWarnings(within(args, rm(id, type))))
  # attach 'entity' as a new class
  class(new_entity) <- c("entity", class(new_entity))
  return(new_entity)
}

#' Get entity(ies)
#'
#' @inheritParams is_rocrate
#' @param id String with the ID of the RO-Crate entity within `@graph` 
#'     (optional if `type` is provided). Alternatively, an entity object / list
#'     with `@id` and `@type`.
#' @param type String with the type of the RO-Crate entity(ies) within `@graph`
#'     to retrieve (optional if `id` is provided).
#'
#' @returns List with found entity object(s), if any, `NULL` otherwise.
#' @export
#' 
#' @examples
#' basic_crate <- rocrateR::rocrate()
#'
#' # create entity for an organisation
#' organisation_uol <- rocrateR::entity(
#'   x = "https://ror.org/04xs57h96",
#'   type = "Organization",
#'   name = "University of Liverpool",
#'   url = "http://www.liv.ac.uk"
#' )
#'
#' # create an entity for a person
#' person_rvd <- rocrateR::entity(
#'   x = "https://orcid.org/0000-0001-5036-8661",
#'   type = "Person",
#'   name = "Roberto Villegas-Diaz",
#'   affiliation = list(`@id` = organisation_uol$`@id`)
#' )
#'
#' basic_crate_person <- basic_crate |>
#'   rocrateR::add_entity(person_rvd) |>
#'   rocrateR::add_entity_value(id = "./", key = "author", value = list(`@id` = person_rvd$`@id`)) |>
#'   rocrateR::add_entity(organisation_uol) |>
#'   rocrateR::get_entity(person_rvd)
#'   
#' basic_crate_person[[1]]$name == person_rvd$name
#' basic_crate_person[[1]]$`@id` == person_rvd$`@id`
get_entity <- function(rocrate, id = NULL, type = NULL) {
  # check the `rocrate` object
  is_rocrate(rocrate)
  
  # if `id` is given as an entity object / list, extract @id and @type
  if (is.list(id)) {
    type <- getElement(id, "@type")
    id <- getElement(id, "@id")
  }
  
  # check that either `id` or `type` were provided
  if (all(is.null(id), is.null(type))) {
    stop("You must provide a value for either `id` or `type`!",
         call. = FALSE)
  }
  
  # initialise local variables
  idx_by_id <- idx_by_type <- NULL
  
  # if `id` was provided, then find elements with that @id
  if (!is.null(id)) {
    idx_by_id <- .find_id_index(rocrate, id)
  }
  # if `type` was provided, then find elements with that @type
  if (!is.null(type)) {
    idx_by_type <- .find_type_index(rocrate, type)
  }
  
  # combine (if both id and type were provided) the indices
  idx <- NULL
  if (!is.null(id) && !is.null(type)) {
    idx <- idx_by_id & idx_by_type
  } else if (!is.null(id)) {
    idx <- idx_by_id
  } else if (!is.null(type)) {
    idx <- idx_by_type
  }
  if (sum(idx) > 0) { # at least one entity was found
    matching_entities <- rocrate$`@graph`[idx] |>
      lapply(function(x) {
        class(x) <- unique(c("entity", class(x)))
        return(x)
      })
    return(matching_entities)
  } else {
    msg <- "No entities were found with "
    msg_id <- paste0("@id = '", id, "'")
    msg_type <- paste0("@type = '", type, "'")
    warning(msg,
            ifelse(is.null(id), "", msg_id),
            ifelse(!is.null(id) && !is.null(type), " and ", ""),
            ifelse(is.null(type), "", msg_type),
            "!",
            call. = FALSE)
  }
  
  # return NULL invisibly, if no entities were found
  return(invisible(NULL))
}

#' Remove entity
#'
#' @inheritParams is_rocrate
#' @param entity Entity object (list) that contains at least the following
#'     components: `@id` and `@type`. Or, scalar value with entity `@id`.
#'
#' @returns Updated RO-Crate object.
#' @export
#'
#' @examples
#' basic_crate <- rocrateR::rocrate()
#'
#' # create entity for an organisation
#' organisation_uol <- rocrateR::entity(
#'   x = "https://ror.org/04xs57h96",
#'   type = "Organization",
#'   name = "University of Liverpool",
#'   url = "http://www.liv.ac.uk"
#' )
#'
#' # create an entity for a person
#' person_rvd <- rocrateR::entity(
#'   x = "https://orcid.org/0000-0001-5036-8661",
#'   type = "Person",
#'   name = "Roberto Villegas-Diaz",
#'   affiliation = list(`@id` = organisation_uol$`@id`)
#' )
#'
#' basic_crate_v2 <- basic_crate |>
#'   rocrateR::add_entity(person_rvd) |>
#'   rocrateR::add_entity_value(id = "./", key = "author", value = list(`@id` = person_rvd$`@id`)) |>
#'   rocrateR::add_entity(organisation_uol) |>
#'   rocrateR::remove_entity(person_rvd)
remove_entity <- function(rocrate, entity) {
  # check the `rocrate` object
  is_rocrate(rocrate)

  if (is.list(entity)) {
    entity_id <- getElement(entity, "@id")
  } else {
    entity_id <- entity
  }

  # verify if the `entity` exists in the given crate
  idx <- .find_id_index(rocrate, entity_id)

  if (sum(idx) > 0) {
    message("Removing the entity with @id = '",
            entity_id, "'.")
    rocrate$`@graph`[idx] <- NULL
  } else {
    warning("No entity found with @id = '", entity_id, "'.")
  }

  return(rocrate)
}

#' Wrapper for \link[rocrateR]{remove_entity}
#' 
#' Wrapper for \link[rocrateR]{remove_entity}, can be use to remove multiple 
#' entities.
#'
#' @inheritParams remove_entity
#'
#' @returns Updated RO-Crate.
#' @export
remove_entities <- function(rocrate, entity) {
  for (i in seq_along(entity)) {
    # call the add_entity function
    rocrate <- rocrate |>
      rocrateR::remove_entity(entity[[i]])
  }
  return(rocrate)
}
