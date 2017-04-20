# @author Scott Dobbins
# @version 0.3
# @date 2017-04-20 16:32
# 
# 
### Version history: ###
# 
# 0.1
# This version mapped out semi-cleaned longitudinal and latitudinal target data
#   from the United States Airforce in WW2 onto one color map with map labels. 
# major changes: implemented basic data cleaning and basic plotting
# 
# 0.2
# This version mapped out semi-cleaned longitudinal and latitudinal target data
#   from the United States Airforce in 4 major conflicts during the 20th century 
#   onto a selection of maps with map label options. 
# major changes: added other datasets; added other maps and map options
# 
# 0.3
# This version maps out semi-cleaned longitudinal and latitudinal target data
#   from the United States Airforce in 4 major conflicts during the 20th century 
#   onto a selection of maps with map label options and clickable, detailed tooltips.
# major changes: tooltips
# 
# 
# **Future version plans:
# **Tabs for exploring each separate conflict on its own in detail
# **Lots of ggplots, maybe a self-playing gif of bombs droppedover time for each conflict
# **Further clean/process the data
# **Fix some buggy tooltips (number agreement, NAs, capitalization, etc.)
# **Make efficient for use on shinyapps.io through SQLite
# **Maybe match (or fail to match) the data with thehistorical record. 
# **Could also allow users to link (using html) to relevant Wikipedia articles on 
#   certain aspects of the conflicts (airframes, campaigns, etc.)
# 
### end version history ###

### import useful packages ###
# import all internet-capable extensions
library(shiny)      # helps with shiny app
library(leaflet)    # helps with maps
library(maps)       # also helps with maps
library(htmltools)  # helps with tooltips

# import data analytic extensions
library(data.table) # helps with data input
library(dplyr)      # helps with data cleaning

# master debug mode control
debug_mode_on = TRUE


