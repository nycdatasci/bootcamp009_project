# @author Scott Dobbins
# @version 0.8
# @date 2017-04-23 01:30

### import useful packages ###
library(shiny)      # app formation
library(leaflet)    # map source
library(ggplot2)    # plots and graphs
#library(maps)       # also helps with maps
#library(htmltools)  # helps with tooltips
library(DT)         # web tables


### server component ###

shinyServer(function(input, output) {#***session is still currently unused below
  
  ### server session variables ###
  
  WW1_selected <- FALSE
  WW2_selected <- FALSE
  Korea_selected <- FALSE
  Vietnam_selected <- FALSE
  
  
  # # show data using DataTable
  # output$table <- DT::renderDataTable({
  #   datatable(state_stat, rownames=FALSE) %>%
  #     formatStyle(input$which_war, background="skyblue", fontWeight='bold')
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
  
  # initialize leaflet map
  output$overview_map <- renderLeaflet({
    overview <- leaflet()
    overview
  })
  
  output$WW1_hist <- renderPlot({
    WW1_plot <- ggplot(WW1_bombs, aes(x = Mission.Date)) + geom_histogram(bins = input$WW1_hist_slider)
    WW1_plot
  })
  
  output$WW2_hist <- renderPlot({
    WW2_plot <- ggplot(WW2_bombs, aes(x = Mission.Date)) + geom_histogram(bins = input$WW2_hist_slider)
    WW2_plot
  })
  
  output$Korea_hist <- renderPlot({
    Korea_plot <- ggplot(Korea_bombs2, aes(x = Mission.Date)) + geom_histogram(bins = input$Korea_hist_slider)
    Korea_plot
  })
  
  output$Vietnam_hist <- renderPlot({
    Vietnam_plot <- ggplot(Vietnam_bombs, aes(x = Mission.Date)) + geom_histogram(bins = input$Vietnam_hist_slider)
    Vietnam_plot
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
  
  # handler for war selection
  observeEvent(eventExpr = input$which_war, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    
    if(debug_mode_on) print("wars selected")
    
    proxy <- leafletProxy("overview_map")
    
    if(xor(WW1_selected, WW1_string %in% input$which_war)) {
      if(WW1_selected) {
        if(debug_mode_on) print("WW1 deselected")
        proxy %>% clearGroup(group = "WW1_unique_targets")
        WW1_selected <<- FALSE
      } else {
        if(debug_mode_on) print("WW1 selected")
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
        WW1_selected <<- TRUE
      }
    } else if(xor(WW2_selected, WW2_string %in% input$which_war)) {
      if(WW2_selected) {
        if(debug_mode_on) print("WW2 deselected")
        proxy %>% clearGroup(group = "WW2_unique_targets")
        WW2_selected <<- FALSE
      } else {
        if(debug_mode_on) print("WW2 selected")
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
        WW2_selected <<- TRUE
      }
    } else if(xor(Korea_selected, Korea_string %in% input$which_war)) {
      if(Korea_selected) {
        if(debug_mode_on) print("Korea deselected")
        proxy %>% clearGroup(group = "Korea_unique_targets")
        Korea_selected <<- FALSE
      } else {
        if(debug_mode_on) print("Korea selected")
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
        Korea_selected <<- TRUE
      }
    } else if(xor(Vietnam_selected, Vietnam_string %in% input$which_war)) {
      if(Vietnam_selected) {
        if(debug_mode_on) print("Vietnam deselected")
        proxy %>% clearGroup(group = "Vietnam_unique_targets")
        Vietnam_selected <<- FALSE
      } else {
        if(debug_mode_on) print("Vietnam selected")
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
        Vietnam_selected <<- TRUE
      }
    } else {
      if(debug_mode_on) print("all wars deselected")
      print(stupid_var)
      if(WW1_selected) {
        proxy %>% clearGroup(group = "WW1_unique_targets")
        WW1_selected <<- FALSE
      } else if(WW2_selected) {
        proxy %>% clearGroup(group = "WW2_unique_targets")
        WW2_selected <<- FALSE
      } else if(Korea_selected) {
        proxy %>% clearGroup(group = "Korea_unique_targets")
        Korea_selected <<- FALSE
      } else if(Vietnam_selected) {
        proxy %>% clearGroup(group = "Vietnam_unique_targets")
        Vietnam_selected <<- FALSE
      } else {
        if(debug_mode_on) print("something else happened")
      }
    }
  })
  
  # handler for country selection
  observeEvent(eventExpr = input$country, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    if(debug_mode_on) print("country selected")
    
    proxy <- leafletProxy("overview_map")
  })
  
  # handler for aircraft selection
  observeEvent(eventExpr = input$aircraft, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    if(debug_mode_on) print("aircraft selected")
    
    proxy <- leafletProxy("overview_map")
  })
  
  # handler for weapon selection
  observeEvent(eventExpr = input$weapon, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    if(debug_mode_on) print("weapon selected")
    
    proxy <- leafletProxy("overview_map")
  })
  
})
