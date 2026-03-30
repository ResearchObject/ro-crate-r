#' Bag the contents of an RO-Crate
#'
#' Bag the contents of an RO-Crate using the BagIt file packaging format v1.0.
#' For more details see the definition:
#' \doi{10.17487/RFC8493}
#'
#' @param x A string to a path containing at the very minimum an RO-Crate
#'     metadata descriptor file, `ro-crate-metadata.json`. Alternatively, an
#'     object with the \link[rocrateR]{rocrate} class.
#' @param ... Additional parameters, see below.
#' @param path String with path to the root of the RO-Crate.
#' @param overwrite Boolean flag to indicate if the RO-Crate metadata descriptor
#'     file should be overwritten if already inside `path` (default: `FALSE`).
#' @param output String with path where the RO-Crate bag will be stored
#'     (default: `x` - same path as the input value).
#' @param force_bag Boolean flag to indicate whether the force the creation of
#'     a 'bag' even if not all the files were successfully bagged
#'     (default: `FALSE` ~ check if all the files were copied successfully).
#' @param extra_bag_info Vector of strings to include in the `bag-info.txt`
#'     file (e.g., `Contact-Email: first.last@rocrate.org`).
#' @param write_content Logical. If TRUE, write `content` fields of
#'   `File` entities to disk before bagging.
#' @param create_dir Boolean flag to indicate if the `path` should be created,
#'    if it doesn't exist.
#'
#' @returns String with full path to the final RO-Crate bag.
#'
#' @export
#'
#' @family RO-Crate BagIt archive functions
#' @examples
#' # -------- SETUP --------
#' basic_crate <- rocrateR::rocrate()
#' # temp file
#' tmp_dir <- file.path(tempdir(), digest::digest(basename(tempfile())))
#' tmp <- file.path(tmp_dir, "ro-crate-metadata.json")
#' dir.create(tmp_dir)
#'
#' # -------- INPUT: RO-Crate --------
#' rocrateR::bag_rocrate(basic_crate, path = tmp_dir)
#'
#' # -------- INPUT: Path --------
#' rocrateR::bag_rocrate(tmp_dir, output = tmp_dir)
#'
#' # delete temp directory
#' unlink(tmp_dir, recursive = TRUE)
bag_rocrate <- function(x, ...) {
  UseMethod("bag_rocrate", x)
}

