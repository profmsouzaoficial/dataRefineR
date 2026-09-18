#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    
    fluidPage(
      # Cabeçalho Fixo (Sticky) com fundo branco para sobrepor o conteúdo rolado
      div(style = "position: sticky; top: 0; z-index: 1000; background-color: #ffffff; padding: 15px 0 10px 0; border-bottom: 2px solid #2C3E50; margin-bottom: 20px;",
          div(style = "display: flex; align-items: center;",
              shiny::icon("cogs", class = "fa-2x", style = "color: #2C3E50; margin-right: 15px;"),
              h2(strong("dataRefineR"), style = "margin: 0; color: #2C3E50; letter-spacing: -1px;"),
              span(" | Higienização de Dados Públicos", style = "font-size: 1.5em; color: #7F8C8D; margin-left: 10px; margin-top: 5px;")
          ),
          # O seu @ oficial do GitHub
          div(style = "margin-top: 8px; margin-left: 55px;",
              a(href = "https://github.com/profmsouzaoficial", target = "_blank", 
                style = "color: #34495e; text-decoration: none; font-weight: 600; font-size: 1.1em;",
                shiny::icon("github"), " @profmsouzaoficial"
              )
          )
      ),
      
      # Chamada do módulo principal
      mod_microdatasus_ui("microdatasus_1")
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )
  
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "dataRefineR"
    )
  )
}