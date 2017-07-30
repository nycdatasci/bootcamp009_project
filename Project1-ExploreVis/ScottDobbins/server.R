# @author Scott Dobbins
# @version 0.9.7.2
# @date 2017-07-29 20:00


# ### initialize plotly ###
# 
# Sys.setenv("plotly_username"="sdobbins")
# Sys.setenv("plotly_api_key"="ElZwoGYrCyhDGcauIpUQ")


### Server Component --------------------------------------------------------

shinyServer(function(input, output, session) {
  
### Session variables -------------------------------------------------------

  # toggles for graphs
  WW1_selected <- FALSE
  WW2_selected <- FALSE
  Korea_selected <- FALSE
  Vietnam_selected <- FALSE
  all_countries_selected <- TRUE
  all_aircraft_selected <- TRUE
  all_weapons_selected <- TRUE
  
  
### DataTable ---------------------------------------------------------------

  output$table <- DT::renderDataTable({
    if (WW1_string %in% input$which_war) {
      datatable(data = select(WW1_selection(), WW1_datatable_columns), 
                rownames = FALSE, 
                colnames = WW1_datatable_colnames) %>%
        formatStyle(columns = WW1_datatable_columns, 
                    background = 'skyblue', 
                    fontWeight = 'bold')
    } else if (WW2_string %in% input$which_war) {
      datatable(data = select(WW2_selection(), WW2_datatable_columns), 
                rownames = FALSE, 
                colnames = WW2_datatable_colnames) %>%
        formatStyle(columns = WW2_datatable_columns, 
                    background = 'indianred', 
                    fontWeight = 'bold')
    } else if (Korea_string %in% input$which_war) {
      datatable(data = select(Korea_selection(), Korea_datatable_columns2), 
                rownames = FALSE, 
                colnames = Korea_datatable_colnames) %>%
        formatStyle(columns = Korea_datatable_columns2, 
                    background = 'khaki', 
                    fontWeight = 'bold')
    } else if (Vietnam_string %in% input$which_war) {
      datatable(data = select(Vietnam_selection(), Vietnam_datatable_columns), 
                rownames = FALSE, 
                colnames = Vietnam_datatable_colnames) %>%
        formatStyle(columns = Vietnam_datatable_columns, 
                    background = 'olivedrab', 
                    fontWeight = 'bold')
    } else {
      datatable(data = data.table(Example = list("Pick a war"), Data = list("to see its data")), 
                rownames = FALSE) %>%
        formatStyle(columns = 1:2, 
                    background = 'snow', 
                    fontWeight = 'bold')
    }
  })
  

### War Selections ----------------------------------------------------------

  WW1_selection <- reactive({
    filter_selection(WW1_clean, 
                     input$dateRange[1], 
                     input$dateRange[2], 
                     input$country, 
                     input$aircraft, 
                     input$weapon)
  })
  
  WW2_selection <- reactive({
    filter_selection(WW2_clean, 
                     input$dateRange[1], 
                     input$dateRange[2], 
                     input$country, 
                     input$aircraft, 
                     input$weapon)
  })
  
  Korea_selection <- reactive({
    filter_selection(Korea_clean2, 
                     input$dateRange[1], 
                     input$dateRange[2], 
                     input$country, 
                     input$aircraft, 
                     input$weapon)
  })
  
  Vietnam_selection <- reactive({
    filter_selection(Vietnam_clean, 
                     input$dateRange[1], 
                     input$dateRange[2], 
                     input$country, 
                     input$aircraft, 
                     input$weapon)
  })
  

### War Samples -------------------------------------------------------------
  
  WW1_sample <- reactive({
    if (WW1_missions_reactive() < input$sample_num) {
      WW1_selection()
    } else {
      sample_n(WW1_selection(), input$sample_num, replace = FALSE)
    }
  })
  
  WW2_sample <- reactive({
    if (WW2_missions_reactive() < input$sample_num) {
      WW2_selection()
    } else {
      sample_n(WW2_selection(), input$sample_num, replace = FALSE)
    }
  })
  
  Korea_sample <- reactive({
    if (Korea_missions_reactive() < input$sample_num) {
      Korea_selection()
    } else {
      sample_n(Korea_selection(), input$sample_num, replace = FALSE)
    }
  })
  
  Vietnam_sample <- reactive({
    if (Vietnam_missions_reactive() < input$sample_num) {
      Vietnam_selection()
    } else {
      sample_n(Vietnam_selection(), input$sample_num, replace = FALSE)
    }
  })
  

### InfoBox Reactives -------------------------------------------------------
  
  

### Missions reactives ------------------------------------------------------
  
  WW1_missions_reactive <- reactive({
    if (WW1_string %in% input$which_war) {
      WW1_selection()[, .N]
    } else { 0 }
  })
  
  WW2_missions_reactive <- reactive({
    if (WW2_string %in% input$which_war) {
      WW2_selection()[, .N]
    } else { 0 }
  })
  
  Korea_missions_reactive <- reactive({
    if (Korea_string %in% input$which_war) {
      Korea_selection()[, .N]
    } else { 0 }
  })
  
  Vietnam_missions_reactive <- reactive({
    if (Vietnam_string %in% input$which_war) {
      Vietnam_selection()[, .N]
    } else { 0 }
  })
  
  
### Flights reactives -------------------------------------------------------

  WW1_flights_reactive <- reactive({
    if (WW1_string %in% input$which_war) {
      WW1_selection()[, sum(Aircraft_Attacking_Num, na.rm = TRUE)]
    } else { 0 }
  })
  
  WW2_flights_reactive <- reactive({
    if (WW2_string %in% input$which_war) {
      WW2_selection()[, sum(Aircraft_Attacking_Num, na.rm = TRUE)]
    } else { 0 }
  })
  
  Korea_flights_reactive <- reactive({
    if (Korea_string %in% input$which_war) {
      Korea_selection()[, sum(Aircraft_Attacking_Num, na.rm = TRUE)]
    } else { 0 }
  })
  
  Vietnam_flights_reactive <- reactive({
    if (Vietnam_string %in% input$which_war) {
      Vietnam_selection()[, sum(Aircraft_Attacking_Num, na.rm = TRUE)]
    } else { 0 }
  })
  

### Bombs reactives ---------------------------------------------------------
  
  WW1_bombs_reactive <- reactive({
    if (WW1_string %in% input$which_war) {
      WW1_selection()[, sum(Weapon_Expended_Num, na.rm = TRUE)]
    } else { 0 }
  })
  
  WW2_bombs_reactive <- reactive({
    if (WW2_string %in% input$which_war) {
      WW2_selection()[, sum(Weapon_Expended_Num, na.rm = TRUE)]
    } else { 0 }
  })
  
  Korea_bombs_reactive <- reactive({
    if (Korea_string %in% input$which_war) {
      Korea_selection()[, sum(Weapon_Expended_Num, na.rm = TRUE)]
    } else { 0 }
  })
  
  Vietnam_bombs_reactive <- reactive({
    if (Vietnam_string %in% input$which_war) {
      Vietnam_selection()[, sum(Weapon_Expended_Num, na.rm = TRUE)]
    } else { 0 }
  })
  

### Weight reactives --------------------------------------------------------

  WW1_weight_reactive <- reactive({
    if (WW1_string %in% input$which_war) {
      WW1_selection()[, sum(Weapon_Weight_Pounds, na.rm = TRUE)]
    } else { 0 }
  })
  
  WW2_weight_reactive <- reactive({
    if (WW2_string %in% input$which_war) {
      WW2_selection()[, sum(as.numeric(Weapon_Weight_Pounds), na.rm = TRUE)]
    } else { 0 }
  })
  
  Korea_weight_reactive <- reactive({
    if (Korea_string %in% input$which_war) {
      Korea_selection()[, sum(Weapon_Weight_Pounds, na.rm = TRUE)]
    } else { 0 }
  })
  
  Vietnam_weight_reactive <- reactive({
    if (Vietnam_string %in% input$which_war) {
      Vietnam_selection()[, sum(Weapon_Weight_Pounds, na.rm = TRUE)]
    } else { 0 }
  })
  

### InfoBox Rendering -------------------------------------------------------

  # number of missions
  output$num_missions <- renderInfoBox({
    total_missions <- WW1_missions_reactive() + WW2_missions_reactive() + Korea_missions_reactive() + Vietnam_missions_reactive()
    infoBox(title = "Missions", value = add_commas(total_missions), icon = icon('chevron-up', lib = 'font-awesome'))
  })
  
  # number of aircraft
  output$num_aircraft <- renderInfoBox({
    total_aircraft <- WW1_flights_reactive() + WW2_flights_reactive() + Korea_flights_reactive() + Vietnam_flights_reactive()
    infoBox(title = "Aircraft Flights", value = add_commas(total_aircraft), icon = icon('fighter-jet', lib = 'font-awesome'))
  })
  
  # number of bombs
  output$num_bombs <- renderInfoBox({
    total_bombs <- WW1_bombs_reactive() + WW2_bombs_reactive() + Korea_bombs_reactive() + Vietnam_bombs_reactive()
    infoBox(title = "Bombs", value = add_commas(total_bombs), icon = icon('bomb', lib = 'font-awesome'))
  })
  
  # weight of bombs
  output$total_weight <- renderInfoBox({
    total_weight <- WW1_weight_reactive() + WW2_weight_reactive() + Korea_weight_reactive() + Vietnam_weight_reactive()
    infoBox(title = "TNT Equivalent (lbs)", value = add_commas(total_weight), icon = icon('fire', lib = 'font-awesome'))
  })
  
  
### Overview Map ------------------------------------------------------------
  
  # initialize overview leaflet map
  output$overview_map <- renderLeaflet({
    overview <- leaflet()
    overview
  })
  
  output$overview_text <- renderText({"<i>Hints for use:</i><br>
    <b>Color</b> map: best aesthetics<br>
    <b>Plain</b> map: visualize individual points<br>
    <b>Terrain</b> map: visualize terrain<br>
    <b>Street</b> map: visualize civil infrastructure<br>
    <b>Satellite</b> map: visualize current-day city features"
  })
  

### Pilot Map ---------------------------------------------------------------
  
  output$pilot_title <- renderText({
    "Where is the most dangerous to fly?"
  })
  

### Commander Map -----------------------------------------------------------
  
  output$commander_title <- renderText({
    "Where are the major battles?"
  })
  

### Civilian Map ------------------------------------------------------------
  
  output$civilian_title <- renderText({
    "Where is the bombing the worst?"
  })
  
  # initialize civilian leaflet map
  output$civilian_map <- renderLeaflet({
    civilian <- leaflet() %>% addProviderTiles("CartoDB.Positron", layerId = "civilian_base")
    civilian
  })
  

### WW1 Graphs --------------------------------------------------------------
  
  # WW1 histogram
  output$WW1_hist <- renderPlot({
    if (input$WW1_sandbox_group == "None") {
      WW1_hist_plot <- ggplot(mapping = aes(x = WW1_selection()[["Mission_Date"]])) + 
        geom_histogram(bins = input$WW1_hist_slider)
    } else {
      group_category <- WW1_categorical[[input$WW1_sandbox_group]]
      WW1_hist_plot <- ggplot(mapping = aes(x     = WW1_selection()[["Mission_Date"]], 
                                            color = WW1_selection()[[group_category]])) + 
        geom_freqpoly(bins = input$WW1_hist_slider) + 
        guides(color = guide_legend(title = input$WW1_sandbox_group))
    }
    WW1_hist_plot + 
      ggtitle("World War One Histogram") + 
      xlab("Date") + 
      ylab("Number of Missions") + 
      theme_bw()
  })
  
  # WW1 sandbox
  output$WW1_sandbox <- renderPlot({
    if (input$WW1_sandbox_ind == "Year") {
      plot_continuous <- WW1_continuous[[input$WW1_sandbox_dep]]
      if (input$WW1_sandbox_group == "None") {
        WW1_sandbox_plot <- ggplot(mapping = aes(x = WW1_selection()[["Year"]], 
                                                 y = WW1_selection()[[plot_continuous]]))
      } else {
        group_category <- WW1_categorical[[input$WW1_sandbox_group]]
        WW1_sandbox_plot <- ggplot(mapping = aes(x     = WW1_selection()[["Year"]], 
                                                 y     = WW1_selection()[[plot_continuous]], 
                                                 group = WW1_selection()[[group_category]], 
                                                 fill  = WW1_selection()[[group_category]])) + 
          guides(fill = guide_legend(title = input$WW1_sandbox_group))
      }
      WW1_sandbox_plot <- WW1_sandbox_plot + geom_col(position = 'dodge')
    } else if (input$WW1_sandbox_ind %in% WW1_categorical_choices) {
      plot_category <- WW1_categorical[[input$WW1_sandbox_ind]]
      plot_continuous <- WW1_continuous[[input$WW1_sandbox_dep]]
      if (input$WW1_sandbox_group == "None") {
        WW1_sandbox_plot <- ggplot(mapping = aes(x = WW1_selection()[[plot_category]], 
                                                 y = WW1_selection()[[plot_continuous]]))
      } else {
        group_category <- WW1_categorical[[input$WW1_sandbox_group]]
        WW1_sandbox_plot <- ggplot(mapping = aes(x     = WW1_selection()[[plot_category]], 
                                                 y     = WW1_selection()[[plot_continuous]], 
                                                 group = WW1_selection()[[group_category]], 
                                                 fill  = WW1_selection()[[group_category]])) + 
          guides(fill = guide_legend(title = input$WW1_sandbox_group))
      }
      WW1_sandbox_plot <- WW1_sandbox_plot + geom_col(position = 'dodge')
    } else {
      plot_independent <- WW1_continuous[[input$WW1_sandbox_ind]]
      plot_dependent <- WW1_continuous[[input$WW1_sandbox_dep]]
      if (input$WW1_sandbox_group == "None") {
        WW1_sandbox_plot <- ggplot(mapping = aes(x = WW1_selection()[[plot_independent]], 
                                                 y = WW1_selection()[[plot_dependent]]))
      } else {
        group_category <- WW1_categorical[[input$WW1_sandbox_group]]
        WW1_sandbox_plot <- ggplot(mapping = aes(x     = WW1_selection()[[plot_independent]], 
                                                 y     = WW1_selection()[[plot_dependent]], 
                                                 color = WW1_selection()[[group_category]])) + 
          guides(color = guide_legend(title = input$WW1_sandbox_group))
      }
      WW1_sandbox_plot <- WW1_sandbox_plot + geom_point() + geom_smooth(method = 'lm')
    }
    WW1_sandbox_plot + 
      ggtitle("World War One Sandbox") + 
      xlab(input$WW1_sandbox_ind) + 
      ylab(input$WW1_sandbox_dep) + 
      theme_bw()
  })
  

### WW2 Graphs --------------------------------------------------------------
  
  # WW2 histogram
  output$WW2_hist <- renderPlot({
    if (input$WW2_sandbox_group == "None") {
      WW2_hist_plot <- ggplot(mapping = aes(x = WW2_selection()[["Mission_Date"]])) + 
        geom_histogram(bins = input$WW2_hist_slider)
    } else {
      group_category <- WW2_categorical[[input$WW2_sandbox_group]]
      WW2_hist_plot <- ggplot(mapping = aes(x     = WW2_selection()[["Mission_Date"]], 
                                            color = WW2_selection()[[group_category]])) + 
        geom_freqpoly(bins = input$WW2_hist_slider) + 
        guides(color = guide_legend(title = input$WW2_sandbox_group))
    }
    WW2_hist_plot + 
      ggtitle("World War Two Histogram") + 
      xlab("Date") + 
      ylab("Number of Missions") + 
      theme_bw()
  })
  
  # WW2 sandbox
  output$WW2_sandbox <- renderPlot({
    if (input$WW2_sandbox_ind == "Year") {
      plot_continuous <- WW2_continuous[[input$WW2_sandbox_dep]]
      if (input$WW2_sandbox_group == "None") {
        WW2_sandbox_plot <- ggplot(mapping = aes(x = WW2_selection()[["Year"]], 
                                                 y = WW2_selection()[[plot_continuous]]))
      } else {
        group_category <- WW2_categorical[[input$WW2_sandbox_group]]
        WW2_sandbox_plot <- ggplot(mapping = aes(x     = WW2_selection()[["Year"]], 
                                                 y     = WW2_selection()[[plot_continuous]], 
                                                 group = WW2_selection()[[group_category]], 
                                                 fill  = WW2_selection()[[group_category]])) + 
          guides(fill = guide_legend(title = input$WW2_sandbox_group))
      }
      WW2_sandbox_plot <- WW2_sandbox_plot + geom_col(position = 'dodge')
    } else if (input$WW2_sandbox_ind %in% WW2_categorical_choices) {
      plot_category <- WW2_categorical[[input$WW2_sandbox_ind]]
      plot_continuous <- WW2_continuous[[input$WW2_sandbox_dep]]
      if (input$WW2_sandbox_group == "None") {
        WW2_sandbox_plot <- ggplot(mapping = aes(x = WW2_selection()[[plot_category]], 
                                                 y = WW2_selection()[[plot_continuous]]))
      } else {
        group_category <- WW2_categorical[[input$WW2_sandbox_group]]
        WW2_sandbox_plot <- ggplot(mapping = aes(x     = WW2_selection()[[plot_category]], 
                                                 y     = WW2_selection()[[plot_continuous]], 
                                                 group = WW2_selection()[[group_category]], 
                                                 fill  = WW2_selection()[[group_category]])) + 
          guides(fill = guide_legend(title = input$WW2_sandbox_group))
      }
      WW2_sandbox_plot <- WW2_sandbox_plot + geom_col(position = 'dodge')
    } else {
      plot_independent <- WW2_continuous[[input$WW2_sandbox_ind]]
      plot_dependent <- WW2_continuous[[input$WW2_sandbox_dep]]
      if (input$WW2_sandbox_group == "None") {
        WW2_sandbox_plot <- ggplot(mapping = aes(x = WW2_selection()[[plot_independent]], 
                                                 y = WW2_selection()[[plot_dependent]]))
      } else {
        group_category <- WW2_categorical[[input$WW2_sandbox_group]]
        WW2_sandbox_plot <- ggplot(mapping = aes(x     = WW2_selection()[[plot_independent]], 
                                                 y     = WW2_selection()[[plot_dependent]], 
                                                 color = WW2_selection()[[group_category]])) + 
          guides(color = guide_legend(title = input$WW2_sandbox_group))
      }
      WW2_sandbox_plot <- WW2_sandbox_plot + geom_point() + geom_smooth(method = 'lm')
    }
    WW2_sandbox_plot + 
      ggtitle("World War Two Sandbox") + 
      xlab(input$WW2_sandbox_ind) + 
      ylab(input$WW2_sandbox_dep) + 
      theme_bw()
  })
  

### Korea Graphs ------------------------------------------------------------

  # Korea histogram
  output$Korea_hist <- renderPlot({
    if (input$Korea_sandbox_group == "None") {
      Korea_hist_plot <- ggplot(mapping = aes(x = Korea_selection()[["Mission_Date"]])) + 
        geom_histogram(bins = input$Korea_hist_slider)
    } else {
      group_category <- Korea_categorical[[input$Korea_sandbox_group]]
      Korea_hist_plot <- ggplot(mapping = aes(x     = Korea_selection()[["Mission_Date"]], 
                                              color = Korea_selection()[[group_category]])) + 
        geom_freqpoly(bins = input$Korea_hist_slider) + 
        guides(color = guide_legend(title = input$Korea_sandbox_group))
    }
    Korea_hist_plot + 
      ggtitle("Korean War Histogram") + 
      xlab("Date") + 
      ylab("Number of Missions") + 
      theme_bw()
  })
  
  # Korea sandbox
  output$Korea_sandbox <- renderPlot({
    if (input$Korea_sandbox_ind == "Year") {
      plot_continuous <- Korea_continuous[[input$Korea_sandbox_dep]]
      if (input$Korea_sandbox_group == "None") {
        Korea_sandbox_plot <- ggplot(mapping = aes(x = Korea_selection()[["Year"]], 
                                                   y = Korea_selection()[[plot_continuous]]))
      } else {
        group_category <- Korea_categorical[[input$Korea_sandbox_group]]
        Korea_sandbox_plot <- ggplot(mapping = aes(x     = Korea_selection()[["Year"]], 
                                                   y     = Korea_selection()[[plot_continuous]], 
                                                   group = Korea_selection()[[group_category]], 
                                                   fill  = Korea_selection()[[group_category]])) + 
          guides(fill = guide_legend(title = input$Korea_sandbox_group))
      }
      Korea_sandbox_plot <- Korea_sandbox_plot + geom_col(position = 'dodge')
    } else if (input$Korea_sandbox_ind %in% Korea_categorical_choices) {
      plot_category <- Korea_categorical[[input$Korea_sandbox_ind]]
      plot_continuous <- Korea_continuous[[input$Korea_sandbox_dep]]
      if (input$Korea_sandbox_group == "None") {
        Korea_sandbox_plot <- ggplot(mapping = aes(x = Korea_selection()[[plot_category]], 
                                                   y = Korea_selection()[[plot_continuous]]))
      } else {
        group_category <- Korea_categorical[[input$Korea_sandbox_group]]
        Korea_sandbox_plot <- ggplot(mapping = aes(x     = Korea_selection()[[plot_category]], 
                                                   y     = Korea_selection()[[plot_continuous]], 
                                                   group = Korea_selection()[[group_category]], 
                                                   fill  = Korea_selection()[[group_category]])) + 
          guides(fill = guide_legend(title = input$Korea_sandbox_group))
      }
      Korea_sandbox_plot <- Korea_sandbox_plot + geom_col(position = 'dodge')
    } else {
      plot_independent <- Korea_continuous[[input$Korea_sandbox_ind]]
      plot_dependent <- Korea_continuous[[input$Korea_sandbox_dep]]
      if (input$Korea_sandbox_group == "None") {
        Korea_sandbox_plot <- ggplot(mapping = aes(x = Korea_selection()[[plot_independent]], 
                                                   y = Korea_selection()[[plot_dependent]]))
      } else {
        group_category <- Korea_categorical[[input$Korea_sandbox_group]]
        Korea_sandbox_plot <- ggplot(mapping = aes(x     = Korea_selection()[[plot_independent]], 
                                                   y     = Korea_selection()[[plot_dependent]], 
                                                   color = Korea_selection()[[group_category]])) + 
          guides(color = guide_legend(title = input$Korea_sandbox_group))
      }
      Korea_sandbox_plot <- Korea_sandbox_plot + geom_point() + geom_smooth(method = 'lm')
    }
    Korea_sandbox_plot + 
      ggtitle("Korean War Sandbox") + 
      xlab(input$Korea_sandbox_ind) + 
      ylab(input$Korea_sandbox_dep) + 
      theme_bw()
  })
  

### Vietnam Graphs ----------------------------------------------------------
  
  # Vietnam histogram
  output$Vietnam_hist <- renderPlot({
    if (input$Vietnam_sandbox_group == "None") {
      Vietnam_hist_plot <- ggplot(mapping = aes(x = Vietnam_selection()[["Mission_Date"]])) + 
        geom_histogram(bins = input$Vietnam_hist_slider)
    } else {
      group_category <- Vietnam_categorical[[input$Vietnam_sandbox_group]]
      Vietnam_hist_plot <- ggplot(mapping = aes(x     = Vietnam_selection()[["Mission_Date"]], 
                                                color = Vietnam_selection()[[group_category]])) + 
        geom_freqpoly(bins = input$Vietnam_hist_slider) + 
        guides(color = guide_legend(title = input$Vietnam_sandbox_group))
    }
    Vietnam_hist_plot + 
      ggtitle("Vietnam War Histogram") + 
      xlab("Date") + 
      ylab("Number of Missions") + 
      theme_bw()
    
  })
  
  # Vietnam sandbox
  output$Vietnam_sandbox <- renderPlot({
    if (input$Vietnam_sandbox_ind == "Year") {
      plot_continuous <- Vietnam_continuous[[input$Vietnam_sandbox_dep]]
      if (input$Vietnam_sandbox_group == "None") {
        Vietnam_sandbox_plot <- ggplot(mapping = aes(x = Vietnam_selection()[["Year"]], 
                                                     y = Vietnam_selection()[[plot_continuous]]))
      } else {
        group_category <- Vietnam_categorical[[input$Vietnam_sandbox_group]]
        Vietnam_sandbox_plot <- ggplot(mapping = aes(x     = Vietnam_selection()[["Year"]], 
                                                     y     = Vietnam_selection()[[plot_continuous]], 
                                                     group = Vietnam_selection()[[group_category]], 
                                                     fill  = Vietnam_selection()[[group_category]])) + 
          guides(fill = guide_legend(title = input$Vietnam_sandbox_group))
      }
      Vietnam_sandbox_plot <- Vietnam_sandbox_plot + geom_col(position = 'dodge')
    } else if (input$Vietnam_sandbox_ind %in% Vietnam_categorical_choices) {
      plot_category <- Vietnam_categorical[[input$Vietnam_sandbox_ind]]
      plot_continuous <- Vietnam_continuous[[input$Vietnam_sandbox_dep]]
      if (input$Vietnam_sandbox_group == "None") {
        Vietnam_sandbox_plot <- ggplot(mapping = aes(x = Vietnam_selection()[[plot_category]], 
                                                     y = Vietnam_selection()[[plot_continuous]]))
      } else {
        group_category <- Vietnam_categorical[[input$Vietnam_sandbox_group]]
        Vietnam_sandbox_plot <- ggplot(mapping = aes(x     = Vietnam_selection()[[plot_category]], 
                                                     y     = Vietnam_selection()[[plot_continuous]], 
                                                     group = Vietnam_selection()[[group_category]], 
                                                     fill  = Vietnam_selection()[[group_category]])) + 
          guides(fill = guide_legend(title = input$Vietnam_sandbox_group))
      }
      Vietnam_sandbox_plot <- Vietnam_sandbox_plot + geom_col(position = 'dodge')
    } else {
      plot_independent <- Vietnam_continuous[[input$Vietnam_sandbox_ind]]
      plot_dependent <- Vietnam_continuous[[input$Vietnam_sandbox_dep]]
      if (input$Vietnam_sandbox_group == "None") {
        Vietnam_sandbox_plot <- ggplot(mapping = aes(x = Vietnam_selection()[[plot_independent]], 
                                                     y = Vietnam_selection()[[plot_dependent]]))
      } else {
        group_category <- Vietnam_categorical[[input$Vietnam_sandbox_group]]
        Vietnam_sandbox_plot <- ggplot(mapping = aes(x     = Vietnam_selection()[[plot_independent]], 
                                                     y     = Vietnam_selection()[[plot_dependent]], 
                                                     color = Vietnam_selection()[[group_category]])) + 
          guides(color = guide_legend(title = input$Vietnam_sandbox_group))
      }
      Vietnam_sandbox_plot <- Vietnam_sandbox_plot + geom_point() + geom_smooth(method = 'lm')
    }
    Vietnam_sandbox_plot + 
      ggtitle("Vietnam War Sandbox") + 
      xlab(input$Vietnam_sandbox_ind) + 
      ylab(input$Vietnam_sandbox_dep) + 
      theme_bw()
  })
  

### Observers ---------------------------------------------------------------


### Map observers -----------------------------------------------------------
  
  # hanlder for changes in map type
  observeEvent(eventExpr = input$pick_map, handlerExpr = {
    debug_message("map altered")
    overview_proxy <- leafletProxy("overview_map")
    # remove other tiles and add designated map
    fix_map_base(overview_proxy, map_type = input$pick_map)
    # gotta redraw the map labels if the underlying map has changed
    fix_map_labels(overview_proxy, borders = "Borders" %in% input$pick_labels, text = "Text" %in% input$pick_labels)
  })
  
  # handler for changes in map labels
  observeEvent(eventExpr = input$pick_labels, ignoreNULL = FALSE, handlerExpr = {
    debug_message("labels altered")
    overview_proxy <- leafletProxy("overview_map")
    fix_map_labels(overview_proxy, borders = "Borders" %in% input$pick_labels, text = "Text" %in% input$pick_labels)
  })
  
  # handler for changes in map zoom
  observeEvent(eventExpr = input$overview_map_zoom, handlerExpr = {
    debug_message("map zoomed")
    overview_proxy <- leafletProxy("overview_map")
    redraw_overview(overview_proxy)
  })
  

### War observer ------------------------------------------------------------

  # handler for war selection
  observeEvent(eventExpr = input$which_war, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    debug_message("wars selected")
    overview_proxy <- leafletProxy("overview_map")
    civilian_proxy <- leafletProxy("civilian_map")
    if (xor(WW1_selected, WW1_string %in% input$which_war)) {
      if (WW1_selected) {
        debug_message("WW1 deselected")
        clear_WW1(overview_proxy, civilian_proxy)
        WW1_selected <<- FALSE
      } else {
        debug_message("WW1 selected")
        draw_WW1(overview_proxy, civilian_proxy)
        WW1_selected <<- TRUE
      }
    } else if(xor(WW2_selected, WW2_string %in% input$which_war)) {
      if (WW2_selected) {
        debug_message("WW2 deselected")
        clear_WW2(overview_proxy, civilian_proxy)
        WW2_selected <<- FALSE
      } else {
        debug_message("WW2 selected")
        draw_WW2(overview_proxy, civilian_proxy)
        WW2_selected <<- TRUE
      }
    } else if(xor(Korea_selected, Korea_string %in% input$which_war)) {
      if (Korea_selected) {
        debug_message("Korea deselected")
        clear_Korea(overview_proxy, civilian_proxy)
        Korea_selected <<- FALSE
      } else {
        debug_message("Korea selected")
        draw_Korea(overview_proxy, civilian_proxy)
        Korea_selected <<- TRUE
      }
    } else if(xor(Vietnam_selected, Vietnam_string %in% input$which_war)) {
      if (Vietnam_selected) {
        debug_message("Vietnam deselected")
        clear_Vietnam(overview_proxy, civilian_proxy)
        Vietnam_selected <<- FALSE
      } else {
        debug_message("Vietnam selected")
        draw_Vietnam(overview_proxy, civilian_proxy)
        Vietnam_selected <<- TRUE
      }
    } else {
      debug_message("all wars deselected")
      print(stupid_var)
      if (WW1_selected) {
        clear_WW1(overview_proxy, civilian_proxy)
        WW1_selected <<- FALSE
      } else if (WW2_selected) {
        clear_WW2(overview_proxy, civilian_proxy)
        WW2_selected <<- FALSE
      } else if (Korea_selected) {
        clear_Korea(overview_proxy, civilian_proxy)
        Korea_selected <<- FALSE
      } else if (Vietnam_selected) {
        clear_Vietnam(overview_proxy, civilian_proxy)
        Vietnam_selected <<- FALSE
      } else {
        debug_message("something else happened")
      }
    }
    update_selectize_inputs()
  })
  

### Country observer --------------------------------------------------------
  
  # handler for country selection
  observeEvent(eventExpr = input$country, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    debug_message("country selected")
    update_maps <- TRUE
    if (all_countries_selected) {# all countries were selected previously
      if ("All" %in% input$country) {# all is still selected
        if (length(input$country) > 1) {# and there's another one in there
          # then do remove all thing
          all_countries_selected <<- FALSE
          updateSelectizeInput(session, inputId = "country", selected = input$country[input$country != "All"])
          update_maps <- FALSE
        }
      } else {# all has been removed
        all_countries_selected <<- FALSE
      }
    } else{# all countries was not selected previously
      if ("All" %in% input$country) {# all is now added
        all_countries_selected <<- TRUE
        if (length(input$country) > 1) {# and there was previously something else in there
          # then do remove other countries thing
          updateSelectizeInput(session, inputId = "country", selected = "All")
          update_maps <- FALSE
        }
      }
    }
    if (update_maps) {# only update when normal changes have been made
      overview_proxy <- leafletProxy("overview_map")
      civilian_proxy <- leafletProxy("civilian_map")
      redraw(overview_proxy, civilian_proxy)
      update_other_selectize_inputs("countries")
    }
  })