#' @rdname bag_rocrate
#' @export
bag_rocrate.character <- function(
  x,
  ...,
  output = x,
  force_bag = FALSE,
  extra_bag_info = NULL
) {
  # check a valid path was given
  if (!dir.exists(x)) {
    stop(
      "The given path, `x`, does not exist!\n",
      "Create with:\n\t`mkdir ",
      x,
      "`",
      call. = FALSE
    )
  }

  # list all the files inside the given path
  rocrate_files <- list.files(x, recursive = TRUE)

  # check if the given path is empty
  if (length(rocrate_files) == 0) {
    stop("No files were found inside the given path: \n", x, call. = FALSE)
  }

  # create an RO-Crate ID
  rocrate_id <- .create_rocrate_id()

  # create temporary directory, including `rocrate_id`
  tmp_dir <- file.path(tempdir(), rocrate_id, "data")

  # create sub-directories
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)
  on.exit(unlink(dirname(tmp_dir), recursive = TRUE, force = TRUE))

  # copy files inside the temporary directory
  rocrate_files_status <- rocrate_files |>
    vapply(
      function(f) {
        # ensure the target sub-directory exists
        dir.create(
          dirname(file.path(tmp_dir, f)),
          showWarnings = FALSE,
          recursive = TRUE
        )
        # create copy of file
        .copy_file(file.path(x, f), file.path(tmp_dir, f), overwrite = TRUE)
      },
      logical(1)
    )

  # check that all the files were copied, unless force_bag = TRUE
  if (!all(rocrate_files_status)) {
    failed <- rocrate_files[!rocrate_files_status]
    copied <- rocrate_files[rocrate_files_status]

    if (!force_bag) {
      stop(
        "It was not possible to bag all your files!\nMissing file(s):\n",
        paste0(" - ", failed, collapse = "\n"),
        "\n\nTo ignore this check, set `force_bag = TRUE`.",
        call. = FALSE
      )
    }
    warning(
      "Forcing the creation of the RO-Crate bag! ",
      "Note that this will ignore checking if all files were copied",
      "into the RO-Crate bag",
      call. = FALSE
    )

    # update list of files that will be included in the RO-Crate bag
    rocrate_files <- copied
  }

  # create bag declaration
  .bagit_declaration(tmp_dir)

  # create bag manifest and stored one level above `tmp_dir`
  if (length(rocrate_files) > 0) {
    .bagit_manifest(tmp_dir, rocrate_files)
  }

  # create bag info
  .bagit_info(tmp_dir, rocrate_files, extra_bag_info)

  # create BagIt tagmanifest
  .bagit_tagmanifest(
    dirname(tmp_dir),
    list.files(dirname(tmp_dir), pattern = "txt$")
  )

  # create BagIt fetch file
  .bagit_fetch(tmp_dir, rocrateR::load_rocrate(x))

  # compress bag contents inside original path
  output_bag <- file.path(output, paste0(rocrate_id, ".zip"))
  ## create version of `output_bag` with absolute/normalised path
  output_bag_nor <- file.path(normalizePath(output), paste0(rocrate_id, ".zip"))
  ## list files within the `tmp_dir`
  bag_files <- list.files(
    dirname(tmp_dir),
    include.dirs = TRUE,
    full.names = FALSE,
    recursive = FALSE
  )
  ## compress RO-Crate bag contents in a zip file
  zip::zip(
    output_bag_nor,
    files = bag_files,
    mode = "cherry-pick",
    root = dirname(tmp_dir)
  )

  message("RO-Crate successfully 'bagged'!\nFor details, see: ", output_bag)

  # return path to RO-Crate bag invisibly
  return(invisible(output_bag))
}

#' @rdname bag_rocrate
#' @export
bag_rocrate.rocrate <- function(
  x,
  ...,
  path,
  output = path,
  overwrite = FALSE,
  force_bag = FALSE,
  extra_bag_info = NULL,
  write_content = TRUE,
  create_dir = TRUE
) {
  # check the `x` object
  is_rocrate(x)
  # check a valid path was given
  if (!dir.exists(path)) {
    stop(
      "The given `path` does not exist!\nCreate with:\n\t`mkdir ",
      path,
      "`",
      call. = FALSE
    )
  }
  # check that output exists
  if (!dir.exists(output)) {
    if (create_dir) {
      dir.create(output, showWarnings = FALSE, recursive = TRUE)
    } else {
      stop(
        "The `output` directory does not exist!\nCreate with:\n\t`mkdir ",
        output,
        "`\nAlternatively, set `create_dir = TRUE`.",
        call. = FALSE
      )
    }
  }
  # check if the given path contains an RO-Crate metadata descriptor file
  if (file.exists(file.path(path, "ro-crate-metadata.json"))) {
    if (overwrite) {
      warning(
        "Overwriting the RO-Crate metadata descriptor file!",
        call. = FALSE
      )
    } else {
      stop(
        "The given `path` already contains an RO-Crate metadata descriptor ",
        "file, `ro-crate-metadata.json`. To ignore this check, set ",
        "`overwrite = TRUE` when calling this function!",
        call. = FALSE
      )
    }
  }

  # if user set `write_content = TRUE`, then extract contents of File entities
  if (isTRUE(write_content)) {
    x <- extract_content(x, path)
  }

  # write the RO-Crate metadata descriptor file
  write_rocrate(x, file.path(path, "ro-crate-metadata.json"))

  # call the bag method for the given `path`
  bag_rocrate(
    path,
    output = output,
    force_bag = force_bag,
    extra_bag_info = extra_bag_info
  )
}

