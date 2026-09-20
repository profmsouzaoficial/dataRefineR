#' microdatasus UI Function
#'
#' @importFrom shiny NS tagList fluidRow column selectInput selectizeInput sliderInput numericInput actionButton actionLink hr helpText downloadButton h4 conditionalPanel showNotification observeEvent req downloadHandler reactiveValues wellPanel div HTML uiOutput renderUI updateSelectInput textInput p tags icon modalDialog modalButton
#' @importFrom DT DTOutput renderDT datatable
#' @importFrom shinyjs useShinyjs disabled enable disable show hide
#' @importFrom dplyr left_join inner_join full_join
#' @importFrom sf st_drop_geometry
#' @noRd 
mod_microdatasus_ui <- function(id){
  ns <- NS(id)
  
  js_color <- I("{
    item: function(item, escape) { var c = {'character':'#2980b9', 'numeric':'#27ae60', 'integer':'#27ae60', 'factor':'#c0392b', 'logical':'#f39c12', 'Date':'#8e44ad'}; return '<div><span style=\"color:' + (c[item.value]||'#333') + '; font-weight:bold;\">' + escape(item.label) + '</span></div>'; },
    option: function(item, escape) { var c = {'character':'#2980b9', 'numeric':'#27ae60', 'integer':'#27ae60', 'factor':'#c0392b', 'logical':'#f39c12', 'Date':'#8e44ad'}; return '<div><span style=\"color:' + (c[item.value]||'#333') + '; font-weight:bold;\">' + escape(item.label) + '</span></div>'; }
  }")
  
  tagList(
    shinyjs::useShinyjs(), 
    
    tags$head(tags$style(HTML("
      .loader-linha { height: 4px; width: 100%; background-color: #ecf0f1; border-radius: 2px; overflow: hidden; margin-top: 4px; display: none; }
      .loader-linha::after { content: ''; display: block; height: 100%; width: 30%; background-color: #2980b9; animation: correr 1.2s infinite ease-in-out; }
      @keyframes correr { 0% { margin-left: -30%; } 100% { margin-left: 100%; } }
      .link-dicionario:hover { color: #f1c40f !important; text-decoration: none; }
    "))),
    
    div(style = "display: flex; gap: 20px; align-items: flex-start; height: calc(100vh - 120px); width: 100%;",
        
        # LADO ESQUERDO: Painel de Controle e Ferramentas
        div(style = "flex: 0 0 350px; max-width: 350px; min-width: 350px; height: 100%; overflow-y: auto; padding-right: 15px; padding-bottom: 20px;", 
            
            wellPanel(style = "background-color: #2c3e50; color: white; border: none; padding: 10px 15px;",
                      h4(shiny::icon("database"), " Gerenciador de Memória", style = "color: white; margin-top: 0;"),
                      uiOutput(ns("ui_seletor_base_ativa")),
                      helpText("As transformações ao lado refletem a base selecionada acima.", style = "color: #bdc3c7; font-size: 0.85em; margin-bottom: 5px;"),
                      
                      # NOVO: Botão/Link discreto para o Dicionário de Dados
                      actionLink(ns("btn_dicionario_painel"), 
                                 HTML("<i class='fa fa-book-open'></i> Consultar Manuais e Dicionários"), 
                                 class = "link-dicionario",
                                 style = "color: #ecf0f1; font-size: 0.85em; display: inline-block; margin-top: 5px; text-decoration: underline; cursor: pointer;")
            ),
            
            wellPanel(style = "background-color: #f8f9fa; border-top: 3px solid #2980b9;",
                      h4(shiny::icon("cloud-download-alt"), " Extração de Dados"),
                      
                      selectInput(ns("fonte_dados"), "Fonte Institucional:", 
                                  choices = c("DATASUS", "IBGE (SIDRA)", "IPEA (Ipeadata)", "GEOBR (Malhas Territoriais)"), width = "100%"),
                      
                      # 1. PAINEL DATASUS
                      conditionalPanel(
                        condition = sprintf("input['%s'] == 'DATASUS'", ns("fonte_dados")),
                        selectInput(ns("sistema"), "Sistema:", choices = c("SIH-RD", "SIH-RJ", "SIH-SP", "SIH-ER", "SIM-DO", "SIM-DOFET", "SIM-DOEXT", "SIM-DOINF", "SIM-DOMAT", "SINASC", "CNES-LT", "CNES-ST", "CNES-DC", "CNES-EQ", "CNES-SR", "CNES-HB", "CNES-PF", "CNES-EP", "CNES-RC", "CNES-IN", "CNES-EE", "CNES-EF", "CNES-GM", "SIA-AB", "SIA-ABO", "SIA-ACF", "SIA-AD", "SIA-AN", "SIA-AM", "SIA-AQ", "SIA-AR", "SIA-ATD", "SIA-PA", "SIA-PS", "SIA-SAD", "SINAN-DENGUE", "SINAN-CHIKUNGUNYA", "SINAN-ZIKA", "SINAN-MALARIA", "SINAN-CHAGAS", "SINAN-LEISHMANIOSE-VISCERAL", "SINAN-LEISHMANIOSE-TEGUMENTAR", "SINAN-LEPTOSPIROSE"), width = "100%"),
                        selectizeInput(ns("estado"), "Estado (UF):", choices = c("Todos", "AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO"), selected = "MG", multiple = TRUE, options = list(plugins = list('remove_button')), width = "100%"),
                        sliderInput(ns("ano"), "Período (Anos):", min = 2010, max = as.numeric(format(Sys.Date(), "%Y")), value = c(2020, 2021), sep = "", step = 1, width = "100%")
                      ),
                      
                      # 2. PAINEL IBGE
                      conditionalPanel(
                        condition = sprintf("input['%s'] == 'IBGE (SIDRA)'", ns("fonte_dados")),
                        selectInput(ns("ibge_tabela"), "Selecione a Tabela/Pesquisa:", 
                                    choices = c("População Residente (Estimativa)" = "6579", "Censo Demográfico: População por Idade e Sexo" = "9605", "PIB dos Municípios" = "5938", "Censo Demográfico: Domicílios" = "9606", "PNAD Contínua: Força de Trabalho" = "6318"), width = "100%")
                      ),
                      
                      # 3. PAINEL IPEA
                      conditionalPanel(
                        condition = sprintf("input['%s'] == 'IPEA (Ipeadata)'", ns("fonte_dados")),
                        selectInput(ns("ipea_serie"), "Selecione a Série Histórica:", 
                                    choices = c("Índice de Preços ao Consumidor (IPCA)" = "PRECOS12_IPCA12", "Taxa de Desocupação (Desemprego)" = "PNADC12_TDESOC12", "Rendimento Médio Real" = "PNADC12_RDTRA12", "Taxa de Câmbio (Comercial)" = "BM12_ERC12", "Salário Mínimo Real" = "MTE12_SALMINRE12"), width = "100%")
                      ),
                      
                      # 4. PAINEL GEOBR
                      conditionalPanel(
                        condition = sprintf("input['%s'] == 'GEOBR (Malhas Territoriais)'", ns("fonte_dados")),
                        selectInput(ns("geobr_malha"), "Nível Territorial (Mapa):", 
                                    choices = c("Municípios" = "municipality", "Estados" = "state", "Regiões de Saúde" = "health_region", "País (Brasil)" = "country"), width = "100%"),
                        selectizeInput(ns("geobr_uf"), "Estado (UF):", choices = c("Todos", "AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO"), selected = "MG", multiple = TRUE, options = list(plugins = list('remove_button')), width = "100%"),
                        numericInput(ns("geobr_ano"), "Ano de Referência:", value = 2020, min = 1872, max = 2024, width = "100%"),
                        helpText("Nota: Mapas serão cruzados com suas outras bases de dados via Join.", style = "color: #e67e22; font-size: 0.85em;")
                      ),
                      
                      textInput(ns("nome_nova_base"), "Salvar na memória como:", value = "dados_brutos", width = "100%"),
                      actionButton(ns("extrair"), "Baixar e Armazenar", class = "btn-primary", style = "width: 100%; margin-top: 5px;"),
                      div(id = ns("loader_extrair"), class = "loader-linha")
            ),
            
            shinyjs::disabled(
              div(id = ns("paineis_dependentes"),
                  
                  wellPanel(style = "background-color: #f8f9fa; border-top: 3px solid #8e44ad;",
                            h4(shiny::icon("link"), " Cruzamento (Join)"),
                            uiOutput(ns("ui_join_bases")),
                            fluidRow(
                              column(6, uiOutput(ns("ui_join_chave_a"))),
                              column(6, uiOutput(ns("ui_join_chave_b")))
                            ),
                            selectInput(ns("tipo_join"), "Tipo de Junção:", choices = c("Left Join (Manter Base A)" = "left", "Inner Join (Interseção)" = "inner", "Full Join (Unir Tudo)" = "full")),
                            textInput(ns("nome_base_join"), "Salvar resultado como:", value = "base_cruzada"),
                            
                            actionButton(ns("executar_join"), "Executar Cruzamento", class = "btn-info", style = "width: 100%; color: white; font-weight: bold;"),
                            div(id = ns("loader_join"), class = "loader-linha")
                  ),
                  
                  wellPanel(style = "background-color: #f8f9fa; border-top: 3px solid #f39c12;",
                            h4(shiny::icon("tools"), " Transformação da Base Ativa"),
                            fluidRow(
                              column(6, style="padding-right:5px;", selectizeInput(ns("tipo_de"), "De:", choices = c("Texto" = "character", "Numérico" = "numeric", "Inteiro" = "integer", "Categoria" = "factor", "Lógico" = "logical", "Data" = "Date"), options = list(render = js_color), width = "100%")),
                              column(6, style="padding-left:5px;", selectizeInput(ns("tipo_para"), "Para:", choices = c("Categoria" = "factor", "Texto" = "character", "Numérico" = "numeric", "Inteiro" = "integer", "Lógico" = "logical", "Data" = "Date"), options = list(render = js_color), width = "100%"))
                            ),
                            uiOutput(ns("ui_seletor_coluna")),
                            
                            actionButton(ns("aplicar_transf"), "Aplicar", class = "btn-warning", style = "width: 100%; color: #fff; font-weight: bold; margin-bottom: 5px;"),
                            div(id = ns("loader_transf"), class = "loader-linha", style = "margin-bottom: 15px;"),
                            
                            hr(style = "border-top: 1px solid #bdc3c7;"),
                            h4(shiny::icon("save"), " Exportação"),
                            selectInput(ns("tipo_arquivo"), "Formato:", choices = c("CSV" = "csv", "Excel" = "xlsx", "SPSS" = "spss", "R Data (.rds)*" = "rds"), width = "100%"),
                            helpText("*O formato .rds preserva a geometria de mapas geobr.", style = "font-size: 0.8em;"),
                            
                            downloadButton(ns("exportar_dados"), "Baixar Base Ativa", style = "width: 100%;")
                  )
              )
            )
        ),
        
        # LADO DIREITO: Tabela limpa sem botões avulsos!
        div(style = "flex: 1; min-width: 0; width: 100%; height: 100%; overflow-x: auto; overflow-y: hidden; padding-bottom: 10px;",
            conditionalPanel(
              condition = sprintf("input['%s'] == 0", ns("extrair")),
              div(style = "text-align: center; margin-top: 150px; color: #bdc3c7;",
                  shiny::icon("project-diagram", class = "fa-4x"),
                  h3("Nenhuma base de dados na memória."),
                  p("Faça a primeira extração à esquerda para iniciar."))
            ),
            
            DT::DTOutput(ns("tabela_preview"), width = "100%")
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
    
    memoria <- reactiveValues(bases = list(), ativa = NULL)
    
    output$ui_seletor_base_ativa <- renderUI({
      req(length(names(memoria$bases)) > 0)
      selectInput(ns("base_ativa"), "Base Selecionada para Análise:", choices = names(memoria$bases), selected = memoria$ativa, width = "100%")
    })
    
    observeEvent(input$base_ativa, { memoria$ativa <- input$base_ativa })
    
    observeEvent(input$extrair, {
      req(input$nome_nova_base)
      
      shinyjs::disable("extrair")
      shinyjs::show("loader_extrair")
      on.exit({
        shinyjs::enable("extrair")
        shinyjs::hide("loader_extrair")
      })
      
      tryCatch({
        dados_processados <- NULL
        nome_fonte <- input$fonte_dados
        
        if(nome_fonte == "DATASUS") {
          require(microdatasus)
          showNotification("Conectando ao DATASUS...", type = "message", duration = 8)
          uf_alvo <- if("Todos" %in% input$estado) "all" else input$estado
          dados_brutos <- microdatasus::fetch_datasus(year_start = input$ano[1], year_end = input$ano[2], uf = uf_alvo, information_system = input$sistema)
          dados_processados <- switch(input$sistema, "SIM-DO" = microdatasus::process_sim(dados_brutos), "SINASC" = microdatasus::process_sinasc(dados_brutos), "SIH-RD" = microdatasus::process_sih(dados_brutos), dados_brutos)
          
        } else if(nome_fonte == "IBGE (SIDRA)") {
          require(sidrar)
          req(input$ibge_tabela)
          showNotification("Conectando à API do SIDRA/IBGE...", type = "message", duration = 8)
          dados_processados <- sidrar::get_sidra(x = input$ibge_tabela)
          
        } else if(nome_fonte == "IPEA (Ipeadata)") {
          require(ipeadatar)
          req(input$ipea_serie)
          showNotification("Conectando ao Ipeadata...", type = "message", duration = 8)
          dados_processados <- ipeadatar::ipeadata(input$ipea_serie)
          
        } else if(nome_fonte == "GEOBR (Malhas Territoriais)") {
          require(geobr)
          require(sf)
          req(input$geobr_malha, input$geobr_ano)
          showNotification("Baixando malhas espaciais...", type = "message", duration = 8)
          
          uf_alvo <- if("Todos" %in% input$geobr_uf) "all" else input$geobr_uf
          
          if(input$geobr_malha == "municipality") {
            dados_processados <- geobr::read_municipality(code_muni = uf_alvo, year = input$geobr_ano)
          } else if(input$geobr_malha == "state") {
            dados_processados <- geobr::read_state(code_state = uf_alvo, year = input$geobr_ano)
          } else if(input$geobr_malha == "health_region") {
            dados_processados <- geobr::read_health_region(year = input$geobr_ano)
            if(uf_alvo != "all" && "abbrev_state" %in% names(dados_processados)) {
              dados_processados <- subset(dados_processados, abbrev_state %in% uf_alvo)
            }
          } else if(input$geobr_malha == "country") {
            dados_processados <- geobr::read_country(year = input$geobr_ano)
          }
        }
        
        if(is.null(dados_processados) || (is.data.frame(dados_processados) && nrow(dados_processados) == 0)) {
          stop("A base retornou vazia ou o download foi interrompido.")
        }
        
        nome_base <- input$nome_nova_base
        memoria$bases[[nome_base]] <- dados_processados
        memoria$ativa <- nome_base
        
        shinyjs::enable("paineis_dependentes")
        showNotification(paste("Base", nome_base, "salva na memória!"), type = "default")
        
      }, error = function(e) { 
        showNotification(paste("Erro ao extrair dados:", e$message), type = "error", duration = 12) 
      })
    })
    
    output$ui_join_bases <- renderUI({
      req(length(names(memoria$bases)) >= 1)
      tagList(
        selectInput(ns("join_base_a"), "Base A (Esquerda):", choices = names(memoria$bases), selected = names(memoria$bases)[1]),
        selectInput(ns("join_base_b"), "Base B (Direita):", choices = names(memoria$bases), selected = names(memoria$bases)[length(names(memoria$bases))])
      )
    })
    
    output$ui_join_chave_a <- renderUI({
      req(input$join_base_a, memoria$bases[[input$join_base_a]])
      selectInput(ns("chave_a"), "Chave A:", choices = names(memoria$bases[[input$join_base_a]]))
    })
    
    output$ui_join_chave_b <- renderUI({
      req(input$join_base_b, memoria$bases[[input$join_base_b]])
      selectInput(ns("chave_b"), "Chave B:", choices = names(memoria$bases[[input$join_base_b]]))
    })
    
    observeEvent(input$executar_join, {
      req(input$join_base_a, input$join_base_b, input$chave_a, input$chave_b, input$nome_base_join)
      
      shinyjs::disable("executar_join")
      shinyjs::show("loader_join")
      on.exit({
        shinyjs::enable("executar_join")
        shinyjs::hide("loader_join")
      })
      
      tryCatch({
        df_a <- memoria$bases[[input$join_base_a]]
        df_b <- memoria$bases[[input$join_base_b]]
        by_vector <- setNames(input$chave_b, input$chave_a)
        
        resultado <- switch(input$tipo_join,
                            "left" = dplyr::left_join(df_a, df_b, by = by_vector),
                            "inner" = dplyr::inner_join(df_a, df_b, by = by_vector),
                            "full" = dplyr::full_join(df_a, df_b, by = by_vector))
        
        memoria$bases[[input$nome_base_join]] <- resultado
        memoria$ativa <- input$nome_base_join
        showNotification("Cruzamento realizado com sucesso!", type = "default")
      }, error = function(e) { showNotification("Erro no Join. As chaves precisam ser da mesma classe.", type = "error", duration = 8) })
    })
    
    output$ui_seletor_coluna <- renderUI({
      req(memoria$ativa, input$tipo_de) 
      df <- memoria$bases[[memoria$ativa]]
      classes <- sapply(df, function(x) class(x)[1])
      col_validas <- names(df)[classes == input$tipo_de]
      if(length(col_validas) == 0) return(helpText("Nenhuma variável encontrada."))
      selectizeInput(ns("coluna_alvo"), "Selecionar Variáveis:", choices = col_validas, multiple = TRUE, options = list(plugins = list('remove_button')), width = "100%")
    })
    
    observeEvent(input$aplicar_transf, {
      req(memoria$ativa, input$coluna_alvo, input$tipo_para)
      
      shinyjs::disable("aplicar_transf")
      shinyjs::show("loader_transf")
      on.exit({
        shinyjs::enable("aplicar_transf")
        shinyjs::hide("loader_transf")
      })
      
      df <- memoria$bases[[memoria$ativa]]
      cols <- input$coluna_alvo
      destino <- input$tipo_para
      tryCatch({
        suppressWarnings({
          for(col in cols) {
            if(destino == "numeric") df[[col]] <- as.numeric(as.character(df[[col]]))
            else if (destino == "integer") df[[col]] <- as.integer(as.character(df[[col]]))
            else if (destino == "factor") df[[col]] <- as.factor(df[[col]])
            else if (destino == "character") df[[col]] <- as.character(df[[col]])
            else if (destino == "logical") df[[col]] <- as.logical(as.character(df[[col]]))
            else if (destino == "Date") df[[col]] <- as.Date(as.character(df[[col]]))
          }
        })
        memoria$bases[[memoria$ativa]] <- df 
        showNotification("Variáveis transformadas!", type = "default")
      }, error = function(e) { showNotification("Erro de conversão.", type = "error") })
    })
    
    # --- RENDERIZAÇÃO DA TABELA (Agora limpa e nativa) ---
    output$tabela_preview <- DT::renderDT({
      req(memoria$ativa)
      df_completo <- memoria$bases[[memoria$ativa]]
      req(!is.null(df_completo))
      
      total_linhas <- nrow(df_completo)
      total_colunas <- ncol(df_completo)
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
    
    # --- POPUP / MODAL DO DICIONÁRIO DE DADOS (Acionado pelo link do painel) ---
    observeEvent(input$btn_dicionario_painel, {
      req(memoria$ativa)
      df_atual <- memoria$bases[[memoria$ativa]]
      
      variaveis <- names(df_atual)
      tipos_var <- sapply(df_atual, function(x) class(x)[1])
      
      df_dic <- data.frame(
        Variável = variaveis,
        Tipo = tipos_var,
        stringsAsFactors = FALSE
      )
      
      # Tabela HTML estruturada e bonita com todos os links que você forneceu!
      tabela_links_html <- HTML("
        <div style='background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin-bottom: 20px; border-left: 4px solid #27ae60;'>
          <h5 style='margin-top: 0; font-weight: bold; color: #2c3e50;'><i class='fa fa-github'></i> Repositório Central (Recomendado)</h5>
          <p>Acesse os dicionários estruturados do DATASUS (SIM, SINASC, SIH, etc.) em formato padronizado:</p>
          <ul style='margin-bottom: 15px;'>
            <li><a href='https://github.com/anapaulagomes/datasus-dicionarios/' target='_blank'><b>Dicionários DATASUS - GitHub (anapaulagomes)</b></a></li>
          </ul>
          
          <h5 style='font-weight: bold; color: #2c3e50;'><i class='fa fa-list-alt'></i> Tabela de Manuais e Dicionários Oficiais</h5>
          <div style='max-height: 200px; overflow-y: auto; border: 1px solid #ddd; border-radius: 4px;'>
            <table class='table table-striped table-hover table-sm' style='margin-bottom: 0; font-size: 0.85em; background-color: white;'>
              <thead style='position: sticky; top: 0; background-color: #ecf0f1; z-index: 1;'>
                <tr><th>Sistema/Fonte</th><th>Descrição da Base</th><th>Link Oficial</th></tr>
              </thead>
              <tbody>
                <tr><td>SIA/SUS</td><td>Produção Ambulatorial (PA, APACs, SAD, Boletins Individuais)</td><td><a href='ftp://ftp.datasus.gov.br/dissemin/publicos/SIASUS/200801_/Doc/Informe_Tecnico_SIASUS_2019_07.pdf' target='_blank'>Informe Técnico SIA/SUS</a></td></tr>
                <tr><td>SIM/SUS</td><td>Dados sobre mortalidade no país</td><td><a href='https://opendatasus.saude.gov.br/pt_BR/dataset/sim' target='_blank'>OpenDataSUS - SIM</a></td></tr>
                <tr><td>e-SUS AB (ABP)</td><td>Problema/Condição Avaliada (CIAP-2)</td><td><a href='https://integracao.esusab.ufsc.br/ledi/documentacao/estrutura_arquivos/dicionario-fai.html#listaciapcondicaoavaliada' target='_blank'>Dicionário FAI</a></td></tr>
                <tr><td>e-SUS AB (ABEX)</td><td>Exames solicitados/avaliados (Tabela SUS)</td><td><a href='https://integracao.esusab.ufsc.br/ledi/documentacao/estrutura_arquivos/dicionario-fai.html#listaexames' target='_blank'>Dicionário Exames</a></td></tr>
                <tr><td>e-SUS AB (ABPG)</td><td>Procedimentos clínicos realizados</td><td><a href='https://integracao.esusab.ufsc.br/ledi/documentacao/estrutura_arquivos/dicionario-fp.html#procedimentos-da-ficha' target='_blank'>Dicionário de Procedimentos</a></td></tr>
                <tr><td>e-SUS AB (ABPO)</td><td>Procedimentos odontológicos realizados</td><td><a href='https://integracao.esusab.ufsc.br/ledi/documentacao/estrutura_arquivos/dicionario-fao.html#listaprocedimentosrealizados' target='_blank'>Dicionário Odontológico</a></td></tr>
                <tr><td>Terminologia</td><td>Classificação Internacional de Doenças (CID-10)</td><td><a href='https://rts.saude.gov.br/#/cid' target='_blank'>RTS Saúde - CID-10</a></td></tr>
                <tr><td>Terminologia</td><td>Classificação Int. de Atenção Primária (CIAP-2)</td><td><a href='https://rts.saude.gov.br/#/ciap2' target='_blank'>RTS Saúde - CIAP-2</a></td></tr>
              </tbody>
            </table>
          </div>
        </div>
      ")
      
      showModal(modalDialog(
        title = tagList(icon("book"), paste("Manuais e Dicionários -", memoria$ativa)),
        size = "l",
        easyClose = TRUE,
        footer = modalButton("Fechar"),
        
        tabela_links_html,
        
        p("Relação das variáveis presentes na sua base de dados atual:"),
        
        DT::renderDT({
          DT::datatable(
            df_dic, 
            options = list(pageLength = 8, scrollY = "200px", dom = 'tp'),
            class = "compact stripe"
          )
        })
      ))
    })
    
    output$exportar_dados <- downloadHandler(
      filename = function() { paste0(memoria$ativa, ".", input$tipo_arquivo) },
      content = function(file) { 
        df_final <- memoria$bases[[memoria$ativa]]
        
        if(inherits(df_final, "sf") && input$tipo_arquivo != "rds") {
          df_final <- sf::st_drop_geometry(df_final)
        }
        
        switch(input$tipo_arquivo, "csv" = write.csv2(df_final, file, row.names=F), "xlsx" = writexl::write_xlsx(df_final, file), "rds" = saveRDS(df_final, file), "spss" = haven::write_sav(df_final, file))
      }
    )
  })
}