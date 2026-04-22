#' Add an author to an RO-Crate
#'
#' This helper creates an author entity and if `affiliation` is provided, then
#' creates an organisation entity for the user's affiliation.
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#' @param name Author's name.
#' @param orcid Optional, ORCID identifier, for details see
#'     \url{https://orcid.org}.
#' @param affiliation Optional, author's organisation.
#' @param ror Optional, ROR identifier for the affiliation, for details see
#'     \url{https://ror.org}.
#' @param set_author Logical, used to indicate if the current user should be set
#'     as the author of the RO-Crate.
#'
#' @returns Updated RO-Crate object.
#' @export
add_author <- function(
  rocrate,
  name,
  orcid = NULL,
  affiliation = NULL,
  ror = NULL,
  set_author = TRUE
) {
  # create person entity
  person_id <- if (!is.null(orcid)) {
    paste0("https://orcid.org/", orcid)
  } else {
    paste0("#", gsub(" ", "_", tolower(name)))
  }

  person <- rocrateR::entity(
    person_id,
    type = "Person",
    name = name
  )

  # check if affiliation was provided
  if (!is.null(affiliation)) {
    org_id <- if (!is.null(ror)) {
      paste0("https://ror.org/", gsub("^https://ror.org/", "", ror))
    } else {
      paste0("#org-", gsub(" ", "_", affiliation))
    }

    org <- rocrateR::entity(
      org_id,
      type = "Organization",
      name = affiliation
    )

    person$affiliation <- list(`@id` = org_id)

    rocrate <- rocrate |>
      rocrateR::add_entity(org)
  }

  rocrate <- rocrate |>
    rocrateR::add_entity(person)

  if (set_author) {
    rocrate <- rocrate |>
      rocrateR::add_entity_value(
        id = "./",
        key = "author",
        value = list(list("@id" = person_id))
      )
  }

  return(rocrate)
}

#' Add a dataset to an RO-Crate
#'
#' This helper converts an R object (typically a `data.frame`) into a
#' dataset inside the RO-Crate. The object is stored in the `content`
#' field and written to disk when calling `extract_content()` or
#' `bag_rocrate(write_content = TRUE)`.
#'
#' Use this when you want to register a dataset file or directory
#' as a formal Dataset entity inside the RO-Crate metadata.
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#' @param file_id Filename for the dataset file.
#' @param data R object to store (typically a `data.frame`).
#' @param name Dataset name.
#' @param description Optional dataset description.
#' @param encodingFormat MIME type (default `"text/csv"`).
#'
#' @returns Updated RO-Crate object.
#' @export
add_dataset <- function(
  rocrate,
  file_id,
  data = NULL,
  name = NULL,
  description = NULL,
  encodingFormat = "text/csv"
) {
  if (missing(file_id)) {
    stop("file_id must be provided")
  }

  if (is.null(name)) {
    name <- file_id
  }

  # create File entity
  file_entity <- rocrateR::entity(
    file_id,
    type = "File",
    name = file_id,
    encodingFormat = encodingFormat,
    content = data
  )

  # create Dataset entity that contains the file
  dataset_id <- paste0(
    "#dataset-",
    tools::file_path_sans_ext(basename(file_id))
  )

  dataset_entity <- rocrateR::entity(
    dataset_id,
    type = "Dataset",
    name = name,
    description = description,
    hasPart = list(list(`@id` = file_id))
  )

  # add File and Dataset entities to the rocrate
  rocrate |>
    rocrateR::add_entity(file_entity) |>
    rocrateR::add_entity(dataset_entity)
}

#' Add a notebook to an RO-Crate
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#' @param file_id Optional, notebook's filename.
#' @param name Optional, notebook's name.
#' @param content Optional, notebook's content.
#'
#' @returns Updated RO-Crate object.
#' @export
add_notebook <- function(rocrate, file_id, name = NULL, content = NULL) {
  if (is.null(name)) {
    name <- file_id
  }

  ext <- tools::file_ext(file_id)

  encoding <- switch(
    tolower(ext),
    "ipynb" = "application/x-ipynb+json",
    "rmd" = "text/markdown",
    "qmd" = "text/markdown",
    "md" = "text/markdown",
    "text/plain"
  )

  # create notebook entity
  ent <- rocrateR::entity(
    file_id,
    type = "File",
    name = name,
    encodingFormat = encoding,
    content = content
  )

  rocrate |>
    rocrateR::add_entity(ent)
}

