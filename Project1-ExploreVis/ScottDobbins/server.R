# @author Scott Dobbins
# @version 0.9.8.1
# @date 2017-08-15 21:00


# ### initialize plotly ###
# 
# Sys.setenv("plotly_username"="sdobbins")
# Sys.setenv("plotly_api_key"="ElZwoGYrCyhDGcauIpUQ")


### Constants ---------------------------------------------------------------

change_token <- "change_token"


### Server Component --------------------------------------------------------

shinyServer(function(input, output, session) {
  
### Session variables -------------------------------------------------------

  previous_wars_selection <- c()
  previous_countries_selection <- c("All")
  previous_aircrafts_selection <- c("All")
  previous_weapons_selection <- c("All")
  
  overview_proxy <- leafletProxy("overview_map")
  civilian_proxy <- leafletProxy("civilian_map")
  

### War Selections ----------------------------------------------------------

  selected <- function(war_label) {
    reactive(war_label %c% input$which_war)
  }
  
  WW1_selected     <- selected(WW1_label)
  WW2_selected     <- selected(WW2_label)
  Korea_selected   <- selected(Korea_label)
  Vietnam_selected <- selected(Vietnam_label)
  
  war_selected <- list(WW1_selected, WW2_selected, Korea_selected, Vietnam_selected)
  setattr(war_selected, "names", war_tags)
  
  selection <- function(war_tag) {
    reactive({
      if (all(length(input$dateRange) == 2L, 
              length(input$country)   >= 1L, 
              length(input$aircraft)  >= 1L, 
              length(input$weapon)    >= 1L)) {
        filter_selection(war_data[[war_tag]], 
                         input$dateRange[1], 
                         input$dateRange[2], 
                         input$country, 
                         input$aircraft, 
                         input$weapon)
      } else {
        war_data[[war_tag]]
      }
    })
  }
  
  WW1_selection     <- selection(WW1)
  WW2_selection     <- selection(WW2)
  Korea_selection   <- selection(Korea)
  Vietnam_selection <- selection(Vietnam)
  
  war_selection <- list(WW1_selection, WW2_selection, Korea_selection, Vietnam_selection)
  setattr(war_selection, "names", war_tags)
  

### War Samples -------------------------------------------------------------
  
  sample_war <- function(war_tag) {
    reactive({
      if ((war_missions_reactive[[war_tag]])() < input$sample_num) {
        (war_selection[[war_tag]])()
      } else {
        sample_n((war_selection[[war_tag]])(), input$sample_num, replace = FALSE)
      }
    })
  }
  
  WW1_sample     <- sample_war(WW1)
  WW2_sample     <- sample_war(WW2)
  Korea_sample   <- sample_war(Korea)
  Vietnam_sample <- sample_war(Vietnam)
  
  war_sample <- list(WW1_sample, WW2_sample, Korea_sample, Vietnam_sample)
  setattr(war_sample, "names", war_tags)
  

### InfoBox Reactives -------------------------------------------------------
  
  

### Missions reactives ------------------------------------------------------
  
  missions_reactive <- function(war_tag) {
    reactive({
      if ((war_selected[[war_tag]])()) {
        (war_selection[[war_tag]])()[, .N]
      } else 0
    })
  }
  
  WW1_missions_reactive     <- missions_reactive(WW1)
  WW2_missions_reactive     <- missions_reactive(WW2)
  Korea_missions_reactive   <- missions_reactive(Korea)
  Vietnam_missions_reactive <- missions_reactive(Vietnam)
  
  war_missions_reactive <- list(WW1_missions_reactive, WW2_missions_reactive, Korea_missions_reactive, Vietnam_missions_reactive)
  setattr(war_missions_reactive, "names", war_tags)
  
  
### Flights reactives -------------------------------------------------------

  flights_reactive <- function(war_tag) {
    reactive({
      if((war_selected[[war_tag]])()) {
        (war_selection[[war_tag]])()[, sum(Aircraft_Attacking_Num,  na.rm = TRUE)]
      } else 0
    })
  }
  
  WW1_flights_reactive     <- flights_reactive(WW1)
  WW2_flights_reactive     <- flights_reactive(WW2)
  Korea_flights_reactive   <- flights_reactive(Korea)
  Vietnam_flights_reactive <- flights_reactive(Vietnam)
  
  war_flights_reactive <- list(WW1_flights_reactive, WW2_flights_reactive, Korea_flights_reactive, Vietnam_flights_reactive)
  setattr(war_flights_reactive, "names", war_tags)
  

### Bombs reactives ---------------------------------------------------------
  
  bombs_reactive <- function(war_tag) {
    reactive({
      if((war_selected[[war_tag]])()) {
        (war_selection[[war_tag]])()[, sum(Weapon_Expended_Num,  na.rm = TRUE)]
      } else 0
    })
  }
  
  WW1_bombs_reactive     <- bombs_reactive(WW1)
  WW2_bombs_reactive     <- bombs_reactive(WW2)
  Korea_bombs_reactive   <- bombs_reactive(Korea)
  Vietnam_bombs_reactive <- bombs_reactive(Vietnam)
  
  war_bombs_reactive <- list(WW1_bombs_reactive, WW2_bombs_reactive, Korea_bombs_reactive, Vietnam_bombs_reactive)
  setattr(war_bombs_reactive, "names", war_tags)
  

### Weight reactives --------------------------------------------------------

  weight_reactive <- function(war_tag) {
    reactive({
      if((war_selected[[war_tag]])()) {
        (war_selection[[war_tag]])()[, sum(as.numeric(Weapon_Weight_Pounds),  na.rm = TRUE)]
      } else 0
    })
  }
  
  WW1_weight_reactive     <- weight_reactive(WW1)
  WW2_weight_reactive     <- weight_reactive(WW2)
  Korea_weight_reactive   <- weight_reactive(Korea)
  Vietnam_weight_reactive <- weight_reactive(Vietnam)
  
  war_weight_reactive <- list(WW1_weight_reactive, WW2_weight_reactive, Korea_weight_reactive, Vietnam_weight_reactive)
  setattr(war_weight_reactive, "names", war_tags)
  

### InfoBox Rendering -------------------------------------------------------

  get_total_missions <- function() {
    return (WW1_missions_reactive() + WW2_missions_reactive() + Korea_missions_reactive() + Vietnam_missions_reactive())
  }
  
  get_total_flights <- function() {
    return (WW1_flights_reactive() + WW2_flights_reactive() + Korea_flights_reactive() + Vietnam_flights_reactive())
  }
  
  get_total_bombs <- function() {
    return (WW1_bombs_reactive() + WW2_bombs_reactive() + Korea_bombs_reactive() + Vietnam_bombs_reactive())
  }
  
  get_total_weight <- function() {
    return (WW1_weight_reactive() + WW2_weight_reactive() + Korea_weight_reactive() + Vietnam_weight_reactive())
  }
  
  # number of missions
  output$num_missions <- renderInfoBox({
    infoBox(title = "Missions", 
            value = add_commas(get_total_missions()), 
            icon = icon('chevron-up', lib = 'font-awesome'))
  })
  
  # number of aircraft
  output$num_aircraft <- renderInfoBox({
    infoBox(title = "Aircraft Flights", 
            value = add_commas(get_total_flights()), 
            icon = icon('fighter-jet', lib = 'font-awesome'))
  })
  
  # number of bombs
  output$num_bombs <- renderInfoBox({
    infoBox(title = "Bombs", 
            value = add_commas(get_total_bombs()), 
            icon = icon('bomb', lib = 'font-awesome'))
  })
  
  # weight of bombs
  output$total_weight <- renderInfoBox({
    infoBox(title = "TNT Equivalent (lbs)", 
            value = add_commas(get_total_weight()), 
            icon = icon('fire', lib = 'font-awesome'))
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

    
### DataTable ---------------------------------------------------------------
  
  datatable_output <- function(war_tag) {
    reactive({
      datatable(data = (war_selection[[war_tag]])() %>% select(war_datatable_columns[[war_tag]]), 
                rownames = FALSE, 
                colnames = war_datatable_colnames[[war_tag]]) %>%
        formatStyle(columns = war_datatable_columns[[war_tag]], 
                    background = war_background[[war_tag]], 
                    fontWeight = font_weight)
    })
  }
  
  WW1_datatable_output <- datatable_output(WW1)
  WW2_datatable_output <- datatable_output(WW2)
  Korea_datatable_output <- datatable_output(Korea)
  Vietnam_datatable_output <- datatable_output(Vietnam)
  
  war_datatable_outputs <- list(WW1_datatable_output, WW2_datatable_output, Korea_datatable_output, Vietnam_datatable_output)
  setattr(war_datatable_outputs, "names", war_tags)
  
  output$table <- DT::renderDataTable({
    if (WW1_selected()) {
      WW1_datatable_output()
    } else if (WW2_selected()) {
      WW2_datatable_output()
    } else if (Korea_selected()) {
      Korea_datatable_output()
    } else if (Vietnam_selected()) {
      Vietnam_datatable_output()
    } else {
      datatable(data = data.table(Example = list("Pick a war"), Data = list("to see its data")), 
                rownames = FALSE) %>%
        formatStyle(columns = 1:2, 
                    background = example_background, 
                    fontWeight = font_weight)
    }
  })
  
  
### Data Graph Inputs -------------------------------------------------------
  
  war_sandbox_group_input <- function(war_tag) {
    switch(war_tag, 
           WW1 = input$WW1_sandbox_group, 
           WW2 = input$WW2_sandbox_group, 
           Korea = input$Korea_sandbox_group, 
           Vietnam = input$Vietnam_sandbox_group)
  }
  
  war_sandbox_ind_input <- function(war_tag) {
    switch(war_tag, 
           WW1 = input$WW1_sandbox_ind, 
           WW2 = input$WW2_sandbox_ind, 
           Korea = input$Korea_sandbox_ind, 
           Vietnam = input$Vietnam_sandbox_ind)
  }
  
  war_sandbox_dep_input <- function(war_tag) {
    switch(war_tag, 
           WW1 = input$WW1_sandbox_dep, 
           WW2 = input$WW2_sandbox_dep, 
           Korea = input$Korea_sandbox_dep, 
           Vietnam = input$Vietnam_sandbox_dep)
  }
  
  war_hist_slider_input <- function(war_tag) {
    switch(war_tag, 
           WW1 = input$WW1_hist_slider, 
           WW2 = input$WW2_hist_slider, 
           Korea = input$Korea_hist_slider, 
           Vietnam = input$Vietnam_hist_slider)
  }
  
  war_hor_trans_input <- function(war_tag) {
    switch(war_tag, 
           WW1 = input$WW1_transformation_hor, 
           WW2 = input$WW2_transformation_hor, 
           Korea = input$Korea_transformation_hor, 
           Vietnam = input$Vietnam_transformation_hor)
  }
  
  war_ver_trans_input <- function(war_tag) {
    switch(war_tag, 
           WW1 = input$WW1_transformation_ver, 
           WW2 = input$WW2_transformation_ver, 
           Korea = input$Korea_transformation_ver, 
           Vietnam = input$Vietnam_transformation_ver)
  }
  

### Data Histograms ---------------------------------------------------------
  
  histogram_output <- function(war_tag) {
    renderPlot({
      war_dt <- (war_selection[[war_tag]])()
      group_input <- war_sandbox_group_input(war_tag)
      ver_trans_input <- war_ver_trans_input(war_tag)
      if (group_input == "None") {
        hist_plot <- ggplot(mapping = aes(x = war_dt[["Mission_Date"]])) + 
          geom_histogram(bins = war_hist_slider_input(war_tag))
      } else {
        group_category <- war_categorical[[war_tag]][[group_input]]
        hist_plot <- ggplot(mapping = aes(x     = war_dt[["Mission_Date"]], 
                                          color = war_dt[[group_category]])) + 
          geom_freqpoly(bins = war_hist_slider_input(war_tag)) + 
          guides(color = guide_legend(title = group_input))
      }
      hist_plot <- hist_plot + 
        ggtitle(war_histogram_title[[war_tag]]) + 
        xlab("Date") + 
        ylab("Number of Missions") + 
        theme_bw()
      if (ver_trans_input == "None") {
        hist_plot
      } else {
        hist_plot + 
          scale_y_log10()
      }
    })
  }
  
  output$WW1_hist <- histogram_output(WW1)
  output$WW2_hist <- histogram_output(WW2)
  output$Korea_hist <- histogram_output(Korea)
  output$Vietnam_hist <- histogram_output(Vietnam)
  

### Data Sandboxes ----------------------------------------------------------
  
  sandbox_output <- function(war_tag) {
    renderPlot({
      war_dt <- (war_selection[[war_tag]])()
      ind_input <- war_sandbox_ind_input(war_tag)
      dep_input <- war_sandbox_dep_input(war_tag)
      group_input <- war_sandbox_group_input(war_tag)
      hor_trans_input <- war_hor_trans_input(war_tag)
      ver_trans_input <- war_ver_trans_input(war_tag)
      if (ind_input == "None (All Data)") {
        plot_continuous <- war_continuous[[war_tag]][[dep_input]]
        if (group_input == "None") {
          sandbox_plot <- ggplot(mapping = aes(x = "", 
                                               y = war_dt[[plot_continuous]]))
        } else {
          group_category <- war_categorical[[war_tag]][[group_input]]
          sandbox_plot <- ggplot(mapping = aes(x     = "", 
                                               y     = war_dt[[plot_continuous]], 
                                               fill  = war_dt[[group_category]]))
          sandbox_plot <- sandbox_plot + guides(fill = guide_legend(title = group_input))
        }
        sandbox_plot <- sandbox_plot + 
          geom_violin() + 
          stat_summary(fun.y = quartile_points, 
                       geom = 'point', 
                       position = position_dodge(width = 0.9))
      } else if (ind_input == "Year") {
        plot_continuous <- war_continuous[[war_tag]][[dep_input]]
        if (group_input == "None") {
          sandbox_plot <- ggplot(mapping = aes(x = war_dt[["Year"]], 
                                               y = war_dt[[plot_continuous]]))
        } else {
          group_category <- war_categorical[[war_tag]][[group_input]]
          sandbox_plot <- ggplot(mapping = aes(x     = war_dt[["Year"]], 
                                               y     = war_dt[[plot_continuous]], 
                                               fill  = war_dt[[group_category]])) + 
            guides(fill = guide_legend(title = group_input))
        }
        sandbox_plot <- sandbox_plot + 
          geom_violin() + 
          stat_summary(fun.y = quartile_points, 
                       geom = 'point', 
                       position = position_dodge(width = 0.9))
      } else if (ind_input %c% war_categorical_choices[[war_tag]]) {
        plot_category <- war_categorical[[war_tag]][[ind_input]]
        plot_continuous <- war_continuous[[war_tag]][[dep_input]]
        if (group_input == "None") {
          sandbox_plot <- ggplot(mapping = aes(x = war_dt[[plot_category]], 
                                               y = war_dt[[plot_continuous]]))
        } else {
          group_category <- war_categorical[[war_tag]][[group_input]]
          sandbox_plot <- ggplot(mapping = aes(x     = war_dt[[plot_category]], 
                                               y     = war_dt[[plot_continuous]], 
                                               fill  = war_dt[[group_category]])) + 
            guides(fill = guide_legend(title = group_input))
        }
        sandbox_plot <- sandbox_plot + 
          geom_violin() + 
          stat_summary(fun.y = quartile_points, 
                       geom = 'point', 
                       position = position_dodge(width = 0.9))
      } else {
        plot_independent <- war_continuous[[war_tag]][[ind_input]]
        plot_dependent <- war_continuous[[war_tag]][[dep_input]]
        if (group_input == "None") {
          sandbox_plot <- ggplot(mapping = aes(x = war_dt[[plot_independent]], 
                                               y = war_dt[[plot_dependent]]))
        } else {
          group_category <- war_categorical[[war_tag]][[group_input]]
          sandbox_plot <- ggplot(mapping = aes(x     = war_dt[[plot_independent]], 
                                               y     = war_dt[[plot_dependent]], 
                                               color = war_dt[[group_category]])) + 
            guides(color = guide_legend(title = group_input))
        }
        sandbox_plot <- sandbox_plot + 
          geom_point() + 
          geom_smooth(method = 'lm')
      }
      sandbox_plot <- sandbox_plot + 
        ggtitle(war_sandbox_title[[war_tag]]) + 
        xlab(ind_input) + 
        ylab(dep_input) + 
        theme_bw()
      if (hor_trans_input == "None" || 
          (ind_input %c% c("None (All Data)", "Year", war_categorical_choices[[war_tag]]))) {
        if (ver_trans_input == "None") {
          sandbox_plot
        } else {
          sandbox_plot + 
            scale_y_log10()
        }
      } else {
        if (ver_trans_input == "None") {
          sandbox_plot + 
            scale_x_log10()
        } else {
          sandbox_plot + 
            scale_x_log10() + 
            scale_y_log10()
        }
      }
    })
  }
  
  output$WW1_sandbox <- sandbox_output(WW1)
  output$WW2_sandbox <- sandbox_output(WW2)
  output$Korea_sandbox <- sandbox_output(Korea)
  output$Vietnam_sandbox <- sandbox_output(Vietnam)
  

### Observers ---------------------------------------------------------------


### Map observers -----------------------------------------------------------
  
  # hanlder for changes in map type
  observeEvent(eventExpr = input$pick_map, handlerExpr = {
    debug_message("map altered")
    # remove other tiles and add designated map
    fix_map_base(map_type = input$pick_map)
    # gotta redraw the map labels if the underlying map has changed
    fix_map_labels(borders = "Borders" %c% input$pick_labels, 
                   text = "Text" %c% input$pick_labels)
  })
  
  # handler for changes in map labels
  observeEvent(eventExpr = input$pick_labels, ignoreNULL = FALSE, handlerExpr = {
    debug_message("labels altered")
    fix_map_labels(borders = "Borders" %c% input$pick_labels, 
                   text = "Text" %c% input$pick_labels)
  })
  
  # handler for changes in map zoom
  observeEvent(eventExpr = input$overview_map_zoom, handlerExpr = {
    debug_message("map zoomed")
    redraw_overview()
  })
  

### War observer ------------------------------------------------------------

  # handler for war selection
  observeEvent(eventExpr = input$which_war, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    debug_message("wars selected")
    diff_war <- previous_wars_selection %dd% input$which_war
    deselected <- length(previous_wars_selection) > length(input$which_war)
    if (WW1_label %e% diff_war) {
      if (deselected) {
        debug_message("WW1 deselected")
        clear_WW1()
      } else {
        debug_message("WW1 selected")
        draw_WW1()
      }
    } else if(WW2_label %e% diff_war) {
      if (deselected) {
        debug_message("WW2 deselected")
        clear_WW2()
      } else {
        debug_message("WW2 selected")
        draw_WW2()
      }
    } else if(Korea_label %e% diff_war) {
      if (deselected) {
        debug_message("Korea deselected")
        clear_Korea()
      } else {
        debug_message("Korea selected")
        draw_Korea()
      }
    } else if(Vietnam_label %e% diff_war) {
      if (deselected) {
        debug_message("Vietnam deselected")
        clear_Vietnam()
      } else {
        debug_message("Vietnam selected")
        draw_Vietnam()
      }
    } else {
      debug_message("all wars deselected")
      if (WW1_label %c% previous_wars_selection) {
        clear_WW1()
      }
      if (WW2_label %c% previous_wars_selection) {
        clear_WW2()
      }
      if (Korea_label %c% previous_wars_selection) {
        clear_Korea()
      }
      if (Vietnam_label %c% previous_wars_selection) {
        clear_Vietnam()
      }
    }
    update_selectize_inputs()
    previous_wars_selection <<- input$which_war
  })
  

### Country observer --------------------------------------------------------
  
  # handler for country selection
  observeEvent(eventExpr = input$country, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    debug_message("country selected")
    if (change_token %c% previous_countries_selection) {
      previous_countries_selection <<- previous_countries_selection %d% change_token
      redraw()
      update_other_selectize_inputs("countries")
    } else {
      if (length(input$country) == 0L) {
        previous_countries_selection <<- c("All", change_token)
        updateSelectizeInput(session, inputId = "country", selected = "All")
      } else {
        diff_country <- previous_countries_selection %dd% input$country
        selected <- length(input$country) > length(previous_countries_selection)
        if ("All" %c% previous_countries_selection) {
          previous_countries_selection <<- c(diff_country, change_token)
          updateSelectizeInput(session, inputId = "country", selected = diff_country)
        } else {
          if ("All" %e% diff_country) {
            previous_countries_selection <<- c("All", change_token)
            updateSelectizeInput(session, inputId = "country", selected = "All")
          } else {
            previous_countries_selection <<- input$country
            redraw()
            update_other_selectize_inputs("countries")
          }
        }
      }
    }
  })


### Aircraft observer -------------------------------------------------------

  # handler for aircraft selection
  observeEvent(eventExpr = input$aircraft, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    debug_message("aircraft selected")
    if (change_token %c% previous_aircrafts_selection) {
      previous_aircrafts_selection <<- previous_aircrafts_selection %d% change_token
      redraw()
      update_other_selectize_inputs("aircraft")
    } else {
      if (length(input$aircraft) == 0L) {
        previous_aircrafts_selection <<- c("All", change_token)
        updateSelectizeInput(session, inputId = "aircraft", selected = "All")
      } else {
        diff_aircraft <- previous_aircrafts_selection %dd% input$aircraft
        selected <- length(input$aircraft) > length(previous_aircrafts_selection)
        if ("All" %c% previous_aircrafts_selection) {
          previous_aircrafts_selection <<- c(diff_aircraft, change_token)
          updateSelectizeInput(session, inputId = "aircraft", selected = diff_aircraft)
        } else {
          if ("All" %e% diff_aircraft) {
            previous_aircrafts_selection <<- c("All", change_token)
            updateSelectizeInput(session, inputId = "aircraft", selected = "All")
          } else {
            previous_aircrafts_selection <<- input$aircraft
            redraw()
            update_other_selectize_inputs("aircraft")
          }
        }
      }
    }
  })
  

### Weapon observer ---------------------------------------------------------

  # handler for weapon selection
  observeEvent(eventExpr = input$weapon, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    debug_message("weapon selected")
    if (change_token %c% previous_weapons_selection) {
      previous_weapons_selection <<- previous_weapons_selection %d% change_token
      redraw()
      update_other_selectize_inputs("weapons")
    } else {
      if (length(input$weapons) == 0L) {
        previous_weapons_selection <<- c("All", change_token)
        updateSelectizeInput(session, inputId = "weapons", selected = "All")
      } else {
        diff_weapon <- previous_weapons_selection %dd% input$weapons
        selected <- length(input$weapons) > length(previous_weapons_selection)
        if ("All" %c% previous_weapons_selection) {
          previous_weapons_selection <<- c(diff_weapon, change_token)
          updateSelectizeInput(session, inputId = "weapons", selected = diff_weapon)
        } else {
          if ("All" %e% diff_weapon) {
            previous_weapons_selection <<- c("All", change_token)
            updateSelectizeInput(session, inputId = "weapons", selected = "All")
          } else {
            previous_weapons_selection <<- input$weapons
            redraw()
            update_other_selectize_inputs("weapons")
          }
        }
      }
    }
  })
  

