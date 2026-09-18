# dataRefineR 📊

> **Interface gráfica e interativa para extração, higienização e exportação de bases de dados públicos.**

Autoria: **Márcio Souza** (`@profmsouzaoficial`)  
Universidade Federal de Juiz de Fora (UFJF) - Campus Governador Valadares  
Departamento de Ciências Básicas da Vida (DCBV)  

---

## 🚀 Sobre o Pacote

O `dataRefineR` é uma ferramenta desenvolvida sob o framework `{golem}` do R que simplifica o acesso, cruzamento e transformação de grandes bases de dados públicas brasileiras (como DATASUS/SIM/SINASC, IBGE/SIDRA, Ipeadata e malhas territoriais do `geobr`), eliminando a barreira de código para análises territoriais e de saúde pública.

## 📦 Instalação

Você pode instalar a versão de desenvolvimento diretamente do GitHub utilizando o pacote `devtools`:

```r
# Instalar odevtools caso não tenha
if (!require("devtools")) install.packages("devtools")

# Instalar o dataRefineR direto do GitHub do professor
devtools::install_github("profmsouzaoficial/dataRefineR")
