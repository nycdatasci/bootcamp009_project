# @author Scott Dobbins
# @version 0.9.8
# @date 2017-08-11 23:30

### Code Graveyard ###
# where buggy or formerly useful but now unnecessary code lays to rest
# can resurrect if necessary

checkboxInput(inputId = "show_labels", label = "Show Labels", value = TRUE),
checkboxGroupInput(inputId = "show_bombings", label = "Show Data Options", choiceNames = c("Show WW1", "Show WW2", "Show Korea", "Show Vietnam"), choiceValues = c("show_WW1", "show_WW2", "show_Korea", "show_Vietnam"))

observeEvent(input$show_map, {
  if(debug_mode_on) print("combo pressed")
  proxy <- leafletProxy("mymap")
  if("show_watercolor" %in% input$show_map) {
    if(debug_mode_on) print("watercolor pressed")
    if("show_borders" %in% input$show_map) {
      proxy %>% addProviderTiles("Stamen.Watercolor", layerId = "watercolor") %>% addProviderTiles("Stamen.TonerHybrid", layerId = "borders")
    } else {
      proxy %>% addProviderTiles("Stamen.Watercolor", layerId = "watercolor")
    }
  } else {
    if(debug_mode_on) print("labels pressed")
    if("show_borders" %in% input$show_map) {
      proxy %>% clearTiles() %>% addProviderTiles("Stamen.TonerHybrid", layerId = "borders")
    } else {
      proxy %>% clearTiles()
    }
  }
})

if(input$show_watercolor) {
  if(input$show_borders) {
    proxy %>% addProviderTiles("Stamen.Watercolor", layerId = "watercolor") %>% addProviderTiles("Stamen.TonerHybrid", layerId = "borders")
  } else {
    proxy %>% addProviderTiles("Stamen.Watercolor", layerId = "watercolor")
  }
} else {
  if(input$show_borders) {
    proxy %>% clearTiles() %>% addProviderTiles("Stamen.TonerHybrid", layerId = "borders")
  } else {
    proxy %>% clearTiles()
  }
}

observeEvent(input$show_bombings, {
  if(debug_mode_on) print("bombings pressed")
  proxy <- leafletProxy("mymap")
  if("show_WW1" %in% input$show_bombings) {
    if(debug_mode_on) print("WW1 pressed")
    proxy %>% addCircles(data = WW1_unique_target, lat = ~Target.Latitude, lng = ~Target.Longitude, color = "blue", weight = 5, opacity = 0.5, fill = TRUE, group = "WW1_unique_targets")
  } else {
    proxy %>% clearGroup(group = "WW1_unique_targets")
  }
  if("show_WW2" %in% input$show_bombings) {
    if(debug_mode_on) print("WW2 pressed")
    proxy %>% addCircles(data = WW2_unique_target, lat = ~Target.Latitude, lng = ~Target.Longitude, color = "red", weight = 5, opacity = 0.5, fill = TRUE, group = "WW2_unique_targets")
  } else {
    proxy %>% clearGroup(group = "WW2_unique_targets")
  }
  if("show_Korea" %in% input$show_bombings) {
    if(debug_mode_on) print("Korea pressed")
    proxy %>% addCircles(data = Korea_unique_target, lat = ~Target.Latitude, lng = ~Target.Longitude, color = "yellow", weight = 5, opacity = 0.5, fill = TRUE, group = "Korea_unique_targets")
  } else {
    proxy %>% clearGroup(group = "Korea_unique_targets")
  }
  if("show_Vietnam" %in% input$show_bombings) {
    if(debug_mode_on) print("Vietnam pressed")
    proxy %>% addCircles(data = Vietnam_unique_target, lat = ~Target.Latitude, lng = ~Target.Longitude, color = "green", weight = 5, opacity = 0.5, fill = TRUE, group = "Vietnam_unique_targets")
  } else {
    proxy %>% clearGroup(group = "Vietnam_unique_targets")
  }
})

col_num_missing_values <- vector(mode='integer', length(WW2_extra))

for(c in 1:length(WW2_extra)) {
  print("hello")
  if(class(WW2_extra[[c]]) == "numeric" | class(WW2_extra[[c]]) == "integer" | class(WW2_extra[[c]]) == "Date") {
    col_num_missing_values[c] <- sum(is.na(WW2_extra[[c]]))
  } else if(class(WW2_extra[[c]]) == "character") {
    col_num_missing_values[c] <- sum(WW2_extra[[c]] == '')
  } else if(class(WW2_extra[[c]]) == 'logical') {
    col_num_missing_values[c] <- sum(!WW2_extra[[c]])
  }
}

remove_quote_padding <- function(cell) {
  if(cell[1] == "\"" & cell[nchar(cell)] == "\"") {
    return(remove_quote_padding(substring(cell, 2, nchar(cell)-1)))
  } else {
    return(cell)
  }
}

WW1_raw$Mission.Date <- as.Date(WW1_raw$Mission.Date, format = "%Y-%m-%d")
WW2_raw$Mission.Date <- as.Date(WW2_raw$Mission.Date, format = "%m/%d/%Y")
Korea_raw1$Mission.Date <- as.Date(Korea_raw1$Mission.Date, format = "%m/%d/%y")
Korea_raw2$Mission.Date <- as.Date(Korea_raw2$Mission.Date, format = "%m/%d/%y")
Vietnam_raw$Mission.Date <- as.Date(Vietnam_raw$Mission.Date, format = "%Y-%m-%d")