#' Add project metadata
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#' @param name Project's name.
#' @param description Optional, project's description.
#'
#' @returns Updated RO-Crate object.
#' @export
add_project <- function(rocrate, name, description = NULL) {
  id <- paste0("#project-", gsub(" ", "_", tolower(name)))

  # create project entity
  proj <- rocrateR::entity(
    id,
    type = "Project",
    name = name,
    description = description
  )

  rocrate |>
    rocrateR::add_entity(proj)
}

#' Add README file to an RO-Crate
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#' @param text Character vector with README content.
#' @param filename README filename.
#'
#' @returns Updated RO-Crate object.
#' @export
add_readme <- function(
  rocrate,
  text,
  filename = "README.md"
) {
  # create README entity
  ent <- rocrateR::entity(
    filename,
    type = "File",
    name = filename,
    encodingFormat = "text/markdown",
    content = list(text)
  )

  rocrate |>
    rocrateR::add_entity(ent)
}

#' Add software application entity
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#' @param name Software name.
#' @param version Version string.
#'
#' @returns Updated RO-Crate object.
#' @export
add_software <- function(rocrate, name, version = NULL) {
  id <- paste0("#software-", gsub(" ", "_", tolower(name)))

  # create SoftwareApplication entity
  sw <- rocrateR::entity(
    id,
    type = "SoftwareApplication",
    name = name,
    version = version
  )

  # add new entity to the RO-Crate
  rocrate |>
    rocrateR::add_entity(sw)
}

#' Add a workflow to an RO-Crate
#'
#' Register a workflow script (e.g. R, Python, Nextflow) as a
#' `ComputationalWorkflow` entity inside the RO-Crate.
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#' @param file_id Filename of the workflow script.
#' @param name Workflow name.
#' @param description Optional description.
#' @param language Programming language (default `"R"`).
#' @param content Optional script contents.
#'
#' @returns Updated RO-Crate object.
#' @export
add_workflow <- function(
  rocrate,
  file_id,
  name = NULL,
  description = NULL,
  language = "R",
  content = NULL
) {
  if (missing(file_id)) {
    stop("file_id must be provided")
  }

  if (is.null(name)) {
    name <- file_id
  }

  # create File entity for the workflow scripts
  file_entity <- rocrateR::entity(
    file_id,
    type = "File",
    name = file_id,
    encodingFormat = "text/plain",
    content = content
  )

  # create ComputerLanguage entity for the workflow scripts language
  lang_id <- paste0("#lang-", tolower(language))
  language_entity <- rocrateR::entity(
    lang_id,
    type = "ComputerLanguage",
    name = language
  )

  # create ComputationalWorkflow entity
  wf_id <- paste0("#workflow-", tools::file_path_sans_ext(basename(file_id)))
  workflow_entity <- rocrateR::entity(
    wf_id,
    type = "ComputationalWorkflow",
    name = name,
    description = description,
    programmingLanguage = list(`@id` = lang_id),
    hasPart = list(list(`@id` = file_id))
  )

  # add new entities to the RO-Crate
  rocrate |>
    rocrateR::add_entity(file_entity) |>
    rocrateR::add_entity(language_entity) |>
    rocrateR::add_entity(workflow_entity)
}