### Aircraft observer -------------------------------------------------------

  # handler for aircraft selection
  observeEvent(eventExpr = input$aircraft, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    debug_message("aircraft selected")
    update_maps <- TRUE
    if (all_aircraft_selected) {# all aircraft were selected previously
      if ("All" %in% input$aircraft) {# all is still selected
        if (length(input$aircraft) > 1) {# and there's another one in there
          # then do remove all thing
          all_aircraft_selected <<- FALSE
          updateSelectizeInput(session, inputId = "aircraft", selected = input$aircraft[input$aircraft != "All"])
          update_maps <- FALSE
        }
      } else {# all has been removed
        all_aircraft_selected <<- FALSE
      }
    } else{# all aircraft was not selected previously
      if ("All" %in% input$aircraft) {# all is now added
        all_aircraft_selected <<- TRUE
        if (length(input$aircraft) > 1) {# and there was previously something else in there
          # then do remove other aircraft thing
          updateSelectizeInput(session, inputId = "aircraft", selected = "All")
          update_maps <- FALSE
        }
      }
    }
    if (update_maps) {# only update when normal changes have been made
      overview_proxy <- leafletProxy("overview_map")
      civilian_proxy <- leafletProxy("civilian_map")
      redraw(overview_proxy, civilian_proxy)
      update_other_selectize_inputs("aircraft")
    }
  })
  

