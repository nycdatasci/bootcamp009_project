# This is the user-interface definition of a Shiny web application.
library(shiny)
library(shinythemes)
navbarPage(
    title = 'NYC Movie Spot',
    id = 'nav',theme = shinytheme("flatly"),
    tabPanel(
        'Interactive Map',
        div(
            class = "outer",
            
            tags$head(# Include the custom CSS
                includeCSS("styles.css"),
                includeScript("gomap.js")),
            #createthe map interface
            leafletOutput("map", width =
                              "100%", height = "100%"),
            
            # Shiny versions prior to 0.11 should use class="modal" instead.
            absolutePanel(
                id = "controls", class = "panel panel-default", fixed = FALSE,
                draggable = TRUE, top = 10, left =30 , right ="auto" , bottom = "auto",
                width = 300, height = "auto",
                
                h2(img(src = "videocam.png", height = 40),
                   "Movies in NYC"),
                
                selectizeInput("Genres", h4(img(src = 'gen.png', height = 40),  "Select the genres:"),choices = Genres,
                                multiple = TRUE),
                helpText("Please select the genres to see the movies on the map and graphs"),
                sliderInput(
                    "Year",
                    h4("Year"),
                    min = 1945,
                    max = 2006,
                    value = c(1945, 2006)
                ),
                sliderInput(
                    "Score",
                    h4("IMDB Score"),
                    min = 5.2,
                    max = 9.0,
                    value = c(5.2, 9.0)
                )
                ),
            absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE,
                          draggable = TRUE, top = 300, left ="auto" , right =20 , bottom = "auto",
                          width = 350, height = "auto",
                          plotOutput("yearbar",height = 200),
                          plotOutput("scorebar",height = 200)
            ),
########################## data scource ###############################
            tags$div(
                id = "cite",
                'Data was provide by ',
                tags$em('New York City Office of Film, Theatre, and Broadcasting '),
                ' and Chuan Sun,who scraped data from the IMDB website'
            )
        )
    ),

    tabPanel("Movie Explorer",   
             
             fluidRow(
                 column(3,
                        h2("NYC Movie Theme"),
                        br(),
                        br(),
                        sliderInput("rfreq",
                                    h4("Minimum Frequency:"),
                                    min = 1,  max = 20, value = c(1,20)),
                        sliderInput("rmax",
                                    h4("Maximum Number of Words:"),
                                    min = 1,  max = 200,  value = c(1,200))),
                 
                 column(9,
                        h3("What are the words the Directors use the most,"),
                        h3("when they film the movies in NYC? "),
                        plotOutput("wordcloud",height=500)
                 )
             )),
    
    
    tabPanel(
        "Find your Film",
        fluidRow(column(3,
                        sliderInput(
                            "dn",
                            h4("Top n Directors"),
                            min = 1,
                            max = 50,
                            value = (1)
                        )
                 ),
                 column(6, DT::dataTableOutput("tbl")))),
    tabPanel("Documentation",fluidRow(column(4,h3(img(src = "videocam.png", height = 40),"Welcome to NYC Movie Spot"),br(),
                                             p("The web application NYC Movie Spot is a tool designed to aid the visualization, 
                                                analysis and exploration of movies that have been filmed in New York City for the past 
                                                several decades. This app was built with R and Shiny and it is designed so that any movie 
                                                lovers can use it."),br(),
                                             h4("Data Source:"),
                                             p(a("NYC Open Data ", href= "https://data.cityofnewyork.us/Business/Filming-Locations-Scenes-from-the-City-/qb3k-n8mm")),
                                             p(a("IMDB 5000", href= "https://www.kaggle.com/deepmatrix/imdb-5000-movie-dataset")),br(),
                                             h4("About the Author"),
                                             p("Author: Yabin Fan"),
                                             p("Email: yfan19@jhu.edu"),
                                             p("Linkedin:", a("Click Here", href = "https://www.linkedin.com/in/yabin-fan-626858105/")),br(),
                                             p("Suggested citation: NYC Movie Locations Guide 2017: 
                                                A web application for the visualization and exploration of NYC movies, 
                                                Version 1.0,  Yabin Fan")),
                                      column(6,h2(img(src ="harry.png")))))
             
             
    )
    
    

