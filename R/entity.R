#' Add entity to RO-Crate
#'
#' @inheritParams is_rocrate
#' @param entity Entity object (list) that contains at least the following
#'     components: `@id` and `@type`. Alternatively, a list of entities.
#' @param overwrite Boolean flag to indicate if the entity (if found in the
#'     given RO-Crate) should be overwritten.
#' @param verbose Boolean flag to indicate if status messages should be hidden
#'     (default: `FALSE`).
#'
#' @returns Updated RO-Crate with the new entity.
#' @export
#'
#' @examples
#' basic_crate <- rocrateR::rocrate()
#'
#' # create entity for an organisation
#' organisation_uol <- rocrateR::entity(
#'   "https://ror.org/04xs57h96",
#'   type = "Organization",
#'   name = "University of Liverpool",
#'   url = "http://www.liv.ac.uk"
#' )
#'
#' # create an entity for a person
#' person_rvd <- rocrateR::entity(
#'   "https://orcid.org/0000-0001-5036-8661",
#'   type = "Person",
#'   name = "Roberto Villegas-Diaz",
#'   affiliation = list(`@id` = organisation_uol$`@id`)
#' )
#'
#' basic_crate_v2 <- basic_crate |>
#'   rocrateR::add_entity(person_rvd) |>
#'   rocrateR::add_entity_value(
#'     id = "./",
#'     key = "author",
#'     value = list(`@id` = person_rvd$`@id`)
#'   ) |>
#'   rocrateR::add_entity(organisation_uol)
add_entity <- function(rocrate, entity, overwrite = FALSE, verbose = FALSE) {
  # check the `rocrate` object
  is_rocrate(rocrate)

  if (!is.list(entity) || inherits(entity, "entity")) {
    entity <- list(entity)
  }

  for (ent in entity) {
    # validate entity
    .validate_entity(ent)

    # verify if the `entity` exists in the given crate
    id <- ent$`@id`
    idx <- .find_id_index(rocrate, id)

    if (any(idx)) {
      if (!overwrite) {
        stop(
          "The entity, `@id = '",
          getElement(entity, "@id"),
          "'`, is part of the RO-Crate, `rocrate`. \n",
          "Try a different `@id` or set `overwrite = TRUE`.",
          call. = FALSE
        )
      }

      if (verbose) {
        message("Overwriting entity with `@id = '", id, "'`")
      }

      rocrate$`@graph`[[which(idx)]] <- ent
    } else {
      if (verbose) {
        message("Adding entity with `@id = '", id, "'`")
      }

      rocrate$`@graph` <- c(rocrate$`@graph`, list(ent))
    }
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
#'   "https://ror.org/04xs57h96",
#'   type = "Organization",
#'   name = "University of Liverpool",
#'   url = "http://www.liv.ac.uk"
#' )
#'
#' # create an entity for a person
#' person_rvd <- rocrateR::entity(
#'   "https://orcid.org/0000-0001-5036-8661",
#'   type = "Person",
#'   name = "Roberto Villegas-Diaz",
#'   affiliation = list(`@id` = organisation_uol$`@id`)
#' )
#'
#' basic_crate_v2 <- basic_crate |>
#'   rocrateR::add_entity_value(
#'     id = "./",
#'     key = "author",
#'     value = list(`@id` = person_rvd$`@id`)
#'   )
add_entity_value <- function(rocrate, id, key, value, overwrite = TRUE) {
  # check the `rocrate` object
  is_rocrate(rocrate)

  # find the index in `@graph` with the matching {id}
  idx <- rocrate$`@graph` |>
    sapply(\(x) {
      getElement(x, "@id") == id && (overwrite || is.null(getElement(x, key)))
    })
  # verify that only one index was found for the matching {id}
  if (sum(idx) != 1) {
    stop(
      "Please, ensure the given {id} is unique and part of the RO-Crate.",
      call. = FALSE
    )
  }
  # set the new {value} for {key} associated to {id}
  # rocrate$`@graph`[idx][[1]][key] <- list(value)
  rocrate$`@graph`[[which(idx)]][[key]] <- value
  return(rocrate)
}

#' @rdname add_entity
#' @export
add_entities <- function(rocrate, entity, overwrite = FALSE, verbose = FALSE) {
  lifecycle::deprecate_warn(
    "0.2.0",
    "add_entities()",
    "add_entity()"
  )

  add_entity(
    rocrate = rocrate,
    entity = entity,
    overwrite = overwrite,
    verbose = verbose
  )
}

#' Create a data entity
#'
#' @param id Scalar value with `@id` for the entity (e.g., `character`,
#'     `numeric`).
#' @param type String with `@type` for the entity (e.g., `Dataset`, `File`).
#' @param ... Optional additional entity values/properties.
#'
#' @returns List with an entity object.
#' @export
#'
#' @examples
#' # create entity for an organisation
#' organisation_uol <- rocrateR::entity(
#'   "https://ror.org/04xs57h96",
#'   type = "Organization",
#'   name = "University of Liverpool",
#'   url = "http://www.liv.ac.uk"
#' )
#'
#' # create an entity for a person
#' person_rvd <- rocrateR::entity(
#'   "https://orcid.org/0000-0001-5036-8661",
#'   type = "Person",
#'   name = "Roberto Villegas-Diaz",
#'   affiliation = list(`@id` = organisation_uol$`@id`)
#' )
entity <- function(id, type, ...) {
  args <- list(...)

  # create entity and attach additional args
  new_entity <- c(list(`@id` = id, `@type` = type), args)

  .validate_entity(new_entity)
  new_entity <- structure(new_entity, class = c("entity", "list"))

  new_entity
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
#'   "https://ror.org/04xs57h96",
#'   type = "Organization",
#'   name = "University of Liverpool",
#'   url = "http://www.liv.ac.uk"
#' )
#'
#' # create an entity for a person
#' person_rvd <- rocrateR::entity(
#'   "https://orcid.org/0000-0001-5036-8661",
#'   type = "Person",
#'   name = "Roberto Villegas-Diaz",
#'   affiliation = list(`@id` = organisation_uol$`@id`)
#' )
#'
#' basic_crate_person <- basic_crate |>
#'   rocrateR::add_entity(person_rvd) |>
#'   rocrateR::add_entity_value(
#'     id = "./",
#'     key = "author",
#'     value = list(`@id` = person_rvd$`@id`)
#'   ) |>
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
    stop("You must provide a value for either `id` or `type`!", call. = FALSE)
  }

  # initialise local variables
  idx_by_id <- idx_by_type <- NULL

  # length validation / recycling rules
  if (!is.null(id) && !is.null(type)) {
    len_id <- length(id)
    len_type <- length(type)

    if (len_id > 1 && len_type > 1 && len_id != len_type) {
      stop(
        "`id` and `type` must have equal length, ",
        "or one of them must be length 1.",
        call. = FALSE
      )
    }

    # recycle shorter
    if (len_id == 1 && len_type > 1) {
      id <- rep(id, len_type)
    } else if (len_type == 1 && len_id > 1) {
      type <- rep(type, len_id)
    }
  }

  results <- list()

  if (!is.null(id) && !is.null(type)) {
    # case 1: both id and type
    for (i in seq_along(id)) {
      idx_id <- .find_id_index(rocrate, id[i])
      idx_type <- .find_type_index(rocrate, type[i])
      idx <- idx_id & idx_type

      if (any(idx)) {
        results <- c(
          results,
          rocrate$`@graph`[idx]
        )
      }
    }
  } else if (!is.null(id)) {
    # case 2: only id (possibly vector)
    idx <- .find_id_index(rocrate, id)
    if (any(idx)) {
      results <- rocrate$`@graph`[idx]
    }
  } else {
    # case 3: only type (possibly vector)
    idx <- .find_type_index(rocrate, type)
    if (any(idx)) {
      results <- rocrate$`@graph`[idx]
    }
  }

  if (length(results) > 0) {
    results <- lapply(results, function(x) {
      class(x) <- unique(c("entity", class(x)))
      x
    })
    return(results)
  }

  warning("No matching entities were found!", call. = FALSE)
  # return NULL invisibly, if no entities were found
  return(invisible(NULL))
}

#' Remove entity
#'
#' @inheritParams is_rocrate
#' @param entity Entity object (list) that contains at least the following
#'     components: `@id` and `@type`. Alternatively, a list of entities.
#' @param verbose Boolean flag to indicate if status messages should be hidden
#'     (default: `FALSE`).
#'
#' @returns Updated RO-Crate object.
#' @export
#'
#' @examples
#' basic_crate <- rocrateR::rocrate()
#'
#' # create entity for an organisation
#' organisation_uol <- rocrateR::entity(
#'   "https://ror.org/04xs57h96",
#'   type = "Organization",
#'   name = "University of Liverpool",
#'   url = "http://www.liv.ac.uk"
#' )
#'
#' # create an entity for a person
#' person_rvd <- rocrateR::entity(
#'   "https://orcid.org/0000-0001-5036-8661",
#'   type = "Person",
#'   name = "Roberto Villegas-Diaz",
#'   affiliation = list(`@id` = organisation_uol$`@id`)
#' )
#'
#' basic_crate_v2 <- basic_crate |>
#'   rocrateR::add_entity(person_rvd) |>
#'   rocrateR::add_entity_value(
#'     id = "./",
#'     key = "author",
#'     value = list(`@id` = person_rvd$`@id`)
#'   ) |>
#'   rocrateR::add_entity(organisation_uol) |>
#'   rocrateR::remove_entity(person_rvd)
remove_entity <- function(rocrate, entity, verbose = FALSE) {
  # check the `rocrate` object
  is_rocrate(rocrate)

  if (is.list(entity) && !inherits(entity, "entity")) {
    entity <- vapply(
      entity,
      function(x) {
        if (is.list(x)) x$`@id` else x
      },
      character(1)
    )
  }

  if (inherits(entity, "entity")) {
    entity <- entity$`@id`
  }

  ids <- as.character(entity)

  for (id in ids) {
    # verify if the `entity` exists in the given crate
    idx <- .find_id_index(rocrate, id)

    if (any(idx)) {
      if (verbose) {
        message("Removing the entity with `@id = '", id, "'`.")
      }

      rocrate$`@graph`[idx] <- NULL
    } else {
      warning(
        "No entity found with `@id = '",
        id,
        "'`.",
        call. = FALSE
      )
    }
  }

  return(rocrate)
}

#' @rdname remove_entity
#' @export
remove_entities <- function(rocrate, entity, verbose = TRUE) {
  lifecycle::deprecate_warn(
    "0.2.0",
    "remove_entities()",
    "remove_entity()"
  )

  remove_entity(
    rocrate = rocrate,
    entity = entity,
    verbose = verbose
  )
}