#' Automatically create an RO-Crate from a project directory
#'
#' @param path String with project directory.
#'
#' @returns RO-Crate object for the project given by `path`.
#' @export
crate_project <- function(path = NULL) {
  # create basic RO-Crate
  rocrate <- rocrateR::rocrate()

  # if path is missing, just return a basic RO-Crate
  if (is.null(path)) {
    return(rocrate)
  }

  # list files inside path
  files <- list.files(path, recursive = TRUE)

  # loop through the files in `path`, create and add entities for each
  for (f in files) {
    ext <- tolower(tools::file_ext(f))

    if (ext %in% c("csv")) {
      rocrate <- rocrate |>
        rocrateR::add_dataset(
          file_id = f,
          data = utils::read.csv(file.path(path, f))
        )
    } else if (ext %in% c("r")) {
      rocrate <- rocrate |>
        rocrateR::add_workflow(
          file_id = f
        )
    } else if (ext %in% c("rmd", "qmd", "ipynb")) {
      rocrate <- rocrate |>
        rocrateR::add_notebook(
          file_id = f
        )
    } else {
      rocrate <- rocrate |>
        rocrateR::add_entity(
          rocrateR::entity(
            f,
            type = "File"
          )
        )
    }
  }

  rocrate
}

#' Extract `File` entities content to files
#'
#' Write the `content` field of `File` entities to disk using their `@id`
#' as the filename.
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#' @param path Directory where files will be written. RO-Crate root.
#' @param overwrite Logical. Overwrite existing files.
#'
#' @returns Invisibly returns updated `rocrate` without contents.
#' @export
extract_content <- function(rocrate, path, overwrite = FALSE) {
  # check if the path exists
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }

  # get 'File' entities with missing `content` (if any)
  ## ignore warnings about not finding `File` entities
  suppressWarnings({
    file_ents <- rocrate |>
      rocrateR::get_entity(type = "File") |>
      (\(.) Filter(f = function(x) !is.null(x$content), x = .))()
  })
  # cycle through each File entity (if any) and attempt writing contents
  for (ent in file_ents) {
    file <- file.path(path, ent$`@id`)

    # check if the file exists and the `overwrite` arg
    if (file.exists(file) && !overwrite) {
      next
    }

    content <- ent$content
    fmt <- ent$encodingFormat
    fmt <- ifelse(is.null(fmt), "", fmt)

    tryCatch(
      {
        switch(
          fmt,
          "text/csv" = utils::write.csv(content, file, row.names = FALSE),
          "application/json" = jsonlite::write_json(
            content,
            file,
            auto_unbox = TRUE,
            pretty = TRUE
          ),
          writeLines(as.character(content), file)
        )

        # remove content from RO-Crate entity
        idx <- .find_id_index(rocrate, basename(file))
        if (any(idx)) {
          rocrate$`@graph`[[which(idx)]]$content <- NULL
        }
      },
      error = function(e) NULL
    )
  }

  invisible(rocrate)
}