WW1_sample <- WW1_unique_target[sample(x = c(TRUE, FALSE), replace = TRUE, prob = c(1000/nrow(WW1_unique_target), 1-1000/nrow(WW1_unique_target))),]
WW2_sample <- WW2_unique_target[sample(x = c(TRUE, FALSE), replace = TRUE, prob = c(1000/nrow(WW2_unique_target), 1-1000/nrow(WW2_unique_target))),]
Korea_sample <- Korea_unique_target2[sample(x = c(TRUE, FALSE), replace = TRUE, prob = c(1000/nrow(Korea_unique_target2), 1-1000/nrow(Korea_unique_target2))),]
Vietnam_sample <- Vietnam_unique_target[sample(x = c(TRUE, FALSE), replace = TRUE, prob = c(1000/nrow(Vietnam_unique_target), 1-1000/nrow(Vietnam_unique_target))),]

  WW1_sample <- fread(file = 'WW1_sample.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
  WW2_sample <- fread(file = 'WW2_sample.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
  Korea_sample <- fread(file = 'Korea_sample.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
  Vietnam_sample <- fread(file = 'Vietnam_sample.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)

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

    # I had to keep these checkboxInputs separate (i.e. not a groupCheckboxInput)
    # so that only redraws of the just-changed aspects occur (i.e. to avoid buggy redrawing)
    checkboxInput(inputId = "show_WW1",
                  label = "Show WW1 Bombings",
                  value = FALSE),

    checkboxInput(inputId = "show_WW2",
                  label = "Show WW2 Bombings",
                  value = FALSE),

    checkboxInput(inputId = "show_Korea",
                  label = "Show Korea Bombings",
                  value = FALSE),

    checkboxInput(inputId = "show_Vietnam",
                  label = "Show Vietnam Bombings",
                  value = FALSE),

    civ_plot <- ggplot(world_map_df, aes(long, lat, group = group)) + geom_polygon() + coord_equal() + theme_opts
    WW1_plot <- geom_density2d(data = WW1_selection(), aes(x = Target.Longitude, y = Target.Latitude, group = 0), color = 'blue')
    WW2_plot <- geom_density2d(data = WW2_selection(), aes(x = Target.Longitude, y = Target.Latitude, group = 0), color = 'red')
    Korea_plot <- geom_density2d(data = Korea_selection(), aes(x = Target.Longitude, y = Target.Latitude, group = 0), color = 'yellow')
    Vietnam_plot <- geom_density2d(data = Vietnam_selection(), aes(x = Target.Longitude, y = Target.Latitude, group = 0), color = 'green')
    if(WW1_selected) civ_plot <- civ_plot + WW1_plot
    if(WW2_selected) civ_plot <- civ_plot + WW2_plot
    if(Korea_selected) civ_plot <- civ_plot + Korea_plot
    if(Vietnam_selected) civ_plot <- civ_plot + Vietnam_plot
    civ_plot

### custom.css ###
.sidebar .widget {
  margin-bottom: 10px;
  padding: 10px;
}
.content {
  padding-top: 0px;
  padding-bottom: 0px;
}
.selectize-dropdown, .selectize-input { 
  line-height: 14px; 
}

#Stamen.Watercolor attribution
      #options = providerTileOptions(attribution = 'Map tiles by <a href="http://stamen.com">Stamen Design</a>,
      #<a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy;
      #<a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'))

#CartoDB.PositronNoLabels attribution
      #options = providerTileOptions(attribution = '&copy;
      #<a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy;
      #<a href="http://cartodb.com/attributions">CartoDB</a>'))

#Stamen.TerrainBackground attribution
      #options = providerTileOptions(attribution = 'Map tiles by <a href="http://stamen.com">Stamen Design</a>,
      #<a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy;
      #<a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'))

#HERE.basicMap attribution
      #attribution = 'Map &copy; 2016
      #<a href="http://developer.here.com">HERE</a>'))

#Esri.WorldImagery attribution
      #options = providerTileOptions(attribution = 'Tiles &copy; Esri &mdash;
      #Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'))

add_commas2 <- function(number) {# for loops, clever, but runs on Vietnam bomb string in 1:03
  number_string <- as.character(number)
  num_digits <- ceiling(log10(number))
  if(num_digits <= 3) {
    return(number_string)
  } else {
    cutoff <- num_digits %% 3
    if(cutoff == 0) {
      end_split <- strsplit(number_string, "")[[1]]
      return(paste0(end_split[c(T,F,F)], end_split[c(F,T,F)], end_split[c(F,F,T)], collapse = ','))
    } else {
      first_bit <- substr(number_string, 1, cutoff)
      end_split <- strsplit(substr(number_string, cutoff+1, num_digits), "")[[1]]
      return(paste0(c(first_bit, paste0(end_split[c(T,F,F)], end_split[c(F,T,F)], end_split[c(F,F,T)])), collapse = ','))
    }
  }
}

add_commas3 <- function(number) {# no for loops, but runs on Vietnam bomb string in 2:30
  num_groups <- log(number, base = 1000)
  if(num_groups < 1) {
    return(as.character(number))
  } else {
    num_rounds <- floor(num_groups)
    factors <- 1000**seq(num_rounds,0,-1)
    remainder <- number %% factors
    left <- number - remainder
    almost <- left - shift(left, fill = 0)
    digits <- almost %/% factors
    first_digits <- digits[1]
    other_digits <- digits[2:(num_rounds+1)]
    return(paste0(c(as.character(first_digits), ifelse(other_digits < 10, paste0("00", as.character(other_digits)), ifelse(other_digits < 100, paste0("0", as.character(other_digits)), as.character(other_digits)))), collapse = ','))
  }
}

add_commas_vectorized2 <- function(numbers) {
  nums_groups <- ifelse(numbers <= 1000, 0, floor(log(numbers, base = 1000)))
  results <- ifelse(nums_groups <= 0, as.character(numbers), "something")

    factorses <- 1000**seq(nums_groups, 0, -1)
    remainders <- numbers %% factorses
    lefts <- numbers - remainders
    almosts <- lefts - shift(lefts, fill = 0)
    digitses <- almosts %/% factorses
    first_digitses <- digits[1]
    other_digitses <- digits[2:(nums_groups+1)]
    return(paste0(c(as.character(first_digits), ifelse(other_digits < 10, paste0("00", as.character(other_digits)), ifelse(other_digits < 100, paste0("0", as.character(other_digits)), as.character(other_digits)))), collapse = ','))
}

WW2_bombs[Weapon_Expl_Type == "" & 
            !is.na(Weapon_Expl_Tons) & Weapon_Expl_Tons != 0, 
          `:=`(Weapon_Expl_Type = empty_string_text)]
WW2_bombs[Weapon_Incd_Type == "" & 
            !is.na(Weapon_Incd_Tons) & Weapon_Incd_Tons != 0, 
          `:=`(Weapon_Incd_Type = empty_string_text)]
WW2_bombs[Weapon_Frag_Type == "" & 
            !is.na(Weapon_Frag_Tons) & Weapon_Frag_Tons != 0, 
          `:=`(Weapon_Frag_Type = empty_string_text)]

WW1_bombs[Aircraft_Type == "AIRCO DH4 DAY BOMBER", 
          `:=`(Aircraft_Type = "Airco DH-4 Day Bomber")]
WW1_bombs[Aircraft_Type == "AIRCO DH9 DAY BOMBER", 
          `:=`(Aircraft_Type = "Airco DH-9 Day Bomber")]
WW1_bombs[Aircraft_Type == "AIRCO DH9A DAY BOMBER", 
          `:=`(Aircraft_Type = "Airco DH-9A Day Bomber")]
WW1_bombs[Aircraft_Type == "BREGUET 14 B2", 
          `:=`(Aircraft_Type = "Breguet 14 B-2")]
WW1_bombs[Aircraft_Type == "CAPRONI CA.32/ FARMANN", 
          `:=`(Aircraft_Type = "Caproni Ca.32")]
WW1_bombs[Aircraft_Type == "FE2B", 
          `:=`(Aircraft_Type = "FE-2B")]
WW1_bombs[Aircraft_Type == "HADLEY PAGE O/100", 
          `:=`(Aircraft_Type = "Hadley Page O-100")]
WW1_bombs[Aircraft_Type == "HADLEY PAGE O/400", 
          `:=`(Aircraft_Type = "Hadley Page O-400")]
WW1_bombs[Aircraft_Type == "LIBERTY DH 4", 
          `:=`(Aircraft_Type = "Liberty DH-4")]

WW2_bombs[Aircraft_Type == "A20", 
          `:=`(Aircraft_Type = "A-20")]
WW2_bombs[Aircraft_Type == "A24", 
          `:=`(Aircraft_Type = "A-24")]
WW2_bombs[Aircraft_Type == "A26", 
          `:=`(Aircraft_Type = "A-26")]
WW2_bombs[Aircraft_Type == "A36", 
          `:=`(Aircraft_Type = "A-36")]
WW2_bombs[Aircraft_Type == "B17", 
          `:=`(Aircraft_Type = "B-17")]
WW2_bombs[Aircraft_Type == "B24", 
          `:=`(Aircraft_Type = "B-24")]
WW2_bombs[Aircraft_Type == "B25", 
          `:=`(Aircraft_Type = "B-25")]
WW2_bombs[Aircraft_Type == "B26", 
          `:=`(Aircraft_Type = "B-26")]
WW2_bombs[Aircraft_Type == "B29", 
          `:=`(Aircraft_Type = "B-29")]
WW2_bombs[Aircraft_Type == "B32", 
          `:=`(Aircraft_Type = "B-32")]
WW2_bombs[Aircraft_Type == "F06", 
          `:=`(Aircraft_Type = "F-06")]
WW2_bombs[Aircraft_Type == "F4U", 
          `:=`(Aircraft_Type = "F-4U")]
WW2_bombs[Aircraft_Type == "JU.86" | 
            Aircraft_Type == "JU.86/HARTBEE/JU86", 
          `:=`(Aircraft_Type = "JU-86")]
WW2_bombs[Aircraft_Type == "LB30", 
          `:=`(Aircraft_Type = "LB-30")]
WW2_bombs[Aircraft_Type == "P38", 
          `:=`(Aircraft_Type = "P-38")]
WW2_bombs[Aircraft_Type == "P39", 
          `:=`(Aircraft_Type = "P-39")]
WW2_bombs[Aircraft_Type == "P40", 
          `:=`(Aircraft_Type = "P-40")]
WW2_bombs[Aircraft_Type == "P400", 
          `:=`(Aircraft_Type = "P-400")]
WW2_bombs[Aircraft_Type == "P401", 
          `:=`(Aircraft_Type = "P-401")]
WW2_bombs[Aircraft_Type == "P47", 
          `:=`(Aircraft_Type = "P-47")]
WW2_bombs[Aircraft_Type == "P51", 
          `:=`(Aircraft_Type = "P-51")]
WW2_bombs[Aircraft_Type == "P61", 
          `:=`(Aircraft_Type = "P-61")]
WW2_bombs[Aircraft_Type == "P70", 
          `:=`(Aircraft_Type = "P-70")]

Korea_bombs1[Aircraft_Type == "B25", 
             `:=`(Aircraft_Type = "B-25")]
Korea_bombs1[Aircraft_Type == "B26", 
             `:=`(Aircraft_Type = "B-26")]
Korea_bombs1[Aircraft_Type == "B29", 
             `:=`(Aircraft_Type = "B-29")]
Korea_bombs1[Aircraft_Type == "C119", 
             `:=`(Aircraft_Type = "C-119")]
Korea_bombs1[Aircraft_Type == "C45", 
             `:=`(Aircraft_Type = "C-45")]
Korea_bombs1[Aircraft_Type == "C46", 
             `:=`(Aircraft_Type = "C-46")]
Korea_bombs1[Aircraft_Type == "C47", 
             `:=`(Aircraft_Type = "C-47")]
Korea_bombs1[Aircraft_Type == "F51", 
             `:=`(Aircraft_Type = "F-51")]
Korea_bombs1[Aircraft_Type == "F80", 
             `:=`(Aircraft_Type = "F-80")]
Korea_bombs1[Aircraft_Type == "F82", 
             `:=`(Aircraft_Type = "F-82")]
Korea_bombs1[Aircraft_Type == "F84", 
             `:=`(Aircraft_Type = "F-84")]
Korea_bombs1[Aircraft_Type == "F86", 
             `:=`(Aircraft_Type = "F-86")]
Korea_bombs1[Aircraft_Type == "G26", 
             `:=`(Aircraft_Type = "G-26")]
Korea_bombs1[Aircraft_Type == "G29", 
             `:=`(Aircraft_Type = "G-29")]
Korea_bombs1[Aircraft_Type == "H05", 
             `:=`(Aircraft_Type = "H-05")]
Korea_bombs1[Aircraft_Type == "RB17", 
             `:=`(Aircraft_Type = "RB-17")]
Korea_bombs1[Aircraft_Type == "RB25", 
             `:=`(Aircraft_Type = "RB-25")]
Korea_bombs1[Aircraft_Type == "RB26", 
             `:=`(Aircraft_Type = "RB-26")]
Korea_bombs1[Aircraft_Type == "RB44", 
             `:=`(Aircraft_Type = "RB-44")]
Korea_bombs1[Aircraft_Type == "RB45", 
             `:=`(Aircraft_Type = "RB-45")]
Korea_bombs1[Aircraft_Type == "RC45", 
             `:=`(Aircraft_Type = "RC-45")]
Korea_bombs1[Aircraft_Type == "RF51", 
             `:=`(Aircraft_Type = "RF-51")]
Korea_bombs1[Aircraft_Type == "RF80", 
             `:=`(Aircraft_Type = "RF-80")]
Korea_bombs1[Aircraft_Type == "RL29", 
             `:=`(Aircraft_Type = "RL-29")]
Korea_bombs1[Aircraft_Type == "SA16", 
             `:=`(Aircraft_Type = "SA-16")]
Korea_bombs1[Aircraft_Type == "SB17", 
             `:=`(Aircraft_Type = "SB-17")]
Korea_bombs1[Aircraft_Type == "SB29", 
             `:=`(Aircraft_Type = "SB-29")]
Korea_bombs1[Aircraft_Type == "T07", 
             `:=`(Aircraft_Type = "T-07")]
Korea_bombs1[Aircraft_Type == "T33", 
             `:=`(Aircraft_Type = "T-33")]
Korea_bombs1[Aircraft_Type == "VB17", 
             `:=`(Aircraft_Type = "VB-17")]
Korea_bombs1[Aircraft_Type == "VC47", 
             `:=`(Aircraft_Type = "VC-47")]
Korea_bombs1[Aircraft_Type == "WB29", 
             `:=`(Aircraft_Type = "WB-29")]
Korea_bombs1[Aircraft_Type == "WS29", 
             `:=`(Aircraft_Type = "WS-29")]

Vietnam_bombs[Aircraft_Type == "A8", 
              `:=`(Aircraft_Type = "A-8")]
Vietnam_bombs[Aircraft_Type == "DA3", 
              `:=`(Aircraft_Type = "DA-3")]
Vietnam_bombs[Aircraft_Type == "P41", 
              `:=`(Aircraft_Type = "P-41")]
Vietnam_bombs[Aircraft_Type == "R44", 
              `:=`(Aircraft_Type = "R-44")]
Vietnam_bombs[Aircraft_Type == "R64", 
              `:=`(Aircraft_Type = "R-64")]
Vietnam_bombs[Aircraft_Type == "T9", 
              `:=`(Aircraft_Type = "T-9")]
Vietnam_bombs[Aircraft_Type == "TF9", 
              `:=`(Aircraft_Type = "TF-9")]

if(debug_mode_on) print("reading WW1")
WW1_bombs <- fread(file =  WW1_missions_filepath, 
                   sep = ',', 
                   sep2 = '\n', 
                   header = TRUE, 
                   stringsAsFactors = FALSE, 
                   blank.lines.skip = TRUE, 
                   colClasses = WW1_col_classes, 
                   col.names = WW1_col_names)

if(debug_mode_on) print("reading WW2")
WW2_bombs <- fread(file =  WW2_missions_filepath, 
                   sep = ',', 
                   sep2 = '\n', 
                   header = TRUE, 
                   stringsAsFactors = FALSE, 
                   blank.lines.skip = TRUE, 
                   colClasses = WW2_col_classes, 
                   col.names = WW2_col_names)

if(debug_mode_on) print("reading Korea1")
Korea_bombs1 <- fread(file =  Korea_missions1_filepath, 
                      sep = ',',
                      sep2 = '\n', 
                      header = TRUE, 
                      stringsAsFactors = FALSE, 
                      blank.lines.skip = TRUE, 
                      colClasses = Korea_col_classes1, 
                      col.names = Korea_col_names1)

if(debug_mode_on) print("reading Korea2")
Korea_bombs2 <- fread(file =  Korea_missions2_filepath, 
                      sep = ',',
                      sep2 = '\n', 
                      header = TRUE, 
                      stringsAsFactors = FALSE, 
                      blank.lines.skip = TRUE, 
                      colClasses = Korea_col_classes2, 
                      col.names = Korea_col_names2)

if(debug_mode_on) print("reading Vietnam")
Vietnam_bombs <- fread(file =  Vietnam_missions_filepath, 
                       sep = ',', 
                       sep2 = '\n', 
                       header = TRUE, 
                       stringsAsFactors = FALSE, 
                       blank.lines.skip = TRUE, 
                       colClasses = Vietnam_col_classes, 
                       col.names = Vietnam_col_names)

WW1_bombs[Operation == "WW I", 
          `:=`(Operation = "")]

WW1_bombs[, Aircraft_Type := gsub(pattern = "([A-Za-z]+)[ ./]?(\\d+[A-Za-z]*)(.*)", replacement = "\\1-\\2", Aircraft_Type)]
WW1_bombs[, Unit_Squadron := gsub(pattern = "GRP", replacement = "GROUP", fixed = TRUE, Unit_Squadron)]
WW1_bombs[, Unit_Squadron := gsub(pattern = "SQDN", replacement = "SQUADRON", fixed = TRUE, Unit_Squadron)]
WW1_bombs[, Target_City := gsub(pattern = "; ", replacement = " OF ", fixed = TRUE, Target_City)]
WW1_bombs[, Weapon_Type := gsub(pattern = " KILO", replacement = " KG", fixed = TRUE, Weapon_Type)]

WW1_bombs[, Operation := proper_noun_phrase_vectorized(Operation)]
WW1_bombs[, Unit_Country := proper_noun_from_caps_vectorized(Unit_Country)]
WW1_bombs[, Unit_Service := proper_noun_from_caps_vectorized(Unit_Service)]
WW1_bombs[, Unit_Squadron := proper_noun_phrase_vectorized(Unit_Squadron)]
WW1_bombs[, Aircraft_Type := proper_noun_phrase_aircraft_vectorized(Aircraft_Type)]
WW1_bombs[, Mission_Num := ifelse(Mission_Num == "", NA, as.integer(Mission_Num))] # gets forced to character somehow
WW1_bombs[, Takeoff_Day_Period := tolower(Takeoff_Day_Period)]
WW1_bombs[, Takeoff_Time := format(strptime(Takeoff_Time, format = "%Y-%m-%d %H:%M:%S"), format = "%H:%M")]
WW1_bombs[, Weapon_Expended_Num := ifelse(Weapon_Expended_Num == "", NA, as.integer(Weapon_Expended_Num))] # gets forced to character somehow
WW1_bombs[, Weapon_Type := tolower(Weapon_Type)]
WW1_bombs[, Aircraft_Bombload_Pounds := as.integer(round(Aircraft_Bombload_Pounds))] # round away needless precision
WW1_bombs[, Weapon_Weight_Pounds := as.integer(round(Weapon_Weight_Pounds))] # round away needless precision
WW1_bombs[, Target_City := proper_noun_phrase_vectorized(remove_nonASCII_chars(Target_City))]
WW1_bombs[, Target_Country := capitalize_from_caps(Target_Country)]
WW1_bombs[, Target_Type := tolower(Target_Type)]
WW1_bombs[, Takeoff_Base := proper_noun_phrase_vectorized(remove_nonASCII_chars(Takeoff_Base))]
WW1_bombs[, Route_Details := proper_noun_phrase_vectorized(Route_Details)]
WW1_bombs[, Target_Weather := tolower(Target_Weather)]

# new columns
WW2_bombs[, Weapon_Expl_Unit_Weight := as.integer(gsub(pattern = " [ -~]*", replacement = '', Weapon_Expl_Type))]
WW2_bombs[, Weapon_Incd_Unit_Weight := as.integer(gsub(pattern = " [ -~]*", replacement = '', Weapon_Incd_Type))]
WW2_bombs[, Weapon_Frag_Unit_Weight := as.integer(gsub(pattern = " [ -~]*", replacement = '', Weapon_Frag_Type))]

# column error fixes
WW2_bombs[regexpr(pattern = ':', Unit_Squadron) > 0, 
          `:=`(Bomb_Time = Unit_Squadron, 
               Unit_Squadron = "")]

WW2_bombs[(!near(Bomb_Altitude * 100, Bomb_Altitude_Feet) | (is.na(Bomb_Altitude) & !is.na(Bomb_Altitude_Feet))) & 
            is.na(Weapon_Expl_Num) & 
            !is.na(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Num = Bomb_Altitude_Feet, 
               Bomb_Altitude_Feet = NA)]

# specific fixes, numerics
WW2_bombs[!near(Bomb_Altitude * 100, Bomb_Altitude_Feet) & 
            Weapon_Expl_Num == 0, 
          `:=`(Bomb_Altitude = Bomb_Altitude_Feet / 100)]
WW2_bombs[!near(Bomb_Altitude * 100, Bomb_Altitude_Feet) & 
            !is.na(Weapon_Expl_Num) & 
            Weapon_Expl_Num != 0, 
          `:=`(Bomb_Altitude_Feet = Bomb_Altitude * 100)]
WW2_bombs[Bomb_Altitude > 0 & 
            Bomb_Altitude < 1, 
          `:=`(Bomb_Altitude = Bomb_Altitude * 100, 
               Bomb_Altitude_Feet = Bomb_Altitude_Feet * 100)]
WW2_bombs[Bomb_Altitude == 1, 
          `:=`(Bomb_Altitude = 10, 
               Bomb_Altitude_Feet = 1000)]
WW2_bombs[Bomb_Altitude >= 1000, 
          `:=`(Bomb_Altitude = Bomb_Altitude / 100, 
               Bomb_Altitude_Feet = Bomb_Altitude)]
WW2_bombs[Bomb_Altitude >= 350, 
          `:=`(Bomb_Altitude = Bomb_Altitude / 10, 
               Bomb_Altitude_Feet = Bomb_Altitude * 10)]
WW2_bombs[!is.na(Bomb_Altitude) & 
            is.na(Bomb_Altitude_Feet), 
          `:=`(Bomb_Altitude_Feet = Bomb_Altitude * 100)]
WW2_bombs[is.na(Bomb_Altitude) & 
            !is.na(Bomb_Altitude_Feet), 
          `:=`(Bomb_Altitude = Bomb_Altitude_Feet / 100)]

WW2_bombs[regexpr(pattern = ' KG', Weapon_Expl_Unit_Weight) > 0, 
          `:=`(Weapon_Expl_Unit_Weight = Weapon_Expl_Unit_Weight * 2.2)]
WW2_bombs[regexpr(pattern = ' KG', Weapon_Incd_Unit_Weight) > 0, 
          `:=`(Weapon_Incd_Unit_Weight = Weapon_Incd_Unit_Weight * 2.2)]
WW2_bombs[regexpr(pattern = ' KG', Weapon_Frag_Unit_Weight) > 0, 
          `:=`(Weapon_Frag_Unit_Weight = Weapon_Frag_Unit_Weight * 2.2)]

# general fixes, numerics
WW2_bombs[, Weapon_Expl_Num := as.integer(round(Weapon_Expl_Num))]
WW2_bombs[, Weapon_Incd_Num := as.integer(round(Weapon_Incd_Num))]
WW2_bombs[, Weapon_Frag_Num := as.integer(round(Weapon_Frag_Num))]
WW2_bombs[, Weapon_Weight_Pounds := as.integer(round(Weapon_Weight_Pounds))]
WW2_bombs[, Weapon_Expl_Pounds := as.integer(round(Weapon_Expl_Pounds))]
WW2_bombs[, Weapon_Incd_Pounds := as.integer(round(Weapon_Incd_Pounds))]
WW2_bombs[, Weapon_Frag_Pounds := as.integer(round(Weapon_Frag_Pounds))]
WW2_bombs[, Target_Priority_Code := ifelse(Target_Priority_Code == "", NA, as.integer(Target_Priority_Code))] # gets forced to character somehow
WW2_bombs[, Aircraft_Airborne_Num := as.integer(Aircraft_Airborne_Num)] # gets forced to double somehow
WW2_bombs[, Sighting_Method_Code := ifelse(Sighting_Method_Code == "", NA, as.integer(Sighting_Method_Code))] # fixing data type due to bad data

# general fixes, times
WW2_bombs[, Bomb_Time := format(strptime(Bomb_Time, format = "%H%M"), format = "%H:%M")]

# specific fixes, strings
WW2_bombs[Target_Country == "UNKNOWN" | 
            Target_Country == "UNKNOWN OR NOT INDICATED", 
          `:=`(Target_Country = "")]

WW2_bombs[!is.na(as.integer(gsub(pattern = "[ NSEW]+", replacement = '', Target_City))) | 
            Target_City == "UNKNOWN" | 
            Target_City == "UNIDENTIFIED", 
          `:=`(Target_City = "")]

WW2_bombs[Target_Type == "UNIDENTIFIED" | 
            Target_Type == "UNIDENTIFIED TARGET", 
          `:=`(Target_Type = "")]

WW2_bombs[Target_Industry == "UNIDENTIFIED TARGETS", 
          `:=`(Target_Industry = "")]

WW2_bombs[Unit_Squadron == "0.458333333", 
          `:=`(Unit_Squadron = "")]

WW2_bombs[Aircraft_Type == "VENGEANCE (A31)" | 
            Aircraft_Type == "VENGEANCE(A-31)", 
          `:=`(Aircraft_Type = "A-31 Vengeance")]

WW2_bombs[Weapon_Expl_Type == "0", 
          `:=`(Weapon_Expl_Type = "")]
WW2_bombs[Weapon_Expl_Type == "TORPEDOES" | 
            Weapon_Expl_Type == "TORPEDOES MISC", 
          `:=`(Weapon_Expl_Type = "TORPEDO")]
WW2_bombs[Weapon_Expl_Type == "UNK CODE 20 110 LB EXPLOSIVE", 
          `:=`(Weapon_Expl_Type = "40 LB EXPLOSIVE")]
WW2_bombs[Weapon_Expl_Type == "250 BAP", 
          `:=`(Weapon_Expl_Type = "250 LB BAP")]

WW2_bombs[Weapon_Incd_Type == "X", 
          `:=`(Weapon_Incd_Type = "")]
WW2_bombs[Weapon_Incd_Type == "110 LB  INCENDIARY", 
          `:=`(Weapon_Incd_Type = "110 LB INCENDIARY")]
WW2_bombs[Weapon_Incd_Type == "10 LB INCENDIARY", 
          `:=`(Weapon_Incd_Tons = Weapon_Incd_Tons * 2.5, 
               Weapon_Incd_Pounds = Weapon_Incd_Pounds * 2.5)]
WW2_bombs[Weapon_Incd_Type == "100 LB WP (WHITE PHOSPHROUS)" & 
            is.na(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Tons = 1)]

WW2_bombs[Weapon_Frag_Type == "0" | 
            Weapon_Frag_Type == "UNK CODE 15", 
          `:=`(Weapon_Frag_Type = "")]
WW2_bombs[Weapon_Frag_Type == "23 LB FRAG CLUSTERS (6 X23 PER CLUSTER)", 
          `:=`(Weapon_Frag_Type = "138 LB FRAG (6X23 CLUSTERS)")]
WW2_bombs[Weapon_Frag_Type == "23 LB PARAFRAG", 
          `:=`(Weapon_Frag_Type = "23 LB PARA FRAG")]

WW2_bombs[Sighting_Method_Code == "PFF", 
          `:=`(Sighting_Method_Code = "", 
               Sighting_Method_Explanation = "PFF")]
WW2_bombs[Sighting_Method_Code == "VISUAL", 
          `:=`(Sighting_Method_Code = "1", 
               Sighting_Method_Explanation = "VISUAL")]
WW2_bombs[Sighting_Method_Code == "" & 
            Sighting_Method_Explanation == "VISUAL", 
          `:=`(Sighting_Method_Code = "1")]
WW2_bombs[Sighting_Method_Code == "0" | 
            Sighting_Method_Code == "7" | 
            Sighting_Method_Code == "9", 
          `:=`(Sighting_Method_Explanation = "", 
               Sighting_Method_Code = "")]

WW2_bombs[, Aircraft_Type := gsub(pattern = "([A-Za-z]+)[ ./]?(\\d+[A-Za-z]*)( ?/.*)?", replacement = "\\1-\\2", Aircraft_Type)]
WW2_bombs[, Unit_Squadron := gsub(pattern = "SQDN", replacement = 'SQUADRON', fixed = TRUE, Unit_Squadron)]
WW2_bombs[, Unit_Squadron := gsub(pattern = " (SQ?)\b", replacement = " SQUADRON", fixed = TRUE, Unit_Squadron)]
WW2_bombs[, Unit_Squadron := gsub(pattern = "IATF", replacement = "INDIA AIR TASK FORCE", fixed = TRUE, Unit_Squadron)]
WW2_bombs[, Unit_Squadron := gsub(pattern = "CATF", replacement = "CHINA AIR TASK FORCE", fixed = TRUE, Unit_Squadron)]
WW2_bombs[, Unit_Squadron := gsub(pattern = "SFTS", replacement = "SERVICE FLYING TRAINING SCHOOL", fixed = TRUE, Unit_Squadron)]
WW2_bombs[, Unit_Squadron := gsub(pattern = "FG", replacement = "FLIGHT GROUP", fixed = TRUE, Unit_Squadron)]
WW2_bombs[, Unit_Squadron := gsub(pattern = "FS", replacement = "FLIGHT SQUADRON", fixed = TRUE, Unit_Squadron)]
WW2_bombs[, Unit_Squadron := gsub(pattern = "BG", replacement = "BOMBARDMENT GROUP", fixed = TRUE, Unit_Squadron)]
WW2_bombs[, Unit_Squadron := gsub(pattern = "BS", replacement = "BOMBARDMENT SQUADRON", fixed = TRUE, Unit_Squadron)]
WW2_bombs[, Weapon_Expl_Type := gsub(pattern = "0 GP", replacement = "0 LB GP", fixed = TRUE, Weapon_Expl_Type)]

# general fixes, strings
WW2_bombs[, Unit_Country := proper_noun_phrase_vectorized(Unit_Country)]
WW2_bombs[, Target_Country := proper_noun_phrase_vectorized(remove_quotes(Target_Country))]
WW2_bombs[, Target_City := proper_noun_phrase_vectorized(remove_nonASCII_chars(remove_quotes(Target_City)))]
WW2_bombs[, Target_Type := tolower(Target_Type)]
WW2_bombs[, Target_Industry := tolower(remove_quotes(Target_Industry))]
WW2_bombs[, Unit_Squadron := proper_noun_phrase_vectorized(remove_quotes(Unit_Squadron))]
WW2_bombs[, Aircraft_Type := proper_noun_phrase_aircraft_vectorized(Aircraft_Type)]
WW2_bombs[, Target_Priority_Explanation := tolower(Target_Priority_Explanation)]
WW2_bombs[, Takeoff_Base := proper_noun_phrase_vectorized(Takeoff_Base)]
WW2_bombs[, Takeoff_Country := proper_noun_phrase_vectorized(Takeoff_Country)]
WW2_bombs[, Sighting_Method_Explanation := tolower(Sighting_Method_Explanation)]
WW2_bombs[, Bomb_Damage_Assessment := remove_quotes(Bomb_Damage_Assessment)]
WW2_bombs[, Target_Comment := remove_quotes(Target_Comment)]
WW2_bombs[, Database_Edit_Comments := remove_quotes(Database_Edit_Comments)]

# specific fixes, strings
Korea_bombs1[Aircraft_Type == "O54", 
             `:=`(Aircraft_Type = "C-54")]
Korea_bombs1[Aircraft_Type == "LO5", 
             `:=`(Aircraft_Type = "L-05")]
Korea_bombs1[Aircraft_Type == "R829", 
             `:=`(Aircraft_Type = "RB-29")]
Korea_bombs1[Aircraft_Type == "TO6" | 
               Aircraft_Type == "TQ6", 
             `:=`(Aircraft_Type = "T-06")]

# new columns
Korea_bombs2 <- separate(data = Korea_bombs2, # maybe change this to a tstrsplit in data.table form
                         col = Bomb_Altitude_Feet_Range,
                         into = c("Bomb_Altitude_Feet_Low", "Bomb_Altitude_Feet_High"),
                         sep = '-',
                         extra = 'merge',
                         fill = 'right')

# general fixes, numerics
Korea_bombs2[, Row_Number := as.integer(Row_Number)] # gets forced to character somehow
Korea_bombs2[, Mission_Number := as.integer(Mission_Number)] # gets forced to character somehow
Korea_bombs2[, Aircraft_Lost_Num := ifelse(Aircraft_Lost_Num == "", NA, as.integer(Aircraft_Lost_Num))] # fixing data type due to bad data
Korea_bombs2[, Target_Latitude := as.numeric(substr(Target_Latitude, 1, nchar(Target_Latitude)-1))]
Korea_bombs2[, Target_Longitude := as.numeric(substr(Target_Longitude, 1, nchar(Target_Longitude)-1))]
Korea_bombs2[, Weapon_Expended_Num := as.integer(Weapon_Expended_Num)] # gets forced to character somehow
Korea_bombs2[, Bomb_Altitude_Feet_Low := as.integer(Bomb_Altitude_Feet_Low)]
Korea_bombs2[, Bomb_Altitude_Feet_High := as.integer(Bomb_Altitude_Feet_High)]

# specific fixes, strings
#KB-29 technically exists, and is modified B-29 available in 1948, so theoretically possible, but it's just a refueling aircraft--probably an OCR error for RB-29, but I'm not sure
Korea_bombs2[Aircraft_Type == "RB 45", 
             `:=`(Aircraft_Type = "RB-45")]
Korea_bombs2[Aircraft_Lost_Num != "1" & 
               Aircraft_Lost_Num != "2" & 
               Aircraft_Lost_Num != "3", 
             `:=`(Aircraft_Lost_Num = "")]
Korea_bombs2[Weapon_Type == "UNKNOWN", 
             `:=`(Weapon_Type = "")]

Korea_bombs2[, Weapon_Type := gsub(pattern = " GP", replacement = " LB GP", fixed = TRUE, Weapon_Type)]
Korea_bombs2[, Unit_Squadron := gsub(pattern = " SQ", replacement = " SQUADRON", fixed = TRUE, Unit_Squadron)]

# general fixes, strings
Korea_bombs2[, Aircraft_Type := proper_noun_phrase_aircraft_vectorized(Aircraft_Type)]
Korea_bombs2[, Target_Name := remove_quotes(Target_Name)]
Korea_bombs2[, Bomb_Sighting_Method := tolower(Bomb_Sighting_Method)]
Korea_bombs2[, Bomb_Damage_Assessment := remove_quotes(Bomb_Damage_Assessment)]
Korea_bombs2[, Nose_Fuze := remove_quotes(Nose_Fuze)]
Korea_bombs2[, Tail_Fuze := remove_quotes(Tail_Fuze)]

# specific fixes, numerics
Vietnam_bombs[Weapon_Jettisoned_Num == -1, 
              `:=`(Weapon_Jettisoned_Num = NA)]
Vietnam_bombs[Weapon_Returned_Num == -1, 
              `:=`(Weapon_Returned_Num = NA)]
Vietnam_bombs[Weapon_Weight_Loaded == -1, 
              `:=`(Weapon_Weight_Loaded = NA)]

# general fixes, numerics
Vietnam_bombs[, Mission_Function_Code := ifelse(Mission_Function_Code == "", 
                                                NA, 
                                                as.integer(Mission_Function_Code))] # fixing data type due to bad data

Vietnam_bombs[, Bomb_Altitude_Feet := ifelse(Bomb_Altitude == 0, 
                                             NA, 
                                             as.integer(Bomb_Altitude * 1000))] # assumed factor of 1000 here (in ft)--otherwise makes no sense

# general fixes, times
Vietnam_bombs[, Bomb_Time := format(strptime(Bomb_Time, 
                                             format = "%H%M"), 
                                    format = "%H:%M")]
Vietnam_bombs[, Target_Time_Off := format(strptime(Target_Time_Off, 
                                                   format = "%H%M"), 
                                          format = "%H:%M")]

# specific fixes, strings
Vietnam_bombs[Target_Type %in% Vietnam_NA_targets, 
              `:=`(Target_Type = "")]
Vietnam_bombs[Weapon_Type == "UNK" | 
                Weapon_Type == "UNKNOWN", 
              `:=`(Weapon_Type = "")]

Vietnam_bombs[Unit_Country == "Korea (south)", 
              `:=`(Unit_Country = "South Korea")]
Vietnam_bombs[Unit_Country == "United States of America", 
              `:=`(Unit_Country = "USA")]
Vietnam_bombs[Unit_Country == "Vietnam (south)", 
              `:=`(Unit_Country = "South Vietnam")]

Vietnam_bombs[Aircraft_Type == "NOT CODED", 
              `:=`(Aircraft_Type = "")]

Vietnam_bombs[Mission_Function_Code == "1B" | 
                Mission_Function_Code == "1S" | 
                Mission_Function_Code == "1T" | 
                Mission_Function_Code == "1U" | 
                Mission_Function_Code == "2I" | 
                Mission_Function_Code == "2N" | 
                Mission_Function_Code == "2O" | 
                Mission_Function_Code == "3C" | 
                Mission_Function_Code == "3F" | 
                Mission_Function_Code == "3K" | 
                Mission_Function_Code == "3S" | 
                Mission_Function_Code == "3T" | 
                Mission_Function_Code == "3U" | 
                Mission_Function_Code == "4N" | 
                Mission_Function_Code == "5J" | 
                Mission_Function_Code == "6L" | 
                Mission_Function_Code == "6S", 
              `:=`(Mission_Function_Code = "")]

Vietnam_bombs[, Aircraft_Type := gsub(pattern = "([A-Za-z]+)[ ./]?(\\d+[A-Za-z]*)( ?/.*)?", replacement = "\\1-\\2", Aircraft_Type)]
Vietnam_bombs[, Operation := gsub(pattern = "IN COUNTRY( - )?", replacement = "", Operation)]
Vietnam_bombs[, Operation := gsub(pattern = "ROLLING THUN((D)|( - ROLLING THUN))?", replacement = "ROLLING THUNDER", Operation)]

# general fixes, strings
Vietnam_bombs[, Unit_Country := proper_noun_phrase_vectorized(Unit_Country)] # this takes a while
Vietnam_bombs[, Aircraft_Type := proper_noun_phrase_aircraft_vectorized(Aircraft_Type)] # this takes a while
Vietnam_bombs[, Takeoff_Location := proper_noun_phrase_vectorized(Takeoff_Location)] # this takes a while
Vietnam_bombs[, Target_Type := tolower(gsub(pattern = '/ANY', 
                                            replacement = '', 
                                            fixed = TRUE, 
                                            gsub(pattern = '\\\\', 
                                                 replacement = '/', 
                                                 fixed = TRUE, 
                                                 Target_Type)))]
Vietnam_bombs[, Mission_Function_Description := tolower(Mission_Function_Description)]
Vietnam_bombs[, Operation := capitalize_phrase_vectorized(Operation)] # this takes a while
Vietnam_bombs[, Mission_Day_Period := ifelse(Mission_Day_Period == "D", 
                                             "day", 
                                      ifelse(Mission_Day_Period == "N", 
                                             "night", 
                                             ""))]
Vietnam_bombs[, Target_CloudCover := tolower(Target_CloudCover)]
Vietnam_bombs[, Target_Country := proper_noun_phrase_vectorized(Target_Country)] # this takes a while
Vietnam_bombs[, Weapon_Class := tolower(Weapon_Class)]

# general fixes, times
WW1_bombs[, Takeoff_Time := format(strptime(Takeoff_Time, format = "%Y-%m-%d %H:%M:%S"), format = "%H:%M")]

WW1_clean[Operation == "",
          `:=`(Operation = empty_string_text)]
WW1_clean[, Operation := ordered(Operation)]
WW1_operations <- levels(WW1_clean$Operation)
if(empty_string_text %in% WW1_operations) {
  WW1_operations <- c(WW1_operations[WW1_operations != empty_string_text], empty_string_text)
  WW1_clean[, Operation := ordered(Operation, levels = WW1_operations)]
}

WW1_clean[Unit_Country == "",
          `:=`(Unit_Country = empty_string_text)]
WW1_clean[, Unit_Country := ordered(Unit_Country)]
WW1_countries <- levels(WW1_clean$Unit_Country)
if(empty_string_text %in% WW1_countries) {
  WW1_countries <- c(WW1_countries[WW1_countries != empty_string_text], empty_string_text)
  WW1_clean[, Unit_Country := ordered(Unit_Country, levels = WW1_countries)]
}

WW1_clean[Unit_Service == "",
          `:=`(Unit_Service = empty_string_text)]
WW1_clean[, Unit_Service := ordered(Unit_Service)]
WW1_unit_services <- levels(WW1_clean$Unit_Service)
if(empty_string_text %in% WW1_unit_services) {
  WW1_unit_services <- c(WW1_unit_services[WW1_unit_services != empty_string_text], empty_string_text)
  WW1_clean[, Unit_Service := ordered(Unit_Service, levels = WW1_unit_services)]
}

WW1_clean[Unit_Squadron == "",
          `:=`(Unit_Squadron = empty_string_text)]
WW1_clean[, Unit_Squadron := ordered(Unit_Squadron)]
WW1_unit_squadrons <- levels(WW1_clean$Unit_Squadron)
if(empty_string_text %in% WW1_unit_squadrons) {
  WW1_unit_squadrons <- c(WW1_unit_squadrons[WW1_unit_squadrons != empty_string_text], empty_string_text)
  WW1_clean[, Unit_Squadron := ordered(Unit_Squadron, levels = WW1_unit_squadrons)]
}

WW1_clean[Aircraft_Type == "",
          `:=`(Aircraft_Type = empty_string_text)]
WW1_clean[, Aircraft_Type := ordered(Aircraft_Type)]
WW1_aircraft <- levels(WW1_clean$Aircraft_Type)
if(empty_string_text %in% WW1_aircraft) {
  WW1_aircraft <- c(WW1_aircraft[WW1_aircraft != empty_string_text], empty_string_text)
  WW1_clean[, Aircraft_Type := ordered(Aircraft_Type, levels = WW1_aircraft)]
}

WW1_clean[Takeoff_Day_Period == "",
          `:=`(Takeoff_Day_Period = empty_string_text)]
WW1_clean[, Takeoff_Day_Period := ordered(Takeoff_Day_Period)]
WW1_takeoff_day_periods <- levels(WW1_clean$Takeoff_Day_Period)
if(empty_string_text %in% WW1_takeoff_day_periods) {
  WW1_takeoff_day_periods <- c(WW1_takeoff_day_periods[WW1_takeoff_day_periods != empty_string_text], empty_string_text)
  WW1_clean[, Takeoff_Day_Period := ordered(Takeoff_Day_Period, levels = WW1_takeoff_day_periods)]
}

WW1_clean[Callsign == "",
          `:=`(Callsign = empty_string_text)]
WW1_clean[, Callsign := ordered(Callsign)]
WW1_callsigns <- levels(WW1_clean$Callsign)
if(empty_string_text %in% WW1_callsigns) {
  WW1_callsigns <- c(WW1_callsigns[WW1_callsigns != empty_string_text], empty_string_text)
  WW1_clean[, Callsign := ordered(Callsign, levels = WW1_callsigns)]
}

WW1_clean[Weapon_Type == "",
          `:=`(Weapon_Type = empty_string_text)]
WW1_clean[, Weapon_Type := ordered(Weapon_Type)]
WW1_weapons <- levels(WW1_clean$Weapon_Type)
if(empty_string_text %in% WW1_weapons) {
  WW1_weapons <- c(WW1_weapons[WW1_weapons != empty_string_text], empty_string_text)
  WW1_clean[, Weapon_Type := ordered(Weapon_Type, levels = WW1_weapons)]
}

WW1_clean[Target_Country == "",
          `:=`(Target_Country = empty_string_text)]
WW1_clean[, Target_Country := ordered(Target_Country)]
WW1_target_countries <- levels(WW1_clean$Target_Country)
if(empty_string_text %in% WW1_target_countries) {
  WW1_target_countries <- c(WW1_target_countries[WW1_target_countries != empty_string_text], empty_string_text)
  WW1_clean[, Target_Country := ordered(Target_Country, levels = WW1_target_countries)]
}

WW1_clean[Target_Type == "",
          `:=`(Target_Type = empty_string_text)]
WW1_clean[, Target_Type := ordered(Target_Type)]
WW1_target_types <- levels(WW1_clean$Target_Type)
if(empty_string_text %in% WW1_target_types) {
  WW1_target_types <- c(WW1_target_types[WW1_target_types != empty_string_text], empty_string_text)
  WW1_clean[, Target_Type := ordered(Target_Type, levels = WW1_target_types)]
}

WW1_clean[Takeoff_Base == "",
          `:=`(Takeoff_Base = empty_string_text)]
WW1_clean[, Takeoff_Base := factor(Takeoff_Base)]
WW1_takeoff_bases <- levels(WW1_clean$Takeoff_Base)
if(empty_string_text %in% WW1_takeoff_bases) {
  WW1_takeoff_bases <- c(WW1_takeoff_bases[WW1_takeoff_bases != empty_string_text], empty_string_text)
  WW1_clean[, Takeoff_Base := ordered(Takeoff_Base, levels = WW1_takeoff_bases)]
}

WW2_clean[Mission_Theater == "",
          `:=`(Mission_Theater = empty_string_text)]
WW2_clean[, Mission_Theater := ordered(Mission_Theater)]
WW2_mission_theaters <- levels(WW2_clean$Mission_Theater)
if(empty_string_text %in% WW2_mission_theaters) {
  WW2_mission_theaters <- c(WW2_mission_theaters[WW2_mission_theaters != empty_string_text], empty_string_text)
  WW2_clean[, Mission_Theater := ordered(Mission_Theater, levels = WW2_mission_theaters)]
}

WW2_clean[Unit_Service == "",
          `:=`(Unit_Service = empty_string_text)]
WW2_clean[, Unit_Service := ordered(Unit_Service)]
WW2_unit_services <- levels(WW2_clean$Unit_Service)
if(empty_string_text %in% WW2_unit_services) {
  WW2_unit_services <- c(WW2_unit_services[WW2_unit_services != empty_string_text], empty_string_text)
  WW2_clean[, Unit_Service := ordered(Unit_Service, levels = WW2_unit_services)]
}

WW2_clean[Unit_Country == "",
          `:=`(Unit_Country = empty_string_text)]
WW2_clean[, Unit_Country := ordered(Unit_Country)]
WW2_countries <- levels(WW2_clean$Unit_Country)
if(empty_string_text %in% WW2_countries) {
  WW2_countries <- c(WW2_countries[WW2_countries != empty_string_text], empty_string_text)
  WW2_clean[, Unit_Country := ordered(Unit_Country, levels = WW2_countries)]
}

WW2_clean[Target_Country == "",
          `:=`(Target_Country = empty_string_text)]
WW2_clean[, Target_Country := ordered(Target_Country)]
WW2_target_countries <- levels(WW2_clean$Target_Country)
if(empty_string_text %in% WW2_target_countries) {
  WW2_target_countries <- c(WW2_target_countries[WW2_target_countries != empty_string_text], empty_string_text)
  WW2_clean[, Target_Country := ordered(Target_Country, levels = WW2_target_countries)]
}

WW2_clean[Target_City == "",
          `:=`(Target_City = empty_string_text)]
WW2_clean[, Target_City := ordered(Target_City)]
WW2_target_cities <- levels(WW2_clean$Target_City)
if(empty_string_text %in% WW2_target_cities) {
  WW2_target_cities <- c(WW2_target_cities[WW2_target_cities != empty_string_text], empty_string_text)
  WW2_clean[, Target_City := ordered(Target_City, levels = WW2_target_cities)]
}

WW2_clean[Target_Type == "",
          `:=`(Target_Type = empty_string_text)]
WW2_clean[, Target_Type := ordered(Target_Type)]
WW2_target_types <- levels(WW2_clean$Target_Type)
if(empty_string_text %in% WW2_target_types) {
  WW2_target_types <- c(WW2_target_types[WW2_target_types != empty_string_text], empty_string_text)
  WW2_clean[, Target_Type := ordered(Target_Type, levels = WW2_target_types)]
}

WW2_clean[Target_Industry == "",
          `:=`(Target_Industry = empty_string_text)]
WW2_clean[, Target_Industry := ordered(Target_Industry)]
WW2_target_industries <- levels(WW2_clean$Target_Industry)
if(empty_string_text %in% WW2_target_industries) {
  WW2_target_industries <- c(WW2_target_industries[WW2_target_industries != empty_string_text], empty_string_text)
  WW2_clean[, Target_Industry := ordered(Target_Industry, levels = WW2_target_industries)]
}

WW2_clean[Unit_Squadron == "",
          `:=`(Unit_Squadron = empty_string_text)]
WW2_clean[, Unit_Squadron := ordered(Unit_Squadron)]
WW2_unit_squadrons <- levels(WW2_clean$Unit_Squadron)
if(empty_string_text %in% WW2_unit_squadrons) {
  WW2_unit_squadrons <- c(WW2_unit_squadrons[WW2_unit_squadrons != empty_string_text], empty_string_text)
  WW2_clean[, Unit_Squadron := ordered(Unit_Squadron, levels = WW2_unit_squadrons)]
}

WW2_clean[Aircraft_Type == "",
          `:=`(Aircraft_Type = empty_string_text)]
WW2_clean[, Aircraft_Type := ordered(Aircraft_Type)]
WW2_aircraft <- levels(WW2_clean$Aircraft_Type)
if(empty_string_text %in% WW2_aircraft) {
  WW2_aircraft <- c(WW2_aircraft[WW2_aircraft != empty_string_text], empty_string_text)
  WW2_clean[, Aircraft_Type := ordered(Aircraft_Type, levels = WW2_aircraft)]
}

WW2_clean[Target_Priority_Explanation == "",
          `:=`(Target_Priority_Explanation = empty_string_text)]
WW2_clean[, Target_Priority_Explanation := ordered(Target_Priority_Explanation)]
WW2_target_priority_explanations <- levels(WW2_clean$Target_Priority_Explanation)
if(empty_string_text %in% WW2_target_priority_explanations) {
  WW2_target_priority_explanations <- c(WW2_target_priority_explanations[WW2_target_priority_explanations != empty_string_text], empty_string_text)
  WW2_clean[, Target_Priority_Explanation := ordered(Target_Priority_Explanation, levels = WW2_target_priority_explanations)]
}

WW2_clean[Weapon_Expl_Type == "",
          `:=`(Weapon_Expl_Type = empty_string_text)]
WW2_clean[, Weapon_Expl_Type := ordered(Weapon_Expl_Type)]
WW2_weapons_explosive <- levels(WW2_clean$Weapon_Expl_Type)
if(empty_string_text %in% WW2_weapons_explosive) {
  WW2_weapons_explosive <- c(WW2_weapons_explosive[WW2_weapons_explosive != empty_string_text], empty_string_text)
  WW2_clean[, Weapon_Expl_Type := ordered(Weapon_Expl_Type, levels = WW2_weapons_explosive)]
}

WW2_clean[Weapon_Incd_Type == "",
          `:=`(Weapon_Incd_Type = empty_string_text)]
WW2_clean[, Weapon_Incd_Type := ordered(Weapon_Incd_Type)]
WW2_weapons_incendiary <- levels(WW2_clean$Weapon_Incd_Type)
if(empty_string_text %in% WW2_weapons_incendiary) {
  WW2_weapons_incendiary <- c(WW2_weapons_incendiary[WW2_weapons_incendiary != empty_string_text], empty_string_text)
  WW2_clean[, Weapon_Incd_Type := ordered(Weapon_Incd_Type, levels = WW2_weapons_incendiary)]
}

WW2_clean[Weapon_Frag_Type == "",
          `:=`(Weapon_Frag_Type = empty_string_text)]
WW2_clean[, Weapon_Frag_Type := ordered(Weapon_Frag_Type)]
WW2_weapons_fragmentary <- levels(WW2_clean$Weapon_Frag_Type)
if(empty_string_text %in% WW2_weapons_fragmentary) {
  WW2_weapons_fragmentary <- c(WW2_weapons_fragmentary[WW2_weapons_fragmentary != empty_string_text], empty_string_text)
  WW2_clean[, Weapon_Frag_Type := ordered(Weapon_Frag_Type, levels = WW2_weapons_fragmentary)]
}

WW2_clean[Weapon_Type == "",
          `:=`(Weapon_Type = empty_string_text)]
WW2_clean[, Weapon_Type := ordered(Weapon_Type)]
WW2_weapons <- levels(WW2_clean$Weapon_Type)
if(empty_string_text %in% WW2_weapons) {
  WW2_weapons <- c(WW2_weapons[WW2_weapons != empty_string_text], empty_string_text)
  WW2_clean[, Weapon_Type := ordered(Weapon_Type, levels = WW2_weapons)]
}

WW2_clean[Takeoff_Base == "",
          `:=`(Takeoff_Base = empty_string_text)]
WW2_clean[, Takeoff_Base := ordered(Takeoff_Base)]
WW2_takeoff_bases <- levels(WW2_clean$Takeoff_Base)
if(empty_string_text %in% WW2_takeoff_bases) {
  WW2_takeoff_bases <- c(WW2_takeoff_bases[WW2_takeoff_bases != empty_string_text], empty_string_text)
  WW2_clean[, Takeoff_Base := ordered(Takeoff_Base, levels = WW2_takeoff_bases)]
}

WW2_clean[Takeoff_Country == "",
          `:=`(Takeoff_Country = empty_string_text)]
WW2_clean[, Takeoff_Country := ordered(Takeoff_Country)]
WW2_takeoff_countries <- levels(WW2_clean$Takeoff_Country)
if(empty_string_text %in% WW2_takeoff_countries) {
  WW2_takeoff_countries <- c(WW2_takeoff_countries[WW2_takeoff_countries != empty_string_text], empty_string_text)
  WW2_clean[, Takeoff_Country := ordered(Takeoff_Country, levels = WW2_takeoff_countries)]
}

WW2_clean[Sighting_Method_Explanation == "",
          `:=`(Sighting_Method_Explanation = empty_string_text)]
WW2_clean[, Sighting_Method_Explanation := ordered(Sighting_Method_Explanation)]
WW2_sighting_method_explanations <- levels(WW2_clean$Sighting_Method_Explanation)
if(empty_string_text %in% WW2_sighting_method_explanations) {
  WW2_sighting_method_explanations <- c(WW2_sighting_method_explanations[WW2_sighting_method_explanations != empty_string_text], empty_string_text)
  WW2_clean[, Sighting_Method_Explanation := ordered(Sighting_Method_Explanation, levels = WW2_sighting_method_explanations)]
}

Korea_clean1[, Unit_Country := ordered(Unit_Country)]
Korea_countries1 <- levels(Korea_clean1$Unit_Country)
if(empty_string_text %in% Korea_countries1) {
  Korea_countries1 <- c(Korea_countries1[Korea_countries1 != empty_string_text], empty_string_text)
  Korea_clean1[, Unit_Country := ordered(Unit_Country, levels = Korea_countries1)]
}

Korea_clean1[Aircraft_Type == "",
             `:=`(Aircraft_Type = empty_string_text)]
Korea_clean1[, Aircraft_Type := ordered(Aircraft_Type)]
Korea_aircraft1 <- levels(Korea_clean1$Aircraft_Type)
if(empty_string_text %in% Korea_aircraft1) {
  Korea_aircraft1 <- c(Korea_aircraft1[Korea_aircraft1 != empty_string_text], empty_string_text)
  Korea_clean1[, Aircraft_Type := ordered(Aircraft_Type, levels = Korea_aircraft1)]
}

Korea_clean2[Unit_Squadron == "",
             `:=`(Unit_Squadron = empty_string_text)]
Korea_clean2[, Unit_Squadron := ordered(Unit_Squadron)]
Korea_unit_squadrons <- levels(Korea_clean2$Unit_Squadron)
if(empty_string_text %in% Korea_unit_squadrons) {
  Korea_unit_squadrons <- c(Korea_unit_squadrons[Korea_unit_squadrons != empty_string_text], empty_string_text)
  Korea_clean2[, Unit_Squadron := ordered(Unit_Squadron, levels = Korea_unit_squadrons)]
}

Korea_clean2[Aircraft_Type == "",
             `:=`(Aircraft_Type = empty_string_text)]
Korea_clean2[, Aircraft_Type := ordered(Aircraft_Type)]
Korea_aircraft <- levels(Korea_clean2$Aircraft_Type)
if(empty_string_text %in% Korea_aircraft) {
  Korea_aircraft <- c(Korea_aircraft[Korea_aircraft != empty_string_text], empty_string_text)
  Korea_clean2[, Aircraft_Type := ordered(Aircraft_Type, levels = Korea_aircraft)]
}

Korea_clean2[Target_Name == "",
             `:=`(Target_Name = empty_string_text)]
Korea_clean2[, Target_Name := ordered(Target_Name)]
Korea_target_names <- levels(Korea_clean2$Target_Name)
if(empty_string_text %in% Korea_target_names) {
  Korea_target_names <- c(Korea_target_names[Korea_target_names != empty_string_text], empty_string_text)
  Korea_clean2[, Target_Name := ordered(Target_Name)]
}

Korea_clean2[Target_Type == "",
             `:=`(Target_Type = empty_string_text)]
Korea_clean2[, Target_Type := ordered(Target_Type)]
Korea_target_types <- levels(Korea_clean2$Target_Type)
if(empty_string_text %in% Korea_target_types) {
  Korea_target_types <- c(Korea_target_types[Korea_target_types != empty_string_text], empty_string_text)
  Korea_clean2[, Target_Type := ordered(Target_Type, levels = Korea_target_types)]
}

Korea_clean2[Weapon_Type == "",
             `:=`(Weapon_Type = empty_string_text)]
Korea_clean2[, Weapon_Type := ordered(Weapon_Type)]
Korea_weapons <- levels(Korea_clean2$Weapon_Type)
if(empty_string_text %in% Korea_weapons) {
  Korea_weapons <- c(Korea_weapons[Korea_weapons != empty_string_text], empty_string_text)
  Korea_clean2[, Weapon_Type := ordered(Weapon_Type, levels = Korea_weapons)]
}

Korea_clean2[Bomb_Sighting_Method == "",
             `:=`(Bomb_Sighting_Method = empty_string_text)]
Korea_clean2[, Bomb_Sighting_Method := ordered(Bomb_Sighting_Method)]
Korea_bomb_sighting_methods <- levels(Korea_clean2$Bomb_Sighting_Method)
if(empty_string_text %in% Korea_bomb_sighting_methods) {
  Korea_bomb_sighting_methods <- c(Korea_bomb_sighting_methods[Korea_bomb_sighting_methods != empty_string_text], empty_string_text)
  Korea_clean2[, Bomb_Sighting_Method := ordered(Bomb_Sighting_Method)]
}

Korea_clean2[Nose_Fuze == "",
             `:=`(Nose_Fuze = empty_string_text)]
Korea_clean2[, Nose_Fuze := ordered(Nose_Fuze)]
Korea_nose_fuzes <- levels(Korea_clean2$Nose_Fuze)
if(empty_string_text %in% Korea_nose_fuzes) {
  Korea_nose_fuzes <- c(Korea_nose_fuzes[Korea_nose_fuzes != empty_string_text], empty_string_text)
  Korea_clean2[, Nose_Fuze := ordered(Nose_Fuze, levels = Korea_nose_fuzes)]
}

Korea_clean2[Tail_Fuze == "",
             `:=`(Tail_Fuze = empty_string_text)]
Korea_clean2[, Tail_Fuze := ordered(Tail_Fuze)]
Korea_tail_fuzes <- levels(Korea_clean2$Tail_Fuze)
if(empty_string_text %in% Korea_tail_fuzes) {
  Korea_tail_fuzes <- c(Korea_tail_fuzes[Korea_tail_fuzes != empty_string_text], empty_string_text)
  Korea_clean2[, Tail_Fuze := ordered(Tail_Fuze, levels = Korea_tail_fuzes)]
}

Korea_clean2[, Unit_Country := ordered(Unit_Country)]
Korea_countries <- levels(Korea_clean2$Unit_Country)

Vietnam_clean[Unit_Country == "",
              `:=`(Unit_Country = empty_string_text)]
Vietnam_clean[, Unit_Country := ordered(Unit_Country)]
Vietnam_countries <- levels(Vietnam_clean$Unit_Country)
if(empty_string_text %in% Vietnam_countries) {
  Vietnam_countries <- c(Vietnam_countries[Vietnam_countries != empty_string_text], empty_string_text)
  Vietnam_clean[, Unit_Country := ordered(Unit_Country, levels = Vietnam_countries)]
}

Vietnam_clean[Aircraft_Type == "",
              `:=`(Aircraft_Type = empty_string_text)]
Vietnam_clean[, Aircraft_Type := ordered(Aircraft_Type)]
Vietnam_aircraft <- levels(Vietnam_clean$Aircraft_Type)
if(empty_string_text %in% Vietnam_aircraft) {
  Vietnam_aircraft <- c(Vietnam_aircraft[Vietnam_aircraft != empty_string_text], empty_string_text)
  Vietnam_clean[, Aircraft_Type := ordered(Aircraft_Type, levels = Vietnam_aircraft)]
}

Vietnam_clean[Weapon_Type == "",
              `:=`(Weapon_Type = empty_string_text)]
Vietnam_clean[, Weapon_Type := ordered(Weapon_Type)]
Vietnam_weapons <- levels(Vietnam_clean$Weapon_Type)
if(empty_string_text %in% Vietnam_weapons) {
  Vietnam_weapons <- c(Vietnam_weapons[Vietnam_weapons != empty_string_text], empty_string_text)
  Vietnam_clean[, Weapon_Type := ordered(Weapon_Type, levels = Vietnam_weapons)]
}

WW1_aircraft_letters <- c("B", "CA", "DH", "FE", "O", "2B", "9A")
WW2_aircraft_letters <- c("A", "B", "F", "IV", "JU", "LB", "P", "PV", "TBF")
Korea_aircraft_letters <- c("B", "C", "F", "G", "H", "L", "RB", "RC", "RF", "SA", "SB", "T", "VB", "VC", "WB", "WS")
Vietnam_aircraft_letters <- c("A", "AC", "AH", "B", "C", "E", "EA", "EB", "EC", "EF", "EKA", "F", "FC", "HC", "JC", "KA", "O", "OV", "RA", "RB", "RC", "RF", "T", "TA", "TF", "UC", "UH", "WC")

unique_from_filtered_col <- function(war_data, column, start_date, end_date, countries, aircrafts, weapons) {
    if ("All" %c% countries) {
      if ("All" %c% aircrafts) {
        if ("All" %c% weapons) {
          war_data[Mission_Date >= start_date & Mission_Date <= end_date, as.character(unique(column))]
        } else {
          war_data[.(weapons), on = .(Weapon_Type)][Mission_Date >= start_date & Mission_Date <= end_date, as.character(unique(column))]
        }
      } else {
        if ("All" %c% weapons) {
          war_data[.(aircrafts), on = .(Aircraft_Type)][Mission_Date >= start_date & Mission_Date <= end_date, as.character(unique(column))]
        } else {
          war_data[.(aircrafts, weapons), on = .(Aircraft_Type, Weapon_Type)][Mission_Date >= start_date & Mission_Date <= end_date, as.character(unique(column))]
        }
      }
    } else {
      if ("All" %c% aircrafts) {
        if ("All" %c% weapons) {
          war_data[.(countries), on = .(Unit_Country)][Mission_Date >= start_date & Mission_Date <= end_date, as.character(unique(column))]
        } else {
          war_data[.(countries, weapons), on = .(Unit_Country, Weapon_Type)][Mission_Date >= start_date & Mission_Date <= end_date, as.character(unique(column))]
        }
      } else {
        if ("All" %c% weapons) {
          war_data[.(countries, aircrafts), on = .(Unit_Country, Aircraft_Type)][Mission_Date >= start_date & Mission_Date <= end_date, as.character(unique(column))]
        } else {
          war_data[.(countries, aircrafts, weapons), on = .(Unit_Country, Aircraft_Type, Weapon_Type)][Mission_Date >= start_date & Mission_Date <= end_date, as.character(unique(column))]
        }
      }
    }
  }

update_maps <- TRUE
    if (all_countries_selected) {# all countries were selected previously
      if ("All" %c% input$country) {# all is still selected
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
      if ("All" %c% input$country) {# all is now added
        all_countries_selected <<- TRUE
        if (length(input$country) > 1) {# and there was previously something else in there
          # then do remove other countries thing
          updateSelectizeInput(session, inputId = "country", selected = "All")
          update_maps <- FALSE
        }
      }
    }
    if (update_maps) {# only update when normal changes have been made
      redraw(overview_proxy, civilian_proxy)
      update_other_selectize_inputs("countries")
    }

gsub_f <- function(pattern, replacement, x, silently = FALSE) {
  if (!silently && grepl("[?*+]", pat)) {
    message("The pattern parameter you used makes it look like you inteded to use a non-fixed version of gsub")
  }
  return (gsub(pattern = pattern, replacement = replacement, fixed = TRUE, x = x))
}

gsub_rf <- function(pattern, x, silently = FALSE) {
  if (!silently && grepl("[?*+]", pattern)) {
    message("The pattern parameter you used makes it look like you inteded to use a non-fixed version of gsub")
  }
  return (gsub(pattern = pattern, replacement = "", fixed = TRUE, x = x))
}

grem <- function(pattern, x, replacement = NULL, ...) {
  if (replacement == "") {
    message('You supplied the assumed default replacement argument, which is redundant in this version of gsub (which assumes replacement = "")')
  } else if (!is.null(replacement)) {
    warning('You supplied a replacement argument, which has been ignored (this version of gsub assumes replacement = "")')
  }
  return (gsub(pattern = pattern, replacement = "", x = x, ...))
}

#KB-29 technically exists, and is modified B-29 available in 1948, so theoretically possible, but it's just a refueling aircraft--probably an OCR error for RB-29, but I'm not sure

    if (WW1_selected()) {
      result <- append(result, as.character(unique(filter_selection(WW1_clean,
                                                                    start_date,
                                                                    end_date,
                                                                    countries,
                                                                    aircrafts,
                                                                    weapons)[[column]])))
    }
    if (WW2_selected()) {
      result <- append(result, as.character(unique(filter_selection(WW2_clean,
                                                                    start_date,
                                                                    end_date,
                                                                    countries,
                                                                    aircrafts,
                                                                    weapons)[[column]])))
    }
    if (Korea_selected()) {
      result <- append(result, as.character(unique(filter_selection(Korea_clean2,
                                                                    start_date,
                                                                    end_date,
                                                                    countries,
                                                                    aircrafts,
                                                                    weapons)[[column]])))
    }
    if (Vietnam_selected()) {
      result <- append(result, as.character(unique(filter_selection(Vietnam_clean,
                                                                    start_date,
                                                                    end_date,
                                                                    countries,
                                                                    aircrafts,
                                                                    weapons)[[column]])))
    }

  WW1_selected <- reactive(WW1_string %c% input$which_war)
  
  WW2_selected <- reactive(WW2_string %c% input$which_war)
  
  Korea_selected <- reactive(Korea_string %c% input$which_war)
  
  Vietnam_selected <- reactive(Vietnam_string %c% input$which_war)

  WW1_selection <- reactive({
    if (all(length(input$dateRange) == 2L, 
            length(input$country)   >= 1L, 
            length(input$aircraft)  >= 1L, 
            length(input$weapon)    >= 1L)) {
      filter_selection(WW1_clean, 
                       input$dateRange[1], 
                       input$dateRange[2], 
                       input$country, 
                       input$aircraft, 
                       input$weapon)
    } else {
      WW1_clean
    }
  })
  
  WW2_selection <- reactive({
    if (all(length(input$dateRange) == 2L, 
            length(input$country)   >= 1L, 
            length(input$aircraft)  >= 1L, 
            length(input$weapon)    >= 1L)) {
      filter_selection(WW2_clean, 
                       input$dateRange[1], 
                       input$dateRange[2], 
                       input$country, 
                       input$aircraft, 
                       input$weapon)
    } else {
      WW2_clean
    }
  })
  
  Korea_selection <- reactive({
    if (all(length(input$dateRange) == 2L, 
            length(input$country)   >= 1L, 
            length(input$aircraft)  >= 1L, 
            length(input$weapon)    >= 1L)) {
      filter_selection(Korea_clean2, 
                       input$dateRange[1], 
                       input$dateRange[2], 
                       input$country, 
                       input$aircraft, 
                       input$weapon)
    } else {
      Korea_clean2
    }
  })
  
  Vietnam_selection <- reactive({
    if (all(length(input$dateRange) == 2L, 
            length(input$country)   >= 1L, 
            length(input$aircraft)  >= 1L, 
            length(input$weapon)    >= 1L)) {
      filter_selection(Vietnam_clean, 
                       input$dateRange[1], 
                       input$dateRange[2], 
                       input$country, 
                       input$aircraft, 
                       input$weapon)
    } else {
      Vietnam_clean
    }
  })

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

  WW1_missions_reactive <- reactive({
    if (WW1_selected()) {
      WW1_selection()[, .N]
    } else 0
  })
  
  WW2_missions_reactive <- reactive({
    if (WW2_selected()) {
      WW2_selection()[, .N]
    } else 0
  })
  
  Korea_missions_reactive <- reactive({
    if (Korea_selected()) {
      Korea_selection()[, .N]
    } else 0
  })
  
  Vietnam_missions_reactive <- reactive({
    if (Vietnam_selected()) {
      Vietnam_selection()[, .N]
    } else 0
  })

  WW1_flights_reactive <- reactive({
    if (WW1_selected()) {
      WW1_selection()[, sum(Aircraft_Attacking_Num, na.rm = TRUE)]
    } else 0
  })
  
  WW2_flights_reactive <- reactive({
    if (WW2_selected()) {
      WW2_selection()[, sum(Aircraft_Attacking_Num, na.rm = TRUE)]
    } else 0
  })
  
  Korea_flights_reactive <- reactive({
    if (Korea_selected()) {
      Korea_selection()[, sum(Aircraft_Attacking_Num, na.rm = TRUE)]
    } else 0
  })
  
  Vietnam_flights_reactive <- reactive({
    if (Vietnam_selected()) {
      Vietnam_selection()[, sum(Aircraft_Attacking_Num, na.rm = TRUE)]
    } else 0
  })

  WW1_bombs_reactive <- reactive({
    if (WW1_selected()) {
      WW1_selection()[, sum(Weapon_Expended_Num, na.rm = TRUE)]
    } else 0
  })
  
  WW2_bombs_reactive <- reactive({
    if (WW2_selected()) {
      WW2_selection()[, sum(Weapon_Expended_Num, na.rm = TRUE)]
    } else 0
  })
  
  Korea_bombs_reactive <- reactive({
    if (Korea_selected()) {
      Korea_selection()[, sum(Weapon_Expended_Num, na.rm = TRUE)]
    } else 0
  })
  
  Vietnam_bombs_reactive <- reactive({
    if (Vietnam_selected()) {
      Vietnam_selection()[, sum(Weapon_Expended_Num, na.rm = TRUE)]
    } else 0
  })

  WW1_weight_reactive <- reactive({
    if (WW1_selected()) {
      WW1_selection()[, sum(Weapon_Weight_Pounds, na.rm = TRUE)]
    } else 0
  })
  
  WW2_weight_reactive <- reactive({
    if (WW2_selected()) {
      WW2_selection()[, sum(as.numeric(Weapon_Weight_Pounds), na.rm = TRUE)]
    } else 0
  })
  
  Korea_weight_reactive <- reactive({
    if (Korea_selected()) {
      Korea_selection()[, sum(Weapon_Weight_Pounds, na.rm = TRUE)]
    } else 0
  })
  
  Vietnam_weight_reactive <- reactive({
    if (Vietnam_selected()) {
      Vietnam_selection()[, sum(as.numeric(Weapon_Weight_Pounds), na.rm = TRUE)]
    } else 0
  })

  output$table <- DT::renderDataTable({
    if (WW1_selected()) {
      datatable(data = WW1_selection() %>% select(WW1_datatable_columns), 
                rownames = FALSE, 
                colnames = WW1_datatable_colnames) %>%
        formatStyle(columns = WW1_datatable_columns, 
                    background = WW1_background, 
                    fontWeight = font_weight)
    } else if (WW2_selected()) {
      datatable(data = WW2_selection() %>% select(WW2_datatable_columns), 
                rownames = FALSE, 
                colnames = WW2_datatable_colnames) %>%
        formatStyle(columns = WW2_datatable_columns, 
                    background = WW2_background, 
                    fontWeight = font_weight)
    } else if (Korea_selected()) {
      datatable(data = Korea_selection() %>% select(Korea_datatable_columns), 
                rownames = FALSE, 
                colnames = Korea_datatable_colnames) %>%
        formatStyle(columns = Korea_datatable_columns, 
                    background = Korea_background, 
                    fontWeight = font_weight)
    } else if (Vietnam_selected()) {
      datatable(data = Vietnam_selection() %>% select(Vietnam_datatable_columns), 
                rownames = FALSE, 
                colnames = Vietnam_datatable_colnames) %>%
        formatStyle(columns = Vietnam_datatable_columns, 
                    background = Vietnam_background, 
                    fontWeight = font_weight)
    } else {
      datatable(data = data.table(Example = list("Pick a war"), Data = list("to see its data")), 
                rownames = FALSE) %>%
        formatStyle(columns = 1:2, 
                    background = example_background, 
                    fontWeight = font_weight)
    }
  })

  # WW1 histogram
  output$WW1_hist <- renderPlot({
    if (input$WW1_sandbox_group == "None") {
      WW1_hist_plot <- ggplot(mapping = aes(x = WW1_selection()[["Mission_Date"]])) +
        geom_histogram(bins = input$WW1_hist_slider)
    } else {
      group_category <- WW1_categorical[[input$WW1_sandbox_group]]
      WW1_hist_plot <- ggplot(mapping = aes(x     = WW1_selection()[["Mission_Date"]],
                                            fill = WW1_selection()[[group_category]])) +
        geom_freqpoly(bins = input$WW1_hist_slider) +
        guides(color = guide_legend(title = input$WW1_sandbox_group))
    }
    WW1_hist_plot +
      ggtitle("World War One Histogram") +
      xlab("Date") +
      ylab("Number of Missions") +
      theme_bw()
  })

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
                                                 fill  = WW1_selection()[[group_category]])) + 
          guides(fill = guide_legend(title = input$WW1_sandbox_group))
      }
      WW1_sandbox_plot <- WW1_sandbox_plot + geom_violin() + stat_summary(fun.y = quartile_points, geom = 'point', position = position_dodge(width = 0.9))
    } else if (input$WW1_sandbox_ind %c% WW1_categorical_choices) {
      plot_category <- WW1_categorical[[input$WW1_sandbox_ind]]
      plot_continuous <- WW1_continuous[[input$WW1_sandbox_dep]]
      if (input$WW1_sandbox_group == "None") {
        WW1_sandbox_plot <- ggplot(mapping = aes(x = WW1_selection()[[plot_category]], 
                                                 y = WW1_selection()[[plot_continuous]]))
      } else {
        group_category <- WW1_categorical[[input$WW1_sandbox_group]]
        WW1_sandbox_plot <- ggplot(mapping = aes(x     = WW1_selection()[[plot_category]], 
                                                 y     = WW1_selection()[[plot_continuous]], 
                                                 fill  = WW1_selection()[[group_category]])) + 
          guides(fill = guide_legend(title = input$WW1_sandbox_group))
      }
      WW1_sandbox_plot <- WW1_sandbox_plot + geom_violin() + stat_summary(fun.y = quartile_points, geom = 'point', position = position_dodge(width = 0.9))
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
      WW2_sandbox_plot <- WW2_sandbox_plot + geom_violin() + stat_summary(fun.y = quartile_points, geom = 'point')
    } else if (input$WW2_sandbox_ind %c% WW2_categorical_choices) {
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
      WW2_sandbox_plot <- WW2_sandbox_plot + geom_violin() + stat_summary(fun.y = quartile_points, geom = 'point')
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
      Korea_sandbox_plot <- Korea_sandbox_plot + geom_violin() + stat_summary(fun.y = quartile_points, geom = 'point')
    } else if (input$Korea_sandbox_ind %c% Korea_categorical_choices) {
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
      Korea_sandbox_plot <- Korea_sandbox_plot + geom_violin() + stat_summary(fun.y = quartile_points, geom = 'point')
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
      Vietnam_sandbox_plot <- Vietnam_sandbox_plot + geom_violin() + stat_summary(fun.y = quartile_points, geom = 'point')
    } else if (input$Vietnam_sandbox_ind %c% Vietnam_categorical_choices) {
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
      Vietnam_sandbox_plot <- Vietnam_sandbox_plot + geom_violin() + stat_summary(fun.y = quartile_points, geom = 'point')
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

clear_WW1_overview <- function() {
    overview_proxy %>% clearGroup(group = "WW1_overview")
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
                         group = "WW1_overview")
  }

clear_WW1_civilian <- function() {
    civilian_proxy %>% clearGroup(group = "WW1_heatmap")
  }

draw_WW1_civilian <- function() {
    civilian_proxy %>% addHeatmap(lng = WW1_selection()$Target_Longitude, 
                         lat = WW1_selection()$Target_Latitude, 
                         blur = civilian_blur, 
                         max = civilian_max, 
                         radius = civilian_radius, 
                         group = "WW1_heatmap")
  }