#' Check if path points to a valid RO-Crate bag
#'
#' @param path String with full path to a compressed file contain an RO-Crate
#'     bag, see \link[rocrateR]{bag_rocrate} for details. Alternatively, a path
#'     to a directory containing an RO-Crate bag.
#' @param algo String with algorithm used to generate the RO-Crate bag
#'     (default: `NULL`, which auto detects the algorithm from the
#'     `manifest-<algo>.txt` file, inside the bag). See \link[digest]{digest}
#'     for more details on valid algorithms.
#' @param bagit_version String with version of BagIt used to generate the
#'     RO-Crate bag (default: `"1.0"`).
#'     See \doi{10.17487/RFC8493} for more details.
#'
#' @returns Returns a boolean flag to indicate if the given RO-Crate bag is
#' valid.
#' @export
#'
#' @family RO-Crate BagIt archive functions
#'
#' @examples
#' # -------- SETUP --------
#' basic_crate <- rocrateR::rocrate()
#' # temp file
#' tmp_dir <- file.path(tempdir(), digest::digest(basename(tempfile())))
#' tmp <- file.path(tmp_dir, "ro-crate-metadata.json")
#' dir.create(tmp_dir)
#'
#' # bag RO-Crate
#' path_to_roc_bag <- rocrateR::bag_rocrate(basic_crate, path = tmp_dir)
#'
#' # -------- INPUT: RO-Crate BagIt archive --------
#' rocrateR::is_rocrate_bag(path_to_roc_bag)
#'
#' # -------- INPUT: Path --------
#' rocrateR::unbag_rocrate(path_to_roc_bag) |>
#'   rocrateR::is_rocrate_bag()
#'
#' # delete temp directory
#' unlink(tmp_dir, recursive = TRUE)
is_rocrate_bag <- function(
  path,
  algo = NULL,
  bagit_version = "1.0"
) {
  # attempt extracting contents if bag is a zip archive
  aux <- .extract_bag_if_zip(path, "is_rocrate_bag-")
  bag_root <- aux$path
  if (is.null(bag_root)) {
    warning(aux$msg, call. = FALSE)
    return(FALSE)
  }

  # delete temporary directory after function ends
  if (!is.null(aux$cleanup)) {
    on.exit(
      unlink(aux$cleanup, recursive = TRUE, force = TRUE),
      add = TRUE
    )
  }

  # call the .validate_rocrate_bag function
  tryCatch(
    {
      .validate_rocrate_bag(
        path = bag_root,
        algo = ifelse(is.null(algo), .detect_manifest_algo(bag_root), algo),
        bagit_version = bagit_version
      )
      TRUE
    },
    error = function(e) FALSE
  )
}

#' Load an RO-Crate BagIt archive
#'
#' @inheritParams is_rocrate_bag
#' @inheritParams load_rocrate
#'
#' @return An object with the \link[rocrateR]{rocrate} class.
#' @export
#'
#' @family RO-Crate BagIt archive functions
#'
#' @examples
#' # -------- SETUP --------
#' basic_crate <- rocrateR::rocrate()
#' # temp file
#' tmp_dir <- file.path(tempdir(), digest::digest(basename(tempfile())))
#' tmp <- file.path(tmp_dir, "ro-crate-metadata.json")
#' dir.create(tmp_dir)
#'
#' # bag RO-Crate
#' path_to_roc_bag <- rocrateR::bag_rocrate(basic_crate, path = tmp_dir)
#'
#' # -------- INPUT: RO-Crate BagIt archive --------
#' rocrateR::load_rocrate_bag(path_to_roc_bag)
#'
#' # -------- INPUT: Path --------
#' rocrateR::unbag_rocrate(path_to_roc_bag) |>
#'   rocrateR::load_rocrate_bag()
#'
#' # delete temp directory
#' unlink(tmp_dir, recursive = TRUE)
load_rocrate_bag <- function(
  path,
  algo = NULL,
  bagit_version = "1.0",
  load_content = FALSE,
  max_file_size = 10 * 1024^2
) {
  # attempt extracting contents if bag is a zip archive
  aux <- .extract_bag_if_zip(path, prefix = "load_rocrate_bag-")
  bag_root <- aux$path

  if (is.null(bag_root)) {
    stop(aux$msg, call. = FALSE)
  }

  # delete temporary directory after function ends
  if (!is.null(aux$cleanup)) {
    on.exit(
      unlink(aux$cleanup, recursive = TRUE, force = TRUE),
      add = TRUE
    )
  }

  # strict validation (throws if invalid)
  .validate_rocrate_bag(
    path = bag_root,
    algo = ifelse(is.null(algo), .detect_manifest_algo(bag_root), algo),
    bagit_version = bagit_version
  )

  # load RO-Crate
  rocrate_path <- file.path(bag_root, "data", "ro-crate-metadata.json")

  rocrate_obj <- .read_rocrate_json(rocrate_path)

  # check if the user request to load content from File entities
  if (isTRUE(load_content)) {
    rocrate_obj <- .load_content(
      rocrate_obj,
      file.path(bag_root, "data"),
      max_file_size
    )
  }

  return(rocrate_obj)
}