### Weapon observer ---------------------------------------------------------

  # handler for weapon selection
  observeEvent(eventExpr = input$weapon, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    debug_message("weapon selected")
    update_maps <- TRUE
    if (all_weapons_selected) {# all weapons were selected previously
      if ("All" %in% input$weapon) {# all is still selected
        if (length(input$weapon) > 1) {# and there's another one in there
          # then do remove all thing
          all_weapons_selected <<- FALSE
          updateSelectizeInput(session, inputId = "weapon", selected = input$weapon[input$weapon != "All"])
          update_maps <- FALSE
        }
      } else {# all has been removed
        all_weapons_selected <<- FALSE
      }
    } else{# all weapons was not selected previously
      if ("All" %in% input$weapon) {# all is now added
        all_weapons_selected <<- TRUE
        if (length(input$weapon) > 1) {# and there was previously something else in there
          # then do remove other weapons thing
          updateSelectizeInput(session, inputId = "weapon", selected = "All")
          update_maps <- FALSE
        }
      }
    }
    if (update_maps) {# only update when normal changes have been made
      overview_proxy <- leafletProxy("overview_map")
      civilian_proxy <- leafletProxy("civilian_map")
      redraw(overview_proxy, civilian_proxy)
      update_other_selectize_inputs("weapons")
    }
  })
  

