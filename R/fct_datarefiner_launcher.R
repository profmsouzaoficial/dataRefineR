#' Iniciar o dataRefineR
#' @export
dataRefineR <- function(...) {
  suppressMessages(
    suppressWarnings({
      run_app(...)
    })
  )
}