#' 'Unbag' (extract) RO-Crate packed with BagIt
#'
#' @param path String with path to compressed file containing an RO-Crate bag.
#' @param output String with target path where the contents will be extracted
#'     (default: `dirname(path)` - same directory as input `path`).
#' @param quiet Boolean flag to indicate if messages should be suppressed
#'     (default: `FALSE` - display messages).
#'
#' @export
#'
#' @returns String with path to root of the RO-Crate.
#'
#' @family RO-Crate BagIt archive functions
#'
#' @examples
#' # -------- SETUP --------
#' basic_crate <- rocrateR::rocrate()
#' # temp file
#' tmp_dir <- file.path(tempdir(), digest::digest(basename(tempfile())))
#' tmp <- file.path(tmp_dir, "ro-crate-metadata.json")
#' dir.create(tmp_dir)
#'
#' # bag RO-Crate
#' path_to_roc_bag <- rocrateR::bag_rocrate(basic_crate, path = tmp_dir)
#'
#' # -------- INPUT: Path --------
#' rocrateR::unbag_rocrate(path_to_roc_bag)
#'
#' # delete temp directory
#' unlink(tmp_dir, recursive = TRUE)
unbag_rocrate <- function(path, output = dirname(path), quiet = FALSE) {
  # check a valid path was given
  if (!file.exists(path)) {
    stop("The given path, `path`, does not exist!", call. = FALSE)
  }

  # check if file has .zip extension
  if (!grepl("zip$", path, ignore.case = TRUE)) {
    stop("The given `path` does not point to a .zip file!", call. = FALSE)
  }

  # check if the `output` directory exists, if not, then it creates it
  if (!dir.exists(output)) {
    dir.create(output, showWarnings = FALSE, recursive = TRUE)
  }

  # inspect zip contents first
  zip_list <- utils::unzip(path, list = TRUE)

  if (nrow(zip_list) == 0) {
    stop("The zip file is empty!", call. = FALSE)
  }

  # filter out macOS and hidden artefacts, before extraction
  is_junk <- grepl(
    pattern = "^(__MACOSX/|\\.|.DS_Store$)",
    x = zip_list$Name
  )

  valid_files <- zip_list$Name[!is_junk]

  if (length(valid_files) == 0) {
    stop(
      "No valid files found in the zip archive after filtering hidden/system files.",
      call. = FALSE
    )
  }

  # extract contents (only valid files) inside the `output` path
  zip::unzip(path, files = valid_files, exdir = output)

  # find the actual BagIt root
  bag_root <- .find_bagit_root(output)

  # final validation
  if (is.null(bag_root)) {
    # helpful diagnostics for debugging broken zips
    stop(
      "Could not locate a valid RO-Crate BagIt root after extraction.\n",
      "Expected to find at least:\n",
      "  - bagit.txt\n",
      "  - data/ directory\n\n",
      "Top-level extracted contents were:\n",
      paste0("  - ", list.files(output), collapse = "\n"),
      call. = FALSE
    )
  }

  if (!quiet) {
    message(
      "RO-Crate bag successfully extracted! For details, see:\n",
      "Root directory: ",
      bag_root
    )
  }

  # path to root of the RO-Crate bag
  return(bag_root)
}