### Other observers ---------------------------------------------------------

  # handler for sample size refresh
  observeEvent(eventExpr = input$sample_num, ignoreNULL = TRUE, ignoreInit = TRUE, handlerExpr = {
    debug_message("sample size changed")
    overview_proxy <- leafletProxy("overview_map")
    redraw_overview(overview_proxy)
  })
  
  # handler for date range refresh
  observeEvent(eventExpr = input$dateRange, ignoreNULL = TRUE, ignoreInit = TRUE, handlerExpr = {
    debug_message("date range changed")
    overview_proxy <- leafletProxy("overview_map")
    civilian_proxy <- leafletProxy("civilian_map")
    redraw(overview_proxy, civilian_proxy)
  })
  

### WW1 Drawers -------------------------------------------------------------

  clear_WW1_overview <- function(proxy) {
    proxy %>% clearGroup(group = "WW1_unique_targets")
  }
  
  draw_WW1_overview <- function(proxy) {
    WW1_opacity <- calculate_opacity(min(WW1_missions_reactive(), input$sample_num), input$overview_map_zoom)
    proxy %>% addCircles(data = WW1_sample(),
                         lat = ~Target_Latitude,
                         lng = ~Target_Longitude,
                         color = WW1_color,
                         weight = point_weight + input$overview_map_zoom,
                         opacity = WW1_opacity,
                         fill = point_fill,
                         fillColor = WW1_color,
                         fillOpacity = WW1_opacity,
                         popup = ~tooltip,
                         group = "WW1_unique_targets")
  }
  
  redraw_WW1_overview <- function(proxy) {
    clear_WW1_overview(proxy)
    draw_WW1_overview(proxy)
  }
  
  clear_WW1_civilian <- function(proxy) {
    proxy %>% clearGroup(group = "WW1_heatmap")
  }
  
  draw_WW1_civilian <- function(proxy) {
    proxy %>% addHeatmap(lng = WW1_selection()$Target_Longitude, 
                         lat = WW1_selection()$Target_Latitude, 
                         blur = civilian_blur, 
                         max = civilian_max, 
                         radius = civilian_radius, 
                         group = "WW1_heatmap")
  }
  
  redraw_WW1_civilian <- function(proxy) {
    clear_WW1_civilian(proxy)
    draw_WW1_civilian(proxy)
  }
  
  clear_WW1 <- function(overview_proxy, civilian_proxy) {
    clear_WW1_overview(overview_proxy)
    clear_WW1_civilian(civilian_proxy)
  }
  
  draw_WW1 <- function(overview_proxy, civilian_proxy) {
    draw_WW1_overview(overview_proxy)
    draw_WW1_civilian(civilian_proxy)
  }
  
  redraw_WW1 <- function(overview_proxy, civilian_proxy) {
    redraw_WW1_overview(overview_proxy)
    redraw_WW1_civilian(civilian_proxy)
  }
  

