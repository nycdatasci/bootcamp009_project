library(shiny)
shinyUI(navbarPage(
    "Personal Sommelier",
    tabPanel("Introduction",
             fluidPage(fluidRow(
                 column(
                     width = 3,
                     align = "center",
                     br(),
                     img(src = "s.png",width = 132,
                         height = 162),
                     br(),
                     br(),
                     br(),
                     br(),
                     img(
                         src = "w.png",
                         width = 160,
                         height = 160
                     )
                 ),
                 column(
                     9,
                     h3("Introduction"),
                     p(
                         strong(
                             "The purpose of this tool is to find the best wine for all the wine lovers."
                         )
                     ),
                     
                     p(
                         'Personal Sommelier is a Tasting Guide which equipped with an ingenious and complicated algorithm that lets you find the wine that best suits for your needs.',
                         br(),
                         'It contains the database that more than 3000 wines and over 250 wineries in the world. Provides useful and detailed information of each wine shows the technical data, aromas and sensations of mouth, rating score and wine related.',
                         
                         strong('only red wine "Vinho Verde".')
                     ),
                     h3("User guide"),
                     p(
                         '1. Choose the top n rated wine ',
                         br(),
                         '2. Choose the words map of wine which wine experts use the most',
                         br(),
                         '3. Choose some flavor words and My Sommelier will advise you on the best wine to match, it could be one or many.
'
                     ),
                     
                     
                     
                     fluidRow(
                         column(
                             width = 8,
                             h3("Information about the dataset"),
                             "The dataset is scraped by author from Wine Enthusiast website.",
                             br(),
                             "It is a magazine and website specializing in wines, spirits, food and travel. Founded in 1988 by Adam Strum, the magazine is run from its headquarters in New York and has a distribution of well over 500,000 readers.",
                             br(),
                             a("[Dataset]", href =
                                   "http://www.winemag.com/ratings/")
                         ),
                         column(
                             width = 4,
                             align = "center",
                             br(),
                             br(),
                             img(
                                 src = "giphy.GIF",
                                 width = 219,
                                 height = 160
                             )
                             
                         )
                     )
                 )
                 
             ))),
    tabPanel(
        "Top Wine List",
        fluidRow(column(3,
                        sliderInput(
                            "dn",
                            h4("Top n List"),
                            min = 80,
                            max = 100,
                            value = (1)
                        )
        ),
        column(6, DT::dataTableOutput("tbl")))),
    
    tabPanel("The Words of Wine",   
             
             fluidRow(
                 column(3,
                        h2("Wine Words"),
                        br(),
                        br(),
                        sliderInput("rfreq",
                                    h4("Minimum Frequency:"),
                                    min = 1,  max = 20, value = c(1,20)),
                        sliderInput("rmax",
                                    h4("Maximum Number of Words:"),
                                    min = 1,  max = 200,  value = c(1,200))),
                 
                 column(9,
                        h3("What are the words that wine experts use the most to describe the wine?"),
                        plotOutput("wordcloud",height=500)
                 )
             )),
    
    
    tabPanel(('Find your Wine'),
             
             
             # Sidebar to control date range
             fluidRow(
                 column(
                     10,
                     #   add tags to custom css for styling
                     tags$head(
                         tags$link(rel = 'stylesheet', type = 'text/css', href = 'styles.css')
                     ),
                     
                     
                     textInput('w', label = 'Describe your ideal wine and the chart updates with the best varietals!', value = ""),
                     
                     actionButton('button', "I need help thinking of descriptive words")
                 ),
                 column(5, showOutput('Plot', 'nvd3'), verbatimTextOutput('words'))
             )),
    
    tabPanel("Author & source code",
             fluidPage(fluidRow(
                 column(width = 3),
                 column(
                     width = 9,
                     h2("Author and source code"),
                     p("This tool was realized by ",
                       strong(
                           a("Yabin Fan", href = "https://www.linkedin.com/yabinfan")
                       )),
                     p(
                         "The source code is available on ",
                         a("Github", href = "https://github.com/YabinFan")
                     )
                 )
             )))
))
