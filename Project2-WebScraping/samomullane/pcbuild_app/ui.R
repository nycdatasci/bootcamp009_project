shinyUI(dashboardPage(
  dashboardHeader(title = "PC Build Recommendation Engine"),

  dashboardSidebar(
    sidebarMenu(
      # menuItem("Simple recommendation",
      #          tabName = "simple_build",
      #          icon = icon("glyphicon glyphicon-check", lib='glyphicon')
      #          ),
      menuItem("Rigorous recommendation",
               tabName = "rig_build",
               icon = icon("glyphicon glyphicon-flash", lib='glyphicon')),
      menuItem("Filters",
               tabName = "filter_rig",
               icon = icon("glyphicon glyphicon-eject", lib='glyphicon'),
               menuSubItem(icon='',      
                           sliderInput("min_rating",
                                       "Minimum rating for all components",
                                       value = 0,
                                       min = 0,
                                       max = 5.0,
                                       step = 0.25)),
               menuSubItem(icon='',      
                           sliderInput("min_rating_n",
                                       "Minimum number of ratings for all components",
                                       value = 3,
                                       min = 0,
                                       max = 11,
                                       step = 1)),
               menuSubItem(icon='',
                           sliderInput("cpu_spec_weight",
                                       "CPU: Rating Weight",
                                       value = 0,
                                       min = 0,
                                       max = 1,
                                       step = 1)),
               menuSubItem(icon='',      
                           checkboxInput("overclock_cpu",
                                         "Overclockable CPU",
                                         value = T)),
               menuSubItem(icon='',
                           sliderInput("cooler_spec_weight",
                                       "Cooler: Rating Weight",
                                       value = 0,
                                       min = 0,
                                       max = 1,
                                       step = 1)),
               menuSubItem(icon='',      
                           checkboxInput("liquid",
                                         "Liquid cooled",
                                         value = T)),
               menuSubItem(icon='',
                           sliderInput("case_spec_weight",
                                       "Case: Rating Weight",
                                       value = 0,
                                       min = 0,
                                       max = 1,
                                       step = 1)),
               menuSubItem(icon='',
                           sliderInput("gpu_spec_weight",
                                       "GPU: Rating Weight",
                                       value = 0,
                                       min = 0,
                                       max = 1,
                                       step = 1)),
               menuSubItem(icon='',      
                           checkboxInput("overclock_gpu",
                                         "Overclockable GPU",
                                         value = T)),
               menuSubItem(icon='',
                           sliderInput("memory_spec_weight",
                                       "Memory: Rating Weight",
                                       value = 0,
                                       min = 0,
                                       max = 1,
                                       step = 1)),
               menuSubItem(icon='',
                           sliderInput("motherboard_spec_weight",
                                       "Motherboard: Rating Weight",
                                       value = 0,
                                       min = 0,
                                       max = 1,
                                       step = 1)),
               menuSubItem(icon='',
                           sliderInput("psu_spec_weight",
                                       "Power Unit: Rating Weight",
                                       value = 0,
                                       min = 0,
                                       max = 1,
                                       step = 1)),
               menuSubItem(icon='',      
                           radioButtons("efficiency_rating",
                                        "PSU efficiency rating:",
                                        choices = c('Titanium', 'Platinum',
                                                    'Gold', 'Silver', 'Bronze',
                                                    'Basic'),
                                        selected = 'Gold')),
               menuSubItem(icon='',      
                           radioButtons("modular_psu",
                                         "Modular PSU:",
                                         choices = c('Full', 'Semi', 'No'),
                                        selected = 'Full')),
               menuSubItem(icon='',
                           sliderInput("storage_spec_weight",
                                       "Storage: Rating Weight",
                                       value = 0,
                                       min = 0,
                                       max = 1,
                                       step = 1)),
               menuSubItem(icon='',      
                           checkboxInput("usb3",
                                       "USB 3.0 compatibility",
                                       value = T)),
               menuSubItem(icon='',      
                           checkboxInput("price_priority",
                                         "Prioritize price",
                                         value = F))
               ),
      menuItem("All Available Products",
               tabName = "available",
               icon = icon("glyphicon glyphicon-list-alt", lib='glyphicon')),
      menuItem("Filters",
               tabName = "filter_available",
               icon = icon("glyphicon glyphicon-eject", lib='glyphicon'),
               menuSubItem(icon='',      
                           sliderInput("rating_n",
                                       "Minimum number of ratings:",
                                       min = 1,
                                       max = 29,
                                       value = 3,
                                       step = 2)),
               menuSubItem(icon='',
                           sliderInput("price",
                                       "Component price range:",
                                       min = 10,
                                       max = 1500,
                                       value = c(10, 300),
                                       step = 10)),
               menuSubItem(icon='',
                           tags$div(HTML('<div id="rating_val" class="form-group shiny-input-radiogroup shiny-input-container">
                                         <label class="control-label" for="rating_val">Rating values:</label>
                                         <div class="shiny-options-group">
                                         <label class="radio-inline">
                                         <input type="radio" name="rating_val" value="all" checked="checked"/>
                                         <span>All ratings</span>
                                         </label>
                                         <br>
                                         <label class="radio-inline">
                                         <input type="radio" name="rating_val" value="four"/>
                                         <span>&#9733 &#9733 &#9733 &#9733 &#9734 and up</span>
                                         </label>
                                         <br>
                                         <label class="radio-inline">
                                         <input type="radio" name="rating_val" value="three"/>
                                         <span>&#9733 &#9733 &#9733 &#9734 &#9734 and up</span>
                                         </label>
                                         <br> 
                                         <label class="radio-inline">
                                         <input type="radio" name="rating_val" value="two"/>
                                         <span>&#9733 &#9733 &#9734 &#9734 &#9734 and up</span>
                                         </label>
                                         <br> 
                                         <label class="radio-inline">
                                         <input type="radio" name="rating_val" value="one"/>
                                         <span>&#9733 &#9734 &#9734 &#9734 &#9734 and up</span>
                                         </label>
                                         </div>
                                         </div> ')))
                           )
    )),

    dashboardBody(
      tabItems(
        tabItem(tabName = "available",
                fluidPage(tabBox(id = 'tabset1', width = 12,
                                 tabPanel("Case dataframe",
                                          fluidRow(
                                            column(12, dataTableOutput('case_db'))
                                            )),
                                 tabPanel("CPU dataframe",
                                          fluidRow(
                                            column(12, dataTableOutput('cpu_db'))
                                            )),
                                 tabPanel("Cooler dataframe",
                                          fluidRow(
                                            column(12, dataTableOutput('cooler_db'))
                                          )),
                                 tabPanel("GPU dataframe",
                                          fluidRow(
                                            column(12, dataTableOutput('gpu_db'))
                                          )),
                                 tabPanel("Memory dataframe",
                                          fluidRow(
                                            column(12, dataTableOutput('memory_db'))
                                          )),
                                 tabPanel("Motherboard dataframe",
                                          fluidRow(
                                            column(12, dataTableOutput('motherboard_db'))
                                          )),
                                 tabPanel("PSU dataframe",
                                          fluidRow(
                                            column(12, dataTableOutput('psu_db'))
                                          )),
                                 tabPanel("Storage dataframe",
                                          fluidRow(
                                            column(12, dataTableOutput('storage_db'))
                                          ))
                                 ))
                ),
        # tabItem(tabName = "simple_build",
        #         fluidPage(
        #           tags$head(tags$style(HTML("input[type='search']:disabled {visibility:hidden}"))),
        #           valueBoxOutput('simple_build_price'),
        #           valueBoxOutput('simple_build_tdp'),
        #           #Add titles to each element (tags$div(...))
        #           dataTableOutput('simple_build_db_cpu'),
        #           dataTableOutput('simple_build_db_cooler'),
        #           dataTableOutput('simple_build_db_case'),
        #           dataTableOutput('simple_build_db_gpu'),
        #           dataTableOutput('simple_build_db_memory'),
        #           dataTableOutput('simple_build_db_motherboard'),
        #           dataTableOutput('simple_build_db_psu'),
        #           dataTableOutput('simple_build_db_storage')
        #         )
        # ),
        tabItem(tabName = "rig_build",
                fluidPage(
                  tags$head(tags$style(HTML("input[type='search']:disabled {visibility:hidden}"))),
                  valueBoxOutput('rig_build_price'),
                  valueBoxOutput('rig_build_tdp'),
                  valueBoxOutput('rig_average_rating'),
                  #Add titles to each element (tags$div(...))
                  dataTableOutput('rig_build_db_cpu'),
                  dataTableOutput('rig_build_db_cooler'),
                  dataTableOutput('rig_build_db_case'),
                  dataTableOutput('rig_build_db_gpu'),
                  dataTableOutput('rig_build_db_memory'),
                  dataTableOutput('rig_build_db_motherboard'),
                  dataTableOutput('rig_build_db_psu'),
                  dataTableOutput('rig_build_db_storage')
                )
        )
      )
    )
))