#' Generate BagIt declaration
#'
#' @param path String with path where the BagIt declaration will be stored.
#' @param version String with BagIt version (default: `"1.0"`)/
#'
#' @keywords internal
#' @noRd
#' @rdname bagit_declaration
#' @source https://www.rfc-editor.org/rfc/rfc8493.html#section-2.2.2
.bagit_declaration <- function(path, version = "1.0") {
  declaration_lines <- c(
    paste0("BagIt-version: ", version),
    "Tag-File-Character-Encoding: UTF-8"
  )
  writeLines(declaration_lines, con = file.path(dirname(path), "bagit.txt"))
}


#' Generate BagIt fetch file
#'
#' @param path String with path where the BagIt declaration will be stored.
#' @param rocrate RO-Crate object, see [rocrateR::rocrate].
#'
#' @keywords internal
#' @noRd
#' @rdname bagit_fetch
.bagit_fetch <- function(path, rocrate = NULL) {
  if (is.null(rocrate)) {
    return(invisible(NULL))
  }

  # extract graph and File entities
  graph <- rocrate$`@graph`
  file_entities <- Filter(
    function(x) {
      "@type" %in% names(x) && "File" %in% x[["@type"]]
    },
    graph
  )

  # filter out File entities with @id pointing to URLs
  remote <- Filter(
    function(x) {
      grepl("^https?://", x[["@id"]])
    },
    file_entities
  )

  # if none are found, then terminate the function execution
  if (length(remote) == 0) {
    return(invisible(NULL))
  }

  # if any are found, extract the URL, content size an file @id
  lines <- vapply(
    remote,
    function(x) {
      url <- x[["@id"]]

      size <- if (!is.null(x$contentSize)) {
        as.character(x$contentSize)
      } else {
        "-"
      }

      file <- file.path("data", basename(url))

      paste(url, size, file)
    },
    character(1)
  )

  # create fetch.txt
  writeLines(
    lines,
    file.path(dirname(path), "fetch.txt")
  )
}

#' Generate BagIt info file
#'
#' @inheritParams .bagit_declaration
#' @param extra_bag_info Additional lines to include in the `bag-info.txt` file.
#'
#' @keywords internal
#' @noRd
#' @rdname bagit_info
.bagit_info <- function(path, files, extra_bag_info = NULL) {
  bagit_info_lines <- c(
    sprintf(
      "Bag-Software-Agent: rocrateR::bag_rocrate() v%s <%s>",
      utils::packageVersion("rocrateR"),
      "https://doi.org/10.32614/CRAN.package.rocrateR"
    ),
    sprintf("Bagging-Date: %s", Sys.Date()),
    .bagit_payload_oxum(path, files),
    extra_bag_info
  )

  writeLines(bagit_info_lines, con = file.path(dirname(path), "bag-info.txt"))
}

#' Generate BagIt manifest file
#'
#' @inheritParams .bagit_declaration
#' @param algo Algorithm to be used when generation files' checksum
#'     (default: 'sha512').
#'
#' @keywords internal
#' @noRd
#' @rdname bagit_manifest
.bagit_manifest <- function(path, files, algo = "sha512") {
  manifest_lines <- sapply(files, function(f) {
    # generate checksum
    checksum <- digest::digest(file.path(path, f), algo = algo, file = TRUE)
    # combine checksum with file path & name
    paste0(checksum, " data/", f)
  })
  writeLines(
    manifest_lines,
    con = file.path(dirname(path), paste0("manifest-", algo, ".txt"))
  )
  return(invisible(manifest_lines))
}

#' Generate BagIt Payload Oxum
#'
#' @inheritParams .bagit_declaration
#'
#' @returns String with BagIt Payload Oxum
#'
#' @keywords internal
#' @noRd
#' @rdname bagit_payload_oxum
.bagit_payload_oxum <- function(path, files) {
  # compute components for the Payload-Oxum:
  num_files <- length(files)
  num_bytes <- sum(file.info(file.path(path, files))$size)

  # create new line for Payload-Oxum
  payload_oxum <- sprintf("Payload-Oxum: %s.%s", num_bytes, num_files)

  return(invisible(payload_oxum))
}

