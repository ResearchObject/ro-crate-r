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
#'
#' @export
#'
#' @family bag_rocrate
# @examples
bag_rocrate <- function(x, ...) {
  UseMethod("bag_rocrate", x)
}

#' @rdname bag_rocrate
#'
#' @param output String with path where the RO-Crate bag will be stored
#'     (default: `x` - same path as the input value).
#' @param force_bag Boolean flag to indicate whether the force the creation of
#'     a 'bag' even if not all the files were successfully bagged
#'     (default: `FALSE` ~ check if all the files were copied successfully).
#'
#' @returns String with full path to the final RO-Crate bag.
#'
#' @export
bag_rocrate.character <- function(x, ..., output = x, force_bag = FALSE) {
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
  rocrate_id <- paste0("rocrate-", digest::digest(Sys.time()))

  # create temporary directory, including `rocrate_id`
  tmp_dir <- file.path(tempdir(), rocrate_id, "data")

  # create sub-directories
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)
  on.exit(unlink(dirname(tmp_dir), recursive = TRUE, force = TRUE))

  # copy files inside the temporary directory
  rocrate_files_status <- rocrate_files |>
    sapply(function(f) {
      # ensure the target sub-directory exists
      dir.create(
        dirname(file.path(tmp_dir, f)),
        showWarnings = FALSE,
        recursive = TRUE
      )
      # create copy of file
      file.copy(file.path(x, f), file.path(tmp_dir, f), overwrite = TRUE)
    })

  # check that all the files were copied, unless force_bag = TRUE
  if (!all(rocrate_files_status) || force_bag) {
    if (!force_bag) {
      stop(
        "It was not possible to bag all your files!\nMissing file(s):\n",
        paste0(" - ", rocrate_files[!rocrate_files_status], collapse = "\n"),
        "\n\nTo ignore this check, set `force_bag = TRUE`.",
        call. = FALSE
      )
    } else {
      warning(
        "Forcing the creation of the RO-Crate bag! ",
        "Note that this will ignore checking if all files were copied",
        "into the RO-Crate bag",
        call. = FALSE
      )
    }
  }

  # create bag declaration
  bagit_declaration(tmp_dir)

  # create bag manifest and stored one level above `tmp_dir`
  bagit_manifest(tmp_dir, rocrate_files)

  # create BagIt tagmanifest
  bagit_tagmanifest(
    dirname(tmp_dir),
    list.files(dirname(tmp_dir), pattern = "txt$")
  )

  # create BagIt fetch file
  bagit_fetch(tmp_dir)

  # compress bag contents inside original path
  output_bag <- file.path(output, paste0(rocrate_id, ".zip"))
  ## create version of `output_ba` with absolute/normalised path
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

  # attempt to delete the temporary directory created to bag the RO-Crate
  unlink(dirname(tmp_dir), recursive = TRUE, force = TRUE)

  # return path to RO-Crate bag invisibly
  return(invisible(output_bag))
}

#' @rdname bag_rocrate
#'
#' @param path String with path to the root of the RO-Crate.
#' @param overwrite Boolean flag to indicate if the RO-Crate metadata descriptor
#'     file should be overwritten if already inside `path` (default: `FALSE`).
#'
#' @export
bag_rocrate.rocrate <- function(
  x,
  ...,
  path,
  output = path,
  overwrite = FALSE,
  force_bag = FALSE
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
  # write the RO-Crate metadata descriptor file
  write_rocrate(x, file.path(path, "ro-crate-metadata.json"))

  # call the bag method for the given `path`
  bag_rocrate(path, output = output, force_bag = force_bag)
}

#' Generate BagIt declaration
#'
#' @param path String with path where the BagIt declaration will be stored.
#' @param version String with BagIt version (default: `"1.0"`)/
#'
#' @keywords internal
#' @source https://www.rfc-editor.org/rfc/rfc8493.html#section-2.2.2
bagit_declaration <- function(path, version = "1.0") {
  declaration_lines <- c(
    paste0("BagIt-version: ", version),
    "Tag-File-Character-Encoding: UTF-8"
  )
  writeLines(declaration_lines, con = file.path(dirname(path), "bagit.txt"))
}

#' @keywords internal
bagit_fetch <- function(path, rocrate = NULL) {
  # to-do
  # 1. read rocrate and find any file entities that have an external URL
  # 2. list results from step 1 in a file called fetch.txt
  # See: https://www.researchobject.org/ro-crate/specification/1.1/appendix/implementation-notes.html
  # Also: https://www.rfc-editor.org/rfc/rfc8493.html#section-2.2.3
}

