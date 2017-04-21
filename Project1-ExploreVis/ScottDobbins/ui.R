# @author Scott Dobbins
# @version 0.5
# @date 2017-04-21 18:53

### import useful packages ###
library(shiny)
library(leaflet)

### UI component ###
ui <- fluidPage(
  
  # major component #1: Title Panel
  titlePanel("Aerial Bombing Operations by the US Air Force"),
  
  sidebarLayout(
    
    # major component #2: Sidebar Panel
    sidebarPanel(
      
      selectizeInput(inputId = "pick_map", 
                     label = "Pick Map", 
                     choices = c("Color Map", "Plain Map", "Terrain Map", "Street Map", "Satellite Map"), 
                     selected = "Color Map", 
                     multiple = FALSE), 
      
      selectizeInput(inputId = "pick_labels", 
                     label = "Pick Labels", 
                     choices = c("Borders", "Text"), 
                     selected = c("Borders","Text"), 
                     multiple = TRUE), 
      
      br(),
      
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
                    value = FALSE)
      
    ),
    
    # major component #3: Main Panel
    mainPanel(
      
      leafletOutput("mymap", 
                    width = "100%", #***I would like to open a window of a specified size to begin with:
                    height = 768)   #***(1024+384, 768+128) or so
      
    )
  )
)