#' Check if object is an RO-Crate
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#' @param strict Boolean to indicate if stricter checks should be done (e.g.,
#'     check profile specification).
#' @param error Boolean to indicate if the function should throw an error, if
#'     any errors are found (default: `TRUE`).
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
is_rocrate <- function(rocrate, strict = FALSE, error = TRUE) {
  # call internal helper to identify errors
  errors <- .validate_rocrate(rocrate, strict = strict)

  if (length(errors)) {
    if (error) {
      stop(
        paste("Invalid RO-Crate:\n", paste(" - ", errors, collapse = "\n")),
        call. = FALSE
      )
    } else {
      return(FALSE)
    }
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
#' @param ... Reserved for future extensions.
#' @param verbose Logical. If `TRUE`, emit diagnostic messages.
#' @param bagit_version String with version of BagIt used to generate the
#'     RO-Crate bag (default: `"1.0"`).
#'     See \doi{10.17487/RFC8493} for more details.
#' @param load_content Logical. If `TRUE` , attempt to load external file
#'     contents into the `content` field for entities of type `File`.
#' @param max_file_size Maximum file size (bytes) allowed when loading
#'   content. Default 10MB.
#'
#' @returns An RO-Crate object.
#' @export
#'
#' @examples
#' # -------- SETUP --------
#' basic_crate <- rocrateR::rocrate()
#' # temp file
#' tmp_dir <- file.path(tempdir(), digest::digest(basename(tempfile())))
#' tmp <- file.path(tmp_dir, "ro-crate-metadata.json")
#' dir.create(tmp_dir)
#'
#' # -------- INPUT: RO-Crate --------
#' rocrateR::load_rocrate(basic_crate, verbose = TRUE)
#'
#' # -------- INPUT: Path --------
#' # save RO-Crate
#' rocrateR::write_rocrate(basic_crate, path = tmp)
#'
#' # load RO-Crate
#' ## with file name
#' rocrateR::load_rocrate(tmp, verbose = TRUE)
#'
#' ## with directory
#' rocrateR::load_rocrate(tmp_dir, verbose = TRUE)
#'
#' # delete temp directory
#' unlink(tmp_dir, recursive = TRUE)
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
  verbose = FALSE,
  bagit_version = "1.0",
  load_content = FALSE,
  max_file_size = 10 * 1024^2
) {
  if (!file.exists(x)) {
    stop("The provided path does not exist.", call. = FALSE)
  }

  if (verbose) {
    message("Detecting RO-Crate input type...")
  }

  # case 1: direct metadata file
  if (grepl("\\.json$", x)) {
    if (verbose) {
      message("Detected metadata JSON file.")
    }

    rocrate <- .read_rocrate_json(x)

    # check if the user request to load content from File entities
    if (isTRUE(load_content)) {
      rocrate <- .load_content(rocrate, dirname(x), max_file_size)
    }

    return(rocrate)
  }

  # case 2: zip archive
  if (!dir.exists(x) && grepl("\\.zip$", x, ignore.case = TRUE)) {
    if (verbose) {
      message("Detected ZIP archive. Extracting...")
    }

    rocrate <- .load_rocrate_bag(
      x,
      bagit_version = bagit_version,
      load_content = load_content,
      max_file_size = max_file_size
    )

    return(rocrate)
  }

  # case 3: directory
  if (dir.exists(x)) {
    # BagIt directory
    if (file.exists(file.path(x, "bagit.txt"))) {
      if (verbose) {
        message("Detected BagIt directory.")
      }

      rocrate <- .load_rocrate_bag(
        x,
        bagit_version = bagit_version,
        load_content = load_content,
        max_file_size = max_file_size
      )

      return(rocrate)
    }

    # Plain RO-Crate directory
    metadata_path <- file.path(x, "ro-crate-metadata.json")

    if (file.exists(metadata_path)) {
      if (verbose) {
        message("Detected plain RO-Crate directory.")
      }

      rocrate <- .read_rocrate_json(metadata_path)

      # check if the user request to load content from File entities
      if (isTRUE(load_content)) {
        rocrate <- .load_content(rocrate, dirname(metadata_path), max_file_size)
      }

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
#' @returns A `rocrate_validation` object (in report mode).
#' @export
#'
#' @examples
#' # -------- SETUP --------
#' basic_crate <- rocrateR::rocrate()
#' # temp file
#' tmp_dir <- file.path(tempdir(), digest::digest(basename(tempfile())))
#' tmp <- file.path(tmp_dir, "ro-crate-metadata.json")
#' dir.create(tmp_dir)
#'
#' # -------- INPUT: RO-Crate --------
#' rocrateR::validate_rocrate(basic_crate)
#'
#' # -------- INPUT: Path --------
#' # save RO-Crate
#' rocrateR::write_rocrate(basic_crate, path = tmp)
#'
#' ## with file name
#' rocrateR::validate_rocrate(tmp)
#'
#' ## with directory
#' rocrateR::validate_rocrate(tmp_dir)
#'
#' # -------- INPUT: Invalid RO-Crate --------
#' structure(list(), class = "rocrate") |>
#'   rocrateR::validate_rocrate(mode = "report")
#'
#' # delete temp directory
#' unlink(tmp_dir, recursive = TRUE)
validate_rocrate <- function(
  x,
  mode = c("stop", "report"),
  strict = FALSE
) {
  # validation reporting mode
  mode <- match.arg(mode)

  # load the RO-Crate
  rocrate <- load_rocrate(x)

  # validate the RO-Crate
  errors <- .validate_rocrate(rocrate, strict = strict)

  # create validation report
  result <- new_rocrate_validation(errors = errors)

  if (mode == "stop" && length(result$errors) != 0) {
    stop(paste(result$errors, collapse = "\n"), call. = FALSE)
  }

  result
}

#' Get root entity for RO-Crate
#'
#' @inheritParams is_rocrate
#'
#' @returns Root entity for `rocrate`.
#' @keywords internal
#' @noRd
.get_root_entity <- function(rocrate) {
  graph <- rocrate$`@graph`
  ids <- .get_entity_ids(rocrate)

  root_idx <- which(ids == "./")

  if (length(root_idx) == 0) {
    return(NULL)
  }

  graph[[root_idx]]
}

#' Get entity IDs for RO-Crate
#'
#' @inheritParams is_rocrate
#'
#' @returns Vector entity IDs for `rocrate`.
#' @keywords internal
#' @noRd
.get_entity_ids <- function(rocrate) {
  graph <- rocrate$`@graph`
  vapply(graph, function(x) as.character(x$`@id`), character(1))
}

#' Load RO-Crate contents for File entities
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#' @param roc_path String with path to the root of the RO-Crate.
#' @param max_file_size Maximum size of file to be loaded.
#'
#' @returns Updated `rocrate` object with contents loaded from external files.
#' @keywords internal
#' @noRd
.load_content <- function(rocrate, roc_path, max_file_size = 10 * 1024^2) {
  # get 'File' entities with missing `content` (if any)
  ## ignore warnings about not finding `File` entities
  suppressWarnings({
    file_ents <- rocrate |>
      rocrateR::get_entity(type = "File") |>
      (\(.) Filter(f = function(x) is.null(x$content), x = .))()
  })
  # attempt loading contents, if any entities were found
  for (ent in file_ents) {
    # attach the root of the RO-Crate to the current File entity
    file <- file.path(roc_path, ent$`@id`)

    # check if the file exists
    if (!file.exists(file)) {
      next
    }
    # check if the file size is greater than `max_file_size`
    if (file.size(file) > max_file_size) {
      next
    }

    content <- tryCatch(
      {
        fmt <- ent$encodingFormat
        fmt <- ifelse(is.null(fmt), "", fmt)

        switch(
          fmt,
          "text/csv" = utils::read.csv(file),
          "application/json" = jsonlite::read_json(file),
          "text/plain" = readLines(file),
          readLines(file)
        )
      },
      error = function(e) NULL
    )

    # update entity within the RO-Crate
    if (!is.null(content)) {
      rocrate <- rocrate |>
        rocrateR::add_entity_value(
          id = ent$`@id`,
          key = "content",
          value = ifelse(is.list(content), content, list(content)),
          overwrite = TRUE
        )
    }
  }

  # return updated object
  return(rocrate)
}

#' Validate minimal RO-Crate structure
#'
#' Ensures required top-level fields are present.
#'
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#'
#' @returns Character vector of errors.
#' @keywords internal
#' @noRd
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
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#'
#' @returns Character vector of errors.
#' @keywords internal
#' @noRd
.validate_semantics <- function(rocrate) {
  errors <- character()

  graph <- rocrate$`@graph`

  if (!is.list(graph)) {
    return(c(errors, "'@graph' must be a list."))
  }

  ids <- .get_entity_ids(rocrate)

  # check root dataset exists
  if (!"./" %in% ids) {
    errors <- c(errors, "Missing root Dataset with '@id' = './'.")
  }

  # check duplicated IDs
  if (any(duplicated(ids))) {
    errors <- c(errors, "Duplicated '@id' values detected in '@graph'.")
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
#' @noRd
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
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#'
#' @returns Character vector of errors.
#' @keywords internal
#' @noRd
.validate_rocrate_profile <- function(rocrate) {
  # local binding
  errors <- character()

  root <- .get_root_entity(rocrate)

  if (is.null(root)) {
    return(errors)
  }

  conforms_to <- root$conformsTo

  if (is.null(conforms_to)) {
    return(errors)
  }

  # Normalise to character vector of URLs
  profile_urls <- unlist(lapply(conforms_to, function(x) {
    if (is.list(x)) x$`@id` else x
  }))

  for (url in profile_urls) {
    profile <- .rocrate_profiles[[url]]

    # Skip unknown profiles silently
    if (is.null(profile)) {
      next
    }

    errors <- c(
      errors,
      .validate_against_profile(rocrate, profile)
    )
  }

  errors
}