#' Generate BagIt tagmanifest file
#'
#' @inheritParams .bagit_manifest
#'
#' @keywords internal
#' @noRd
#' @rdname bagit_tagmanifest
.bagit_tagmanifest <- function(path, files, algo = "sha512") {
  tagmanifest_lines <- sapply(files, function(f) {
    # generate checksum
    checksum <- digest::digest(file.path(path, f), algo = algo, file = TRUE)
    # combine checksum with file path & name
    paste0(checksum, " ", f)
  })
  writeLines(
    tagmanifest_lines,
    con = file.path(path, paste0("tagmanifest-", algo, ".txt"))
  )
  return(invisible(tagmanifest_lines))
}

#' Create a unique RO-Crate identifier
#'
#' Uses tempfile to generate a unique identifier without altering
#' the global RNG state.
#'
#' @param prefix String with prefix for the RO-Crate ID
#'
#' @returns String RO-Crate identifier
#'
#' @keywords internal
#' @noRd
.create_rocrate_id <- function(prefix = "rocrate-") {
  paste0(prefix, digest::digest(basename(tempfile())))
}

#' Detect BagIt archive's manifest algorith
#'
#' @param path Path to BagIt archive directory.
#'
#' @returns String with the algorithm.
#' @keywords internal
#' @noRd
.detect_manifest_algo <- function(path) {
  manifest_files <- list.files(
    path,
    pattern = "^manifest-.*\\.txt$",
    full.names = FALSE
  )

  if (length(manifest_files) == 0) {
    stop("No manifest-<algo>.txt file found in bag root.", call. = FALSE)
  }

  if (length(manifest_files) > 1) {
    stop(
      "Multiple manifest files detected:\n",
      paste0("  - ", manifest_files, collapse = "\n"),
      "\nCannot determine checksum algorithm automatically.",
      call. = FALSE
    )
  }

  algo <- sub("^manifest-(.*)\\.txt$", "\\1", manifest_files)

  return(algo)
}

#' Extract BagIt archive
#'
#' @inheritParams is_rocrate_bag
#' @param prefix String with prefix for the RO-Crate ID
#'
#' @returns List with input path and temporary path where the contents were
#'     extracted.
#' @keywords internal
#' @noRd
.extract_bag_if_zip <- function(path, prefix = "rocrate_extract-") {
  if (dir.exists(path)) {
    return(list(path = .find_bagit_root(path), cleanup = NULL, msg = NULL))
  }

  if (!file.exists(path)) {
    return(list(
      path = NULL,
      cleanup = NULL,
      msg = "The given path does not exist!"
    ))
  }

  if (dir.exists(path)) {
    return(list(path = .find_bagit_root(path), cleanup = NULL, msg = NULL))
  }
  if (!file.info(path)$isdir && grepl("\\.zip$", path, ignore.case = TRUE)) {
    roc_id <- .create_rocrate_id(prefix)
    tmp_dir <- file.path(tempdir(), roc_id)
    dir.create(tmp_dir, recursive = TRUE)

    bag_root <- tryCatch(
      unbag_rocrate(path, output = tmp_dir, quiet = TRUE),
      error = function(e) NULL
    )

    msg <- NULL
    if (is.null(bag_root)) {
      msg <- "Invalid BagIt archive."
    }

    return(list(path = bag_root, cleanup = tmp_dir, msg = msg))
  }

  NULL
}

#' Find BagIt root for an RO-Crate
#'
#' @param path String with path to RO-Crate bag.
#'
#' @returns String with path to RO-Crate bag root (if any).
#' @keywords internal
#' @noRd
.find_bagit_root <- function(path) {
  path <- normalizePath(path, mustWork = TRUE)

  # candidate directories: root + all subdirectories
  candidate_dirs <- c(
    path,
    list.dirs(path, recursive = TRUE, full.names = TRUE)
  )

  for (dir in candidate_dirs) {
    if (
      file.exists(file.path(dir, "bagit.txt")) &&
        dir.exists(file.path(dir, "data"))
    ) {
      return(dir)
    }
  }

  return(NULL)
}

#' Create new temporary directory
#'
#' @param subdirs String with additional subdirectories
#' @returns Path to temporary directory
#' @keywords internal
#' @noRd
.new_tmp_dir <- function(subdirs = character(1)) {
  dir <- file.path(tempdir(), subdirs)
  dir.create(dir, recursive = TRUE)
  dir
}

