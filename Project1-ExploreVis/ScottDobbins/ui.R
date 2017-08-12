# @author Scott Dobbins
# @version 0.9.8
# @date 2017-08-11 23:30


### UI Component ------------------------------------------------------------

shinyUI(dashboardPage(
  

### Header and Sidebar ------------------------------------------------------

  dashboardHeader(title = "Aerial Bombing Operations", titleWidth = title_width), 
  
  dashboardSidebar(width = sidebar_width, 
                   
                   # Sidebar Panel
                   sidebarUserPanel("Scott Dobbins", 
                                    image = sidebar_image), 
                   
                   sidebarMenu(id = "tabs", 
                               menuItem("Overview",       tabName = "overview",  icon = icon('map')), 
                               menuItem("Data",           tabName = "data",      icon = icon('database')),
                               menuItem("World War I",    tabName = "WW1",       icon = icon('bar-chart',   lib = 'font-awesome')), 
                               menuItem("World War II",   tabName = "WW2",       icon = icon('bar-chart',   lib = 'font-awesome')), 
                               menuItem("Korea",          tabName = "Korea",     icon = icon('bar-chart',   lib = 'font-awesome')), 
                               menuItem("Vietnam",        tabName = "Vietnam",   icon = icon('bar-chart',   lib = 'font-awesome')), 
                               menuItem("Be a pilot",     tabName = "pilot",     icon = icon('fighter-jet', lib = 'font-awesome')),
                               menuItem("Be a commander", tabName = "commander", icon = icon('map-o',       lib = 'font-awesome')),
                               menuItem("Be a civilian",  tabName = "civilian",  icon = icon('life-ring',   lib = 'font-awesome'))
                   ), 
                   
                   # war picker
                   selectizeInput(inputId = "which_war", 
                                  label = "Which wars?", 
                                  choices = c(WW1_string, WW2_string, Korea_string, Vietnam_string), 
                                  selected = c(), 
                                  multiple = TRUE, 
                                  width = sidebar_width), 
                   
                   # date picker
                   dateRangeInput(inputId = "dateRange", 
                                  label = "Select which dates to show", 
                                  start = earliest_date, 
                                  end = latest_date, 
                                  min = earliest_date, 
                                  max = latest_date, 
                                  startview = "year", 
                                  width = sidebar_width), 
                   
                   # country picker
                   selectizeInput(inputId = "country", 
                                  label = "Which country's air force?", 
                                  choices = c("All"), 
                                  selected = "All", 
                                  multiple = TRUE, 
                                  width = sidebar_width),
                   
                   # aircraft picker
                   selectizeInput(inputId = "aircraft", 
                                  label = "Which types of aircraft?", 
                                  choices = c("All"), 
                                  selected = "All", 
                                  multiple = TRUE, 
                                  width = sidebar_width),
                   
                   # weapon picker
                   selectizeInput(inputId = "weapon", 
                                  label = "Which types of bombs?", 
                                  choices = c("All"), 
                                  selected = "All", 
                                  multiple = TRUE, 
                                  width = sidebar_width)
                   
  ),
  

### Body --------------------------------------------------------------------
  
  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")), #***really wish this would also apply my desired formatting to the sidebar, but it seems not
    
    tabItems(
      

### Overview (Main) ---------------------------------------------------------

      tabItem(tabName = "overview", 
              
              # some stats
              fluidRow(
                infoBoxOutput(outputId = "num_missions", width = 3),
                infoBoxOutput(outputId = "num_aircraft", width = 3), 
                infoBoxOutput(outputId = "num_bombs",    width = 3),
                infoBoxOutput(outputId = "total_weight", width = 3)
              ), 
              
              # map
              fluidRow(
                box(width  = map_width, 
                    height = map_height, 
                    leafletOutput("overview_map", 
                                  width  = "100%", 
                                  height = map_height))
              ), 
              
              # selection widgets
              fluidRow(
                
                # map picker
                box(width = 6, 
                    selectizeInput(inputId = "pick_map", 
                                   label = "Pick Map", 
                                   choices = c("Color Map", "Plain Map", "Terrain Map", "Street Map", "Satellite Map"), 
                                   selected = "Color Map", 
                                   multiple = FALSE)),
                
                # label picker
                box(width = 6, 
                    selectizeInput(inputId = "pick_labels", 
                                   label = "Pick Labels", 
                                   choices = c("Borders", "Text"), 
                                   selected = c("Borders","Text"), 
                                   multiple = TRUE)) 
                
              ), 
              
              fluidRow(
                
                # text box whose sole purpose is actually just to add spacing to the bottom of the window
                box(width = 6, 
                    htmlOutput(outputId = "overview_text", 
                               inline = FALSE)), 
                
                # select number of points to graph on the map
                box(width = 6, 
                    numericInput(inputId = "sample_num", 
                                 label = "Maximum number of points to display on map", 
                                 value = init_sample_size, 
                                 min = min_sample_size, 
                                 max = max_sample_size))
              )
      ), 
      

### DataTable ---------------------------------------------------------------

      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"), width = 12))
      ),
      

### WW1 ---------------------------------------------------------------------

      tabItem(tabName = "WW1",
              
              fluidRow(
                box(plotOutput("WW1_hist")), 
                box(plotOutput("WW1_sandbox"))
              ), 
              
              fluidRow(
                box(width = 6, 
                    sliderInput(inputId = "WW1_hist_slider", 
                                label = "# of bins", 
                                value = WW1_init_bins, 
                                min = WW1_min_bins, 
                                max = WW1_max_bins, 
                                step = 1)), 
                
                box(width = 6, 
                    selectizeInput(inputId = "WW1_sandbox_ind", 
                                   label = "Which independent variable?", 
                                   choices = c("Year", WW1_all_choices), 
                                   selected = c("Year"), 
                                   multiple = FALSE))
              ), 
              
              fluidRow(
                box(width = 6, 
                    selectizeInput(inputId = "WW1_sandbox_group", 
                                   label = "Group by what?", 
                                   choices = c("None", WW1_categorical_choices), 
                                   selected = c("None"), 
                                   multiple = FALSE)), 
                
                box(width = 6, 
                    selectizeInput(inputId = "WW1_sandbox_dep", 
                                   label = "Which dependent variable?", 
                                   choices = WW1_continuous_choices, 
                                   selected = c("Number of Attacking Aircraft"), 
                                   multiple = FALSE))
              )
      ),
      

### WW2 ---------------------------------------------------------------------

      tabItem(tabName = "WW2",
              
              fluidRow(
                box(plotOutput("WW2_hist")), 
                box(plotOutput("WW2_sandbox"))
              ), 
              
              fluidRow(
                box(width = 6, 
                    sliderInput(inputId = "WW2_hist_slider", 
                                label = "# of bins", 
                                value = WW2_init_bins, 
                                min = WW2_min_bins, 
                                max = WW2_max_bins, 
                                step = 1)), 
                
                box(width = 6, 
                    selectizeInput(inputId = "WW2_sandbox_ind", 
                                   label = "Which independent variable?", 
                                   choices = c("Year", WW2_all_choices), 
                                   selected = c("Year"), 
                                   multiple = FALSE))
              ), 
              
              fluidRow(
                box(width = 6, 
                    selectizeInput(inputId = "WW2_sandbox_group", 
                                   label = "Group by what?", 
                                   choices = c("None", WW2_categorical_choices), 
                                   selected = c("None"), 
                                   multiple = FALSE)), 
                
                box(width = 6, 
                    selectizeInput(inputId = "WW2_sandbox_dep", 
                                   label = "Which dependent variable?", 
                                   choices = WW2_continuous_choices, 
                                   selected = c("Number of Attacking Aircraft"), 
                                   multiple = FALSE))
              )
      ),
      

### Korea -------------------------------------------------------------------

      tabItem(tabName = "Korea",
              
              fluidRow(
                box(plotOutput("Korea_hist")), 
                box(plotOutput("Korea_sandbox"))
              ), 
              
              fluidRow(
                box(width = 6, 
                    sliderInput(inputId = "Korea_hist_slider", 
                                label = "# of bins", 
                                value = Korea_init_bins, 
                                min = Korea_min_bins, 
                                max = Korea_max_bins, 
                                step = 1)), 
                
                box(width = 6, 
                    selectizeInput(inputId = "Korea_sandbox_ind", 
                                   label = "Which independent variable?", 
                                   choices = c("Year", Korea_all_choices), 
                                   selected = c("Year"), 
                                   multiple = FALSE))
              ), 
              
              fluidRow(
                box(width = 6, 
                    selectizeInput(inputId = "Korea_sandbox_group", 
                                   label = "Group by what?", 
                                   choices = c("None", Korea_categorical_choices), 
                                   selected = c("None"), 
                                   multiple = FALSE)), 
                
                box(width = 6, 
                    selectizeInput(inputId = "Korea_sandbox_dep", 
                                   label = "Which dependent variable?", 
                                   choices = Korea_continuous_choices, 
                                   selected = c("Number of Attacking Aircraft"), 
                                   multiple = FALSE))
              )
      ),
      

### Vietnam -----------------------------------------------------------------

      tabItem(tabName = "Vietnam",
              
              fluidRow(
                box(plotOutput("Vietnam_hist")), 
                box(plotOutput("Vietnam_sandbox"))
              ), 
              
              fluidRow(
                box(width = 6, 
                    sliderInput(inputId = "Vietnam_hist_slider", 
                                label = "# of bins", 
                                value = Vietnam_init_bins, 
                                min = Vietnam_min_bins, 
                                max = Vietnam_max_bins, 
                                step = 1)), 
                
                box(width = 6, 
                    selectizeInput(inputId = "Vietnam_sandbox_ind", 
                                   label = "Which independent variable?", 
                                   choices = c("Year", Vietnam_all_choices), 
                                   selected = c("Year"), 
                                   multiple = FALSE))
              ), 
              
              fluidRow(
                box(width = 6, 
                    selectizeInput(inputId = "Vietnam_sandbox_group", 
                                   label = "Group by what?", 
                                   choices = c("None", Vietnam_categorical_choices), 
                                   selected = c("None"), 
                                   multiple = FALSE)), 
                
                box(width = 6, 
                    selectizeInput(inputId = "Vietnam_sandbox_dep", 
                                   label = "Which dependent variable?", 
                                   choices = Vietnam_continuous_choices, 
                                   selected = c("Number of Attacking Aircraft"), 
                                   multiple = FALSE))
              )
      ),
      

### Pilot -------------------------------------------------------------------

      tabItem(tabName = "pilot",
              
              # title
              fluidRow(
                box(width = 12, 
                    htmlOutput(outputId = "pilot_title", 
                               inline = FALSE))
              )
      ),
      

### Commander ---------------------------------------------------------------

      tabItem(tabName = "commander",
              
              # title
              fluidRow(
                box(width = 12, 
                    htmlOutput(outputId = "commander_title", 
                               inline = FALSE))
              )
      ),
      

### Civilian ----------------------------------------------------------------

      tabItem(tabName = "civilian",
              
              # title
              fluidRow(
                box(width = 12, 
                    htmlOutput(outputId = "civilian_title", 
                               inline = FALSE))
              ),
              
              # map
              fluidRow(
                box(width  = map_width, 
                    height = map_height, 
                    leafletOutput("civilian_map", 
                                  width  = "100%", 
                                  height = map_height))
              ), 
              
              # priority picker
              fluidRow(
                box(width = 12, 
                    selectizeInput(inputId = "civilian_priority",
                                   label = "I am most concerned about:",
                                   choices = c("The number of planes flying", "The number of bombs dropped", "The intensity of the bombing"),
                                   selected = c("The intensity of the bombing"), 
                                   multiple = FALSE))
              )
      )
    )
  )
))