#' @keywords internal
bagit_manifest <- function(path, files, algo = "sha512") {
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

#' @keywords internal
bagit_tagmanifest <- function(path, files, algo = "sha512") {
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

#' Check if path points to a valid RO-Crate bag
#'
#' @param path String with full path to a compressed file contain an RO-Crate
#'     bag, see \link[rocrateR]{bag_rocrate} for details. Alternatively, a path
#'     to a directory containing an RO-Crate bag.
#' @param algo String with algorithm used to generate the RO-Crate bag
#'     (default: `"sha512"`). See \link[digest]{digest} for more details.
#' @param bagit_version String with version of BagIt used to generate the
#'     RO-Crate bag (default: `"1.0"`).
#'     See \doi{10.17487/RFC8493} for more details.
#'
#' @returns Returns a boolean flag to indicate if the given RO-Crate bag is
#' valid.
#' @export
#'
#' @family bag_rocrate
is_rocrate_bag <- function(path, algo = "sha512", bagit_version = "1.0") {
  # initialise object that will be returned
  bag_root <- ro_crate <- NULL

  # check if given path is a directory or a file
  if (missing(path) || !file.exists(path)) {
    warning("The given `path` is invalid!", call. = FALSE)
    return(FALSE)
  }

  # if `path` is a zip file. extract using `unbag_rocrate()`
  if (
    file.info(path)$isdir == FALSE &&
      grepl("\\.zip$", path, ignore.case = TRUE)
  ) {
    # create temporary directory
    tmp_dir <- file.path(tempdir(), digest::digest(Sys.time()))
    dir.create(tmp_dir, recursive = TRUE)
    on.exit(unlink(tmp_dir, recursive = TRUE, force = TRUE), add = TRUE)

    # extract contents of the RO-Crate bag inside temporary directory AND
    # update path, so it points to the contents of the RO-Crate bag
    bag_root <- tryCatch(
      unbag_rocrate(path, output = tmp_dir, quiet = TRUE),
      error = function(e) NULL
    )
    if (is.null(bag_root)) {
      return(FALSE)
    }
  } else if (dir.exists(path)) {
    bag_root <- .find_bagit_root(path)
  } else {
    return(FALSE)
  }

  if (is.null(bag_root)) {
    warning("No valid BagIt root found.", call. = FALSE)
    return(FALSE)
  }

  # call the .validate_rocrate_bag function
  valid <- tryCatch(
    {
      .validate_rocrate_bag(
        path = bag_root,
        algo = algo,
        bagit_version = bagit_version
      )
      TRUE
    },
    error = function(e) FALSE
  )

  return(valid)
}

#' Load a validated RO-Crate BagIt archive
#'
#' @param path Path to a directory or .zip file
#' @param algo Checksum algorithm (default: sha512)
#' @param bagit_version Required BagIt version (default: 1.0)
#'
#' @return An object with the \link[rocrateR]{rocrate} class.
#' @export
load_rocrate_bag <- function(
  path,
  algo = "sha512",
  bagit_version = "1.0"
) {
  if (!file.exists(path)) {
    stop("The given path does not exist!", call. = FALSE)
  }

  # extract if zip
  if (
    !file.info(path)$isdir &&
      grepl("\\.zip$", path, ignore.case = TRUE)
  ) {
    # create temporary directory
    tmp_dir <- file.path(tempdir(), digest::digest(Sys.time()))
    dir.create(tmp_dir, TRUE)
    on.exit(unlink(tmp_dir, recursive = TRUE, force = TRUE), add = TRUE)

    # extract contents of the RO-Crate bag inside temporary directory AND
    # update path, so it points to the contents of the RO-Crate bag
    bag_root <- tryCatch(
      unbag_rocrate(path, output = tmp_dir, quiet = TRUE),
      error = function(e) NULL
    )
  } else {
    bag_root <- path
  }

  # strict validation (throws if invalid)
  .validate_rocrate_bag(
    path = bag_root,
    algo = algo,
    bagit_version = bagit_version
  )

  # load RO-Crate
  rocrate_path <- file.path(bag_root, "data", "ro-crate-metadata.json")

  rocrate_obj <- rocrateR::read_rocrate(rocrate_path)

  return(rocrate_obj)
}

#' Find BagIt root for an RO-Crate
#'
#' @param path String with path to RO-Crate bag.
#'
#' @returns String with path to RO-Crate bag root (if any).
#' @keywords internal
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

#' Verify if a given path points to a valid RO-Crate bag
#'
#' @inheritParams is_rocrate_bag
#'
#' @returns Returns invisibly the RO-Crate pointed by `path`.
#' @keywords internal
.validate_rocrate_bag <- function(
  path,
  algo = "sha512",
  bagit_version = "1.0"
) {
  # check if the given path exists
  if (!dir.exists(path)) {
    stop("The given `path` is not a valid directory!", call. = FALSE)
  }

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

  # BagIT tagmanifest validation (optional)
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

  invisible(TRUE)
}

#' Validate BagIt declaration
#'
#' @inheritParams is_rocrate_bag
#'
#' @returns A list with `status` and `errors` identified.
#' @keywords internal
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
#' @rdname bagit_manifest
.validate_bagit_manifest <- function(
  path,
  algo = "sha512",
  manifest_suffix = "manifest"
) {
  # load the manifest file
  manifest_filename <- paste0(manifest_suffix, "-", algo, ".txt")
  bagit_manifest_txt <- file.path(path, manifest_filename) |>
    utils::read.table(header = FALSE, col.names = c("checksum", "filename"))
  # check all the files in the manifest file
  bagit_manifest_txt_validity <- seq_len(nrow(bagit_manifest_txt)) |>
    sapply(function(i) {
      est_checksum <- file.path(path, bagit_manifest_txt[i, "filename"]) |>
        digest::digest(algo = algo, file = TRUE)
      est_checksum == bagit_manifest_txt[i, "checksum"]
    })
  # return list with status: TRUE = all valid, FALSE = invalid file found AND
  # errors: vector of invalid files (if any)
  list(
    status = all(bagit_manifest_txt_validity),
    errors = bagit_manifest_txt[!bagit_manifest_txt_validity, "filename"]
  )
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
#' @family bag_rocrate
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
  if (dir.exists(output)) {
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
