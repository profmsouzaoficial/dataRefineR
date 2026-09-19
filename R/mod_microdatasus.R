#' microdatasus UI
#'
#' @param id Internal parameters for {golem}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList div actionButton icon p HTML
#' @importFrom DT DTOutput
mod_microdatasus_ui <- function(id){
  ns <- NS(id)
  tagList(
    div(
      style = "display: flex; justify-content: flex-end; align-items: center; margin-bottom: 8px;",
      actionButton(
        ns("btn_dicionario"), 
        label = " Dicionário de Dados", 
        icon = icon("book"), 
        class = "btn-info btn-sm",
        style = "font-weight: bold;"
      )
    ),
    div(
      style = "width: 100%; overflow-x: auto;",
      DT::DTOutput(ns("tabela_preview"))
    )
  )
}

#' microdatasus Server
#'
#' @noRd
#' @importFrom shiny moduleServer req observeEvent showModal modalDialog modalButton tagList icon p
#' @importFrom DT renderDT datatable
#' @importFrom sf st_drop_geometry
mod_microdatasus_server <- function(id, memoria){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    # --- RENDERIZAÇÃO DA TABELA DE PREVIEW ---
    output$tabela_preview <- DT::renderDT({
      req(memoria$ativa)
      df_completo <- memoria$bases[[memoria$ativa]]
      req(!is.null(df_completo))
      
      # Captura dimensões reais da base completa
      total_linhas <- nrow(df_completo)
      total_colunas <- ncol(df_completo)
      
      # Prepara o preview de até 1000 linhas para exibição fluida
      df_preview <- head(df_completo, 1000)
      
      if(inherits(df_preview, "sf")) {
        df_preview <- sf::st_drop_geometry(df_preview)
      }
      
      tipos <- sapply(df_preview, function(x) class(x)[1])
      nomes_html <- sapply(names(df_preview), function(nome) {
        cor <- if(tipos[[nome]] %in% c("numeric", "integer")) "#27ae60" else if(tipos[[nome]] %in% c("factor", "ordered")) "#c0392b" else "#2980b9"
        paste0("<span style='color:", cor, "; font-weight:bold;'>", nome, "<br><small style='color:#7f8c8d; font-weight:normal;'>", tipos[[nome]], "</small></span>")
      })
      names(df_preview) <- nomes_html
      
      # Legenda dinâmica informando o total real de registros e colunas
      texto_legenda <- paste0(
        "<b>Base Ativa: ", memoria$ativa, "</b> | ",
        "<span style='color: #2980b9;'>Total: ", format(total_linhas, big.mark = ".", decimal.mark = ","), " linhas</span> e ",
        "<span style='color: #27ae60;'>", total_colunas, " variáveis</span> ",
        "<small style='color: #7f8c8d;'>(Exibindo preview de até 1.000 linhas)</small>"
      )
      
      DT::datatable(
        df_preview, 
        escape = FALSE, 
        options = list(
          scrollX = TRUE,               
          scrollCollapse = TRUE, 
          scrollY = "calc(100vh - 240px)", 
          autoWidth = TRUE,             
          paging = FALSE, 
          bInfo = FALSE,
          # Traduz o rótulo de busca para o português
          language = list(
            search = "Busca:",
            sSearch = "Busca:"
          ),
          dom = "<'row'<'col-sm-12'f>>"
        ), 
        class = "display nowrap compact", 
        caption = HTML(texto_legenda)
      )
    })
    
    # --- POPUP / MODAL DO DICIONÁRIO DE DADOS ---
    observeEvent(input$btn_dicionario, {
      req(memoria$ativa)
      df_atual <- memoria$bases[[memoria$ativa]]
      
      variaveis <- names(df_atual)
      tipos_var <- sapply(df_atual, function(x) class(x)[1])
      
      df_dic <- data.frame(
        Variável = variaveis,
        Tipo = tipos_var,
        stringsAsFactors = FALSE
      )
      
      showModal(modalDialog(
        title = tagList(icon("book"), paste("Dicionário de Dados -", memoria$ativa)),
        size = "l",
        easyClose = TRUE,
        footer = modalButton("Fechar"),
        
        p("Relação de variáveis disponíveis nesta base de dados carregada na memória:"),
        
        DT::renderDT({
          DT::datatable(
            df_dic, 
            options = list(pageLength = 10, scrollY = "300px", dom = 'tp'),
            class = "compact stripe"
          )
        })
      ))
    })
    
  })
}