### Other observers ---------------------------------------------------------

  # handler for sample size refresh
  observeEvent(eventExpr = input$sample_num, ignoreNULL = TRUE, ignoreInit = TRUE, handlerExpr = {
    debug_message("sample size changed")
    redraw_overview()
  })
  
  # handler for date range refresh
  observeEvent(eventExpr = input$dateRange, ignoreNULL = TRUE, ignoreInit = TRUE, handlerExpr = {
    debug_message("date range changed")
    redraw()
  })
  
  
### General Drawers ---------------------------------------------------------

  war_clear_overview <- function(war_tag) {
    reactive({
      overview_proxy %>% clearGroup(group = war_overview[[war_tag]])
    })
  }
  
  clear_WW1_overview <- war_clear_overview(WW1)
  clear_WW2_overview <- war_clear_overview(WW2)
  clear_Korea_overview <- war_clear_overview(Korea)
  clear_Vietnam_overview <- war_clear_overview(Vietnam)
  
  war_draw_overview <- function(war_tag) {
    reactive({
      opacity <- calculate_opacity(min((war_missions_reactive[[war_tag]])(), input$sample_num), input$overview_map_zoom)
      overview_proxy %>% addCircles(data = (war_sample[[war_tag]])(),
                                    lat = ~Target_Latitude,
                                    lng = ~Target_Longitude,
                                    color = war_color[[war_tag]],
                                    weight = point_weight + input$overview_map_zoom,
                                    opacity = opacity,
                                    fill = point_fill,
                                    fillColor = war_color[[war_tag]],
                                    fillOpacity = opacity,
                                    popup = ~tooltip,
                                    group = war_overview[[war_tag]])
    })
  }
  
  draw_WW1_overview <- war_draw_overview(WW1)
  draw_WW2_overview <- war_draw_overview(WW2)
  draw_Korea_overview <- war_draw_overview(Korea)
  draw_Vietnam_overview <- war_draw_overview(Vietnam)
  
  war_clear_civilian <- function(war_tag) {
    reactive({
      civilian_proxy %>% clearGroup(group = war_civilian[[war_tag]])
    })
  }
  
  clear_WW1_civilian <- war_clear_civilian(WW1)
  clear_WW2_civilian <- war_clear_civilian(WW2)
  clear_Korea_civilian <- war_clear_civilian(Korea)
  clear_Vietnam_civilian <- war_clear_civilian(Vietnam)
  
  war_draw_civilian <- function(war_tag) {
    reactive({
      war_dt <- (war_selection[[war_tag]])()
      civilian_proxy %>% addHeatmap(lng = war_dt[["Target_Longitude"]], 
                                    lat = war_dt[["Target_Latitude"]], 
                                    blur = civilian_blur, 
                                    max = civilian_max, 
                                    radius = civilian_radius, 
                                    group = war_civilian[[war_tag]])
    })
  }
  
  draw_WW1_civilian <- war_draw_civilian(WW1)
  draw_WW2_civilian <- war_draw_civilian(WW2)
  draw_Korea_civilian <- war_draw_civilian(Korea)
  draw_Vietnam_civilian <- war_draw_civilian(Vietnam)
  

