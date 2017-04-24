library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(skin = 'red',
  dashboardHeader(title = "Soccer Betting Analysis", titleWidth = 300),
  dashboardSidebar(
    sidebarUserPanel('Chen Trilnik', image = 'http://buenavistaco.gov/ImageRepository/Document?documentID=676'),
    sidebarMenu(
      
      #0
      menuItem("Project Introduction", 
               tabName = "intro", 
               icon = icon("futbol-o")),
      
      
      #1
      menuItem("Soccer Betting Explanation", 
               tabName = "explanation", 
               icon = icon("bullseye")),
      #2
      menuItem("Odds Distribution", 
               tabName = "Odds_Distribution", 
               icon = icon("calculator")),
      #3
      menuItem("Agencies Average Success Rate", 
               tabName = "Agencies_Success_Rate_over_Time", 
               icon = icon("bar-chart")),
      #4
      menuItem("Actual Vs Predicted", 
               tabName = "Real_Results_Vs_Agencies_Predicted_Results", 
               icon = icon("line-chart")),
      #5
      menuItem("Bets Minimum Odds",
               tabName = "min_odd_barplot",
               icon = icon("area-chart")),
      
      #6
      menuItem("Agencies' Favorite Level", 
               tabName = "Agencies_Favorite", 
               icon = icon("pie-chart")),
      
      #7
      menuItem("Draw Result Analysis", 
               tabName = "drow_analysis", 
               icon = icon("area-chart")),
      
      #8
      menuItem("Succes Rate Table", 
               tabName = "Success_Rate_Table", 
               icon = icon("table")),
      #9
      menuItem("European Leagues", 
               tabName = "map", 
               icon = icon("map"))
      
      
    )),
  dashboardBody(
      tabItems(  
        #0
        tabItem(tabName = 'intro',
                h2("Project Introduction"),
                h4('Background of Data Sets : The data sets were taken from Kaggle,
                   a part of a soccer SQLite data base.'),
                h3('The data sets include data on more than 25,000 matches from 9 different leagues in Europe over 8 seasons (2008/2009 - 2015/2016).'),
                h3('The data includes :'),
                h4(' - Match results'),
                h4(' - Teams and leagues'),
                h4(' - Match betting odds from 9 different betting agencies'),
                h4(' - Match dates'),
                h4(' - Player information and skills'),
                fluidRow(tags$iframe(src="https://www.youtube.com/embed/5tkZe8LJwzQ?ecver=2", 
                                     width="480", height="270"))
                ),
        
        
        #8
        tabItem(tabName = 'Success_Rate_Table',
                fluidRow(column(12,(selectInput(inputId = "Agencies_fav_level",
                                    label = "Choose a Favored Level",
                                    choices = c('A high favorite',
                                                'A moderate favorite',
                                                'A low favorite'))))),
                fluidRow(column(12,(selectInput(inputId = "Agencies_fav",
                                      label = "Choose one",
                                      choices = c('home team','away team','drow'))))),
               # fluidRow(infoBoxOutput('avg_success_rate_breakdown')),
                fluidRow(column(12,tableOutput('success_rates')))),
        #3
        tabItem(tabName = 'Agencies_Success_Rate_over_Time',
                h1("Betting Agencies Favorite Results vs Actual Match Results"),
                fluidRow(infoBoxOutput('avg_success_rates')),
                plotOutput('winrate',height = 500, width= 600)),
        #4
        tabItem(tabName = 'Real_Results_Vs_Agencies_Predicted_Results',
                fluidRow(column(12,(selectInput(inputId = "Agencies_fav_success_rate",
                                                label = "Choose a chart",
                                                choices = c('Agencies Favorite','Agencies Favorite Success Rates'))))),
                box(plotOutput('game_winner')),
                box(plotOutput('agencies_fav'))
                ),
        #2
        tabItem(tabName = 'Odds_Distribution',
                h1("How do the odds distribute?"),
                h4('Minimum and Maximum Odds Distribution'),
                
                checkboxInput("show_hist", "Switch to min/max histogram", value = FALSE),
                fluidRow(plotOutput('min_max_hist', height = 500, width= 600)),
                h1(" "),
                fluidRow(plotOutput('mid_odd_hist', height = 500, width= 600)),
                fluidRow(plotOutput('min_max', height = 500, width= 600))),
        #1
        tabItem(tabName = 'explanation', 
                h1("What is Soccer Betting?"),
                
                   h4('Soccer is a widely-bet sport worldwide and there are a number of different ways to bet on an individual game.

                      This analysis will follow the most basic way, the 3-way bet.'),  
                
                   h4('In most soccer competitions, draws may be the final result of the game, so there are 3 different outcomes to bet on between Team 1 and Team 2:'),
                     
                   h4('  - Team 1 wins'),
                   
                   h4('  - Team 2 wins'),
                   
                   h4('  - Team 1 and Team 2 draw'),
                  
                   h4(' '),
                
                fluidRow(column(12,(img(src ='http://bookmaker-info.com/en/wordpress/wp-content/uploads/2013/12/dafabet_bet_8.png',
                width= '70%'))))
                
              ),
        #5
        tabItem(tabName = 'min_odd_barplot',
                fluidRow(column(12,(selectInput(inputId = "season",
                                        label = "Choose a Season",
                                        choices = unique(min_max_odds$season))))),
                h3("How to categorize the matches using the minimum and maximum odds:"),
                h4('Favored result = the result with the minimum odd'),
                h5('A high favored result == max odd - min odd > 2'),
                h5('A moderate favored result == 2 > max odd - min odd  > 1'),
                h5('A low favored result == max odd - min odd < 1 '),
                fluidRow(plotOutput('min_odd_boxplot', height = 400, width= 600))),

        
        #6
        tabItem(tabName = 'Agencies_Favorite',
                h3("Count of Matches"),
                fluidRow(plotOutput('favor_count', height = 500, width= 600))),
        #7
        tabItem(tabName = 'drow_analysis',
                h3("What favored level are we likely to see the draw result?"),
                fluidRow(plotOutput('drow_analysis', height = 500, width= 600))),
        
        #9
        tabItem(tabName = 'map',
                h3("European Leagues Favored Results Win Rates"),
                checkboxInput("show", "show max success rates", value = FALSE),
                fluidRow(leafletOutput('map', height = 500, width= 600))) 
        
        

      )
    )

)
)