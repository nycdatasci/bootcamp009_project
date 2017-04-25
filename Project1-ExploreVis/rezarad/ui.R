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
                                  h5("Subway Line:"),
                                  selectizeInput("line", label = NULL, names(mta_lines)),
                                  h6(HTML(paste("Station Name:", uiOutput("station_name", inline = T), sep=" "))),
                                  h6(HTML(paste("Number of Turnstiles:", uiOutput("ts_per_station", inline = T), sep=" "))),
                                  h4(HTML(paste("Entries This Year:", uiOutput("entries_year", inline = T), sep=" "))),
                                  h4(HTML(paste("Exits This Year:", uiOutput("exits_year", inline = T), sep=" "))),
                                  h4(HTML(paste("Entries All Time:", uiOutput("entries_all", inline = T), sep=" "))),
                                  h4(HTML(paste("Entries All Time:", uiOutput("exits_all", inline = T), sep=" ")))
                            ),
              tags$div(id="cite", "Data Provided by New York City's Metropolitan Transportation Authority (MTA).")
              )
        ),
  tabPanel("Fares Data",
          icon = icon("table"),
          tags$div(id = "date_box",
         dateRangeInput("date_fares_tab",
               label = h4("Select Date Range to Filter By:"),
               start = "2014-10-18",
               end = "2017-04-01",
               min = "2014-10-18",
               max = "2017-04-01",
               format = "mm/dd/yyyy",
               separator = "-"
                        )
                   ),
            tags$div(id = "fares_table", DT::dataTableOutput("fares_data"))
          ),
  tabPanel("Turnstile Data",
          icon = icon("table")
          )
)
