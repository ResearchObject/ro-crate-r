#' Get root directory of zip file
#'
#' @param zip_filename String with path to valid Zip file
#'
#' @returns String with root directory for the given Zip file
#' @keywords internal
.get_zip_root <- function(zip_filename) {
  # list files
  files <- utils::unzip(zip_filename, list = TRUE)
  # extract root directory for each file inside the given zip
  root_dir <- seq_len(nrow(files)) |>
    sapply(\(i) strsplit(files[i, "Name"], "/")[[1]][1]) |>
    unique()
  if (length(root_dir) != 1) {
    return("")
  }
  return(root_dir)
}