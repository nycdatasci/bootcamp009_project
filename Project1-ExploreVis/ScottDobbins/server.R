# @author Scott Dobbins
# @version 0.9.8.3
# @date 2017-08-24 22:30


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
  previous_dropdown_selection <- list(country = "All", aircraft = "All", weapon = "All")
  
  overview_proxy <- leafletProxy("overview_map")
  civilian_proxy <- leafletProxy("civilian_map")
  

### War Selections ----------------------------------------------------------

  selected <- function(war_label) {
    reactive(war_label %c% input$which_war)
  }
  war_selected <- lapply(war_labels, selected)
  
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
  war_selection <- lapply(war_tags, selection)
  
  sample_war <- function(war_tag) {
    reactive({
      if ((war_missions_reactive[[war_tag]])() < input$sample_num) {
        (war_selection[[war_tag]])()
      } else {
        war_dt <- (war_selection[[war_tag]])()
        war_dt[sample(seq_len(nrow(war_dt)), size = input$sample_num, replace = FALSE)]
      }
    })
  }
  war_sample <- lapply(war_tags, sample_war)
  
  walk(list(war_selected, 
            war_selection, 
            war_sample), 
       ~setattr(., "names", war_tags))
  

### InfoBox Reactives -------------------------------------------------------
  
  missions_reactive <- function(war_tag) {
    reactive({
      if ((war_selected[[war_tag]])()) {
        (war_selection[[war_tag]])()[, .N]
      } else 0
    })
  }
  war_missions_reactive <- lapply(war_tags, missions_reactive)
  
  flights_reactive <- function(war_tag) {
    reactive({
      if((war_selected[[war_tag]])()) {
        (war_selection[[war_tag]])()[, sum(Aircraft_Attacking_Num,  na.rm = TRUE)]
      } else 0
    })
  }
  war_flights_reactive <- lapply(war_tags, flights_reactive)

  bombs_reactive <- function(war_tag) {
    reactive({
      if((war_selected[[war_tag]])()) {
        (war_selection[[war_tag]])()[, sum(Weapon_Expended_Num,  na.rm = TRUE)]
      } else 0
    })
  }
  war_bombs_reactive <- lapply(war_tags, bombs_reactive)
  
  weight_reactive <- function(war_tag) {
    reactive({
      if((war_selected[[war_tag]])()) {
        (war_selection[[war_tag]])()[, sum(as.numeric(Weapon_Weight_Pounds),  na.rm = TRUE)]
      } else 0
    })
  }
  war_weight_reactive <- lapply(war_tags, weight_reactive)
  
  walk(list(war_missions_reactive, 
            war_flights_reactive, 
            war_bombs_reactive, 
            war_weight_reactive), 
       ~setattr(., "names", war_tags))
  
  war_reactive <- list(missions = war_missions_reactive, 
                       flights  = war_flights_reactive, 
                       bombs    = war_bombs_reactive, 
                       weight   = war_weight_reactive)
  

