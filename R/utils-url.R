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
#' @examples
#' url <- c(
#'   "w3id.org/ro/crate/1.2/context",
#'   "http://w3id.org/ro/crate/1.2",
#'   "http://w3id.org/ro/crate/1.2/context",
#'   "https://w3id.org/ro/crate/1.2/context",
#'   "123",
#'   "https://w3id.org/ro/crate/1.1/context",
#'   "https://w3id.org/ro/crate/1.0/context"
#' )
#' rocrateR:::.is_valid_url(url)
#' rocrateR:::.is_valid_url(url, suffix = "/context")
.is_valid_url <- function(x, suffix = "") {
  pattern <- paste0("(https?|ftp)://[^ /$.?#].[^\\s]*", suffix, "$")
  grepl(pattern, x)
}