### WW1 Drawers -------------------------------------------------------------
  
  redraw_WW1_overview <- function() {
    clear_WW1_overview()
    draw_WW1_overview()
  }
  
  redraw_WW1_civilian <- function() {
    clear_WW1_civilian()
    draw_WW1_civilian()
  }
  
  clear_WW1 <- function() {
    clear_WW1_overview()
    clear_WW1_civilian()
  }
  
  draw_WW1 <- function() {
    draw_WW1_overview()
    draw_WW1_civilian()
  }
  
  redraw_WW1 <- function() {
    redraw_WW1_overview()
    redraw_WW1_civilian()
  }
  

### WW2 Drawers -------------------------------------------------------------
  
  redraw_WW2_overview <- function() {
    clear_WW2_overview()
    draw_WW2_overview()
  }
  
  redraw_WW2_civilian <- function() {
    clear_WW2_civilian()
    draw_WW2_civilian()
  }
  
  clear_WW2 <- function() {
    clear_WW2_overview()
    clear_WW2_civilian()
  }
  
  draw_WW2 <- function() {
    draw_WW2_overview()
    draw_WW2_civilian()
  }
  
  redraw_WW2 <- function() {
    redraw_WW2_overview()
    redraw_WW2_civilian()
  }
  

### Korea Drawers -----------------------------------------------------------
  
  redraw_Korea_overview <- function() {
    clear_Korea_overview()
    draw_Korea_overview()
  }
  
  redraw_Korea_civilian <- function() {
    clear_Korea_civilian()
    draw_Korea_civilian()
  }
  
  clear_Korea <- function() {
    clear_Korea_overview()
    clear_Korea_civilian()
  }
  
  draw_Korea <- function() {
    draw_Korea_overview()
    draw_Korea_civilian()
  }
  
  redraw_Korea <- function() {
    redraw_Korea_overview()
    redraw_Korea_civilian()
  }
  