### Infobox Outputs ---------------------------------------------------------
  
  get_total <- function(type) {
    function() return(sum(map_dbl(war_reactive[[type]], function(f) (f)())))
  }
  get_total_missions <- get_total('missions')
  get_total_flights  <- get_total('flights')
  get_total_bombs    <- get_total('bombs')
  get_total_weight   <- get_total('weight')
  
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
      datatable(data = (war_selection[[war_tag]])()[, war_datatable_columns[[war_tag]], with = FALSE], 
                rownames = FALSE, 
                colnames = war_datatable_colnames[[war_tag]]) %>%
        formatStyle(columns = war_datatable_columns[[war_tag]], 
                    background = war_background[[war_tag]], 
                    fontWeight = font_weight)
    })
  }
  war_datatable_output <- lapply(war_tags, datatable_output)
  setattr(war_datatable_output, "names", war_tags)
  
  output$table <- DT::renderDataTable({
    if ((war_selected[[WW1]])()) {
      (war_datatable_output[[WW1]])()
    } else if ((war_selected[[WW2]])()) {
      (war_datatable_output[[WW2]])()
    } else if ((war_selected[[Korea]])()) {
      (war_datatable_output[[Korea]])()
    } else if ((war_selected[[Vietnam]])()) {
      (war_datatable_output[[Vietnam]])()
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
           WW1     = input$WW1_sandbox_group, 
           WW2     = input$WW2_sandbox_group, 
           Korea   = input$Korea_sandbox_group, 
           Vietnam = input$Vietnam_sandbox_group)
  }
  
  war_sandbox_ind_input <- function(war_tag) {
    switch(war_tag, 
           WW1     = input$WW1_sandbox_ind, 
           WW2     = input$WW2_sandbox_ind, 
           Korea   = input$Korea_sandbox_ind, 
           Vietnam = input$Vietnam_sandbox_ind)
  }
  
  war_sandbox_dep_input <- function(war_tag) {
    switch(war_tag, 
           WW1     = input$WW1_sandbox_dep, 
           WW2     = input$WW2_sandbox_dep, 
           Korea   = input$Korea_sandbox_dep, 
           Vietnam = input$Vietnam_sandbox_dep)
  }
  
  war_hist_slider_input <- function(war_tag) {
    switch(war_tag, 
           WW1     = input$WW1_hist_slider, 
           WW2     = input$WW2_hist_slider, 
           Korea   = input$Korea_hist_slider, 
           Vietnam = input$Vietnam_hist_slider)
  }
  
  war_hor_trans_input <- function(war_tag) {
    switch(war_tag, 
           WW1     = input$WW1_transformation_hor, 
           WW2     = input$WW2_transformation_hor, 
           Korea   = input$Korea_transformation_hor, 
           Vietnam = input$Vietnam_transformation_hor)
  }
  
  war_ver_trans_input <- function(war_tag) {
    switch(war_tag, 
           WW1     = input$WW1_transformation_ver, 
           WW2     = input$WW2_transformation_ver, 
           Korea   = input$Korea_transformation_ver, 
           Vietnam = input$Vietnam_transformation_ver)
  }
  

### Dropdown Inputs ---------------------------------------------------------

  dropdown_input <- function(type) {
    switch(type, 
           country = input$country, 
           aircraft = input$aircraft, 
           weapon = input$weapon)
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
  output$WW1_hist     <- histogram_output(WW1)
  output$WW2_hist     <- histogram_output(WW2)
  output$Korea_hist   <- histogram_output(Korea)
  output$Vietnam_hist <- histogram_output(Vietnam)
  
  
### Data Sandboxes ----------------------------------------------------------
  
  sandbox_output <- function(war_tag) {
    renderPlot({
      ind_input <- war_sandbox_ind_input(war_tag)
      dep_input <- war_sandbox_dep_input(war_tag)
      group_input <- war_sandbox_group_input(war_tag)
      war_dt <- (war_selection[[war_tag]])()
      plot_dep <- war_continuous[[war_tag]][[dep_input]]
      plot_group <- war_categorical[[war_tag]][[group_input]]
      if (ind_input %c% war_continuous_choices[[war_tag]]) {
        plot_ind <- war_continuous[[war_tag]][[ind_input]]
        sandbox_plot <- ggplot(data = war_dt, 
                               mapping = aes_string(x     = plot_ind, 
                                                    y     = plot_dep, 
                                                    color = plot_group)) + 
          guides(color = guide_legend(title = group_input)) + 
          geom_point() + 
          geom_smooth(method = 'lm')
        if (war_hor_trans_input(war_tag) == "Logarithm") {
          sandbox_plot <- sandbox_plot + scale_x_log10()
        }
      } else {
        plot_ind <- war_categorical[[war_tag]][[ind_input]]
        if (ind_input == "None (All Data)") {
          if (group_input == "None") {
            sandbox_plot <- ggplot(mapping = aes(x = "", 
                                                 y = war_dt[[plot_dep]]))
          } else {
            sandbox_plot <- ggplot(mapping = aes(x    = "", 
                                                 y    = war_dt[[plot_dep]], 
                                                 fill = war_dt[[plot_group]])) + 
              guides(fill = guide_legend(title = group_input))
          }
        } else {
          sandbox_plot <- ggplot(data = war_dt, 
                                 mapping = aes_string(x    = plot_ind, 
                                                      y    = plot_dep, 
                                                      fill = plot_group)) + 
            guides(fill = guide_legend(title = group_input))
        }
        sandbox_plot <- sandbox_plot + 
          geom_violin(draw_quantiles = c(0.25, 0.50, 0.75))
      }
      if (war_ver_trans_input(war_tag) == "Logarithm") {
        sandbox_plot <- sandbox_plot + scale_y_log10()
      }
      sandbox_plot + 
        ggtitle(war_sandbox_title[[war_tag]]) + 
        xlab(ind_input) + 
        ylab(dep_input) + 
        theme_bw()
    })
  }
  output$WW1_sandbox     <- sandbox_output(WW1)
  output$WW2_sandbox     <- sandbox_output(WW2)
  output$Korea_sandbox   <- sandbox_output(Korea)
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
    diff_war <- war_tags[which(war_labels == previous_wars_selection %dd% input$which_war)]
    deselected <- length(previous_wars_selection) > length(input$which_war)
    if (is_scalar(diff_war)) {
      if (deselected) {
        debug_message0(diff_war, "deselected")
        (war_clear[[diff_war]])()
      } else {
        debug_message0(diff_war, "selected")
        (war_draw[[diff_war]])()
      }
    } else {
      if (deselected) {
        debug_message("all wars deselected")
        for (tag in diff_war) {
          (war_clear[[diff_war]])()
        }
      } else {
        debug_message("impossible?")
      }
    }
    update_selectize_inputs()
    previous_wars_selection <<- input$which_war
  })
  