### WW2 Drawers -------------------------------------------------------------
  
  clear_WW2_overview <- function(proxy) {
    proxy %>% clearGroup(group = "WW2_unique_targets")
  }
  
  draw_WW2_overview <- function(proxy) {
    WW2_opacity <- calculate_opacity(min(WW2_missions_reactive(), input$sample_num), input$overview_map_zoom)
    proxy %>% addCircles(data = WW2_sample(),
                         lat = ~Target_Latitude,
                         lng = ~Target_Longitude,
                         color = WW2_color,
                         weight = point_weight + input$overview_map_zoom,
                         opacity = WW2_opacity,
                         fill = point_fill,
                         fillColor = WW2_color,
                         fillOpacity = WW2_opacity, 
                         popup = ~tooltip,
                         group = "WW2_unique_targets")
  }
  
  redraw_WW2_overview <- function(proxy) {
    clear_WW2_overview(proxy)
    draw_WW2_overview(proxy)
  }
  
  clear_WW2_civilian <- function(proxy) {
    proxy %>% clearGroup(group = "WW2_heatmap")
  }
  
  draw_WW2_civilian <- function(proxy) {
    proxy %>% addHeatmap(lng = WW2_selection()$Target_Longitude, 
                         lat = WW2_selection()$Target_Latitude, 
                         blur = civilian_blur, 
                         max = civilian_max, 
                         radius = civilian_radius, 
                         group = "WW2_heatmap")
  }
  
  redraw_WW2_civilian <- function(proxy) {
    clear_WW2_civilian(proxy)
    draw_WW2_civilian(proxy)
  }
  
  clear_WW2 <- function(overview_proxy, civilian_proxy) {
    clear_WW2_overview(overview_proxy)
    clear_WW2_civilian(civilian_proxy)
  }
  
  draw_WW2 <- function(overview_proxy, civilian_proxy) {
    draw_WW2_overview(overview_proxy)
    draw_WW2_civilian(civilian_proxy)
  }
  
  redraw_WW2 <- function(overview_proxy, civilian_proxy) {
    redraw_WW2_overview(overview_proxy)
    redraw_WW2_civilian(civilian_proxy)
  }
  

