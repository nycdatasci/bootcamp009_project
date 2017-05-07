shinyUI(dashboardPage(
  dashboardHeader(title = "PC Build Recommendation Engine"),

  dashboardSidebar(
    sidebarMenu(
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
                           ),
      menuItem("Simple recommendation",
               tabName = "simple_build",
               icon = icon("glyphicon glyphicon-check", lib='glyphicon')
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
        tabItem(tabName = "simple_build",
                fluidPage(
                  tags$head(tags$style(HTML("input[type='search']:disabled {visibility:hidden}"))),
                  valueBoxOutput('simple_build_price'),
                  valueBoxOutput('simple_build_tdp'),
                  #Add titles to each element (tags$div(...))
                  dataTableOutput('simple_build_db_cpu'),
                  dataTableOutput('simple_build_db_cooler'),
                  dataTableOutput('simple_build_db_case'),
                  dataTableOutput('simple_build_db_gpu'),
                  dataTableOutput('simple_build_db_memory'),
                  dataTableOutput('simple_build_db_motherboard'),
                  dataTableOutput('simple_build_db_psu'),
                  dataTableOutput('simple_build_db_storage')
                )
        )
      )
    )
))