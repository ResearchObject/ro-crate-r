#' Validate URL
#'
#' @param x String with URL to validate.
#' @param suffix String with any additional characters to match when validating
#'     the given URL, `x`.
#'
#' @returns Boolean value indicating if the given string (`x) is a valid URL.
#' @keywords internal
#'
#' @source https://stackoverflow.com/a/73952264
.is_valid_url <- function(x, suffix = "") {
  pattern <- paste0("(https?|ftp)://[^ /$.?#].[^\\s]*", suffix, "$")
  grepl(pattern, x)
}