### Vietnam Drawers ---------------------------------------------------------
  
  redraw_Vietnam_overview <- function() {
    clear_Vietnam_overview()
    draw_Vietnam_overview()
  }
  
  redraw_Vietnam_civilian <- function() {
    clear_Vietnam_civilian()
    draw_Vietnam_civilian()
  }
  
  clear_Vietnam <- function() {
    clear_Vietnam_overview()
    clear_Vietnam_civilian()
  }
  
  draw_Vietnam <- function() {
    draw_Vietnam_overview()
    draw_Vietnam_civilian()
  }
  
  redraw_Vietnam <- function() {
    redraw_Vietnam_overview()
    redraw_Vietnam_civilian()
  }
  

### General Drawers ---------------------------------------------------------

  redraw_overview <- function() {
    if (WW1_selected()) redraw_WW1_overview()
    if (WW2_selected()) redraw_WW2_overview()
    if (Korea_selected()) redraw_Korea_overview()
    if (Vietnam_selected()) redraw_Vietnam_overview()
  }
  
  redraw_civilian <- function() {
    if (WW1_selected()) redraw_WW1_civilian()
    if (WW2_selected()) redraw_WW2_civilian()
    if (Korea_selected()) redraw_Korea_civilian()
    if (Vietnam_selected()) redraw_Vietnam_civilian()
  }
  
  redraw <- function() {
    if (WW1_selected()) redraw_WW1()
    if (WW2_selected()) redraw_WW2()
    if (Korea_selected()) redraw_Korea()
    if (Vietnam_selected()) redraw_Vietnam()
  }
  