### Korea Drawers -----------------------------------------------------------
  
  clear_Korea_overview <- function(proxy) {
    proxy %>% clearGroup(group = "Korea_unique_targets")
  }
  
  draw_Korea_overview <- function(proxy) {
    Korea_opacity <- calculate_opacity(min(Korea_missions_reactive(), input$sample_num), input$overview_map_zoom)
    proxy %>% addCircles(data = Korea_sample(),
                         lat = ~Target_Latitude,
                         lng = ~Target_Longitude,
                         color = Korea_color,
                         weight = point_weight + input$overview_map_zoom,
                         opacity = Korea_opacity,
                         fill = point_fill,
                         fillColor = Korea_color, 
                         fillOpacity = Korea_opacity, 
                         popup = ~tooltip,
                         group = "Korea_unique_targets")
  }
  
  redraw_Korea_overview <- function(proxy) {
    clear_Korea_overview(proxy)
    draw_Korea_overview(proxy)
  }
  
  clear_Korea_civilian <- function(proxy) {
    proxy %>% clearGroup(group = "Korea_heatmap")
  }
  
  draw_Korea_civilian <- function(proxy) {
    proxy %>% addHeatmap(lng = Korea_selection()$Target_Longitude, 
                         lat = Korea_selection()$Target_Latitude, 
                         blur = civilian_blur, 
                         max = civilian_max, 
                         radius = civilian_radius, 
                         group = "Korea_heatmap")
  }
  
  redraw_Korea_civilian <- function(proxy) {
    clear_Korea_civilian(proxy)
    draw_Korea_civilian(proxy)
  }
  
  clear_Korea <- function(overview_proxy, civilian_proxy) {
    clear_Korea_overview(overview_proxy)
    clear_Korea_civilian(civilian_proxy)
  }
  
  draw_Korea <- function(overview_proxy, civilian_proxy) {
    draw_Korea_overview(overview_proxy)
    draw_Korea_civilian(civilian_proxy)
  }
  
  redraw_Korea <- function(overview_proxy, civilian_proxy) {
    redraw_Korea_overview(overview_proxy)
    redraw_Korea_civilian(civilian_proxy)
  }
  

