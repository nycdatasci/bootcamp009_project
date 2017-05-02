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
                            verticalLayout(h4("Subway Line:"),selectizeInput("line", label = NULL, names(mta_lines))),
                            h4(HTML(paste("Station Name:", uiOutput("station_name", inline = T), sep=" "))),
                            h4(HTML(paste("Number of Turnstiles:", uiOutput("ts_per_station", inline = T), sep=" "))),
                            # h4(HTML(paste("Total Entries:", uiOutput("entries_year", inline = T), sep=" "))),
                            h4(HTML(paste("Total Exits:", uiOutput("exits_year", inline = T), sep=" ")))
                      ),
                      verticalLayout(
                      h4(dateRangeInput("daterange_turnstile",
                                     label = "Select Date Range:",
                                     start = "2017-01-01",
                                     end = "2017-04-01",
                                     min = "2017-01-01",
                                     max = "2017-04-01",
                                     format = "mm/dd/yyyy",
                                     separator = "-")),
                      h4(verbatimTextOutput("daterange_turnstile")),
                      h4(selectizeInput("start_time", label = "Start Time:", hour)),
                      h4(selectizeInput("end_time", label = "Stop Time:", hour)),
                      actionButton("button",label = "Update")
                      )
                      ),
        tags$div(id="cite", "Data Provided by New York City's Metropolitan Transportation Authority (MTA).")
        )
      ),
  tabPanel("Turnstile Data",
          icon = icon("table"),
          splitLayout(
          tags$div(id = "table", DT::dataTableOutput("by_day")), 
          tags$div(id = "table", DT::dataTableOutput("entries_year"))
          )
          ),
  tabPanel("Station Comparison",
           tags$div(id = "table",  DT::dataTableOutput("stations_compare"))
           )
)
