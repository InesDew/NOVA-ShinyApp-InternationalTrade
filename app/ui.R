library(bslib)
library(leaflet)
library(DT)
library(ggplot2)
library(scales)
library(shinythemes)

# Define UI --------------------------------------------------------------------
ui <- fluidPage(
  tags$style(HTML("
    .irs-bar {
      background-color: #58B99D !important;
    }

    .irs-from, .irs-to, .irs-single, .irs-handle > i:first-child {
      background-color: #58B99D !important;
    }
  ")),
  theme = shinytheme("flatly"),
  navbarPage(
    title <- "International Trade Analysis",
    tabPanel("Trade Network Map",
             sidebarLayout(
               sidebarPanel(
                 #Adding logo to sidebar
                 img(src = "logo.svg",width="80%", style = "margin-bottom: 30px;"),
                 #Introducing Inputs for the user to select type of trade, 
                 #country, minimum trade value and years to plot 
                 selectInput(inputId = "trader.map", 
                             label = "Select Imports or Exports:",
                             choices = c("Exports" = "reporter_name","Imports" 
                                         = "partner_name"), 
                             selected = "reporter_name"
                 ),
                 selectInput(inputId = "country.map", 
                             label = "Select Country:",
                             choices = l.countries, 
                             selected = "Ghana"
                 ),
                 sliderInput(inputId = "weight.map",
                             label = "% of Maximum Trade Value:",
                             min = 0,
                             max = 100,
                             value = 0,
                             step = 1,
                             width = "90%"
                 ),
                 sliderInput(inputId = "year.map",
                             label = "Select Year Range:",
                             min = 2000,
                             max = 2021,
                             value = c(2018, 2021),
                             step = 1,
                             sep = "")
               ),
               # Output: Show network
               mainPanel(
                 leafletOutput("network.map"),
                 htmlOutput("text.map"),
                 DTOutput("centralities.map")
               )
             )
    ),
    
    tabPanel("Compare Countries",
             sidebarLayout(
               sidebarPanel(
                 img(src = "logo.svg",width="80%", style = "margin-bottom: 30px;"),
                 selectizeInput(
                   inputId = "country.comp",
                   label = "Country:",
                   choices = c("", levels(as.factor(dt.trade$reporter_name))),
                   selected = c("Italy", "Portugal", "Germany"),
                   multiple = TRUE,
                   options = list(maxItems = 3)
                 ),
                 selectInput("column", "KPI:", 
                             choices = c("Export Value in USD" = 
                                           "export_value_usd",
                                         "Import Value in USD" = 
                                           "import_value_usd",
                                         "Number of Exporting Partners" = 
                                           "num_exporting_partners",
                                         "Number of Importing Partners" = 
                                           "num_importing_partners", 
                                         "Average Export Value per Partner" = 
                                           "avg_export_value_usd",
                                         "Average Import Value per Partner" = 
                                           "avg_import_value_usd",
                                         "Trade Balance in USD" = 
                                           "trade_balance")),
                 sliderInput("year.comp", "Year:", 
                             min = min(dt.merged$year), 
                             max = max(dt.merged$year), 
                             value = c(min(dt.merged$year), max(dt.merged$year)), 
                             step = 1,
                             sep = ""),
                 leafletOutput("map.comp")
               ),
               mainPanel(
                 plotOutput("plot.comp"),
                 htmlOutput("example.comp")
               )
             )
    ),
    tabPanel("Community Analysis",
             sidebarLayout(
               sidebarPanel(
                 img(src = "logo.svg",width="80%", style = "margin-bottom: 30px;"),
                 # Set year range
                 selectInput(inputId = "year.comm",
                             label = "Select Year Range:",
                             choices = c('', levels(as.factor(dt.trade$year))),
                             selected = '2021',
                             multiple = FALSE),
                 h6("The map visualization takes time to load, please wait"),
                 htmlOutput("textKPI.comm")
               ),
               mainPanel(
                 tabsetPanel(
                   tabPanel("Worldmap Plot",
                            leafletOutput("map.comm"),
                            htmlOutput("textMap.comm")
                   ),
                   tabPanel("Network Plot", 
                            plotOutput("network.comm"),
                            dataTableOutput("countries.comm")
                   ),
                   tabPanel("Modularity over Time",
                            plotOutput("modularity.comm"),
                            htmlOutput("textModularity.comm")
                   ),
                   tabPanel("Walktrap Algorithm", 
                            htmlOutput("textWalktrap.comm")
                   )
                 )
               )
             )
    ),
    tabPanel("Descriptives",
             sidebarLayout(
               sidebarPanel(
                 img(src = "logo.svg",width="80%", style = "margin-bottom: 30px;"),
                 selectInput(
                   inputId = "continent.des",
                   label = "Select a continent: ",
                   choices = c(
                     "Europe",
                     "Asia",
                     "Africa",
                     "North America",
                     "South America",
                     "Oceania",
                     "Antarctica"
                   ),
                   selected = c(
                     "Europe",
                     "Asia",
                     "Africa",
                     "North America",
                     "South America",
                     "Oceania",
                     "Antarctica"
                   ),
                   multiple = TRUE
                 )
               ),
               mainPanel(
                 tabsetPanel(
                   tabPanel("Degree Distribution", plotOutput("degree.dist.des"),
                            htmlOutput("text.degree.dist")),
                   tabPanel("Countries per Continent", 
                            plotOutput(outputId = "continent.count.des")),
                   tabPanel("Edge Value Distribution", 
                            plotOutput(outputId = "kpi.chart.des")),
                 ),
                 DTOutput("table.overview.des")
                 
                 
               )
             )),
    tabPanel(
      "Data",
      tabsetPanel(
      tabPanel("Data Overview",
      fluidRow(
        column(
          width = 3,
          img(src = "logo.svg",width="80%", style = "margin-bottom: 30px;"),
        ),
        column(
          width = 3,
          selectInput(
            inputId = "partner.data",
            label = "Partner: ",
            choices = c("", levels(as.factor(
              dt.trade$partner_name
            ))),
            selected = "",
            multiple = FALSE
          )
        ),
        column(
          width = 3,
          selectInput(
            inputId = "reporter.data",
            label = "Reporter: ",
            choices = c("", levels(as.factor(
              dt.trade$reporter_name
            ))),
            selected = "",
            multiple = FALSE
          )
        ),
        column(
          width = 3,
          selectInput(
            inputId = "year.data",
            label = "Year:",
            choices = c("", levels(as.factor(dt.trade$year))),
            selected = "",
            multiple = FALSE
          )
        ),
        style = "margin-bottom: 10px;",
      ),
      DTOutput("table.overview.data", width = "100%")
    ),
    tabPanel("Data Source",
      htmlOutput("source.info.data"),
      DTOutput("source.column.data")
    )
      )
    )
  )
)