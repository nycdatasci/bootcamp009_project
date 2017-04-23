# @author Scott Dobbins
# @version 0.7
# @date 2017-04-22 20:50

### import useful packages ###
library(shiny)      # app formation
library(leaflet)    # map source
#library(maps)       # also helps with maps
#library(htmltools)  # helps with tooltips
library(DT)         # web tables

### server component ###

shinyServer(function(input, output) {#***session is still currently unused below
  
  # # show data using DataTable
  # output$table <- DT::renderDataTable({
  #   datatable(state_stat, rownames=FALSE) %>% 
  #     formatStyle(input$selected, background="skyblue", fontWeight='bold')
  # })
  # 
  # # show statistics using infoBox
  # output$maxBox <- renderInfoBox({
  #   max_value <- max(state_stat[,input$selected])
  #   max_state <- 
  #     state_stat$state.name[state_stat[,input$selected] == max_value]
  #   infoBox(max_state, max_value, icon = icon("hand-o-up"))
  # })
  # output$minBox <- renderInfoBox({
  #   min_value <- min(state_stat[,input$selected])
  #   min_state <- 
  #     state_stat$state.name[state_stat[,input$selected] == min_value]
  #   infoBox(min_state, min_value, icon = icon("hand-o-down"))
  # })
  # output$avgBox <- renderInfoBox(
  #   infoBox(paste("AVG.", input$selected),
  #           mean(state_stat[,input$selected]), 
  #           icon = icon("calculator"), fill = TRUE))
  
  # initialize with watercolor map with both borders and labels drawn
  output$overview_map <- renderLeaflet({
    overview <- leaflet()
    overview
  })

  # hanlder for changes in map type
  observeEvent(eventExpr = input$pick_map, ignoreNULL = FALSE, handlerExpr = {
    if(debug_mode_on) print("map altered"); print(input$pick_map)

    proxy <- leafletProxy("overview_map")

    # remove other tiles and add designated map
    if(input$pick_map == "Color Map") {

      proxy %>%
        clearTiles() %>%
        addProviderTiles("Stamen.Watercolor", layerId = "map_base")#,
                         #options = providerTileOptions(attribution = 'Map tiles by <a href="http://stamen.com">Stamen Design</a>,
                         #<a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy;
                         #<a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'))

    } else if(input$pick_map == "Plain Map") {

      proxy %>%
        clearTiles() %>%
        addProviderTiles("CartoDB.PositronNoLabels",
                         layerId = "map_base")#,
                         #options = providerTileOptions(attribution = '&copy;
                         #<a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy;
                         #<a href="http://cartodb.com/attributions">CartoDB</a>'))

    } else if(input$pick_map == "Terrain Map") {

      proxy %>%
        clearTiles() %>%
        addProviderTiles("Stamen.TerrainBackground",
                         layerId = "map_base")#,
                         #options = providerTileOptions(attribution = 'Map tiles by <a href="http://stamen.com">Stamen Design</a>,
                         #<a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy;
                         #<a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'))

    } else if(input$pick_map == "Street Map") {

      proxy %>%
        clearTiles() %>%
        addProviderTiles("HERE.basicMap",
                         layerId = "map_base",
                         options = providerTileOptions(app_id = '5LPi1Hu7Aomn8Nv4If6c',
                                                       app_code = 'mrmfvq4OREjya6Vbjmw6Gw'))#,
                                                       #attribution = 'Map &copy; 2016
                                                       #<a href="http://developer.here.com">HERE</a>'))

    } else if(input$pick_map == "Satellite Map") {

      proxy %>%
        clearTiles() %>%
        addProviderTiles("Esri.WorldImagery",
                         layerId = "map_base")#,
                         #options = providerTileOptions(attribution = 'Tiles &copy; Esri &mdash;
                         #Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'))

    }

    # gotta redraw the map labels if the underlying map has changed
    if("Borders" %in% input$pick_labels) {
      if("Text" %in% input$pick_labels) {

        proxy %>%
          removeTiles(layerId = "map_labels") %>%
          addProviderTiles("Stamen.TonerHybrid", layerId = "map_labels")

      } else {

        proxy %>%
          removeTiles(layerId = "map_labels") %>%
          addProviderTiles("Stamen.TonerLines", layerId = "map_labels")

      }
    } else {
      if("Text" %in% input$pick_labels) {

        proxy %>%
          removeTiles(layerId = "map_labels") %>%
          addProviderTiles("Stamen.TonerLabels", layerId = "map_labels")

      } else {

        proxy %>%
          removeTiles(layerId = "map_labels")

      }
    }
  })

  # handler for changes in map labels
  # had to make sure ignoreNULL = FALSE so it would also update when all labels were removed
  observeEvent(eventExpr = input$pick_labels, ignoreNULL = FALSE, handlerExpr = {

    if(debug_mode_on) print("labels altered")

    proxy <- leafletProxy("overview_map")

    # remove current label tiles and re-add designated label tiles
    if("Borders" %in% input$pick_labels) {
      if("Text" %in% input$pick_labels) {
        if(debug_mode_on) print("Both borders and text")

        proxy %>%
          removeTiles(layerId = "map_labels") %>%
          addProviderTiles("Stamen.TonerHybrid", layerId = "map_labels")

      } else {
        if(debug_mode_on) print("Just borders; no text")

        proxy %>%
          removeTiles(layerId = "map_labels") %>%
          addProviderTiles("Stamen.TonerLines", layerId = "map_labels")

      }

    } else {

      if("Text" %in% input$pick_labels) {
        if(debug_mode_on) print("Just text; no borders")

        proxy %>%
          removeTiles(layerId = "map_labels") %>%
          addProviderTiles("Stamen.TonerLabels", layerId = "map_labels")

      } else {
        if(debug_mode_on) print("Neither text nor borders")

        proxy %>%
          removeTiles(layerId = "map_labels")

      }
    }
  })

  # handler for WW1 data plotting
  observeEvent(eventExpr = input$show_WW1, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {

    if(debug_mode_on) print("WW1 selected")

    proxy <- leafletProxy("overview_map")

    if(input$show_WW1) {

      proxy %>% addCircles(data = WW1_sample,
                           lat = ~Target.Latitude,
                           lng = ~Target.Longitude,
                           color = "darkblue",
                           weight = 5,
                           opacity = 0.5,
                           fill = TRUE,
                           fillColor = "darkblue",
                           fillOpacity = 0.5,
                           popup = ~tooltip,
                           group = "WW1_unique_targets")

    } else {

      proxy %>% clearGroup(group = "WW1_unique_targets")

    }
  })

  # handler for WW2 data plotting
  observeEvent(eventExpr = input$show_WW2, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {

    if(debug_mode_on) print("WW2 selected")

    proxy <- leafletProxy("overview_map")

    if(input$show_WW2) {

      proxy %>% addCircles(data = WW2_sample,
                           lat = ~Target.Latitude,
                           lng = ~Target.Longitude,
                           color = "darkred",
                           weight = 5,
                           opacity = 0.5,
                           fill = TRUE,
                           fillColor = "darkred",
                           popup = ~tooltip,
                           group = "WW2_unique_targets")

    } else {

      proxy %>% clearGroup(group = "WW2_unique_targets")

    }
  })

  # handler for Korea data plotting
  observeEvent(eventExpr = input$show_Korea, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {

    if(debug_mode_on) print("Korea selected")

    proxy <- leafletProxy("overview_map")

    if(input$show_Korea) {

      proxy %>% addCircles(data = Korea_sample,
                           lat = ~Target.Latitude,
                           lng = ~Target.Longitude,
                           color = "yellow",
                           weight = 5,
                           opacity = 0.5,
                           fill = TRUE,
                           fillColor = "yellow",
                           popup = ~tooltip,
                           group = "Korea_unique_targets")

    } else {

      proxy %>% clearGroup(group = "Korea_unique_targets")

    }
  })

  # handler for Vietnam data plotting
  observeEvent(eventExpr = input$show_Vietnam, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {

    if(debug_mode_on) print("Vietnam selected")

    proxy <- leafletProxy("overview_map")

    if(input$show_Vietnam) {

      proxy %>% addCircles(data = Vietnam_sample,
                           lat = ~Target.Latitude,
                           lng = ~Target.Longitude,
                           color = "darkgreen",
                           weight = 5,
                           opacity = 0.5,
                           fill = TRUE,
                           fillColor = "darkgreen",
                           popup = ~tooltip,
                           group = "Vietnam_unique_targets")

    } else {

      proxy %>% clearGroup(group = "Vietnam_unique_targets")

    }
  })
})
