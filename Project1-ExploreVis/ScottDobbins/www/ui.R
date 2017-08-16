# @author Scott Dobbins
# @version 0.9.8.2
# @date 2017-08-15 22:30


### Constructors ------------------------------------------------------------

### Menu Items

menu_overview <- function() {
  menuItem("Overview", 
           tabName = "overview", 
           icon = icon('map'))
}

menu_data <- function() {
  menuItem("Data", 
           tabName = "data", 
           icon = icon('database'))
}

menu_WW1 <- function() {
  menuItem("World War I", 
           tabName = "WW1", 
           icon = icon('bar-chart', lib = 'font-awesome'))
}

menu_WW2 <- function() {
  menuItem("World War II", 
           tabName = "WW2", 
           icon = icon('bar-chart', lib = 'font-awesome'))
}

menu_Korea <- function() {
  menuItem("Korea", 
           tabName = "Korea", 
           icon = icon('bar-chart', lib = 'font-awesome'))
}

menu_Vietnam <- function() {
  menuItem("Vietnam", 
           tabName = "Vietnam", 
           icon = icon('bar-chart', lib = 'font-awesome'))
}

menu_pilot <- function() {
  menuItem("Be a pilot", 
           tabName = "pilot", 
           icon = icon('fighter-jet', lib = 'font-awesome'))
}

menu_commander <- function() {
  menuItem("Be a commander", 
           tabName = "commander", 
           icon = icon('map-o', lib = 'font-awesome'))
}

menu_civilian <- function() {
  menuItem("Be a civilian", 
           tabName = "civilian", 
           icon = icon('life-ring',   lib = 'font-awesome'))
}

### Tab Picker Constructors

war_picker <- function() {
  selectizeInput(inputId = "which_war", 
                 label = "Which wars?", 
                 choices = c(WW1_label, WW2_label, Korea_label, Vietnam_label), 
                 selected = c(), 
                 multiple = TRUE, 
                 width = sidebar_width)
}

date_picker <- function() {
  dateRangeInput(inputId = "dateRange", 
                 label = "Select which dates to show", 
                 start = earliest_date, 
                 end = latest_date, 
                 min = earliest_date, 
                 max = latest_date, 
                 startview = "year", 
                 width = sidebar_width)
}

country_picker <- function() {
  selectizeInput(inputId = "country", 
                 label = "Which country's air force?", 
                 choices = c("All"), 
                 selected = "All", 
                 multiple = TRUE, 
                 width = sidebar_width)
}

aircraft_picker <- function() {
  selectizeInput(inputId = "aircraft", 
                 label = "Which types of aircraft?", 
                 choices = c("All"), 
                 selected = "All", 
                 multiple = TRUE, 
                 width = sidebar_width)
}

weapon_picker <- function() {
  selectizeInput(inputId = "weapon", 
                 label = "Which types of bombs?", 
                 choices = c("All"), 
                 selected = "All", 
                 multiple = TRUE, 
                 width = sidebar_width)
}

### Item Constructors

overview_map_type_mod <- function() {
  box(width = 6, 
      selectizeInput(inputId = "pick_map", 
                     label = "Pick Map", 
                     choices = c("Color Map", 
                                 "Plain Map", 
                                 "Terrain Map", 
                                 "Street Map", 
                                 "Satellite Map"), 
                     selected = "Color Map", 
                     multiple = FALSE))
}

overview_map_label_mod <- function() {
  box(width = 6, 
      selectizeInput(inputId = "pick_labels", 
                     label = "Pick Labels", 
                     choices = c("Borders", "Text"), 
                     selected = c("Borders","Text"), 
                     multiple = TRUE))
}

overview_map_text_spacer <- function() {
  box(width = 6, 
      htmlOutput(outputId = "overview_text", 
                 inline = FALSE))
}

overview_map_sample_mod <- function() {
  box(width = 6, 
      numericInput(inputId = "sample_num", 
                   label = "Maximum number of points to display on map", 
                   value = init_sample_size, 
                   min = min_sample_size, 
                   max = max_sample_size))
}

war_hist_slider <- function(war_tag) {
  box(width = 12,
      #height = 200,
      sliderInput(inputId = paste0(war_tag, "_hist_slider"), 
                  label = "# of bins", 
                  value = war_init_bins[[war_tag]], 
                  min = war_min_bins[[war_tag]], 
                  max = war_max_bins[[war_tag]], 
                  step = 1))
}

war_transformation_ver <- function(war_tag) {
  box(width = 12,
      #height = 100,
      selectizeInput(inputId = paste0(war_tag, "_transformation_ver"), 
                     label = "Apply vertical transformation?", 
                     choices = c("None", "Logarithm"), 
                     selected = "None", 
                     multiple = FALSE))
}

war_transformation_hor <- function(war_tag) {
  box(width = 12,
      #height = 100,
      selectizeInput(inputId = paste0(war_tag, "_transformation_hor"), 
                     label = "Apply horizontal transformation?", 
                     choices = c("None", "Logarithm"), 
                     selected = "None", 
                     multiple = FALSE))
}

war_sandbox_ind <- function(war_tag) {
  box(width = 12,
      #height = 100,
      selectizeInput(inputId = paste0(war_tag, "_sandbox_ind"), 
                     label = "Which independent variable?", 
                     choices = c("None (All Data)", "Year", war_all_choices[[war_tag]]), 
                     selected = c("Year"), 
                     multiple = FALSE))
}

war_sandbox_dep <- function(war_tag) {
  box(width = 12,
      #height = 100,
      selectizeInput(inputId = paste0(war_tag, "_sandbox_dep"), 
                     label = "Which dependent variable?", 
                     choices = war_continuous_choices[[war_tag]], 
                     selected = c("Number of Attacking Aircraft"), 
                     multiple = FALSE))
}