### import and clean data ###
# WW1
# data source: data.mil
# data origin URL: https://insight.livestories.com/s/v2/world-war-i/5be11be2-83c7-4d20-b5bc-05b3dc325d7e/
WW1_raw <- fread('WW1_bombing_operations.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
colnames(WW1_raw)[colnames(WW1_raw) %in% c("LATITUDE","LONGITUDE")] <- c("Target.Latitude","Target.Longitude")
WW1_clean <- data.table(filter(WW1_raw, Target.Latitude <= 90 & Target.Latitude >= -90 & Target.Longitude <= 180 & Target.Longitude >= -180))
WW1_unique_target <- unique(WW1_clean, by = c("Target.Latitude","Target.Longitude"))[1:1000,]#***take this out, and also move to after the cleaning step maybe?
WW1_unique_target$TAKEOFFTIME <- tolower(WW1_unique_target$TAKEOFFTIME)
WW1_unique_target$BOMBLOAD <- as.integer(round(WW1_unique_target$BOMBLOAD))
WW1_unique_target$TGTLOCATION <- paste0(substring(WW1_unique_target$TGTLOCATION, 1, 1), tolower(substring(WW1_unique_target$TGTLOCATION, 2)))
WW1_unique_target$TGTCOUNTRY <- paste0(substring(WW1_unique_target$TGTCOUNTRY, 1, 1), tolower(substring(WW1_unique_target$TGTCOUNTRY, 2)))
WW1_unique_target$TGTTYPE <- tolower(WW1_unique_target$TGTTYPE)
WW1_unique_target$tooltip <- paste0('On ', WW1_unique_target$MSNDATE, ' during the ', WW1_unique_target$TAKEOFFTIME, ', ', WW1_unique_target$NUMBEROFPLANESATTACKING, ' ', WW1_unique_target$SERVICE, ' ', WW1_unique_target$MDS, 's dropped ', WW1_unique_target$BOMBLOAD, ' lbs of bombs on ', WW1_unique_target$TGTTYPE, ' in ', WW1_unique_target$TGTLOCATION, ', ', WW1_unique_target$TGTCOUNTRY)

# WW2
# data source: data.mil
# data origin URL: https://insight.livestories.com/s/v2/world-war-ii/3262351e-df74-437c-8624-0c3b623064b5/
# pre-cleaned data source URL: https://www.kaggle.com/usaf/world-war-ii
WW2_raw <- fread('WW2_bombing_operations.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
colnames(WW2_raw) <- gsub("[()]", "", colnames(WW2_raw))
colnames(WW2_raw) <- gsub(" ", ".", colnames(WW2_raw))
WW2_clean <- data.table(filter(WW2_raw, Target.Latitude <= 90 & Target.Latitude >= -90 & Target.Longitude <= 180 & Target.Longitude >= -180))
WW2_unique_target <- unique(WW2_clean, by = c("Target.Latitude","Target.Longitude"))[1:1000,]#***take this out, and also move to after the cleaning step maybe?
WW2_unique_target$Service <- ifelse(WW2_unique_target$Country == "USA", paste(WW2_unique_target$Country, WW2_unique_target$Air.Force), WW2_unique_target$Air.Force)
WW2_unique_target$Target.City <- paste0(substring(WW2_unique_target$Target.City, 1, 1), tolower(substring(WW2_unique_target$Target.City, 2)))
WW2_unique_target$Target.Country <- paste0(substring(WW2_unique_target$Target.Country, 1, 1), tolower(substring(WW2_unique_target$Target.Country, 2)))
WW2_unique_target$Target.Type <- tolower(WW2_unique_target$Target.Type)
WW2_unique_target$Target.Industry <- tolower(WW2_unique_target$Target.Industry)
WW2_unique_target$Aircraft.Total <- ifelse(!is.na(WW2_unique_target$Bombing.Aircraft), WW2_unique_target$Bombing.Aircraft, ifelse(!is.na(WW2_unique_target$Attacking.Aircraft), WW2_unique_target$Attacking.Aircraft, ifelse(!is.na(WW2_unique_target$Airborne.Aircraft), WW2_unique_target$Airborne.Aircraft, "some")))
WW2_unique_target$tooltip <- paste0('On ', WW2_unique_target$Mission.Date, ', ', WW2_unique_target$Aircraft.Total, ' ', WW2_unique_target$Service, ' ', WW2_unique_target$Aircraft.Series, 's dropped ', WW2_unique_target$Total.Weight.Tons, ' tons of bombs on ', WW2_unique_target$Target.Type, ' in ', WW2_unique_target$Target.City, ', ', WW2_unique_target$Target.Country)

# Korea
# data source: data.mil
# data origin URL: https://insight.livestories.com/s/v2/korea/ff390af4-7ee7-4742-a404-2c3490f6ed96/
Korea_raw <- fread('Korea_bombing_operations2.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
Korea_clean <- mutate(Korea_raw, Target.Latitude = as.numeric(substr(TGT_LATITUDE_WGS84, 1, nchar(TGT_LATITUDE_WGS84)-1)), Target.Longitude = as.numeric(substr(TGT_LONGITUDE_WGS84, 1, nchar(TGT_LONGITUDE_WGS84)-1)))
Korea_clean <- data.table(filter(Korea_clean, Target.Latitude <= 90 & Target.Latitude >= -90 & Target.Longitude <= 180 & Target.Longitude >= -180))
Korea_unique_target <- unique(Korea_clean, by = c("Target.Latitude","Target.Longitude"))[1:1000,]#***take this out, and also move to after the cleaning step maybe?
Korea_unique_target <- select(Korea_unique_target, -ROW_NUMBER)
Korea_unique_target$tooltip <- paste0('On ', Korea_unique_target$MISSION_DATE, ', ', Korea_unique_target$NBR_ATTACK_EFFEC_AIRCRAFT, ' ', Korea_unique_target$UNIT, ' ', Korea_unique_target$AIRCRAFT_TYPE_MDS, 's dropped ', Korea_unique_target$CALCULATED_BOMBLOAD_LBS, ' pounds of bombs on ', Korea_unique_target$TGT_TYPE, ' in ', Korea_unique_target$TARGET_NAME)

# Vietnam ***actually a small sample of Vietnam data, which is currently too large to effectively use
# data source: data.mil
# data origin URL: https://insight.livestories.com/s/v2/vietnam/48973b96-8add-4898-9b33-af2a676b10bb/
Vietnam_raw <- fread('./datamil-vietnam-war-thor-data/VietNam_1965.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
colnames(Vietnam_raw)[colnames(Vietnam_raw) %in% c("TGTLATDD_DDD_WGS84","TGTLONDDD_DDD_WGS84")] <- c("Target.Latitude","Target.Longitude")
Vietnam_clean <- data.table(filter(Vietnam_raw, Target.Latitude <= 90 & Target.Latitude >= -90 & Target.Longitude <= 180 & Target.Longitude >= -180))
Vietnam_unique_target <- unique(Vietnam_clean, by = c("Target.Latitude","Target.Longitude"))[1:1000,]#***take this out, and also move to after the cleaning step maybe?
Vietnam_unique_target$TGTTYPE <- tolower(Vietnam_unique_target$TGTTYPE)
Vietnam_unique_target$tooltip <- paste0('On ', Vietnam_unique_target$MSNDATE, ', ', Vietnam_unique_target$NUMOFACFT, ' ', Vietnam_unique_target$MILSERVICE, ' ', Vietnam_unique_target$VALID_AIRCRAFT_ROOT, 's dropped bombs on ', Vietnam_unique_target$TGTTYPE, ' on ', Vietnam_unique_target$TGTCOUNTRY)

### UI component ###
ui <- fluidPage(
  
  # major component #1: Title Panel
  titlePanel("Aerial Bombing Operations by the US Air Force"),
  
  sidebarLayout(
    
    # major component #2: Sidebar Panel
    sidebarPanel(
      selectizeInput(inputId = "pick_map", label = "Pick Map", choices = c("Color Map", "Plain Map", "Terrain Map", "Street Map", "Satellite Map"), selected = "Color Map", multiple = FALSE),#, selectize = FALSE), 
      selectizeInput(inputId = "pick_labels", label = "Pick Labels", choices = c("Borders", "Text"), selected = c("Borders","Text"), multiple = TRUE),#, selectize = TRUE), 
      br(),
      # I had to keep these checkboxInputs separate (i.e. not a groupCheckboxInput) so that only redraws of the just-changed aspects occur (i.e. to avoid buggy redrawing)
      checkboxInput(inputId = "show_WW1", label = "Show WW1 Bombings", value = FALSE),
      checkboxInput(inputId = "show_WW2", label = "Show WW2 Bombings", value = FALSE),
      checkboxInput(inputId = "show_Korea", label = "Show Korea Bombings", value = FALSE),
      checkboxInput(inputId = "show_Vietnam", label = "Show Vietnam Bombings", value = FALSE)
    ),
    
    # major component #3: Main Panel
    mainPanel(
      leafletOutput("mymap", width = "100%", height = 768)#***I would like to open a window of a specified size to begin with: (1024+384, 768+128) or so
    )
    
  )
)


### server component ###

server <- function(input, output, session) {#***session is still currently unused below
  
  # initialize with watercolor map with both borders and labels drawn
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("Stamen.Watercolor", layerId = "map_base") %>% addProviderTiles("Stamen.TonerHybrid", layerId = "map_labels")
  })
  
  # hanlder for changes in map type
  observeEvent(eventExpr = input$pick_map, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    if(debug_mode_on) print("map altered"); print(input$pick_map)
    
    proxy <- leafletProxy("mymap")
    
    # remove other tiles and add designated map
    if(input$pick_map == "Color Map") {
      proxy %>% clearTiles() %>% addProviderTiles("Stamen.Watercolor", layerId = "map_base")
    } else if(input$pick_map == "Plain Map") {
      proxy %>% clearTiles() %>% addProviderTiles("CartoDB.PositronNoLabels", layerId = "map_base")
    } else if(input$pick_map == "Terrain Map") {
      proxy %>% clearTiles() %>% addProviderTiles("Stamen.TerrainBackground", layerId = "map_base")
    } else if(input$pick_map == "Street Map") {
      proxy %>% clearTiles() %>% addProviderTiles("HERE.basicMap", layerId = "map_base")
    } else if(input$pick_map == "Satellite Map") {
      proxy %>% clearTiles() %>% addProviderTiles("Esri.WorldImagery", layerId = "map_base")
    }
    
    # gotta redraw the map labels if the underlying map has changed
    if("Borders" %in% input$pick_labels) {
      if("Text" %in% input$pick_labels) {
        proxy %>% removeTiles(layerId = "map_labels") %>% addProviderTiles("Stamen.TonerHybrid", layerId = "map_labels")
      } else {
        proxy %>% removeTiles(layerId = "map_labels") %>% addProviderTiles("Stamen.TonerLines", layerId = "map_labels")
      }
    } else {
      if("Text" %in% input$pick_labels) {
        proxy %>% removeTiles(layerId = "map_labels") %>% addProviderTiles("Stamen.TonerLabels", layerId = "map_labels")
      } else {
        proxy %>% removeTiles(layerId = "map_labels")
      }
    }
    
  })
  
  # handler for changes in map labels
  # had to make sure ignoreNULL = FALSE so it would also update when all labels were removed
  observeEvent(eventExpr = input$pick_labels, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    if(debug_mode_on) print("labels altered")
    
    proxy <- leafletProxy("mymap")
    
    # remove current label tiles and re-add designated label tiles
    if("Borders" %in% input$pick_labels) {
      if("Text" %in% input$pick_labels) {
        if(debug_mode_on) print("Both borders and text")
        proxy %>% removeTiles(layerId = "map_labels") %>% addProviderTiles("Stamen.TonerHybrid", layerId = "map_labels")
      } else {
        if(debug_mode_on) print("Just borders; no text")
        proxy %>% removeTiles(layerId = "map_labels") %>% addProviderTiles("Stamen.TonerLines", layerId = "map_labels")
      }
    } else {
      if("Text" %in% input$pick_labels) {
        if(debug_mode_on) print("Just text; no borders")
        proxy %>% removeTiles(layerId = "map_labels") %>% addProviderTiles("Stamen.TonerLabels", layerId = "map_labels")
      } else {
        if(debug_mode_on) print("Neither text nor borders")
        proxy %>% removeTiles(layerId = "map_labels")
      }
    }
    
  })
  
  # handler for WW1 data plotting
  observeEvent(eventExpr = input$show_WW1, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    if(debug_mode_on) print("WW1 selected")
    proxy <- leafletProxy("mymap")
    if(input$show_WW1) {
      proxy %>% addCircles(data = WW1_unique_target, lat = ~Target.Latitude, lng = ~Target.Longitude, color = "darkblue", weight = 5, opacity = 0.5, fill = TRUE, fillColor = "darkblue", fillOpacity = 0.5, popup = htmlEscape(~tooltip), group = "WW1_unique_targets")
    } else {
      proxy %>% clearGroup(group = "WW1_unique_targets")
    }
  })
  
  # handler for WW2 data plotting
  observeEvent(eventExpr = input$show_WW2, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    if(debug_mode_on) print("WW2 selected")
    proxy <- leafletProxy("mymap")
    if(input$show_WW2) {
      proxy %>% addCircles(data = WW2_unique_target, lat = ~Target.Latitude, lng = ~Target.Longitude, color = "darkred", weight = 5, opacity = 0.5, fill = TRUE, fillColor = "darkred", popup = htmlEscape(~tooltip), group = "WW2_unique_targets")
    } else {
      proxy %>% clearGroup(group = "WW2_unique_targets")
    }
  })
  
  # handler for Korea data plotting
  observeEvent(eventExpr = input$show_Korea, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    if(debug_mode_on) print("Korea selected")
    proxy <- leafletProxy("mymap")
    if(input$show_Korea) {
      proxy %>% addCircles(data = Korea_unique_target, lat = ~Target.Latitude, lng = ~Target.Longitude, color = "yellow", weight = 5, opacity = 0.5, fill = TRUE, fillColor = "yellow", popup = htmlEscape(~tooltip), group = "Korea_unique_targets")
    } else {
      proxy %>% clearGroup(group = "Korea_unique_targets")
    }
  })
  
  # handler for Vietnam data plotting
  observeEvent(eventExpr = input$show_Vietnam, ignoreNULL = FALSE, ignoreInit = TRUE, handlerExpr = {
    if(debug_mode_on) print("Vietnam selected")
    proxy <- leafletProxy("mymap")
    if(input$show_Vietnam) {
      proxy %>% addCircles(data = Vietnam_unique_target, lat = ~Target.Latitude, lng = ~Target.Longitude, color = "darkgreen", weight = 5, opacity = 0.5, fill = TRUE, fillColor = "darkgreen", popup = htmlEscape(~tooltip), group = "Vietnam_unique_targets")
    } else {
      proxy %>% clearGroup(group = "Vietnam_unique_targets")
    }
  })
  
}