### Vietnam Drawers ---------------------------------------------------------

  clear_Vietnam_overview <- function(proxy) {
    proxy %>% clearGroup(group = "Vietnam_unique_targets")
  }
  
  draw_Vietnam_overview <- function(proxy) {
    Vietnam_opacity <- calculate_opacity(min(Vietnam_missions_reactive(), input$sample_num), input$overview_map_zoom)
    proxy %>% addCircles(data = Vietnam_sample(),
                         lat = ~Target_Latitude,
                         lng = ~Target_Longitude,
                         color = Vietnam_color,
                         weight = point_weight + input$overview_map_zoom,
                         opacity = Vietnam_opacity,
                         fill = point_fill, 
                         fillColor = Vietnam_color, 
                         fillOpacity = Vietnam_opacity, 
                         popup = ~tooltip,
                         group = "Vietnam_unique_targets")
  }
  
  redraw_Vietnam_overview <- function(proxy) {
    clear_Vietnam_overview(proxy)
    draw_Vietnam_overview(proxy)
  }
  
  clear_Vietnam_civilian <- function(proxy) {
    proxy %>% clearGroup(group = "Vietnam_heatmap")
  }
  
  draw_Vietnam_civilian <- function(proxy) {
    proxy %>% addHeatmap(lng = Vietnam_selection()$Target_Longitude, 
                         lat = Vietnam_selection()$Target_Latitude, 
                         blur = civilian_blur, 
                         max = civilian_max, 
                         radius = civilian_radius, 
                         group = "Vietnam_heatmap")
  }
  
  redraw_Vietnam_civilian <- function(proxy) {
    clear_Vietnam_civilian(proxy)
    draw_Vietnam_civilian(proxy)
  }
  
  clear_Vietnam <- function(overview_proxy, civilian_proxy) {
    clear_Vietnam_overview(overview_proxy)
    clear_Vietnam_civilian(civilian_proxy)
  }
  
  draw_Vietnam <- function(overview_proxy, civilian_proxy) {
    draw_Vietnam_overview(overview_proxy)
    draw_Vietnam_civilian(civilian_proxy)
  }
  
  redraw_Vietnam <- function(overview_proxy, civilian_proxy) {
    redraw_Vietnam_overview(overview_proxy)
    redraw_Vietnam_civilian(civilian_proxy)
  }
  

### General Drawers ---------------------------------------------------------

  redraw_overview <- function(proxy) {
    if (WW1_selected) {
      redraw_WW1_overview(proxy)
    }
    if (WW2_selected) {
      redraw_WW2_overview(proxy)
    }
    if (Korea_selected) {
      redraw_Korea_overview(proxy)
    }
    if (Vietnam_selected) {
      redraw_Vietnam_overview(proxy)
    }
  }
  
  redraw_civilian <- function(proxy) {
    if (WW1_selected) {
      redraw_WW1_civilian(proxy)
    }
    if (WW2_selected) {
      redraw_WW2_civilian(proxy)
    }
    if (Korea_selected) {
      redraw_Korea_civilian(proxy)
    }
    if (Vietnam_selected) {
      redraw_Vietnam_civilian(proxy)
    }
  }
  
  redraw <- function(overview_proxy, civilian_proxy) {
    if (WW1_selected) {
      redraw_WW1(overview_proxy, civilian_proxy)
    }
    if (WW2_selected) {
      redraw_WW2(overview_proxy, civilian_proxy)
    }
    if (Korea_selected) {
      redraw_Korea(overview_proxy, civilian_proxy)
    }
    if (Vietnam_selected) {
      redraw_Vietnam(overview_proxy, civilian_proxy)
    }
  }
  