#' Verify if a given path points to a valid RO-Crate bag
#'
#' @inheritParams is_rocrate_bag
#'
#' @returns Returns invisibly the RO-Crate pointed by `path`.
#' @keywords internal
#' @noRd
.validate_rocrate_bag <- function(
  path,
  algo,
  bagit_version = "1.0"
) {
  # check that at least the following files & directory are in the given path
  required_top_level <- c(
    "bagit.txt",
    "data",
    paste0("manifest-", algo, ".txt")
  )

  # list files inside the given path / top level only
  top_level_contents <- list.files(path, recursive = FALSE)

  missing_top <- setdiff(required_top_level, top_level_contents)

  errors <- character()

  if (length(missing_top) > 0) {
    errors <- c(
      errors,
      paste0(
        "Missing required top-level entries:\n",
        paste0("  - ", missing_top, collapse = "\n")
      )
    )
  }

  # ensure `data/` is a directory
  data_dir <- file.path(path, "data")
  if (file.exists(data_dir) && !dir.exists(data_dir)) {
    errors <- c(errors, "`data` exists but is not a directory.")
  }

  # ensure RO-Crate metadata exists
  metadata_file <- file.path(data_dir, "ro-crate-metadata.json")
  if (!file.exists(metadata_file)) {
    errors <- c(
      errors,
      "Missing required RO-Crate descriptor: data/ro-crate-metadata.json"
    )
  }

  # BagIt declaration validation
  bagit_decl <- .validate_bagit_declaration(path, bagit_version)
  if (!bagit_decl$status) {
    errors <- c(
      errors,
      paste0(
        "BagIt declaration (bagit.txt) invalid:\n",
        paste0("  - ", bagit_decl$errors, collapse = "\n")
      )
    )
  }

  # BagIt manifest validation
  bagit_manifest <- .validate_bagit_manifest(path, algo)
  if (!bagit_manifest$status) {
    errors <- c(
      errors,
      paste0(
        "BagIt manifest contains invalid file(s):\n",
        paste0("  - ", bagit_manifest$errors, collapse = "\n")
      )
    )
  }

  # BagIt tagmanifest validation (optional)
  tagmanifest_file <- file.path(path, paste0("tagmanifest-", algo, ".txt"))

  if (file.exists(tagmanifest_file)) {
    bagit_tagmanifest <-
      .validate_bagit_manifest(
        path,
        algo,
        manifest_suffix = "tagmanifest"
      )

    if (!bagit_tagmanifest$status) {
      errors <- c(
        errors,
        paste0(
          "BagIt tagmanifest contains invalid file(s):\n",
          paste0("  - ", bagit_tagmanifest$errors, collapse = "\n")
        )
      )
    }
  }

  # BagIt payload oxum (optional)
  oxum <- .validate_bagit_payload_oxum(path)
  if (!oxum$status) {
    errors <- c(errors, oxum$errors)
  }

  # aggregate errors (if any)
  if (length(errors) > 0) {
    stop(
      paste(
        "Invalid RO-Crate bag! The following issues were found:\n",
        paste(errors, collapse = "\n\n")
      ),
      call. = FALSE
    )
  }

  # JSON syntax validation
  .validate_json_syntax(metadata_file)

  invisible(TRUE)
}

#' Validate BagIt declaration
#'
#' @inheritParams is_rocrate_bag
#'
#' @returns A list with `status` and `errors` identified.
#' @keywords internal
#' @noRd
#' @rdname bagit_declaration
.validate_bagit_declaration <- function(
  path,
  bagit_version = "1.0"
) {
  # load the BagIt declaration file
  bagit_declaration_txt <- readLines(file.path(path, "bagit.txt"), warn = FALSE)

  # normalise contents (trim + case-insensitive)
  bagit_declaration_txt_norm <- trimws(tolower(bagit_declaration_txt))

  has_version <- any(grepl(
    paste0("^bagit-version:\\s*", bagit_version, ".*"),
    bagit_declaration_txt_norm
  ))
  has_encoding <- any(grepl(
    "^tag-file-character-encoding:\\s*utf-8$",
    bagit_declaration_txt_norm
  ))

  errors <- character(0)
  if (!has_version) {
    errors <- c(errors, paste0("BagIt-Version: ", bagit_version))
  }

  if (!has_encoding) {
    errors <- c(errors, "Tag-File-Character-Encoding: UTF-8")
  }

  # return list with status: TRUE = all lines found, FALSE = missing line AND
  # errors: vector of the missing lines (if any)
  list(
    status = length(errors) == 0,
    errors = errors
  )
}

