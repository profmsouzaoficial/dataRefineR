#' microdatasus UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList fluidRow column selectInput numericInput actionButton hr helpText downloadButton h4 conditionalPanel showNotification observeEvent req tryCatch downloadHandler reactiveVal
#' @importFrom DT DTOutput renderDT datatable
#' @importFrom microdatasus fetch_datasus process_sim process_sinasc process_sih
mod_microdatasus_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      column(width = 4,
             selectInput(ns("sistema"), "Sistema de Informação:", 
                         choices = c("SIM-DO", "SINASC", "SIH-RD")),
             selectInput(ns("estado"), "Estado (UF):", 
                         choices = c("MG", "SP", "RJ", "ES", "BA", "PR", "SC", "RS")),
             numericInput(ns("ano"), "Ano Base:", value = 2021, min = 2010, max = 2024),
             
             actionButton(ns("extrair"), "Extrair e Limpar Dados", class = "btn-primary", style = "width: 100%;"),
             hr(),
             helpText("Exporte a base tratada para o seu computador:"),
             downloadButton(ns("exportar_csv"), "Exportar CSV (Excel)", style = "width: 100%;")
      ),
      column(width = 8,
             conditionalPanel(
               condition = sprintf("input['%s'] == 0", ns("extrair")),
               h4("Selecione os parâmetros ao lado e clique em 'Extrair e Limpar Dados'.")
             ),
             DT::DTOutput(ns("tabela_preview"))
      )
    )
  )
}

#' microdatasus Server Functions
#'
#' @noRd 
mod_microdatasus_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    dados_reativos <- reactiveVal(NULL)
    
    observeEvent(input$extrair, {
      req(input$sistema, input$estado, input$ano)
      
      showNotification("Conectando ao DATASUS. Isso pode demorar...", type = "message", duration = 8)
      
      tryCatch({
        # 1. Baixa os dados brutos
        dados_brutos <- microdatasus::fetch_datasus(
          year_start = input$ano, year_end = input$ano, 
          uf = input$estado, information_system = input$sistema
        )
        
        # 2. Aplica o processamento automático correto para cada sistema
        showNotification("Limpando e categorizando variáveis...", type = "message", duration = 5)
        
        dados_processados <- switch(input$sistema,
                                    "SIM-DO" = microdatasus::process_sim(dados_brutos),
                                    "SINASC" = microdatasus::process_sinasc(dados_brutos),
                                    "SIH-RD" = microdatasus::process_sih(dados_brutos),
                                    dados_brutos
        )
        
        # 3. Salva na memória e avisa o aluno
        dados_reativos(dados_processados)
        showNotification("Sucesso! Base pronta para análise.", type = "default")
        
      }, error = function(e) {
        showNotification(paste("Erro:", e$message), type = "error", duration = 10)
      })
    })
    
    output$tabela_preview <- DT::renderDT({
      req(dados_reativos())
      DT::datatable(head(dados_reativos(), 100), 
                    options = list(scrollX = TRUE, pageLength = 5),
                    caption = "Pré-visualização (100 primeiras linhas)")
    })
    
    output$exportar_csv <- downloadHandler(
      filename = function() { paste0("datasus_", input$sistema, "_", input$estado, "_", input$ano, ".csv") },
      content = function(file) { write.csv2(dados_reativos(), file, row.names = FALSE) }
    )
  })
}