### Map Drawers -------------------------------------------------------------

  swap_map_base <- function(proxy, type, options = NULL) {
    proxy %>% clearTiles() %>% addProviderTiles(provider = type, layerId = "overview_base", options = options)
  }
  
  fix_map_base <- function(proxy, map_type) {
    if (map_type == "Color Map") {
      swap_map_base(proxy, type = "Stamen.Watercolor")
    } else if (map_type == "Plain Map") {
      swap_map_base(proxy, type = "CartoDB.PositronNoLabels")
    } else if (map_type == "Terrain Map") {
      swap_map_base(proxy, type = "Stamen.TerrainBackground")
    } else if (map_type == "Street Map") {
      swap_map_base(proxy, type = "HERE.basicMap", options = providerTileOptions(app_id = HERE_id, app_code = HERE_code))
    } else if (input$pick_map == "Satellite Map") {
      swap_map_base(proxy, type = "Esri.WorldImagery")
    }
  }
  
  swap_map_labels <- function(proxy, type) {
    proxy %>% removeTiles(layerId = "overview_labels")
    if (type != "none") {
      proxy %>% addProviderTiles(type, layerId = "overview_labels")
    }
  }
  
  fix_map_labels <- function(proxy, borders, text) {
    if (borders) {
      if (text) {
        debug_message("Both borders and text")
        swap_map_labels(proxy, type = "Stamen.TonerHybrid")
      } else {
        debug_message("Just borders; no text")
        swap_map_labels(proxy, type = "Stamen.TonerLines")
      }
    } else {
      if (text) {
        debug_message("Just text; no borders")
        swap_map_labels(proxy, type = "Stamen.TonerLabels")
      } else {
        debug_message("Neither text nor borders")
        swap_map_labels(proxy, type = "none")
      }
    }
  }
  

### Dropdown Updaters -------------------------------------------------------
  
  # country drop-down updater
  update_countries <- function() {
    countries <- c("All", get_unique_from_selected_wars("Unit_Country"))
    updateSelectizeInput(session, 
                         inputId = "country", 
                         choices = countries, 
                         selected = ifelse(any(input$country %in% countries), 
                                           input$country[input$country %in% countries], 
                                           "All"))
  }
  
  # aircraft drop-down updater
  update_aircraft <- function() {
    aircraft <- c("All", get_unique_from_selected_wars("Aircraft_Type"))
    updateSelectizeInput(session, 
                         inputId = "aircraft", 
                         choices = aircraft, 
                         selected = ifelse(any(input$aircraft %in% aircraft), 
                                           input$aircraft[input$aircraft %in% aircraft], 
                                           "All"))
  }
  
  # weapon drop-down updater
  update_weapons <- function() {
    weapons <- c("All", get_unique_from_selected_wars("Weapon_Type"))
    updateSelectizeInput(session, 
                         inputId = "weapon", 
                         choices = weapons, 
                         selected = ifelse(any(input$weapon %in% weapons), 
                                           input$weapon[input$weapon %in% weapons], 
                                           "All"))
  }
  
  update_selectize_inputs <- function() {
    update_countries()
    update_aircraft()
    update_weapons()
  }
  
  update_other_selectize_inputs <- function(changed) {
    if (changed == "countries") {
      update_aircraft()
      update_weapons()
    } else if (changed == "aircraft") {
      update_countries()
      update_weapons()
    } else if (changed == "weapons") {
      update_countries()
      update_aircraft()
    }
  }
  

### Filtering Functions -----------------------------------------------------

  get_unique_from_selected_wars <- function(column) {
    start_date <- input$dateRange[1]
    end_date <- input$dateRange[2]
    countries <- ifelse(column == "Unit_Country", "All", input$country)
    aircrafts <- ifelse(column == "Aircraft_Type", "All", input$aircraft)
    weapons <- ifelse(column == "Weapon_Type", "All", input$weapon)
    result <- c()
    if (WW1_selected) {
      result <- c(result, 
                  as.character(unique(filter_selection(WW1_clean, 
                                                       start_date, 
                                                       end_date, 
                                                       countries, 
                                                       aircrafts, 
                                                       weapons)[[column]])))
    }
    if (WW2_selected) {
      result <- c(result, 
                  as.character(unique(filter_selection(WW2_clean, 
                                                       start_date, 
                                                       end_date, 
                                                       countries, 
                                                       aircrafts, 
                                                       weapons)[[column]])))
    }
    if (Korea_selected) {
      result <- c(result, 
                  as.character(unique(filter_selection(Korea_clean2, 
                                                       start_date, 
                                                       end_date, 
                                                       countries, 
                                                       aircrafts, 
                                                       weapons)[[column]])))
    }
    if (Vietnam_selected) {
      result <- c(result, 
                  as.character(unique(filter_selection(Vietnam_clean, 
                                                       start_date, 
                                                       end_date, 
                                                       countries, 
                                                       aircrafts, 
                                                       weapons)[[column]])))
    }
    print(result)
    if (length(result) > 0) {
      result <- base::sort(unique(result))
      if ("unspecified" %in% result) {
        result <- c(result[result != "unspecified"], "unspecified")
      }
    }
    result
  }
  
  filter_selection <- function(war_data, start_date, end_date, countries, aircrafts, weapons) {
    if ("All" %in% countries) {
      if ("All" %in% aircrafts) {
        if ("All" %in% weapons) {
          war_data[Mission_Date >= start_date & Mission_Date <= end_date]
        } else {
          war_data[.(weapons), on = .(Weapon_Type)][Mission_Date >= start_date & Mission_Date <= end_date]
        }
      } else {
        if ("All" %in% weapons) {
          war_data[.(aircrafts), on = .(Aircraft_Type)][Mission_Date >= start_date & Mission_Date <= end_date]
        } else {
          war_data[.(aircrafts, weapons), on = .(Aircraft_Type, Weapon_Type)][Mission_Date >= start_date & Mission_Date <= end_date]
        }
      }
    } else {
      if ("All" %in% aircrafts) {
        if ("All" %in% weapons) {
          war_data[.(countries), on = .(Unit_Country)][Mission_Date >= start_date & Mission_Date <= end_date]
        } else {
          war_data[.(countries, weapons), on = .(Unit_Country, Weapon_Type)][Mission_Date >= start_date & Mission_Date <= end_date]
        }
      } else {
        if ("All" %in% weapons) {
          war_data[.(countries, aircrafts), on = .(Unit_Country, Aircraft_Type)][Mission_Date >= start_date & Mission_Date <= end_date]
        } else {
          war_data[.(countries, aircrafts, weapons), on = .(Unit_Country, Aircraft_Type, Weapon_Type)][Mission_Date >= start_date & Mission_Date <= end_date]
        }
      }
    }
  }
  
})
