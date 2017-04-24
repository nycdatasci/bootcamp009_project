##############################################
# Geospatial Data Digester Prototyped in R -- 
# A Shiny Project @ NYC Data Science Academy
# 
#
# Chao Shi
# chao.shi.datasci@gmail.com
# 4/23/2017
##############################################

navbarPage(div(style='font-size: 25px;', "Geospatial Data Digester -- US County"),
           windowTitle = "Olivia loves colorful maps",
           id="nav",
           collapsible = TRUE,
           
           # ======================================================================================
           # ====================                                         =========================
           # ====================     Tab 1 Starts -- Interactive map     =========================
           # ====================                                         =========================
           # ======================================================================================
           
           # --------------------------------------------------------------------------------------
           #   This main tab layout and style are inspired by Joe Cheng's 'superzip' example
           #               https://shiny.rstudio.com/gallery/superzip-example.html
           # --------------------------------------------------------------------------------------
           tabPanel("Interactive map",
                    div(class="outer",
                        
                        tags$head(
                          includeCSS("styles.css")
                        ),
                        
                        tags$style(type = "text/css",
                                   ".radio label {font-size: 11px;}
                                   "),
                        
                        # ============================================== #
                        #              THE MAP -- leaflet map            #
                        # ============================================== #
                        
                        leafletOutput("map", width="100%", height="100%"),

                        # =========================================================== #
                        #    floating control panel hosting most of the user input    #
                        # =========================================================== #
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = 500, height = "auto",
                                      
                                      h2("Pick and Choose"),
                                      
                                      # ---------------------------------------------------------------------------
                                      # Each fluidRow is for 1 input check box
                                      # Due to specific contidionalPanel design, checkboxGroupInput is not chosen
                                      # ---------------------------------------------------------------------------
                                      
                                      # Air Quality
                                      fluidRow(
                                        column(5, checkboxInput("ck1", "Air Quality", value = FALSE, width = NULL)),
                                        conditionalPanel(condition = "input.ck1",
                                                         column(3,numericInput("w1", div(style='font-size: 12px;', "wt"),
                                                                               20, min = 1, max = 100)),
                                                         div(style="height: 1px;",
                                                             column(4,sliderInput("sl1", div(style='font-size: 10px;', "PM 2.5 µg/m³:"),
                                                                                  min = MINs[1], max = MAXs[1], value = c(MINs[1],MAXs[1]), 
                                                                                  step = 0.1, ticks=FALSE)))
                                        ) # end of conditionalPanel
                                      ),  # end of fluidRow 1
                                      
                                      # Politics - VoteDiff
                                      fluidRow(
                                        column(2, checkboxInput("ck2", "Politics", value = FALSE, width = NULL)),
                                        conditionalPanel(condition = "input.ck2",
                                                         column(3, radioButtons("radio2", label = NULL,
                                                                                choices = list("prefer dem" = 1, "prefer gop" = 2), 
                                                                                selected = 1)),
                                                         column(3,numericInput("w2", div(style='font-size: 12px;', "wt"),
                                                                               20, min = 1, max = 100)),
                                                         column(4,sliderInput("sl2", div(style='font-size: 10px;', "dem% - gop%"),
                                                                              min = MINs[2], max = MAXs[2], value = c(MINs[2],MAXs[2]),
                                                                              ticks=FALSE))
                                        ) # end of conditionalPanel
                                      ),  # end of fluidRow 2
                                      
                                      # Income
                                      fluidRow(
                                        column(5, checkboxInput("ck3", "Income", value = FALSE, width = NULL)),
                                        conditionalPanel(condition = "input.ck3",
                                                         column(3,numericInput("w3", div(style='font-size: 12px;', "wt"),
                                                                               20, min = 1, max = 100)),
                                                         column(4,sliderInput("sl3", div(style='font-size: 10px;', "$/year"),
                                                                              min = MINs[3], max = MAXs[3], value = c(MINs[3],MAXs[3]),
                                                                              ticks=FALSE))
                                        ) # end of conditionalPanel
                                      ),  # end of fluidRow 3
                                      
                                      # Living Cost
                                      fluidRow(
                                        column(5, checkboxInput("ck4", "Living Cost", value = FALSE, width = NULL)),
                                        conditionalPanel(condition = "input.ck4",
                                                         column(3,numericInput("w4", div(style='font-size: 12px;', "wt"),
                                                                               20, min = 1, max = 100)),
                                                         column(4,sliderInput("sl4", div(style='font-size: 10px;', "$/year"),
                                                                              min = MINs[4], max = MAXs[4], value = c(MINs[4],MAXs[4]),
                                                                              ticks=FALSE))
                                        ) # end of conditionalPanel
                                      ),  # end of fluidRow 4
                                      
                                      # Income/Cost
                                      fluidRow(
                                        column(5, checkboxInput("ck5", "Income/Cost Ratio", value = FALSE, width = NULL)),
                                        conditionalPanel(condition = "input.ck5",
                                                         column(3,numericInput("w5", div(style='font-size: 12px;', "wt"),
                                                                               20, min = 1, max = 100)),
                                                         column(4,sliderInput("sl5", div(style='font-size: 10px;', ""),
                                                                              min = MINs[5], max = MAXs[5], value = c(MINs[5],MAXs[5]),
                                                                              ticks=FALSE))
                                        ) # end of conditionalPanel
                                      ),  # end of fluidRow 5
                                      
                                      # Crime Rate
                                      fluidRow(
                                        column(5, checkboxInput("ck6", "Crime Rate", value = FALSE, width = NULL)),
                                        conditionalPanel(condition = "input.ck6",
                                                         column(3,numericInput("w6", div(style='font-size: 12px;', "wt"),
                                                                               20, min = 1, max = 100)),
                                                         column(4,sliderInput("sl6", div(style='font-size: 10px;', "per 100k people"),
                                                                              min = MINs[6], max = MAXs[6], value = c(MINs[6],MAXs[6]),
                                                                              ticks=FALSE))
                                        ) # end of conditionalPanel
                                      ),  # end of fluidRow 6
                                      
                                      # Population Density
                                      fluidRow(
                                        column(3, checkboxInput("ck7", "Population Density", value = FALSE, width = NULL)),
                                        conditionalPanel(condition = "input.ck7",
                                                         column(2, radioButtons("radio7", label = NULL,
                                                                                choices = list("crowd" = 1, "space" = 2), 
                                                                                selected = 1)),
                                                         column(3,numericInput("w7", div(style='font-size: 12px;', "wt"),
                                                                               20, min = 1, max = 100)),
                                                         column(4,sliderInput("sl7", div(style='font-size: 10px;', "log(population/area)"),
                                                                              min = MINs[7], max = MAXs[7], value = c(MINs[7],MAXs[7]),
                                                                              ticks=FALSE))
                                        ) # end of conditionalPanel
                                      ),  # end of fluidRow 7
                                      
                                      # ##########################################################################################
                                      #  ......>>    Addtional input fluidRow should be added here before the mouse click fluidRow
                                      # ##########################################################################################
                                      
                                      # -----------------------------------------------------------------------------------------------
                                      # End of regular fluidRow items. The above rows each have a slider for filtering
                                      # The fluidRow below is for mouse-click (lat,lng) input. This will not be used to filter data
                                      # -----------------------------------------------------------------------------------------------
                                      
                                      # mouse input for distance calc
                                      fluidRow(
                                        column(3, checkboxInput("ck100", "Distance to", value = FALSE, width = NULL)),
                                        conditionalPanel(condition = "input.ck100",
                                                         column(2, radioButtons("radio100", label = NULL,
                                                                                choices = list("close to" = 1, "away from" = 2), 
                                                                                selected = 1)),
                                                         column(3, numericInput("w100", div(style='font-size: 12px;', "wt"),
                                                                               20, min = 1, max = 100)),
                                                         column(4, verbatimTextOutput('click_lat_lon'))
                                                         
                                        ) # end of conditionalPanel
                                      ),  # end of fluidRow #100 for mouse click input
                                      
                                      
                                      # action button -- user triggers a plot refresh when all changes are made,
                                      #                  since backend calculation and map refresh take some time 
                                      #                  (filtering > weighted average > plot)
                                      actionButton("do", "Update Plots",icon("refresh"), width="100%")
                                      
                        ),  # end of absolutePanel "controls"
                        
                        
                        # ========================= #
                        #    floating radar chart   #     a quick visual strength / weakness multi-variable plot
                        # ========================= #
                        
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 705, left = "auto", right = 1038, bottom = "auto",
                                      width = 500, height = "auto",
                                      
                                      # chartJSRadarOutput("radar", height = "300")      # this is provided by 'radarchart' package,
                                      uiOutput("radar")                                  # but not as stable as uiOutput
                                      
                        ),  # end of absolutePanel for radar chart
                        
                        
                        # ======================= #
                        #    floating pie chart   #    user choice and weights visual reminder
                        # ======================= #
                        
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 720, left = "auto", right = 650, bottom = "auto",
                                      width = 320, height = "auto",
                                      
                                      # pie chart
                                      htmlOutput("pie")
                                      
                        ),  # end of absolutePanel
                        
                        
                        tags$div(id="cite",
                                 'Geospatial Data Digester Prototype --- ', tags$em('Chao Shi'), '04/2017'
                        )
                        
                    ) # end of div
           ),
           
           # ======================================================================================
           # ====================   Tab 1 ENDS -- Interactive Map Tab     =========================
           # ====================                                         =========================
           # ====================              Tab 2 STARTS               =========================
           # ======================================================================================
           
           tabPanel("Map filtered data explorer",
                    
                    DT::dataTableOutput("leafmaptable")   # in the server.R logic, user can click 
                                                          # on multiple rows, markers will show
                                                          # up on tab 1 map (read lat-lng, plot)
           ), # end of tabPanel
           
           
           # ======================================================================================
           # ====================                 Tab 2 ENDS              =========================
           # ====================                                         =========================
           # ====================                Tab 3 STARTS             =========================
           # ======================================================================================
           
           # -----------------------------------------------------------------------------
           # This correlation matrix tab is largely adapted from saurfang's shinyCorrplot
           #                  https://github.com/saurfang/shinyCorrplot
           # -----------------------------------------------------------------------------
           tabPanel("Correlation analysis",
                    
                    sidebarLayout(
                      
                      sidebarPanel(
                        
                        selectInput("corMethod", "Correlation Method",
                                    eval(formals(cor)$method)),
                        selectInput("corUse", "NA Action",
                                    c("everything", "all.obs", "complete.obs", "na.or.complete", "pairwise.complete.obs"),
                                    selected = "pairwise.complete.obs"),
                        tags$hr(),
                        
                        #Only works if we are not showing confidence interval
                        conditionalPanel("!input.showConf",
                                         selectInput("plotMethod", "Plot Method",
                                                     list("mixed", all = eval(formals(corrplot)$method)), "circle"),
                                         conditionalPanel("input.plotMethod === 'mixed'",
                                                          wellPanel(
                                                            selectInput("plotLower", "Lower Method", eval(formals(corrplot)$method)),
                                                            selectInput("plotUpper", "Upper Method", eval(formals(corrplot)$method)))
                                         )
                        ),
                        conditionalPanel("input.showConf || input.plotMethod !== 'mixed'",
                                         selectInput("plotType", "Plot Type",
                                                     eval(formals(corrplot)$type))),
                        
                        selectInput("plotOrder", "Reorder Correlation",
                                    eval(formals(corrplot)$order)),
                        conditionalPanel("input.plotOrder === 'hclust'",
                                         wellPanel(
                                           selectInput("plotHclustMethod", "Method",
                                                       eval(formals(corrplot)$hclust.method)),
                                           numericInput("plotHclustAddrect", "Number of Rectangles", 3, 0, NA))),
                        
                        tags$hr(),
                        checkboxInput("sigTest", "Significance Test"),
                        conditionalPanel("input.sigTest",
                                         numericInput("sigLevel", "Significane Level",
                                                      0.05, 0, 1, 0.01),
                                         selectInput("sigAction", "Insignificant Action",
                                                     eval(formals(corrplot)$insig))),
                        checkboxInput("showConf", "Show Confidence Interval"),
                        conditionalPanel("input.showConf",
                                         selectInput("confPlot", "Ploting Method",
                                                     eval(formals(corrplot)$plotCI)[-1]),
                                         numericInput("confLevel", "Confidence Level",
                                                      0.95, 0, 1, 0.01))
                      ),
                      
                      # Show a plot of the generated correlation
                      mainPanel(
                        tabsetPanel(
                          tabPanel("Correlation", 
                                   column(3, 
                                          radioButtons("variablesStyle", "Variable Selection Style", c("Checkbox", "Selectize"), inline = T),
                                          helpText("Choose the variables to display. Drag and drop to reorder."), 
                                          conditionalPanel("input.variablesStyle === 'Checkbox'",
                                                           sortableCheckboxGroupInput("variablesCheckbox", "", c("Loading..."))),
                                          conditionalPanel("input.variablesStyle === 'Selectize'",
                                                           sortableSelectizeInput("variables", "", c("Loading..."), multiple = T,
                                                                                  options = list(plugins = list("remove_button"))))),
                                   column(9, 
                                          plotOutput("corrPlot", height = 600),
                                          uiOutput("warning"))
                          ),
                          tabPanel("Variable name explanation",
                                   includeMarkdown("CorrInsight.md")
                          )
                        )
                      ) # end of mainPnel in the corrplot tab
                    )
           ), # end of tabPanel
           
           # ======================================================================================
           # ====================                 Tab 3 Ends              =========================
           # ====================                                         =========================
           # ====================                Tab 4 Starts             =========================
           # ======================================================================================
           
           tabPanel("About",
                    includeMarkdown("README.md")),
           
           conditionalPanel("false", icon("crosshair"))
)
