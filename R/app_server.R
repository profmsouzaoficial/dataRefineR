#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  
  # Replicando o ecossistema do seu Estudo Dirigido
  library(tidyverse)
  library(sf)
  library(geobr)
  
  mod_microdatasus_server("microdatasus_1")
}