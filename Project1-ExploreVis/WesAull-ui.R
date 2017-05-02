library(shinydashboard)
library(ggvis)

# For dropdown menu
actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}

ui <- dashboardPage(
  dashboardHeader(title = "Spinoff Study"),
  dashboardSidebar(
  sidebarMenu(
    menuItem("Return Overview", tabName = "Return_Overview", icon = icon("Return Overview")),
    menuItem("Return vs. Benchmark Index", tabName = "Return_v_SP500", icon = icon("Return v. S&P 500")),   
    menuItem("Spin Characteristics", tabName = "Spin_Char", icon = icon("Spin Characteristics")),
    menuItem("Predictor Exploration", tabName = "Predictor_Explor", icon = icon("Predictor Exploration"))
  )
),
  dashboardBody(
    tags$style(HTML(".box-header{background:#d2d2d2; color:#d83000; text-align:center;}")),
    tabItems(
    # First tab content
      tabItem(tabName = "Return_Overview",
            fluidRow(
              box(width = 6,
                  selectInput("spin_year1", label = h4("Spin Year"),
                              choices = list("2009" = "2009", "2010" = "2010", "2011" = "2011",
                                             "2012" = "2012","2013" = "2013","2014" = "2014"), selected = "2009")),
              box(width=12,
                  plotOutput("plot1", height = 430, width=650)),
              infoBoxOutput("avgBox", width = 6),
              infoBoxOutput("medianBox", width = 6))
              ),
    
    # Second tab content
      tabItem(tabName = "Return_v_SP500",
              fluidRow(
                box(width = 6,
                    selectInput("spin_year2", label = h4("Spin Year"),
                                choices = list("2009" = "2009", "2010" = "2010", "2011" = "2011",
                                               "2012" = "2012","2013" = "2013","2014" = "2014"), selected = 1)),
                box(width=12,
                    plotOutput("relplot1", height = 430, width=650)),
                box(width = 6,
                    infoBoxOutput("avgrelBox", width = 16))
              )),
    # Third tab content
      tabItem(tabName = "Spin_Char",
              selectInput("densxvar", "X-Axis Variable", axis_vars, selected = "ff.mkt.val"),
              box(width=12,
                plotOutput("denscurve", height = 500, width=650))),
    # Fourth tab content
      tabItem(tabName = "Predictor_Explor",
              fluidRow(
                column(3,
                  wellPanel(
                    h4("Filter"),
                     selectInput("start_point", "Starting Point of Investment in Spin",
                      c('6 Months Post-Spin', '12 Months Post-Spin'), selected = "6 Months Post-Spin")),
                   wellPanel(
                    selectInput("xscatter", "X-Axis Variable", axis_vars, selected = "ff.ltd.tcap"),
                    sliderInput("xcut", "Deciles of X Values to View", 0, 100, step = 10, value = c(0,100)),              
                    selectInput("zvar", "Color Gradient Variable", axis_vars, selected = "ff.oper.inc.tcap"),
                      tags$small(
                        " Note:", tags$br(), "EBIT = Earnings Before Interest & Taxes,", tags$br(), "a.k.a. Operating Income.", tags$br(), 
                        " EBITDA = Earnings Before Interest, Taxes, Depreciation, & Amortization,", tags$br(),
                        " an Approximation of Operating Cash Flows.", tags$br(), "FCF = Free Cash Flow, or Operating Cash",
                        " Flow - Capital Expenditures,", tags$br(), "an Approximation of Cash Return Potentially",
                        " Available to Shareholders.", tags$br(), "Enterprise Value = (Market Value of Equity and",
                        " Debt) - Cash,", tags$br(), "an Approximation",
                        " of the Market Value of the Company's Assets minus its Cash,", tags$br(), "also its'",
                        " Take-out Price of the Company / Company's Assets."
                       )
                    )),
                column(9,
                       plotOutput("predictor_plot")
        )
    )
  )
)
)
)