### make the app run ###
shinyApp(ui, server)


### END OF EXECUTED TEXT ###


### Code Graveyard ###
# where buggy or formerly useful but now unnecessary code lays to rest
# can resurrect if necessary

# checkboxInput(inputId = "show_labels", label = "Show Labels", value = TRUE),
# checkboxGroupInput(inputId = "show_bombings", label = "Show Data Options", choiceNames = c("Show WW1", "Show WW2", "Show Korea", "Show Vietnam"), choiceValues = c("show_WW1", "show_WW2", "show_Korea", "show_Vietnam"))

# observeEvent(input$show_map, {
#   if(debug_mode_on) print("combo pressed")
#   proxy <- leafletProxy("mymap")
#   if("show_watercolor" %in% input$show_map) {
#     if(debug_mode_on) print("watercolor pressed")
#     if("show_borders" %in% input$show_map) {
#       proxy %>% addProviderTiles("Stamen.Watercolor", layerId = "watercolor") %>% addProviderTiles("Stamen.TonerHybrid", layerId = "borders")
#     } else {
#       proxy %>% addProviderTiles("Stamen.Watercolor", layerId = "watercolor")
#     } 
#   } else {
#     if(debug_mode_on) print("labels pressed")
#     if("show_borders" %in% input$show_map) {
#       proxy %>% clearTiles() %>% addProviderTiles("Stamen.TonerHybrid", layerId = "borders")
#     } else {
#       proxy %>% clearTiles()
#     }
#   }
# })