### Map Drawers -------------------------------------------------------------

  swap_map_base <- function(type, options = NULL) {
    overview_proxy %>% clearTiles() %>% addProviderTiles(provider = type, layerId = "overview_base", options = options)
  }
  
  fix_map_base <- function(map_type) {
    if (map_type == "Color Map") {
      swap_map_base(type = "Stamen.Watercolor")
    } else if (map_type == "Plain Map") {
      swap_map_base(type = "CartoDB.PositronNoLabels")
    } else if (map_type == "Terrain Map") {
      swap_map_base(type = "Stamen.TerrainBackground")
    } else if (map_type == "Street Map") {
      swap_map_base(type = "HERE.basicMap", options = providerTileOptions(app_id = HERE_id, app_code = HERE_code))
    } else if (input$pick_map == "Satellite Map") {
      swap_map_base(type = "Esri.WorldImagery")
    }
  }
  
  swap_map_labels <- function(type) {
    overview_proxy %>% removeTiles(layerId = "overview_labels")
    if (type != "none") {
      overview_proxy %>% addProviderTiles(type, layerId = "overview_labels")
    }
  }
  
  fix_map_labels <- function(borders, text) {
    if (borders) {
      if (text) {
        debug_message("Both borders and text")
        swap_map_labels(type = "Stamen.TonerHybrid")
      } else {
        debug_message("Just borders; no text")
        swap_map_labels(type = "Stamen.TonerLines")
      }
    } else {
      if (text) {
        debug_message("Just text; no borders")
        swap_map_labels(type = "Stamen.TonerLabels")
      } else {
        debug_message("Neither text nor borders")
        swap_map_labels(type = "none")
      }
    }
  }
  

