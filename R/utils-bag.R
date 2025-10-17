#' Bag the contents of an RO-Crate
#' 
#' Bag the contents of an RO-Crate using the BagIt file packaging format v1.0.
#' For more details see the definition: 
#' \url{https://datatracker.ietf.org/doc/html/rfc8493}
#'
#' @param x A string to a path containing at the very minimum an RO-Crate
#'     metadata descriptor file, `ro-crate-metadata.json`. Alternatively, an
#'     object with the \link[rocrateR]{rocrate} class.
#' @param ... Additional parameters, see below.
#' 
#' @export
#'
# @examples
bag_rocrate <- function(x, ...) {
  UseMethod("bag_rocrate", x)
}

#' @rdname bag_rocrate
#' 
#' @param force_bag Boolean flag to indicate whether the force the creation of
#'     a 'bag' even if not all the files were successfully bagged  
#'     (default: `FALSE` ~ check if all the files were copied successfully).
#' @param zip_flags String of characters with the flags to be used when 
#'     archiving/compressing the RO-Crate bag (default: `-r9X`, see 
#'     `zip -h` in the terminal for more details).
#'
#' @returns String with full path to the final RO-Crate bag.
#' 
#' @export
bag_rocrate.character <- function(x, ..., force_bag = FALSE, zip_flags = "-r9X") {
  # check a valid path was given
  if (!dir.exists(x)) {
    stop("The given path, `x`, does not exist!\n",
         "Create with:\n\t`mkdir ", x, "`")
  }
  
  # list all the files inside the given path
  rocrate_files <- list.files(x, recursive = TRUE)
  
  # create an RO-Crate ID
  rocrate_id <- paste0("rocrate-", digest::digest(Sys.time()))
  
  # create temporary directory, including `rocrate_id`
  tmp_dir <- file.path(".", rocrate_id, "data")
  
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
  if (force_bag || !all(rocrate_files_status)) {
    stop("It was not possible to bag all your files!\nMissing file(s):\n",
         paste0(" - ", rocrate_files[rocrate_files_status], collapse = "\n"),
         "\n\nTo ignore this check, set `force_bag = TRUE`.")  
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
  output_bag <- file.path(x, paste0(rocrate_id, ".zip"))
  bag_files <- list.files(dirname(tmp_dir), 
                          full.names = TRUE,
                          recursive = TRUE)
  utils::zip(output_bag, bag_files, flags = zip_flags)
  
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
bag_rocrate.rocrate <- function(x, ..., path, overwrite = FALSE, force_bag = FALSE, zip_flags = "-r9X") {
  # check the `x` object
  is_rocrate(x)
  # check a valid path was given
  if (!dir.exists(path)) {
    stop("The given `path` does not exist!\nCreate with:\n\t`mkdir ", path, "`")
  }
  # check if the given path contains an RO-Crate metadata descriptor file
  if (file.exists(file.path(path, "ro-crate-metadata.json"))){
    if (overwrite) {
      warning("Overwriting the RO-Crate metadata descriptor file!")
    } else {
      stop("The given `path` already contains an RO-Crate metadata descriptor ",
           "file, `ro-crate-metadata.json`. To ignore this check, set ",
           "`overwrite = TRUE` when calling this function!")
    }
  }
  # write the RO-Crate metadata descriptor file
  write_rocrate(x, file.path(path, "ro-crate-metadata.json"))
  
  # call the bag method for the given `path`
  bag_rocrate(path, force_bag = force_bag, zip_flags = zip_flags)
}

#' @keywords internal
bagit_declaration <- function(path) {
  declaration_lines <- c("BagIt-version: 1.0", 
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
#'     (default: `"sha512"`).
#'
#' @returns Returns invisibly the RO-Crate pointed by `path`.
#' @export
is_rocrate_bag <- function(path, algo = "sha512") {
  # initialise return object
  ro_crate <- NULL
  
  # check if path is a directory or file
  idx <- c(dir.exists(path), file.exists(path))
  if (!all(idx)){
    stop("The given `path` is invalid!")
  } else if(idx[1]) { # path is a valid directory
    # no extra steps required
  } else if (idx[2]) { # path is a valid file
    # check if file has .zip extension
    if (!grepl("zip$", path, ignore.case = TRUE)) {
      stop("The given `path` does not point to a .zip file!")
    }
    
    # create temporary directory
    tmp_dir <- file.path(tempdir(), digest::digest(Sys.time()))
    on.exit(unlink(dirname(tmp_dir), recursive = TRUE, force = TRUE))
    
    # extract contents inside temporary directory
    unzip(path, exdir = tmp_dir)
    
    # list directories inside the RO-Crate bag
    rocrate_bag_dir <- list.dirs(tmp_dir, recursive = FALSE, full.names = FALSE)
    
    # check if the RO-Crate bag has only a root directory
    if (length(rocrate_bag_dir) == 0) {
      rocrate_bag_dir <- "."
    }
    
    # check if the RO-Crate bag has more than one directory, only 1 is expected
    if (length(unique(rocrate_bag_dir)) > 1) {
      stop("A valid RO-Crate bag should have ONE and ONLY ONE root directory!",
           "\nThe given path has the following: ",
           paste0("  - ", unique(rocrate_bag_dir), "\n"))
    }
    
    # update path
    path <- file.path(tmp_dir, rocrate_bag_dir)
  }
  # call the .validate_rocrate_bag function
  ro_crate <- .validate_rocrate_bag(path, algo = algo)
  return(invisible(ro_crate))
}

#' @keywords internal
.validate_rocrate_bag <- function(path, algo = "sha512") {
  # list files inside the given path / top level only
  rocrate_bag_files <- list.files(path, recursive = FALSE)
  
  # check that at least the following files & directory are in the given path
  expected_files_dir <- c("bagit.txt", "data", paste0("manifest-", algo, ".txt"))
  idx <- expected_files_dir %in% rocrate_bag_files
  if (!all(idx)) {
    stop("The given `path` is missing the following:",
         paste0("  - ", expected_files_dir[idx], "\n"))
  }
  
  # list files inside the given path / all levels
  rocrate_bag_files <- list.files(path, recursive = TRUE)
  
}

unbag_rocrate <- function(path, output = path) {
  # check a valid path was given
  if (!file.exists(path)) {
    stop("The given path, `path`, does not exist!")
  }
  
  # check if
}
