#' Iniciar o dataRefineR
#' @export
dataRefineR <- function(...) {
  suppressPackageStartupMessages(
    suppressWarnings({
      run_app(...)
    })
  )
}