### Dropdown Updaters -------------------------------------------------------
  
  # country drop-down updater
  update_countries <- function() {
    debug_message("Countries choices updated")
    country_choices <- c("All", possible_selectize_choices("Unit_Country"))
    country_matches <- input$country %in% country_choices
    if (any(country_matches)) {
      countries_selected <- input$country[country_matches]
    } else {
      countries_selected <- "All"
    }
    updateSelectizeInput(session, 
                         inputId = "country", 
                         choices = country_choices, 
                         selected = countries_selected)
  }
  
  # aircraft drop-down updater
  update_aircraft <- function() {
    debug_message("Aircraft choices updated")
    aircraft_choices <- c("All", possible_selectize_choices("Aircraft_Type"))
    aircraft_matches <- input$aircraft %in% aircraft_choices
    if (any(aircraft_matches)) {
      aircraft_selected <- input$aircraft[aircraft_matches]
    } else {
      aircraft_selected <- "All"
    }
    updateSelectizeInput(session, 
                         inputId = "aircraft", 
                         choices = aircraft_choices, 
                         selected = aircraft_selected)
  }
  
  # weapon drop-down updater
  update_weapons <- function() {
    debug_message("Weapons choices updated")
    weapon_choices <- c("All", possible_selectize_choices("Weapon_Type"))
    weapon_matches <- input$weapon %in% weapon_choices
    if (any(weapon_matches)) {
      weapons_selected <- input$weapon[weapon_matches]
    } else {
      weapons_selected <- "All"
    }
    updateSelectizeInput(session, 
                         inputId = "weapon", 
                         choices = weapon_choices, 
                         selected = weapons_selected)
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

  possible_selectize_choices <- function(column) {
    start_date <- input$dateRange[1]
    end_date <- input$dateRange[2]
    countries <- input$country
    aircrafts <- input$aircraft
    weapons <- input$weapon
    if (column == "Unit_Country") {
      countries <- "All"
    } else if (column == "Aircraft_Type") {
      aircrafts <- "All"
    } else if (column == "Weapon_Type") {
      weapons <- "All"
    }
    
    result <- c()
    conditions <- c(WW1_selected(), WW2_selected(), Korea_selected(), Vietnam_selected())
    
    if (all(c(countries, aircrafts, weapons) == "All")) {
      for (i in seq_along(conditions)) {
        if (conditions[[i]]) {
          result <- append(result, levels(war_data[[i]][[column]]))
        }
      }
    } else {
      for (i in seq_along(conditions)) {
        if (conditions[[i]]) {
          result <- append(result, unique_from_filter(war_tags[[i]], 
                                                      column, 
                                                      start_date, 
                                                      end_date, 
                                                      countries, 
                                                      aircrafts, 
                                                      weapons))
        }
      }
    }
    
    if (length(result) > 0) {
      result <- sort(unique(result))
      if (empty_text %c% result) {
        result <- c(result %[!=]% empty_text, empty_text)
      }
    }
    result
  }
  
  unique_from_filter_slow <- function(war_tag, column, start_date, end_date, countries, aircrafts, weapons) {
    return (as.character(unique(filter_selection(war_data[[war_tag]], 
                                                 start_date, 
                                                 end_date, 
                                                 countries, 
                                                 aircrafts, 
                                                 weapons)[[column]])))
  }
  
  unique_from_filter <- memoise(unique_from_filter_slow)
  
  filter_selection <- function(war_dt, start_date, end_date, countries, aircrafts, weapons) {
    if ("All" %c% countries) {
      if ("All" %c% aircrafts) {
        if ("All" %c% weapons) {
          war_dt[Mission_Date >= start_date & Mission_Date <= end_date]
        } else {
          war_dt[.(weapons), on = .(Weapon_Type)][Mission_Date >= start_date & Mission_Date <= end_date]
        }
      } else {
        if ("All" %c% weapons) {
          war_dt[.(aircrafts), on = .(Aircraft_Type)][Mission_Date >= start_date & Mission_Date <= end_date]
        } else {
          war_dt[.(aircrafts, weapons), on = .(Aircraft_Type, Weapon_Type)][Mission_Date >= start_date & Mission_Date <= end_date]
        }
      }
    } else {
      if ("All" %c% aircrafts) {
        if ("All" %c% weapons) {
          war_dt[.(countries), on = .(Unit_Country)][Mission_Date >= start_date & Mission_Date <= end_date]
        } else {
          war_dt[.(countries, weapons), on = .(Unit_Country, Weapon_Type)][Mission_Date >= start_date & Mission_Date <= end_date]
        }
      } else {
        if ("All" %c% weapons) {
          war_dt[.(countries, aircrafts), on = .(Unit_Country, Aircraft_Type)][Mission_Date >= start_date & Mission_Date <= end_date]
        } else {
          war_dt[.(countries, aircrafts, weapons), on = .(Unit_Country, Aircraft_Type, Weapon_Type)][Mission_Date >= start_date & Mission_Date <= end_date]
        }
      }
    }
  }
  
})