war_sandbox_group <- function(war_tag) {
  box(width = 12,
      #height = 100,
      selectizeInput(inputId = paste0(war_tag, "_sandbox_group"), 
                     label = "Group by what?", 
                     choices = c("None", war_categorical_choices[[war_tag]]), 
                     selected = c("None"), 
                     multiple = FALSE)
  )
}

### Row Constructors

stat_infoboxes <- function() {
  fluidRow(
    infoBoxOutput(outputId = "num_missions", width = 3),
    infoBoxOutput(outputId = "num_aircraft", width = 3), 
    infoBoxOutput(outputId = "num_bombs",    width = 3),
    infoBoxOutput(outputId = "total_weight", width = 3))
}

overview_map_output <- function() {
  fluidRow(
    box(width  = map_width, 
        height = map_height, 
        leafletOutput("overview_map", 
                      width  = "100%", 
                      height = map_height)))
}

overview_map_mods <- function() {
  fluidRow(
    overview_map_type_mod(),
    overview_map_label_mod()
  )
}

overview_map_sampler <- function() {
  fluidRow(
    overview_map_text_spacer(), 
    overview_map_sample_mod()
  )
}

datatable_output <- function() {
  fluidRow(box(DT::dataTableOutput("table"), width = 12))
}

war_plot_outputs <- function(war_tag) {
  fluidRow(box(plotOutput(paste0(war_tag, "_hist"))),
           box(plotOutput(paste0(war_tag, "_sandbox"))))
}

war_plot_mods <- function(war_tag) {
  fluidRow(
    column(width = 6, 
           war_hist_slider(war_tag), 
           war_transformation_ver(war_tag), 
           war_transformation_hor(war_tag)), 
    column(width = 6, 
           war_sandbox_ind(war_tag), 
           war_sandbox_dep(war_tag), 
           war_sandbox_group(war_tag))
  )
}

pilot_title <- function() {
  fluidRow(
    box(width = 12, 
        htmlOutput(outputId = "pilot_title", 
                   inline = FALSE))
  )
}

commander_title <- function() {
  fluidRow(
    box(width = 12, 
        htmlOutput(outputId = "commander_title", 
                   inline = FALSE))
  )
}

civilian_title <- function() {
  fluidRow(
    box(width = 12, 
        htmlOutput(outputId = "civilian_title", 
                   inline = FALSE))
  )
}

civilian_map_output <- function() {
  fluidRow(
    box(width  = map_width, 
        height = map_height, 
        leafletOutput("civilian_map", 
                      width  = "100%", 
                      height = map_height))
  )
}

civilian_map_mods <- function() {
  fluidRow(
    box(width = 12, 
        selectizeInput(inputId = "civilian_priority",
                       label = "I am most concerned about:",
                       choices = c("The number of planes flying", 
                                   "The number of bombs dropped", 
                                   "The intensity of the bombing"),
                       selected = c("The intensity of the bombing"), 
                       multiple = FALSE))
  )
}


### UI Component ------------------------------------------------------------

shinyUI(dashboardPage(
  

### Header and Sidebar ------------------------------------------------------

  dashboardHeader(title = "Aerial Bombing Operations", titleWidth = title_width), 
  
  dashboardSidebar(width = sidebar_width, 
                   
                   sidebarUserPanel("Scott Dobbins", 
                                    image = sidebar_image), 
                   
                   sidebarMenu(id = "tabs", 
                               menu_overview(), 
                               menu_data(), 
                               menu_WW1(), 
                               menu_WW2(), 
                               menu_Korea(), 
                               menu_Vietnam(), 
                               menu_pilot(), 
                               menu_commander(), 
                               menu_civilian()
                   ), 
                   
                   war_picker(), 
                   date_picker(), 
                   country_picker(), 
                   aircraft_picker(), 
                   weapon_picker()
  ),
  

### Body --------------------------------------------------------------------
  
  dashboardBody(
    #***really wish this would also apply my desired formatting to the sidebar, but it seems not
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")), 
    
    tabItems(
      

### Overview (Main) ---------------------------------------------------------

      tabItem(tabName = "overview", 
              stat_infoboxes(), 
              overview_map_output(), 
              overview_map_mods(), 
              overview_map_sampler()
      ), 
      

### DataTable ---------------------------------------------------------------

      tabItem(tabName = "data",
              datatable_output()
      ),


### WW1 ---------------------------------------------------------------------

      tabItem(tabName = WW1,
              war_plot_outputs(WW1), 
              war_plot_mods(WW1)
      ),


### WW2 ---------------------------------------------------------------------

      tabItem(tabName = WW2,
              war_plot_outputs(WW2), 
              war_plot_mods(WW2)
      ),


### Korea -------------------------------------------------------------------

      tabItem(tabName = Korea,
              war_plot_outputs(Korea), 
              war_plot_mods(Korea)
      ),


### Vietnam -----------------------------------------------------------------

      tabItem(tabName = Vietnam,
              war_plot_outputs(Vietnam), 
              war_plot_mods(Vietnam)
      ),
      

### Pilot -------------------------------------------------------------------

      tabItem(tabName = "pilot",
              pilot_title()
      ),
      

### Commander ---------------------------------------------------------------

      tabItem(tabName = "commander",
              commander_title()
      ),
      

### Civilian ----------------------------------------------------------------

      tabItem(tabName = "civilian",
              civilian_title(),
              civilian_map_output(), 
              civilian_map_mods()
      )
    )
  )
))