### Country observer --------------------------------------------------------
  
  # general observer maker
  dropdown_observer <- function(type) {
    observeEvent(eventExpr = dropdown_input(type), ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
      debug_message0(type, "selected")
      if (change_token %c% previous_dropdown_selection[[type]]) {
        previous_dropdown_selection[[type]] <<- previous_dropdown_selection[[type]] %d% change_token
        redraw()
        update_other_selectize_inputs(type)
      } else {
        input <- dropdown_input(type)
        if (is_empty(input)) {
          previous_dropdown_selection[[type]] <<- c("All", change_token)
          updateSelectizeInput(session, inputId = type, selected = "All")
        } else {
          difference <- previous_dropdown_selection[[type]] %dd% input
          selected <- length(input) > length(previous_dropdown_selection[[type]])
          if ("All" %c% previous_dropdown_selection[[type]]) {
            previous_dropdown_selection[[type]] <<- c(difference, change_token)
            updateSelectizeInput(session, inputId = type, selected = difference)
          } else {
            if ("All" %e% difference) {
              previous_dropdown_selection[[type]] <<- c("All", change_token)
              updateSelectizeInput(session, inputId = type, selected = "All")
            } else {
              previous_dropdown_selection[[type]] <<- input
              redraw()
              update_other_selectize_inputs(type)
            }
          }
        }
      }
    })
  }
  dropdown_observers <- lapply(names(dropdowns), dropdown_observer)
  setattr(dropdown_observers, "names", names(dropdowns))
  

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
  
  
### War Map Drawers ---------------------------------------------------------

  draw_overview_war <- function(war_tag) {
    function() {
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
    }
  }
  war_draw_overview <- lapply(war_tags, draw_overview_war)
  
  clear_overview_war <- function(war_tag) {
    function() {
      overview_proxy %>% clearGroup(group = war_overview[[war_tag]])
    }
  }
  war_clear_overview <- lapply(war_tags, clear_overview_war)
  
  draw_civilian_war <- function(war_tag) {
    function() {
      war_dt <- (war_selection[[war_tag]])()
      civilian_proxy %>% addHeatmap(lng = war_dt[["Target_Longitude"]], 
                                    lat = war_dt[["Target_Latitude"]], 
                                    blur = civilian_blur, 
                                    max = civilian_max, 
                                    radius = civilian_radius, 
                                    group = war_civilian[[war_tag]])
    }
  }
  war_draw_civilian <- lapply(war_tags, draw_civilian_war)
  
  clear_civilian_war <- function(war_tag) {
    function() {
      civilian_proxy %>% clearGroup(group = war_civilian[[war_tag]])
    }
  }
  war_clear_civilian <- lapply(war_tags, clear_civilian_war)
  
  walk(list(war_draw_overview, 
            war_clear_overview, 
            war_draw_civilian, 
            war_clear_civilian), 
       ~setattr(., "names", war_tags))
  

### War Map Composite Drawers -----------------------------------------------
  
  redraw_overview_war <- function(war_tag) {
    function() {
      (war_clear_overview[[war_tag]])()
      (war_draw_overview[[war_tag]])()
    }
  }
  war_redraw_overview <- lapply(war_tags, redraw_overview_war)
  
  redraw_civilian_war <- function(war_tag) {
    function() {
      (war_clear_civilian[[war_tag]])()
      (war_draw_civilian[[war_tag]])()
    }
  }
  war_redraw_civilian <- lapply(war_tags, redraw_civilian_war)
  
  draw_war <- function(war_tag) {
    function() {
      (war_draw_overview[[war_tag]])()
      (war_draw_civilian[[war_tag]])()
    }
  }
  war_draw <- lapply(war_tags, draw_war)
  
  clear_war <- function(war_tag) {
    function() {
      (war_clear_overview[[war_tag]])()
      (war_clear_civilian[[war_tag]])()
    }
  }
  war_clear <- lapply(war_tags, clear_war)
  
  redraw_war <- function(war_tag) {
    function() {
      (war_redraw_overview[[war_tag]])()
      (war_redraw_civilian[[war_tag]])()
    }
  }
  war_redraw <- lapply(war_tags, redraw_war)
  
  walk(list(war_redraw_overview, 
            war_redraw_civilian, 
            war_draw, 
            war_clear, 
            war_redraw), 
       ~setattr(., "names", war_tags))
  

