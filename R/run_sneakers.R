#' Launch Sneakers Shiny Application
#'
#' Opens an interactive Shiny application that shows current sneaker prices
#' and attempts to forecast future prices.
#' @export
#' @importFrom shiny runApp
run_sneakers = function() {
  
  appDir = system.file("sneakersApp", package = "sneakers")
  if (appDir == "") {
    stop("Could not find `shiny` directory. Try re-installing `sneakers`.", call. = FALSE)
  }
  
  shiny::runApp(appDir, display.mode = "normal")
}
