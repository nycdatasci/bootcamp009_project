# @author Scott Dobbins
# @version 0.9.3
# @date 2017-05-01 01:30

### import useful packages ###
library(shiny)          # app formation
library(leaflet)        # map source
library(leaflet.extras) # map extras
library(ggplot2)        # plots and graphs
library(data.table)     # data processing
library(dplyr)          # data processing
#library(plotly)         # pretty interactive graphs
#library(maps)           # also helps with maps
#library(htmltools)      # helps with tooltips
library(DT)             # web tables

# get helper functions if not already present
require(helper.R)


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
      (WW1_selection() %>% summarize(n = n()))$n
    } else {
      0
    }
  })
  
  WW2_missions_reactive <- reactive({
    if(WW2_string %in% input$which_war) {
      (WW2_selection() %>% summarize(n = n()))$n
    } else {
      0
    }
  })
  
  Korea_missions_reactive <- reactive({
    if(Korea_string %in% input$which_war) {
      (Korea_selection() %>% summarize(n = n()))$n
    } else {
      0
    }
  })
  
  Vietnam_missions_reactive <- reactive({
    if(Vietnam_string %in% input$which_war) {
      (Vietnam_selection() %>% summarize(n = n()))$n
    } else {
      0
    }
  })
  
  WW1_bombs_reactive <- reactive({
    if(WW1_string %in% input$which_war) {
      (WW1_selection() %>% summarize(sum = sum(Weapons.Expended, na.rm = TRUE)))$sum
    } else {
      0
    }
  })
  
  WW2_bombs_reactive <- reactive({
    if(WW2_string %in% input$which_war) {
      (WW2_selection() %>% summarize(sum = sum(Bomb.HE.Num, na.rm = TRUE)))$sum
    } else {
      0
    }
  })
  
  Korea_bombs_reactive <- reactive({
    if(Korea_string %in% input$which_war) {
      (Korea_selection() %>% summarize(sum = sum(Weapons.Num, na.rm = TRUE)))$sum
    } else {
      0
    }
  })
  
  Vietnam_bombs_reactive <- reactive({
    if(Vietnam_string %in% input$which_war) {
      (Vietnam_selection() %>% summarize(sum = sum(Weapons.Delivered.Num, na.rm = TRUE)))$sum
    } else {
      0
    }
  })
  
  WW1_weight_reactive <- reactive({
    if(WW1_string %in% input$which_war) {
      (WW1_selection() %>% summarize(sum = sum(Aircraft.Bombload, na.rm = TRUE)))$sum
    } else {
      0
    }
  })
  
  WW2_weight_reactive <- reactive({
    if(WW2_string %in% input$which_war) {
      (WW2_selection() %>% summarize(sum = sum(Bomb.Total.Pounds, na.rm = TRUE)))$sum
    } else {
      0
    }
  })
  
  Korea_weight_reactive <- reactive({
    if(Korea_string %in% input$which_war) {
      (Korea_selection() %>% summarize(sum = sum(Aircraft.Bombload.Calculated.Pounds, na.rm = TRUE)))$sum
    } else {
      0
    }
  })
  
  Vietnam_weight_reactive <- reactive({
    if(Vietnam_string %in% input$which_war) {
      (Vietnam_selection() %>% summarize(sum = sum(Weapon.Type.Weight, na.rm = TRUE)))$sum
    } else {
      0
    }
  })
  
  # number of missions
  output$num_missions <- renderInfoBox({
    total_missions <- WW1_missions_reactive() + WW2_missions_reactive() + Korea_missions_reactive() + Vietnam_missions_reactive()
    infoBox(title = "Number of Missions", value = add_commas(total_missions), icon = icon('chevron-up', lib = 'font-awesome'))
  })
  
  # number of bombs
  output$num_bombs <- renderInfoBox({
    total_bombs <- WW1_bombs_reactive() + WW2_bombs_reactive() + Korea_bombs_reactive() + Vietnam_bombs_reactive()
    infoBox(title = "Number of Bombs", value = add_commas(total_bombs), icon = icon('bomb', lib = 'font-awesome'))
  })
  
  # weight of bombs
  output$total_weight <- renderInfoBox({
    total_weight <- WW1_weight_reactive() + WW2_weight_reactive() + Korea_weight_reactive() + Vietnam_weight_reactive()
    infoBox(title = "Weight of Bombs", value = add_commas(total_weight), icon = icon('fire', lib = 'font-awesome'))
  })
  
  
  # initialize overview leaflet map
  output$overview_map <- renderLeaflet({
    overview <- leaflet()
    overview
  })
  
  output$overview_text <- renderText({"<i>Hints on use:</i><br>
    <b>Color</b> map is best for aesthetic appearance<br>
    <b>Plain</b> map is best for finding individual points<br>
    <b>Terrain</b> map is best for investigating bomb locations with respect to terrain<br>
    <b>Street</b> map is best for investigating bomb locations with respect to civil infrastructure<br>
    <b>Satellite</b> map is best for investigating bomb locations with respect to current-day city features"
  })
  
  # initialize civilian leaflet map
  output$civilian_map <- renderLeaflet({
    civilian <- leaflet() %>% addProviderTiles("CartoDB.Positron", layerId = "civilian_base")
    civilian
  })
  
  
  ### WW1 tab ###
  
  # WW1 histogram
  output$WW1_hist <- renderPlot({
    WW1_hist_plot <- ggplot(WW1_selection(), aes(x = Mission.Date)) + 
      geom_histogram(bins = input$WW1_hist_slider) + 
      ggtitle("Missions over time during World War One") + 
      xlab("Date") + 
      ylab("Number of Missions")
    WW1_hist_plot
  })
  
  # WW1 sandbox
  output$WW1_sandbox <- renderPlot({
    if(input$WW1_sandbox_ind == "Year") {
      plot_continuous <- WW1_continuous[[input$WW1_sandbox_dep]]
      if(input$WW1_sandbox_group == "None") {
        WW1_sandbox_plot <- ggplot(mapping = aes(x = year((WW1_selection())[, "Mission.Date"]), 
                                                 y = (WW1_selection())[, plot_continuous]))
      } else {
        group_category <- WW1_categorical[[input$WW1_sandbox_group]]
        WW1_sandbox_plot <- ggplot(mapping = aes(x = year((WW1_selection())[, "Mission.Date"]), 
                                                 y = (WW1_selection())[, plot_continuous], 
                                                 group = (WW1_selection())[, group_category], 
                                                 fill = (WW1_selection())[, group_category]))
      }
      WW1_sandbox_plot <- WW1_sandbox_plot + geom_col(position = 'dodge')
    } else if(input$WW1_sandbox_ind %in% WW1_categorical_choices) {
      plot_category <- WW1_categorical[[input$WW1_sandbox_ind]]
      plot_continuous <- WW1_continuous[[input$WW1_sandbox_dep]]
      if(input$WW1_sandbox_group == "None") {
        WW1_sandbox_plot <- ggplot(data = WW1_selection(), 
                                   mapping = aes_string(x = plot_category, 
                                                        y = plot_continuous))
      } else {
        group_category <- WW1_categorical[[input$WW1_sandbox_group]]
        WW1_sandbox_plot <- ggplot(data = WW1_selection(), 
                                   mapping = aes_string(x = plot_category, 
                                                        y = plot_continuous, 
                                                        group = group_category, 
                                                        fill = group_category))
      }
      WW1_sandbox_plot <- WW1_sandbox_plot + geom_col(position = 'dodge')
    } else {
      plot_independent <- WW1_continuous[[input$WW1_sandbox_ind]]
      plot_dependent <- WW1_continuous[[input$WW1_sandbox_dep]]
      if(input$WW1_sandbox_group == "None") {
        WW1_sandbox_plot <- ggplot(data = WW1_selection(), 
                                   mapping = aes_string(x = plot_independent, 
                                                        y = plot_dependent))
      } else {
        group_category <- WW1_categorical[[input$WW1_sandbox_group]]
        WW1_sandbox_plot <- ggplot(data = WW1_selection(), 
                                   mapping = aes_string(x = plot_independent, 
                                                        y = plot_dependent, 
                                                        color = group_category))
      }
      WW1_sandbox_plot <- WW1_sandbox_plot + geom_point() + geom_smooth(method = 'lm')
    }
    WW1_sandbox_plot + 
      ggtitle("World War 1 sandbox") + 
      xlab(input$WW1_sandbox_ind) + 
      ylab(input$WW1_sandbox_dep)
  })
  
  
  ### WW2 tab ###
  
  # WW2 histogram
  output$WW2_hist <- renderPlot({
    WW2_hist_plot <- ggplot(WW2_selection(), aes(x = Mission.Date)) + 
      geom_histogram(bins = input$WW2_hist_slider) + 
      ggtitle("Missions over time during World War Two") + 
      xlab("Date") + 
      ylab("Number of Missions")
    WW2_hist_plot
  })
  
  # WW2 sandbox
  output$WW2_sandbox <- renderPlot({
    if(input$WW2_sandbox_ind == "Year") {
      plot_continuous <- WW2_continuous[[input$WW2_sandbox_dep]]
      if(input$WW2_sandbox_group == "None") {
        WW2_sandbox_plot <- ggplot(mapping = aes(x = year((WW2_selection())[, "Mission.Date"]), 
                                                 y = (WW2_selection())[, plot_continuous]))
      } else {
        group_category <- WW2_categorical[[input$WW2_sandbox_group]]
        WW2_sandbox_plot <- ggplot(mapping = aes(x = year((WW2_selection())[, "Mission.Date"]), 
                                                 y = (WW2_selection())[, plot_continuous], 
                                                 group = (WW2_selection())[, group_category], 
                                                 fill = (WW2_selection())[, group_category]))
      }
      WW2_sandbox_plot <- WW2_sandbox_plot + geom_col(position = 'dodge')
    } else if(input$WW2_sandbox_ind %in% WW2_categorical_choices) {
      plot_category <- WW2_categorical[[input$WW2_sandbox_ind]]
      plot_continuous <- WW2_continuous[[input$WW2_sandbox_dep]]
      if(input$WW2_sandbox_group == "None") {
        WW2_sandbox_plot <- ggplot(data = WW2_selection(), 
                                   mapping = aes_string(x = plot_category, 
                                                        y = plot_continuous))
      } else {
        group_category <- WW2_categorical[[input$WW2_sandbox_group]]
        WW2_sandbox_plot <- ggplot(data = WW2_selection(), 
                                   mapping = aes_string(x = plot_category, 
                                                        y = plot_continuous, 
                                                        group = group_category, 
                                                        fill = group_category))
      }
      WW2_sandbox_plot <- WW2_sandbox_plot + geom_col(position = 'dodge')
    } else {
      plot_independent <- WW2_continuous[[input$WW2_sandbox_ind]]
      plot_dependent <- WW2_continuous[[input$WW2_sandbox_dep]]
      if(input$WW2_sandbox_group == "None") {
        WW2_sandbox_plot <- ggplot(data = WW2_selection(), 
                                   mapping = aes_string(x = plot_independent, 
                                                        y = plot_dependent))
      } else {
        group_category <- WW2_categorical[[input$WW2_sandbox_group]]
        WW2_sandbox_plot <- ggplot(data = WW2_selection(), 
                                   mapping = aes_string(x = plot_independent, 
                                                        y = plot_dependent, 
                                                        color = group_category))
      }
      WW2_sandbox_plot <- WW2_sandbox_plot + geom_point() + geom_smooth(method = 'lm')
    }
    WW2_sandbox_plot + 
      ggtitle("World War 2 sandbox") + 
      xlab(input$WW2_sandbox_ind) + 
      ylab(input$WW2_sandbox_dep)
  })
  
  
  ### Korea tab ###
  
  # Korea histogram
  output$Korea_hist <- renderPlot({
    Korea_hist_plot <- ggplot(Korea_selection(), aes(x = Mission.Date)) + 
      geom_histogram(bins = input$Korea_hist_slider) + 
      ggtitle("Missions over time during the Korean War") + 
      xlab("Date") + 
      ylab("Number of Missions")
    Korea_hist_plot
  })
  
  # Korea sandbox
  output$Korea_sandbox <- renderPlot({
    if(input$Korea_sandbox_ind == "Year") {
      plot_continuous <- Korea_continuous[[input$Korea_sandbox_dep]]
      if(input$Korea_sandbox_group == "None") {
        Korea_sandbox_plot <- ggplot(mapping = aes(x = year((Korea_selection())[, "Mission.Date"]), 
                                                   y = (Korea_selection())[, plot_continuous]))
      } else {
        group_category <- Korea_categorical[[input$Korea_sandbox_group]]
        Korea_sandbox_plot <- ggplot(mapping = aes(x = year((Korea_selection())[, "Mission.Date"]), 
                                                   y = (Korea_selection())[, plot_continuous], 
                                                   group = (Korea_selection())[, group_category], 
                                                   fill = (Korea_selection())[, group_category]))
      }
      Korea_sandbox_plot <- Korea_sandbox_plot + geom_col(position = 'dodge')
    } else if(input$Korea_sandbox_ind %in% Korea_categorical_choices) {
      plot_category <- Korea_categorical[[input$Korea_sandbox_ind]]
      plot_continuous <- Korea_continuous[[input$Korea_sandbox_dep]]
      if(input$Korea_sandbox_group == "None") {
        Korea_sandbox_plot <- ggplot(data = Korea_selection(), 
                                     mapping = aes_string(x = plot_category, 
                                                          y = plot_continuous))
      } else {
        group_category <- Korea_categorical[[input$Korea_sandbox_group]]
        Korea_sandbox_plot <- ggplot(data = Korea_selection(), 
                                     mapping = aes_string(x = plot_category, 
                                                          y = plot_continuous, 
                                                          group = group_category, 
                                                          fill = group_category))
      }
      Korea_sandbox_plot <- Korea_sandbox_plot + geom_col(position = 'dodge')
    } else {
      plot_independent <- Korea_continuous[[input$Korea_sandbox_ind]]
      plot_dependent <- Korea_continuous[[input$Korea_sandbox_dep]]
      if(input$Korea_sandbox_group == "None") {
        Korea_sandbox_plot <- ggplot(data = Korea_selection(), 
                                     mapping = aes_string(x = plot_independent, 
                                                          y = plot_dependent))
      } else {
        group_category <- Korea_categorical[[input$Korea_sandbox_group]]
        Korea_sandbox_plot <- ggplot(data = Korea_selection(), 
                                     mapping = aes_string(x = plot_independent, 
                                                          y = plot_dependent, 
                                                          color = group_category))
      }
      Korea_sandbox_plot <- Korea_sandbox_plot + geom_point() + geom_smooth(method = 'lm')
    }
    Korea_sandbox_plot + 
      ggtitle("Korean War sandbox") + 
      xlab(input$Korea_sandbox_ind) + 
      ylab(input$Korea_sandbox_dep)
  })
  
  
  ### Vietnam tab ###
  
  # Vietnam histogram
  output$Vietnam_hist <- renderPlot({
    Vietnam_hist_plot <- ggplot(Vietnam_selection(), aes(x = Mission.Date)) + 
      geom_histogram(bins = input$Vietnam_hist_slider) + 
      ggtitle("Missions over time during the Vietnam War") + 
      xlab("Date") + 
      ylab("Number of Missions")
    Vietnam_hist_plot
  })
  
  # Vietnam sandbox
  output$Vietnam_sandbox <- renderPlot({
    if(input$Vietnam_sandbox_ind == "Year") {
      plot_continuous <- Vietnam_continuous[[input$Vietnam_sandbox_dep]]
      if(input$Vietnam_sandbox_group == "None") {
        Vietnam_sandbox_plot <- ggplot(mapping = aes(x = year((Vietnam_selection())[, "Mission.Date"]), 
                                                     y = (Vietnam_selection())[, plot_continuous]))
      } else {
        group_category <- Vietnam_categorical[[input$Vietnam_sandbox_group]]
        Vietnam_sandbox_plot <- ggplot(mapping = aes(x = year((Vietnam_selection())[, "Mission.Date"]), 
                                                     y = (Vietnam_selection())[, plot_continuous], 
                                                     group = (Vietnam_selection())[, group_category], 
                                                     fill = (Vietnam_selection())[, group_category]))
      }
      Vietnam_sandbox_plot <- Vietnam_sandbox_plot + geom_col(position = 'dodge')
    } else if(input$Vietnam_sandbox_ind %in% Vietnam_categorical_choices) {
      plot_category <- Vietnam_categorical[[input$Vietnam_sandbox_ind]]
      plot_continuous <- Vietnam_continuous[[input$Vietnam_sandbox_dep]]
      if(input$Vietnam_sandbox_group == "None") {
        Vietnam_sandbox_plot <- ggplot(data = Vietnam_selection(), 
                                       mapping = aes_string(x = plot_category, 
                                                            y = plot_continuous))
      } else {
        group_category <- Vietnam_categorical[[input$Vietnam_sandbox_group]]
        Vietnam_sandbox_plot <- ggplot(data = Vietnam_selection(), 
                                       mapping = aes_string(x = plot_category, 
                                                            y = plot_continuous, 
                                                            group = group_category, 
                                                            fill = group_category))
      }
      Vietnam_sandbox_plot <- Vietnam_sandbox_plot + geom_col(position = 'dodge')
    } else {
      plot_independent <- Vietnam_continuous[[input$Vietnam_sandbox_ind]]
      plot_dependent <- Vietnam_continuous[[input$Vietnam_sandbox_dep]]
      if(input$Vietnam_sandbox_group == "None") {
        Vietnam_sandbox_plot <- ggplot(data = Vietnam_selection(), 
                                       mapping = aes_string(x = plot_independent, 
                                                            y = plot_dependent))
      } else {
        group_category <- Vietnam_categorical[[input$Vietnam_sandbox_group]]
        Vietnam_sandbox_plot <- ggplot(data = Vietnam_selection(), 
                                       mapping = aes_string(x = plot_independent, 
                                                            y = plot_dependent, 
                                                            color = group_category))
      }
      Vietnam_sandbox_plot <- Vietnam_sandbox_plot + geom_point() + geom_smooth(method = 'lm')
    }
    Vietnam_sandbox_plot + 
      ggtitle("Vietnam War sandbox") + 
      xlab(input$Vietnam_sandbox_ind) + 
      ylab(input$Vietnam_sandbox_dep)
  })
  
  # hanlder for changes in map type
  observeEvent(eventExpr = input$pick_map, ignoreNULL = FALSE, handlerExpr = {
    
    if(debug_mode_on) print("map altered")
    
    overview_proxy <- leafletProxy("overview_map")
    
    # remove other tiles and add designated map
    if(input$pick_map == "Color Map") {
      
      overview_proxy %>%
        clearTiles() %>%
        addProviderTiles("Stamen.Watercolor", layerId = "map_base")#,
      #options = providerTileOptions(attribution = 'Map tiles by <a href="http://stamen.com">Stamen Design</a>,
      #<a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy;
      #<a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'))
      
    } else if(input$pick_map == "Plain Map") {
      
      overview_proxy %>%
        clearTiles() %>%
        addProviderTiles("CartoDB.PositronNoLabels",
                         layerId = "map_base")#,
      #options = providerTileOptions(attribution = '&copy;
      #<a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy;
      #<a href="http://cartodb.com/attributions">CartoDB</a>'))
      
    } else if(input$pick_map == "Terrain Map") {
      
      overview_proxy %>%
        clearTiles() %>%
        addProviderTiles("Stamen.TerrainBackground",
                         layerId = "map_base")#,
      #options = providerTileOptions(attribution = 'Map tiles by <a href="http://stamen.com">Stamen Design</a>,
      #<a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy;
      #<a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'))
      
    } else if(input$pick_map == "Street Map") {
      
      overview_proxy %>%
        clearTiles() %>%
        addProviderTiles("HERE.basicMap",
                         layerId = "map_base",
                         options = providerTileOptions(app_id = '5LPi1Hu7Aomn8Nv4If6c',
                                                       app_code = 'mrmfvq4OREjya6Vbjmw6Gw'))#,
      #attribution = 'Map &copy; 2016
      #<a href="http://developer.here.com">HERE</a>'))
      
    } else if(input$pick_map == "Satellite Map") {
      
      overview_proxy %>%
        clearTiles() %>%
        addProviderTiles("Esri.WorldImagery",
                         layerId = "map_base")#,
      #options = providerTileOptions(attribution = 'Tiles &copy; Esri &mdash;
      #Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'))
      
    }
    
    # gotta redraw the map labels if the underlying map has changed
    if("Borders" %in% input$pick_labels) {
      if("Text" %in% input$pick_labels) {
        
        overview_proxy %>%
          removeTiles(layerId = "map_labels") %>%
          addProviderTiles("Stamen.TonerHybrid", layerId = "map_labels")
        
      } else {
        
        overview_proxy %>%
          removeTiles(layerId = "map_labels") %>%
          addProviderTiles("Stamen.TonerLines", layerId = "map_labels")
        
      }
    } else {
      if("Text" %in% input$pick_labels) {
        
        overview_proxy %>%
          removeTiles(layerId = "map_labels") %>%
          addProviderTiles("Stamen.TonerLabels", layerId = "map_labels")
        
      } else {
        
        overview_proxy %>%
          removeTiles(layerId = "map_labels")
        
      }
    }
  })
  
  # handler for changes in map labels
  observeEvent(eventExpr = input$pick_labels, ignoreNULL = FALSE, handlerExpr = {
    
    if(debug_mode_on) print("labels altered")
    
    overview_proxy <- leafletProxy("overview_map")
    
    # remove current label tiles and re-add designated label tiles
    if("Borders" %in% input$pick_labels) {
      if("Text" %in% input$pick_labels) {
        if(debug_mode_on) print("Both borders and text")
        
        overview_proxy %>%
          removeTiles(layerId = "map_labels") %>%
          addProviderTiles("Stamen.TonerHybrid", layerId = "map_labels")
        
      } else {
        if(debug_mode_on) print("Just borders; no text")
        
        overview_proxy %>%
          removeTiles(layerId = "map_labels") %>%
          addProviderTiles("Stamen.TonerLines", layerId = "map_labels")
        
      }
      
    } else {
      
      if("Text" %in% input$pick_labels) {
        if(debug_mode_on) print("Just text; no borders")
        
        overview_proxy %>%
          removeTiles(layerId = "map_labels") %>%
          addProviderTiles("Stamen.TonerLabels", layerId = "map_labels")
        
      } else {
        if(debug_mode_on) print("Neither text nor borders")
        
        overview_proxy %>%
          removeTiles(layerId = "map_labels")
        
      }
    }
  })
  
  # handler for war selection
  observeEvent(eventExpr = input$which_war, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    
    if(debug_mode_on) print("wars selected")
    
    overview_proxy <- leafletProxy("overview_map")
    civilian_proxy <- leafletProxy("civilian_map")
    
    if(xor(WW1_selected, WW1_string %in% input$which_war)) {
      if(WW1_selected) {
        if(debug_mode_on) print("WW1 deselected")
        overview_proxy %>% clearGroup(group = "WW1_unique_targets")
        civilian_proxy %>% clearGroup(group = "WW1_heatmap")
        WW1_selected <<- FALSE
      } else {
        if(debug_mode_on) print("WW1 selected")
        overview_proxy %>% addCircles(data = WW1_sample(),
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
        civilian_proxy %>% addHeatmap(lng = WW1_selection()$Target.Longitude, 
                                      lat = WW1_selection()$Target.Latitude, 
                                      blur = 20, 
                                      max = 0.05, 
                                      radius = 15, 
                                      group = "WW1_heatmap")
        WW1_selected <<- TRUE
      }
    } else if(xor(WW2_selected, WW2_string %in% input$which_war)) {
      if(WW2_selected) {
        if(debug_mode_on) print("WW2 deselected")
        overview_proxy %>% clearGroup(group = "WW2_unique_targets")
        civilian_proxy %>% clearGroup(group = "WW2_heatmap")
        WW2_selected <<- FALSE
      } else {
        if(debug_mode_on) print("WW2 selected")
        overview_proxy %>% addCircles(data = WW2_sample(),
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
        civilian_proxy %>% addHeatmap(lng = WW2_selection()$Target.Longitude, 
                                      lat = WW2_selection()$Target.Latitude, 
                                      blur = 20, 
                                      max = 0.05, 
                                      radius = 15, 
                                      group = "WW2_heatmap")
        WW2_selected <<- TRUE
      }
    } else if(xor(Korea_selected, Korea_string %in% input$which_war)) {
      if(Korea_selected) {
        if(debug_mode_on) print("Korea deselected")
        overview_proxy %>% clearGroup(group = "Korea_unique_targets")
        civilian_proxy %>% clearGroup(group = "Korea_heatmap")
        Korea_selected <<- FALSE
      } else {
        if(debug_mode_on) print("Korea selected")
        overview_proxy %>% addCircles(data = Korea_sample(),
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
        civilian_proxy %>% addHeatmap(lng = Korea_selection()$Target.Longitude, 
                                      lat = Korea_selection()$Target.Latitude, 
                                      blur = 20, 
                                      max = 0.05, 
                                      radius = 15, 
                                      group = "Korea_heatmap")
        Korea_selected <<- TRUE
      }
    } else if(xor(Vietnam_selected, Vietnam_string %in% input$which_war)) {
      if(Vietnam_selected) {
        if(debug_mode_on) print("Vietnam deselected")
        overview_proxy %>% clearGroup(group = "Vietnam_unique_targets")
        civilian_proxy %>% clearGroup(group = "Vietnam_heatmap")
        Vietnam_selected <<- FALSE
      } else {
        if(debug_mode_on) print("Vietnam selected")
        overview_proxy %>% addCircles(data = Vietnam_sample(),
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
        civilian_proxy %>% addHeatmap(lng = Vietnam_selection()$Target.Longitude, 
                                      lat = Vietnam_selection()$Target.Latitude, 
                                      blur = 20, 
                                      max = 0.05, 
                                      radius = 15, 
                                      group = "Vietnam_heatmap")
        Vietnam_selected <<- TRUE
      }
    } else {
      if(debug_mode_on) print("all wars deselected")
      print(stupid_var)
      if(WW1_selected) {
        overview_proxy %>% clearGroup(group = "WW1_unique_targets")
        civilian_proxy %>% clearGroup(group = "WW1_heatmap")
        WW1_selected <<- FALSE
      } else if(WW2_selected) {
        overview_proxy %>% clearGroup(group = "WW2_unique_targets")
        civilian_proxy %>% clearGroup(group = "WW2_heatmap")
        WW2_selected <<- FALSE
      } else if(Korea_selected) {
        overview_proxy %>% clearGroup(group = "Korea_unique_targets")
        civilian_proxy %>% clearGroup(group = "Korea_heatmap")
        Korea_selected <<- FALSE
      } else if(Vietnam_selected) {
        overview_proxy %>% clearGroup(group = "Vietnam_unique_targets")
        civilian_proxy %>% clearGroup(group = "Vietnam_heatmap")
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
  observeEvent(eventExpr = input$sample_num, ignoreNULL = TRUE, ignoreInit = TRUE, handlerExpr = {
    
    overview_proxy <- leafletProxy("overview_map")
    
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
      overview_proxy %>% 
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
      overview_proxy %>% 
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
      overview_proxy %>% 
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
      overview_proxy %>% 
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
  
  # handler for date range refresh
  observeEvent(eventExpr = input$dateRange, ignoreNULL = TRUE, ignoreInit = TRUE, handlerExpr = {
    
    overview_proxy <- leafletProxy("overview_map")
    
    if(WW1_selected) {
      overview_proxy %>% 
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
      overview_proxy %>% 
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
      overview_proxy %>% 
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
      overview_proxy %>% 
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