### Total War Map Drawers ---------------------------------------------------

  redraw_overview <- function() {
    for (tag in war_tags) {
      if ((war_selected[[tag]])()) (war_redraw_overview[[tag]])()
    }
  }
  
  redraw_civilian <- function() {
    for (tag in war_tags) {
      if ((war_selected[[tag]])()) (war_redraw_civilian[[tag]])()
    }
  }
  
  redraw <- function() {
    for (tag in war_tags) {
      if ((war_selected[[tag]])()) (war_redraw[[tag]])()
    }
  }
  

### Map Drawers -------------------------------------------------------------

  swap_map_base <- function(type, options = NULL) {
    overview_proxy %>% clearTiles() %>% addProviderTiles(provider = type, layerId = "overview_base", options = options)
  }
  
  fix_map_base <- function(map_type) {
    switch(map_type, 
           "Color Map"     = swap_map_base(type = "Stamen.Watercolor"), 
           "Plain Map"     = swap_map_base(type = "CartoDB.PositronNoLabels"), 
           "Terrain Map"   = swap_map_base(type = "Stamen.TerrainBackground"), 
           "Street Map"    = swap_map_base(type = "HERE.basicMap", options = providerTileOptions(app_id = HERE_id, app_code = HERE_code)), 
           "Satellite Map" = swap_map_base(type = "Esri.WorldImagery"))
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
  
  update_dropdown <- function(type) {
    function() {
      debug_message0(type, "choices updated")
      choices <- c("All", possible_selectize_choices(dropdowns[[type]]))
      input <- dropdown_input(type)
      matches <- input %in% choices
      if (any(matches)) {
        selected <- input[matches]
      } else {
        selected <- "All"
      }
      updateSelectizeInput(session, 
                           inputId = type, 
                           choices = choices, 
                           selected = selected)
    }
  }
  update_countries <- update_dropdown('country')
  update_aircraft  <- update_dropdown('aircraft')
  update_weapons   <- update_dropdown('weapon')
  
  update_selectize_inputs <- function() {
    update_countries()
    update_aircraft()
    update_weapons()
  }
  
  update_other_selectize_inputs <- function(changed) {
    switch(changed, 
           country  = {update_aircraft()
                       update_weapons()}, 
           aircraft = {update_countries()
                       update_weapons()}, 
           weapon   = {update_countries()
                       update_aircraft()})
  }
  

### Filtering Functions -----------------------------------------------------

  possible_selectize_choices <- function(column) {
    start_date <- input$dateRange[1]
    end_date   <- input$dateRange[2]
    countries  <- input$country
    aircrafts  <- input$aircraft
    weapons    <- input$weapon
    switch(column, 
           "Unit_Country"  = {countries <- "All"}, 
           "Aircraft_Type" = {aircrafts <- "All"}, 
           "Weapon_Type"   = {weapons   <- "All"})
    result <- c()
    if (all(c(countries, aircrafts, weapons) == "All")) {
      for (tag in war_tags) {
        if ((war_selected[[tag]])()) {
          result <- append(result, levels(war_data[[tag]][[column]]))
        }
      }
    } else {
      for (tag in war_tags) {
        if ((war_selected[[tag]])()) {
          result <- append(result, unique_from_filter(tag, 
                                                      column, 
                                                      start_date, 
                                                      end_date, 
                                                      countries, 
                                                      aircrafts, 
                                                      weapons))
        }
      }
    }
    if (!is_empty(result)) {
      result <- sort(unique(result))
      if (empty_text %c% result) {
        result <- c(result %[!=]% empty_text, empty_text)
      }
    }
    result
  }
  
  unique_from_filter_slow <- function(war_tag, column, start_date, end_date, countries, aircrafts, weapons) {
    return (levels(unique(filter_selection(war_data[[war_tag]], 
                                           start_date, 
                                           end_date, 
                                           countries, 
                                           aircrafts, 
                                           weapons)[[column]])[, drop = TRUE]))
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
