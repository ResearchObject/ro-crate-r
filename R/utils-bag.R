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
    stop("The given path, `x`, does not exist!\n",
         "Create with:\n\t`mkdir ", x, "`", call. = FALSE)
  }
  
  # list all the files inside the given path
  rocrate_files <- list.files(x, recursive = TRUE)
  
  # check if the given path is empty
  if (length(rocrate_files) == 0) {
    stop("No files were found inside the given path: \n",
         x, call. = FALSE)
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
      dir.create(dirname(file.path(tmp_dir, f)), 
                 showWarnings = FALSE, recursive = TRUE)
      # create copy of file
      file.copy(file.path(x, f), file.path(tmp_dir, f), overwrite = TRUE)
    })
  
  # check that all the files were copied, unless force_bag = TRUE
  if (!all(rocrate_files_status) || force_bag) {
    if (!force_bag) {
      stop("It was not possible to bag all your files!\nMissing file(s):\n",
           paste0(" - ", rocrate_files[!rocrate_files_status], collapse = "\n"),
           "\n\nTo ignore this check, set `force_bag = TRUE`.", call. = FALSE)
    } else {
      warning("Forcing the creation of the RO-Crate bag! ",
              "Note that this will ignore checking if all files were copied",
              "into the RO-Crate bag",
              call. = FALSE)
    }
  }
  
  # create bag declaration
  bagit_declaration(tmp_dir)
  
  # create bag manifest and stored one level above `tmp_dir`
  bagit_manifest(tmp_dir, rocrate_files)
  
  # create BagIt tagmanifest
  bagit_tagmanifest(dirname(tmp_dir), 
                    list.files(dirname(tmp_dir), pattern = "txt$"))
  
  # create BagIt fetch file
  bagit_fetch(tmp_dir)
  
  # compress bag contents inside original path
  output_bag <- file.path(output, paste0(rocrate_id, ".zip"))
  ## create version of `output_ba` with absolute/normalised path
  output_bag_nor <- file.path(normalizePath(output), paste0(rocrate_id, ".zip"))
  ## list files within the `tmp_dir`
  bag_files <- list.files(dirname(tmp_dir),
                          include.dirs = TRUE,
                          full.names = FALSE,
                          recursive = FALSE)
  ## compress RO-Crate bag contents in a zip file
  zip::zip(output_bag_nor, files = bag_files,
           mode = "cherry-pick", root = dirname(tmp_dir))
  
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
bag_rocrate.rocrate <- function(x, ..., path, output = path, overwrite = FALSE, force_bag = FALSE) {
  # check the `x` object
  is_rocrate(x)
  # check a valid path was given
  if (!dir.exists(path)) {
    stop("The given `path` does not exist!\nCreate with:\n\t`mkdir ", path, "`",
         call. = FALSE)
  }
  # check if the given path contains an RO-Crate metadata descriptor file
  if (file.exists(file.path(path, "ro-crate-metadata.json"))){
    if (overwrite) {
      warning("Overwriting the RO-Crate metadata descriptor file!", call. = FALSE)
    } else {
      stop("The given `path` already contains an RO-Crate metadata descriptor ",
           "file, `ro-crate-metadata.json`. To ignore this check, set ",
           "`overwrite = TRUE` when calling this function!", call. = FALSE)
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
  declaration_lines <- c(paste0("BagIt-version: ", version), 
                         "Tag-File-Character-Encoding: UTF-8")
  writeLines(declaration_lines, 
             con = file.path(dirname(path), "bagit.txt"))
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
  writeLines(manifest_lines, 
             con = file.path(dirname(path), paste0("manifest-", algo, ".txt")))
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
  writeLines(tagmanifest_lines, 
             con = file.path(path, paste0("tagmanifest-", algo, ".txt")))
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
#' @returns Returns invisibly the RO-Crate pointed by `path`.
#' @export
#' 
#' @family bag_rocrate
is_rocrate_bag <- function(path, algo = "sha512", bagit_version = "1.0") {
  # initialise object that will be returned
  ro_crate <- NULL
  
  # check if given path is a directory or a file
  idx <- c(dir.exists(path), file.exists(path))
  if (all(!idx)){
    stop("The given `path` is invalid!", call. = FALSE)
  } else if(idx[1]) { # path is a valid directory
    # no extra steps required
  } else if (idx[2]) { # path is a valid file
    # create temporary directory
    tmp_dir <- file.path(tempdir(), digest::digest(Sys.time()))
    on.exit(unlink(tmp_dir, recursive = TRUE, force = TRUE))
    
    # extract contents of the RO-Crate bag inside temporary directory AND
    # update path, so it points to the contents of the RO-Crate bag
    path <- unbag_rocrate(path, output = tmp_dir, quiet = TRUE)
  }
  # call the .validate_rocrate_bag function
  ro_crate <- .validate_rocrate_bag(path, algo = algo)
  return(invisible(ro_crate))
}

#' Verify if a given path points to a valid RO-Crate bag
#'
#' @inheritParams is_rocrate_bag
#'
#' @returns Returns invisibly the RO-Crate pointed by `path`.
#' @keywords internal
.validate_rocrate_bag <- function(path, algo = "sha512", bagit_version = "1.0") {
  # list files inside the given path / top level only
  rocrate_bag_files <- list.files(path, recursive = FALSE)
  
  # check that at least the following files & directory are in the given path
  expected_contents <- c("bagit.txt", "data", paste0("manifest-", algo, ".txt"))
  idx <- expected_contents %in% rocrate_bag_files
  if (!all(idx)) {
    stop("The given `path` is missing the following:\n",
         paste0("  - ", expected_contents[!idx], "\n"), call. = FALSE)
  }
  
  # list files inside the given path / all levels
  rocrate_bag_files <- list.files(path, recursive = TRUE)
  
  # check for valid BagIt declaration
  valid_bagit_declaration <- .validate_bagit_declaration(path, algo, bagit_version)
  
  # check integrity of manifest file
  valid_bagit_manifest <- .validate_bagit_manifest(path, algo)
  
  # check integrity of tagmanifest file (if found) 
  if (file.exists(file.path(path, paste0("tagmanifest-", algo, ".txt")))) {
    valid_bagit_tagmanifest <- 
      .validate_bagit_manifest(path, algo, manifest_suffix = "tagmanifest")
  } else {
    valid_bagit_tagmanifest <- list(status = TRUE)
  }
  
  # validation overview
  idx <- c(
    valid_bagit_declaration$status,
    valid_bagit_manifest$status,
    valid_bagit_tagmanifest$status
  )
  
  if (any(!idx)) {
    error_message <- "Invalid RO-Crate bag! The following issues were found:\n"
    # BagIt declaration (required)
    if (!idx[1]) {
      error_message <- paste0(
        error_message,
        "\n BagIt declaration (bagit.txt) missing the following:\n",
        paste0("  - ", valid_bagit_declaration$errors, collapse = "\n")
      )
    }
    # BagIt manifest (required)
    if (!idx[2]) {
      error_message <- paste0(
        error_message,
        "\n BagIt manifest contains invalid file(s):\n",
        paste0("  - ", valid_bagit_manifest$errors, collapse = "\n")
      )
    }
    # BagIt tagmanifest (optional)
    if (!idx[3]) {
      error_message <- paste0(
        error_message,
        "\n BagIt tagmanifest contains invalid file(s):\n",
        paste0("  - ", valid_bagit_tagmanifest$errors, collapse = "\n")
      )
    }
    # print error message and stop execution
    stop(error_message, call. = FALSE)
  }
  
  # if no errors where found, load the and return the RO-Crate in the bag
  rocrate_contents <- file.path(path, "data/ro-crate-metadata.json") |>
    rocrateR::read_rocrate()
  
  message("Valid RO-Crate found!")
  return(rocrate_contents)
}

#' Validate BagIt declaration
#' 
#' @inheritParams is_rocrate_bag
#' 
#' @returns A list with `status` and `errors` identified.
#' @keywords internal
#' @rdname bagit_declaration
.validate_bagit_declaration <- function(path, algo = "sha512", bagit_version = "1.0") {
  # load the BagIt declaration file
  bagit_declaration_txt <- readLines(file.path(path, "bagit.txt"))
  # expect lines
  expected_bagit_declaration <- c(paste0("BagIt-version: ", bagit_version), 
                                  "Tag-File-Character-Encoding: UTF-8")
  valid_bagit_declaration_validity <- 
    expected_bagit_declaration %in% bagit_declaration_txt
  # return list with status: TRUE = all lines found, FALSE = missing line AND
  # errors: vector of the missing lines (if any)
  list(
    status = all(valid_bagit_declaration_validity),
    errors = expected_bagit_declaration[!valid_bagit_declaration_validity]
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
.validate_bagit_manifest <- function(path, algo = "sha512", manifest_suffix = "manifest") {
  # load the manifest file
  manifest_filename <- paste0(manifest_suffix, "-", algo, ".txt")
  bagit_manifest_txt <- file.path(path, manifest_filename) |>
    utils::read.table(header = FALSE, col.names = c("checksum", "filename"))
  # check all the files in the manifest file
  bagit_manifest_txt_validity <- seq_len(nrow(bagit_manifest_txt)) |>
    sapply(function(i) {
      est_checksum <- file.path(path, bagit_manifest_txt[i, "filename"]) |>
        digest::digest(algo = algo, file = TRUE)
      est_checksum ==  bagit_manifest_txt[i, "checksum"]
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
#' @returns String with path to root of the RO-Crate, invisibly.
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
  
  # extract contents inside the `output` path
  zip::unzip(path, exdir = output)
  
  # get root directory
  zip_root <- .get_zip_root(path)
  
  # list directories inside the RO-Crate bag
  rocrate_bag_dir <- list.dirs(file.path(output, zip_root), 
                               recursive = FALSE, full.names = FALSE)
  
  # check if the RO-Crate bag has more than one directory, only 1 is expected
  if (length(unique(rocrate_bag_dir)) > 1) {
    stop("A valid RO-Crate bag should have ONE and ONLY ONE root directory!",
         "\nThe given path has the following: ",
         paste0("  - ", unique(rocrate_bag_dir), "\n"), call. = FALSE)
  }
  
  if (!quiet) {
    message("RO-Crate bag successfully extracted! For details, see:\n", 
            file.path(output, zip_root))
  }
  
  # path to root of the RO-Crate bag
  return(invisible(file.path(output, zip_root)))
}
