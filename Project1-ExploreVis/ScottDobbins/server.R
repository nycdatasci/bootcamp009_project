# @author Scott Dobbins
# @version 0.9
# @date 2017-04-23 23:45

### import useful packages ###
library(shiny)      # app formation
library(leaflet)    # map source
library(ggplot2)    # plots and graphs
library(data.table) # data processing
library(dplyr)      # data processing
#library(plotly)     # pretty interactive graphs
#library(maps)       # also helps with maps
#library(htmltools)  # helps with tooltips
library(DT)         # web tables


# ### initialize plotly ###
# 
# Sys.setenv("plotly_username"="sdobbins")
# Sys.setenv("plotly_api_key"="ElZwoGYrCyhDGcauIpUQ")


### server component ###

shinyServer(function(input, output, session) {
  
  ### server session variables ###
  
  # toggles for graphs
  WW1_selected <- FALSE
  WW2_selected <- FALSE
  Korea_selected <- FALSE
  Vietnam_selected <- FALSE
  
  # graphing behavior
  opacity_now <- 0.2
  
  
  # # show data using DataTable
  # output$table <- DT::renderDataTable({
  #   datatable(state_stat, rownames=FALSE) %>%
  #     formatStyle(input$which_war, background="skyblue", fontWeight='bold')
  # })

  ### show overview statistics
  
  WW1_selection <- reactive({
    WW1_clean %>% 
      filter(Mission.Date >= input$dateRange[1] & Mission.Date <= input$dateRange[2])# %>% 
      #filter(Unit.Country %in% input$country) %>%
      #filter(Aircraft.Type %in% input$aircraft)
  })
  
  WW2_selection <- reactive({
    WW2_clean %>% 
      filter(Mission.Date >= input$dateRange[1] & Mission.Date <= input$dateRange[2])# %>% 
  })
  
  Korea_selection <- reactive({
    Korea_clean2 %>% 
      filter(Mission.Date >= input$dateRange[1] & Mission.Date <= input$dateRange[2])# %>% 
  })
  
  Vietnam_selection <- reactive({
    Vietnam_clean %>%
      filter(Mission.Date >= input$dateRange[1] & Mission.Date <= input$dateRange[2])# %>% 
  })
  
  WW1_sample <- reactive({
    if(WW1_missions_reactive() < input$sample_num) {
      WW1_selection()
    } else {
      sample_n(WW1_selection(), input$sample_num, replace = FALSE)
    }
  })
  
  WW2_sample <- reactive({
    if(WW2_missions_reactive() < input$sample_num) {
      WW2_selection()
    } else {
      sample_n(WW2_selection(), input$sample_num, replace = FALSE)
    }
  })
  
  Korea_sample <- reactive({
    if(Korea_missions_reactive() < input$sample_num) {
      Korea_selection()
    } else {
      sample_n(Korea_selection(), input$sample_num, replace = FALSE)
    }
  })
  
  Vietnam_sample <- reactive({
    if(Vietnam_missions_reactive() < input$sample_num) {
      Vietnam_selection()
    } else {
      sample_n(Vietnam_selection(), input$sample_num, replace = FALSE)
    }
  })
  
  WW1_missions_reactive <- reactive({
    if(WW1_string %in% input$which_war) {
      WW1_selection() %>% summarize(n = n())
    } else {
      0
    }
  })
  
  WW2_missions_reactive <- reactive({
    if(WW2_string %in% input$which_war) {
      WW2_selection() %>% summarize(n = n())
    } else {
      0
    }
  })
  
  Korea_missions_reactive <- reactive({
    if(Korea_string %in% input$which_war) {
      Korea_selection() %>% summarize(n = n())
    } else {
      0
    }
  })
  
  Vietnam_missions_reactive <- reactive({
    if(Vietnam_string %in% input$which_war) {
      Vietnam_selection() %>% summarize(n = n())
    } else {
      0
    }
  })
  
  WW1_bombs_reactive <- reactive({
    if(WW1_string %in% input$which_war) {
      WW1_selection() %>% summarize(sum = sum(Weapons.Expended, na.rm = TRUE))
    } else {
      0
    }
  })
  
  WW2_bombs_reactive <- reactive({
    if(WW2_string %in% input$which_war) {
      WW2_selection() %>% summarize(sum = sum(Bomb.HE.Num, na.rm = TRUE))
    } else {
      0
    }
  })
  
  Korea_bombs_reactive <- reactive({
    if(Korea_string %in% input$which_war) {
      Korea_selection() %>% summarize(sum = sum(Weapons.Num, na.rm = TRUE))
    } else {
      0
    }
  })
  
  Vietnam_bombs_reactive <- reactive({
    if(Vietnam_string %in% input$which_war) {
      Vietnam_selection() %>% summarize(sum = sum(Weapons.Delivered.Num, na.rm = TRUE))
    } else {
      0
    }
  })
  
  WW1_weight_reactive <- reactive({
    if(WW1_string %in% input$which_war) {
      WW1_selection() %>% summarize(sum = sum(Aircraft.Bombload, na.rm = TRUE))
    } else {
      0
    }
  })
  
  WW2_weight_reactive <- reactive({
    if(WW2_string %in% input$which_war) {
      WW2_selection() %>% summarize(sum = sum(Bomb.Total.Pounds, na.rm = TRUE))
    } else {
      0
    }
  })
  
  Korea_weight_reactive <- reactive({
    if(Korea_string %in% input$which_war) {
      Korea_selection() %>% summarize(sum = sum(Aircraft.Bombload.Calculated.Pounds, na.rm = TRUE))
    } else {
      0
    }
  })
  
  Vietnam_weight_reactive <- reactive({
    if(Vietnam_string %in% input$which_war) {
      Vietnam_selection() %>% summarize(sum = sum(Weapon.Type.Weight, na.rm = TRUE))
    } else {
      0
    }
  })
  
  # number of missions
  output$num_missions <- renderInfoBox({
    total_missions <- WW1_missions_reactive() + WW2_missions_reactive() + Korea_missions_reactive() + Vietnam_missions_reactive()
    infoBox(title = "Number of Missions", total_missions, icon = icon('chevron-up', lib = 'font-awesome'))
  })
  
  # number of bombs
  output$num_bombs <- renderInfoBox({
    total_bombs <- WW1_bombs_reactive() + WW2_bombs_reactive() + Korea_bombs_reactive() + Vietnam_bombs_reactive()
    infoBox(title = "Number of Bombs", total_bombs, icon = icon('bomb', lib = 'font-awesome'))
  })
  
  # weight of bombs
  output$total_weight <- renderInfoBox({
    total_weight <- WW1_weight_reactive() + WW2_weight_reactive() + Korea_weight_reactive() + Vietnam_weight_reactive()
    infoBox(title = "Weight of Bombs", total_weight, icon = icon('fire', lib = 'font-awesome'))
  })
  
  
  # initialize leaflet map
  output$overview_map <- renderLeaflet({
    overview <- leaflet()
    overview
  })
  
  output$WW1_hist <- renderPlot({
    WW1_hist_plot <- ggplot(WW1_selection(), aes(x = Mission.Date)) + 
                     geom_histogram(bins = input$WW1_hist_slider) + 
                     ggtitle("Missions over time during World War One") + 
                     xlab("Date") + 
                     ylab("Number of Missions")
    WW1_hist_plot
  })
  
  output$WW2_hist <- renderPlot({
    WW2_hist_plot <- ggplot(WW2_selection(), aes(x = Mission.Date)) + 
                     geom_histogram(bins = input$WW2_hist_slider) + 
                     ggtitle("Missions over time during World War Two") + 
                     xlab("Date") + 
                     ylab("Number of Missions")
    WW2_hist_plot
  })
  
  output$WW2_sandbox <- renderPlot({
    if(input$WW2_sandbox_ind == "Year") {
      plot_continuous <- WW2_continuous[[input$WW2_sandbox_dep]]
      WW2_sandbox_plot <- ggplot(mapping = aes(x = year((WW2_selection())[, "Mission.Date"]), 
                                               y = (WW2_selection())[, plot_continuous]))
      WW2_sandbox_plot <- WW2_sandbox_plot + geom_col(position = 'dodge')
    } else if(input$WW2_sandbox_ind %in% WW2_categorical_choices) {
      plot_category <- WW2_categorical[[input$WW2_sandbox_ind]]
      plot_continuous <- WW2_continuous[[input$WW2_sandbox_dep]]
      if(input$WW2_sandbox_group == "None") {
        WW2_sandbox_plot <- ggplot(mapping = aes(x = (WW2_selection())[, plot_category], 
                                                 y = (WW2_selection())[, plot_continuous]))
      } else {
        group_category <- WW2_categorical[[input$WW2_sandbox_group]]
        WW2_sandbox_plot <- ggplot(mapping = aes(x = (WW2_selection())[, plot_category], 
                                                 y = (WW2_selection())[, plot_continuous], 
                                                 group = (WW2_selection())[, group_category], 
                                                 fill = (WW2_selection())[, group_category]))
      }
      WW2_sandbox_plot <- WW2_sandbox_plot + geom_col(position = 'dodge')
    } else {
      plot_independent <- WW2_continuous[[input$WW2_sandbox_ind]]
      plot_dependent <- WW2_continuous[[input$WW2_sandbox_dep]]
      if(input$WW2_sandbox_group == "None") {
        WW2_sandbox_plot <- ggplot(mapping = aes(x = (WW2_selection())[, plot_independent], 
                                                 y = (WW2_selection())[, plot_dependent]))
      } else {
        group_category <- WW2_categorical[[input$WW2_sandbox_group]]
        WW2_sandbox_plot <- ggplot(mapping = aes(x = (WW2_selection())[, plot_independent], 
                                                 y = (WW2_selection())[, plot_dependent], 
                                                 color = (WW2_selection())[, group_category]))
      }
      WW2_sandbox_plot <- WW2_sandbox_plot + geom_point() + geom_smooth(method = 'lm')
    }
    WW2_sandbox_plot + 
      ggtitle("World War 2 sandbox") + 
      xlab(input$WW2_sandbox_ind) + 
      ylab(input$WW2_sandbox_dep)
  })
  
  output$Korea_hist <- renderPlot({
    Korea_hist_plot <- ggplot(Korea_selection(), aes(x = Mission.Date)) + 
                       geom_histogram(bins = input$Korea_hist_slider) + 
                       ggtitle("Missions over time during the Korean War") + 
                       xlab("Date") + 
                       ylab("Number of Missions")
    Korea_hist_plot
  })
  
  output$Vietnam_hist <- renderPlot({
    Vietnam_hist_plot <- ggplot(Vietnam_selection(), aes(x = Mission.Date)) + 
                         geom_histogram(bins = input$Vietnam_hist_slider) + 
                         ggtitle("Missions over time during the Vietnam War") + 
                         xlab("Date") + 
                         ylab("Number of Missions")
    Vietnam_hist_plot
  })
  
  # output$civilian_density <- renderPlot({
  #   civ_plot <- ggplot(world_map_df, aes(long, lat, group = group)) + geom_polygon() + coord_equal() + theme_opts
  #   WW1_plot <- geom_density2d(data = WW1_selection(), aes(x = Target.Longitude, y = Target.Latitude, group = 0), color = 'blue')
  #   WW2_plot <- geom_density2d(data = WW2_selection(), aes(x = Target.Longitude, y = Target.Latitude, group = 0), color = 'red')
  #   Korea_plot <- geom_density2d(data = Korea_selection(), aes(x = Target.Longitude, y = Target.Latitude, group = 0), color = 'yellow')
  #   Vietnam_plot <- geom_density2d(data = Vietnam_selection(), aes(x = Target.Longitude, y = Target.Latitude, group = 0), color = 'green')
  #   if(WW1_selected) civ_plot <- civ_plot + WW1_plot
  #   if(WW2_selected) civ_plot <- civ_plot + WW2_plot
  #   if(Korea_selected) civ_plot <- civ_plot + Korea_plot
  #   if(Vietnam_selected) civ_plot <- civ_plot + Vietnam_plot
  #   civ_plot
  # })

  # hanlder for changes in map type
  observeEvent(eventExpr = input$pick_map, ignoreNULL = FALSE, handlerExpr = {
    
    if(debug_mode_on) print("map altered")
    
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
        proxy %>% addCircles(data = WW1_sample(),
                             lat = ~Target.Latitude,
                             lng = ~Target.Longitude,
                             color = "darkblue",
                             weight = 5,
                             opacity = opacity_now,
                             fill = TRUE,
                             fillColor = "darkblue",
                             fillOpacity = opacity_now,
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
        proxy %>% addCircles(data = WW2_sample(),
                             lat = ~Target.Latitude,
                             lng = ~Target.Longitude,
                             color = "darkred",
                             weight = 5,
                             opacity = opacity_now,
                             fill = TRUE,
                             fillColor = "darkred",
                             fillOpacity = opacity_now, 
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
        proxy %>% addCircles(data = Korea_sample(),
                             lat = ~Target.Latitude,
                             lng = ~Target.Longitude,
                             color = "yellow",
                             weight = 5,
                             opacity = opacity_now,
                             fill = TRUE,
                             fillColor = "yellow", 
                             fillOpacity = opacity_now, 
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
        proxy %>% addCircles(data = Vietnam_sample(),
                             lat = ~Target.Latitude,
                             lng = ~Target.Longitude,
                             color = "darkgreen",
                             weight = 5,
                             opacity = opacity_now,
                             fill = TRUE,
                             fillColor = "darkgreen", 
                             fillOpacity = opacity_now, 
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
  
  # # handler for country selection
  # observeEvent(eventExpr = input$country, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
  #   if(debug_mode_on) print("country selected")
  #   
  #   proxy <- leafletProxy("overview_map")
  # })
  # 
  # # handler for aircraft selection
  # observeEvent(eventExpr = input$aircraft, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
  #   if(debug_mode_on) print("aircraft selected")
  #   
  #   proxy <- leafletProxy("overview_map")
  # })
  # 
  # # handler for weapon selection
  # observeEvent(eventExpr = input$weapon, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
  #   if(debug_mode_on) print("weapon selected")
  #   
  #   proxy <- leafletProxy("overview_map")
  # })
  
  # handler for sample size refresh
  observeEvent(eventExpr = input$sample_num, ignoreInit = TRUE, handlerExpr = {
    
    proxy <- leafletProxy("overview_map")
    
    if(input$sample_num > 1024) opacity_now <<- 0.1
    else if(input$sample_num > 512) opacity_now <<- 0.2
    else if(input$sample_num > 256) opacity_now <<- 0.3
    else if(input$sample_num > 128) opacity_now <<- 0.4
    else if(input$sample_num > 64) opacity_now <<- 0.5
    else if(input$sample_num > 32) opacity_now <<- 0.6
    else if(input$sample_num > 16) opacity_now <<- 0.7
    else if(input$sample_num > 8) opacity_now <<- 0.8
    else if(input$sample_num > 4) opacity_now <<- 0.9
    else opacity_now <<- 1.0
    
    if(WW1_selected) {
      proxy %>% 
        clearGroup(group = "WW1_unique_targets") %>% 
        addCircles(data = WW1_sample(),
                   lat = ~Target.Latitude,
                   lng = ~Target.Longitude,
                   color = "darkblue",
                   weight = 5,
                   opacity = opacity_now,
                   fill = TRUE,
                   fillColor = "darkblue",
                   fillOpacity = opacity_now,
                   popup = ~tooltip,
                   group = "WW1_unique_targets")
    }
    if(WW2_selected) {
      proxy %>% 
        clearGroup(group = "WW2_unique_targets") %>% 
        addCircles(data = WW2_sample(),
                   lat = ~Target.Latitude,
                   lng = ~Target.Longitude,
                   color = "darkred",
                   weight = 5,
                   opacity = opacity_now,
                   fill = TRUE,
                   fillColor = "darkred",
                   fillOpacity = opacity_now, 
                   popup = ~tooltip,
                   group = "WW2_unique_targets")
    }
    if(Korea_selected) {
      proxy %>% 
        clearGroup(group = "Korea_unique_targets") %>% 
        addCircles(data = Korea_sample(),
                   lat = ~Target.Latitude,
                   lng = ~Target.Longitude,
                   color = "yellow",
                   weight = 5,
                   opacity = opacity_now,
                   fill = TRUE,
                   fillColor = "yellow", 
                   fillOpacity = opacity_now, 
                   popup = ~tooltip,
                   group = "Korea_unique_targets")
    }
    if(Vietnam_selected) {
      proxy %>% 
        clearGroup(group = "Vietnam_unique_targets") %>% 
        addCircles(data = Vietnam_sample(),
                   lat = ~Target.Latitude,
                   lng = ~Target.Longitude,
                   color = "darkgreen",
                   weight = 5,
                   opacity = opacity_now,
                   fill = TRUE, 
                   fillColor = "darkgreen", 
                   fillOpacity = opacity_now, 
                   popup = ~tooltip,
                   group = "Vietnam_unique_targets")
    }
  })
  
})
