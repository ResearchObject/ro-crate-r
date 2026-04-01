#' Create hexagonal logo
#'
#' Create hexagonal logo for the package.
#'
#' @param subplot Image to use as the main logo.
#' @param dpi Plot resolution (dots-per-inch).
#' @param h_color Colour for hexagon border.
#' @param h_fill Colour to fill hexagon.
#' @param output Output file (hexagonal logo).
#' @param package Title for logo (package name).
#' @param p_color Colour for package name.
#' @param url URL for package repository or website.
#' @param u_size Text size for URL.
#'
#' @returns Hexagonal logo.
#' @keywords internal
hex_logo <- function(
  subplot = system.file("images/ro-crate-w-text.png", package = "rocrateR"),
  dpi = 600,
  h_color = "#000000",
  h_fill = "#FFFFFF",
  output = system.file("images/logo.png", package = "rocrateR"),
  package = "rocrateR",
  p_color = "#54969D",
  url = "https://github.com/ResearchObject/ro-crate-r",
  u_size = 1.25
) {
  hexSticker::sticker(
    subplot = subplot,
    package = package,
    h_color = h_color,
    h_fill = h_fill,
    dpi = dpi,
    s_x = 1.0,
    s_y = 1.0,
    s_width = .7,
    p_x = 1.0,
    p_y = 1.52,
    p_size = 20,
    p_color = p_color,
    url = url,
    u_angle = 30,
    u_color = p_color,
    u_size = u_size,
    u_y = 0.06,
    filename = output
  )
}

# pak::pak("emilioxavier/hexSticker")
hex_logo(
  "inst/images/ro-crate-w-text.png",
  output = "man/figures/logo_hq.png",
  package = "",
  u_size = 6.8,
  dpi = 600
)
hex_logo(
  "inst/images/ro-crate-w-text.png",
  output = "man/figures/logo.png",
  package = "",
  u_size = 3.5,
  dpi = 300
)
