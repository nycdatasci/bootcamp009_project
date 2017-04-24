## app.R ##
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(data.table)
library(leaflet)
library(htmltools)
library(DT)
source("~/NYC Data Science Academy/NY Parking Dashboard/global.R")
# source("~/NYC Data Science Academy/NY Parking Dashboard/helpers.R")

# dbname = "~/NYC Data Science Academy/NY Parking Dashboard/nyparking.sqlite"
# tblname = "nyparking"
# 
# dbname_map = "~/NYC Data Science Academy/NY Parking Dashboard/Police_Precincts.sqlite"
# tblname_map = "ogrgeojson"

  
ui <- dashboardPage(
  
  
  dashboardHeader(title = "NYC Parking Tickets"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      # menuItem("Summary", tabName = "bar_graph", icon = icon("th")),
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Data", tabName = "data", icon = icon("database"))
    ),
    # selectizeInput(
    #   selectizeInput("selected",
    #                  "Select Item to Display",
    #                  choices = unique(nyparking_data[, Item]))
    # )
    selectizeInput(inputId = "fiscal_year",
                   label = "Fiscal Year",
                   width = 140,
                   choices = unique(na.omit(nyparking_data[, `Report Year`]))
  )),
  ## Body content
  dashboardBody(
    tabItems(
      # First tab content
      # tabItem(tabName = "dashboard",
      #         fluidRow(
      #           box(plotOutput("plot1", height = 250)),
      #           
      #           box(
      #             title = "Controls",
      #             sliderInput("slider", "Number of observations:", 1, 100, 50)
      #           )
      #         )
      # ),
      # Bar Graph tab content
      tabItem(tabName = "dashboard",
              fluidRow(box(plotOutput("number",
                                      height = 300)
                           ),
                       box(
                         title = "Controls",

                         selectizeInput(inputId = "item",
                                        label = "Ticket Data by Group",
                                        
                                        choices = unique(nyparking_data[, Item]))
                       )
              )),
             
      # Map tab content
      tabItem(tabName = "map",
              fluidRow(
                box(
                    leafletOutput("map",
                            width="100%"),
                           width=600)
                       
                       )),

      # Data tab content
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"),
                           width = 12)))
              
      ))
)
  


server <- function(session,input, output) {
  
  conn <- dbConnector(session,dbname = dbname)
  
  
  output$table<-DT::renderDataTable({
    datatable(nyparking_data,rownames=FALSE)%>%
      formatStyle(input$item,
                  background="Skyblue",
                  fontWeight="bold")
  })
  
  ##### Using dataframe and not SQLite
  group_data <- reactive({
    if (input$item=="Report Year"){
      filter(nyparking_data,Item==input$item)%>%
        arrange(desc(n))%>%
        head(7)

    }else{
      filter(nyparking_data,Item==input$item&
               `Fiscal Year`==input$fiscal_year)%>%
        arrange(desc(n))%>%
        head(7)
    }

  })

  # This part uses SQLite to get datatable 
  # parking_db <- reactive(dbGetData(conn = conn,
  #                                  tblname = tblname,
  #                                  item=input$item,
  #                                  fiscal_year=input$fiscal_year)
  #                        )


  #### Output Bar Graph using GGplot
  #### Grouped by various factors
  output$number <- renderPlot(

    ##### SQLite output 
    # parking_db()%>%
    #####
    ##### Data Frame
    group_data() %>%
      ggplot(aes(x = get(input$item), y = n)) +
      geom_col(fill = "skyblue",na.rm=TRUE) +
      xlab(input$item) +
      ylab("Num of Tickets") +
      ggtitle("Number of Tickets")+
      theme_economist()
    
  )
  
  #### Draw map by using leaflet
  #### Maps out Precinct and color by
  #### number of tickets in the precinct
  
  choose_map <- reactive({
    
      filter(precinct_map_df,`Fiscal Year`==input$fiscal_year)%>%
      select(n,total_fine,precinct)
  })
  
  
  
  ?row.names
  ?SpatialPolygonsDataFrame
  output$map<- renderLeaflet({
    # 
    # row.names(choose_map())=row.names(precinct_map)
    # chosen_map = SpatialPolygonsDataFrame(precinct_map,choose_map())
    # 
    # chosen_map <- filter(precinct_map_df,`Fiscal Year`==2015)%>%
    #           select(n,total_fine,precinct)
    chosen_map<-choose_map()
    row.names(chosen_map)=row.names(precinct_map)    
    chosen_map = SpatialPolygonsDataFrame(precinct_map,chosen_map)
    
    
    bins <- c(0, 50000, 70000, 100000, 150000, 200000, 300000, Inf)
    pal <- colorBin("YlOrRd", domain = as.numeric(chosen_map$n), bins = bins)
    
    
    hover_text<-mapply(function(x, y, z) {
      htmltools::HTML(sprintf("%s <br> %s <br> %s", 
                              htmlEscape(x),
                              htmlEscape(y),
                              htmlEscape(z)))},
      paste0("Precint: ",as.character(chosen_map$precinct)), 
      paste0("Num of Tickets: ",as.character(
        formatC(chosen_map$n, format="d", big.mark=","))),
      paste0("Dollar Amount of Tickets: ","$",as.character(
        formatC(chosen_map$total_fine, format="d", big.mark=","))
      ),
      SIMPLIFY = F)
    
    leaflet(chosen_map) %>%
      setView(-74, 40.75, 10) %>%
      addProviderTiles("MapBox", options = providerTileOptions(
        id = "mapbox.light",
        accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')))%>%
      addTiles() %>%
      addPolygons(fillColor = ~pal(as.numeric(chosen_map$n)),
                  weight = 2,
                  opacity = 1,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7,
                  highlight = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 0.7,
                    bringToFront = TRUE),
                  label = lapply(as.character(hover_text),HTML), 
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto"))

  })
}

shinyApp(ui, server)