#' Validate BagIt declaration
#'
#' @inheritParams is_rocrate_bag
#' @param manifest_suffix String with suffix for the manifest file (default:
#'     `"manifest"`).
#'
#' @returns A list with `status` and `errors` identified.
#' @keywords internal
#' @noRd
#' @rdname bagit_manifest
.validate_bagit_manifest <- function(
  path,
  algo,
  manifest_suffix = "manifest"
) {
  manifest_filename <- file.path(
    path,
    paste0(manifest_suffix, "-", algo, ".txt")
  )
  # check if the manifest file is missing
  if (!file.exists(manifest_filename)) {
    return(list(
      status = FALSE,
      errors = paste0("Missing ", basename(manifest_filename))
    ))
  }

  # load the manifest file
  bagit_manifest_txt <- manifest_filename |>
    utils::read.table(
      header = FALSE,
      sep = "",
      col.names = c("checksum", "filename"),
      colClasses = c("character", "character"),
      stringsAsFactors = FALSE,
      quote = "",
      fill = TRUE
    )

  # check if the manifest file is empty
  if (nrow(bagit_manifest_txt) == 0) {
    return(list(
      status = FALSE,
      errors = "Manifest file is empty."
    ))
  }

  # check all the files in the manifest file
  bagit_manifest_txt_validity <- seq_len(nrow(bagit_manifest_txt)) |>
    sapply(function(i) {
      est_checksum <- file.path(path, bagit_manifest_txt[i, "filename"]) |>
        digest::digest(algo = algo, file = TRUE)
      tolower(est_checksum) == tolower(bagit_manifest_txt[i, "checksum"])
    })

  # return list with status: TRUE = all valid, FALSE = invalid file found AND
  # errors: vector of invalid files (if any)
  list(
    status = all(bagit_manifest_txt_validity),
    errors = bagit_manifest_txt[!bagit_manifest_txt_validity, "filename"]
  )
}

#' Validate BagIt Payload Oxum
#'
#' @inheritParams is_rocrate_bag
#'
#' @returns A list with `status` and `errors` identified.
#' @keywords internal
#' @noRd
#' @rdname bagit_payload_oxum
.validate_bagit_payload_oxum <- function(path) {
  bag_info <- file.path(path, "bag-info.txt")

  if (!file.exists(bag_info)) {
    return(list(status = TRUE)) # optional field
  }

  lines <- readLines(bag_info, warn = FALSE)

  oxum_line <- grep("^Payload-Oxum:", lines, value = TRUE)

  if (length(oxum_line) == 0) {
    return(list(status = TRUE))
  }

  oxum_value <- sub("^Payload-Oxum:\\s*", "", oxum_line)
  parts <- strsplit(oxum_value, "\\.")[[1]]

  if (length(parts) != 2) {
    return(list(
      status = FALSE,
      errors = "Malformed Payload-Oxum value."
    ))
  }

  expected_bytes <- as.numeric(parts[1])
  expected_files <- as.numeric(parts[2])

  payload_files <- list.files(
    file.path(path, "data"),
    recursive = TRUE,
    full.names = TRUE
  )

  actual_files <- length(payload_files)
  actual_bytes <- sum(file.info(payload_files)$size)

  errors <- character()

  if (as.integer(actual_files) != as.integer(expected_files)) {
    errors <- c(errors, "Payload-Oxum file count mismatch.")
  }

  if (!identical(actual_bytes, expected_bytes)) {
    errors <- c(errors, "Payload-Oxum byte size mismatch.")
  }

  list(
    status = length(errors) == 0,
    errors = errors
  )
}
