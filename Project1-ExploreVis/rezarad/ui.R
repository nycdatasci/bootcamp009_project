## ui.R ##

navbarPage("NYC MTA Subway Ridership",
  id = "nav",
  position = "fixed-bottom",
  collapsible = TRUE,
  fluid = TRUE,

  tabPanel("Map",
     icon = icon("subway"),
     div(class="outer",

        tags$head(includeCSS("./www/custom.css")),

        leafletOutput("mtamap", width = "100%", height = "100%"),
        absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE,
                    draggable = TRUE, top = 40, left = "auto", right = 60, bottom = "auto",
                    width = 480, height = "auto",
                    verticalLayout(
                      verticalLayout(
                        h3(HTML("Click on a Station to Generate Data:")),
                        h4("Subway Line:"),selectizeInput("line", label = NULL, names(mta_lines))),
                        h4(HTML(paste("Station Name:", uiOutput("station_name", inline = T), sep=" "))),
                        h4(HTML(paste("Number of Turnstiles:", uiOutput("ts_per_station", inline = T), sep=" "))),
                        # h4(HTML(paste("Total Entries:", uiOutput("entries_year", inline = T), sep=" "))),
                        h4(HTML(paste("Entries This Year:", uiOutput("entries_year", inline = T), sep=" "))),
                        h4(HTML(paste("Exits This Year:", uiOutput("exits_year", inline = T), sep=" "))),
                        h4(HTML(paste("Busiest Day:", uiOutput("busiest_day", inline = T), sep=" "))),
                        h4(HTML(paste("Entries/Exit Ratio:", uiOutput("entries_exits_ratio", inline = T), sep=" ")))
                      # h4(dateRangeInput("daterange_turnstile",
                      #                label = "Select Date Range:",
                      #                start = "2017-03-01",
                      #                end = "2017-04-01",
                      #                min = "2017-01-01",
                      #                max = "2017-04-01",
                      #                format = "mm/dd/yyyy",
                      #                separator = "-")),
                      # h4(verbatimTextOutput("daterange_turnstile")),
                      # h4(selectizeInput("start_time", label = "Start Time:", hour)),
                      # h4(selectizeInput("end_time", label = "Stop Time:", hour)),
                      
                      )
                      ),
        tags$div(id="cite", "Data Provided by New York City's Metropolitan Transportation Authority (MTA).")
        )
      ),
  tabPanel("Tables",
          icon = icon("table"),
          sidebarLayout(
            sidebarPanel(
              h4(HTML(paste("Subway Line:",uiOutput("line", inline = T), sep =" ")))
              # h4(HTML(paste("Station Name:", uiOutput("station_name", inline = T), sep=" "))),
              # h4(HTML(paste("Number of Turnstiles:", uiOutput("ts_per_station", inline = T), sep=" ")))
            ),
            mainPanel()
          # tags$div(id = "table", DT::dataTableOutput("by_day")), 
          # tags$div(id = "table", DT::dataTableOutput("entries_year"))
          )
          ),
  tabPanel("Station Comparison",
           tags$div(id = "table", DT::dataTableOutput("stations_compare"))
           )
)