# if(input$show_watercolor) {
#   if(input$show_borders) {
#     proxy %>% addProviderTiles("Stamen.Watercolor", layerId = "watercolor") %>% addProviderTiles("Stamen.TonerHybrid", layerId = "borders")
#   } else {
#     proxy %>% addProviderTiles("Stamen.Watercolor", layerId = "watercolor")
#   }
# } else {
#   if(input$show_borders) {
#     proxy %>% clearTiles() %>% addProviderTiles("Stamen.TonerHybrid", layerId = "borders")
#   } else {
#     proxy %>% clearTiles()
#   }
# }

# observeEvent(input$show_bombings, {
#   if(debug_mode_on) print("bombings pressed")
#   proxy <- leafletProxy("mymap")
#   if("show_WW1" %in% input$show_bombings) {
#     if(debug_mode_on) print("WW1 pressed")
#     proxy %>% addCircles(data = WW1_unique_target, lat = ~Target.Latitude, lng = ~Target.Longitude, color = "blue", weight = 5, opacity = 0.5, fill = TRUE, group = "WW1_unique_targets")
#   } else {
#     proxy %>% clearGroup(group = "WW1_unique_targets")
#   }
#   if("show_WW2" %in% input$show_bombings) {
#     if(debug_mode_on) print("WW2 pressed")
#     proxy %>% addCircles(data = WW2_unique_target, lat = ~Target.Latitude, lng = ~Target.Longitude, color = "red", weight = 5, opacity = 0.5, fill = TRUE, group = "WW2_unique_targets")
#   } else {
#     proxy %>% clearGroup(group = "WW2_unique_targets")
#   }
#   if("show_Korea" %in% input$show_bombings) {
#     if(debug_mode_on) print("Korea pressed")
#     proxy %>% addCircles(data = Korea_unique_target, lat = ~Target.Latitude, lng = ~Target.Longitude, color = "yellow", weight = 5, opacity = 0.5, fill = TRUE, group = "Korea_unique_targets")
#   } else {
#     proxy %>% clearGroup(group = "Korea_unique_targets")
#   }
#   if("show_Vietnam" %in% input$show_bombings) {
#     if(debug_mode_on) print("Vietnam pressed")
#     proxy %>% addCircles(data = Vietnam_unique_target, lat = ~Target.Latitude, lng = ~Target.Longitude, color = "green", weight = 5, opacity = 0.5, fill = TRUE, group = "Vietnam_unique_targets")
#   } else {
#     proxy %>% clearGroup(group = "Vietnam_unique_targets")
#   }
# })
