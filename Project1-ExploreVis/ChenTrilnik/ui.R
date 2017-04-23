library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(skin = 'red',
  dashboardHeader(title = "Soccer Betting Analysis", titleWidth = 300),
  dashboardSidebar(
    sidebarUserPanel('Chen Trilnik', image = 'http://buenavistaco.gov/ImageRepository/Document?documentID=676'),
    sidebarMenu(
      
      #0
      menuItem("Project introduction", 
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
      menuItem("Bet's Min odd",
               tabName = "min_odd_barplot",
               icon = icon("area-chart")),
      
      #6
      menuItem("Agencies' Favorite Level", 
               tabName = "Agencies_Favorite", 
               icon = icon("pie-chart")),
      
      #7
      menuItem("Drow Result Analysis", 
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
                h2("Project introduction"),
                h4('Datasets background : The datasets were taken from Kaggle,
                   as part of a soccer SQLite data base.'),
                h3('The datasets included data on more then 25,000 matches from 9 different leaugues in Europe over 8 seasons (2008/2009 - 2015/2016).'),
                h3('The data included :'),
                h4(' - Matches results'),
                h4(' - Teams and leagues'),
                h4(' - Matches betting odds from 9 different betting agencies'),
                h4(' - Dates of matchs'),
                h4(' - Players information and skills'),
                h3('Why do we care ?'),
                h4('As a soccer fan that follows European leagues, 
                   I like to predict matches results, 
                   I found this dataset and project as a good opportunity 
                   to analyze the betting agencies matches odd, 
                   in order see if they can help predict matches results.'),
                fluidRow(tags$iframe(src="https://www.youtube.com/embed/5tkZe8LJwzQ?ecver=2", 
                                     width="480", height="270"))
                ),
        
        
        #8
        tabItem(tabName = 'Success_Rate_Table',
                fluidRow(column(12,(selectInput(inputId = "Agencies_fav_level",
                                    label = "Choose a Favorite Level",
                                    choices = c('A high favorite',
                                                'A moderate favorite',
                                                'A low favorite'))))),
                fluidRow(column(12,(selectInput(inputId = "Agencies_fav",
                                      label = "Choose a Favorite Case",
                                      choices = c('home team','away team','drow'))))),
               # fluidRow(infoBoxOutput('avg_success_rate_breakdown')),
                fluidRow(column(12,tableOutput('success_rates')))),
        #3
        tabItem(tabName = 'Agencies_Success_Rate_over_Time',
                h1("Betting agencies favorite result : Actual match result"),
                h4('Minimum odd = Favored result'),
                fluidRow(infoBoxOutput('avg_success_rates')),
                plotOutput('winrate',height = 500, width= 600)),
        #4
        tabItem(tabName = 'Real_Results_Vs_Agencies_Predicted_Results',
                fluidRow(column(12,(selectInput(inputId = "Agencies_fav_success_rate",
                                                label = "Choose a chart",
                                                choices = c('Agencies Favorite','Agencies Favorite Success Rates'))))),
                box(plotOutput('agencies_fav')),
                box(plotOutput('game_winner'))),
        #2
        tabItem(tabName = 'Odds_Distribution',
                h1("How do the odds distribute?"),
                h4('Min & Max odds distribution'),
                fluidRow(plotOutput('min_max', height = 500, width= 600)),
                checkboxInput("show_hist", "Switch to min/max histogram", value = FALSE),
                fluidRow(plotOutput('min_max_hist', height = 500, width= 600)),
                h1(" "),
                fluidRow(plotOutput('mid_odd_hist', height = 500, width= 600))),
        #1
        tabItem(tabName = 'explanation', 
                h1("What is Soccer Betting?"),
                
                   h4('Soccer is a widely-bet sport worldwide and there are a number of different ways to bet an individual game.

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
                h3("How to categoraize the matches using favored result?"),
                h4('Favored result = The result with the minimum odd'),
                h5('A high favored result == max odd - min odd > 2'),
                h5('A moderate favored result == 2 > max odd - min odd  > 1'),
                h5('A low favored result == max odd - min odd < 1 '),
                fluidRow(plotOutput('min_odd_boxplot', height = 400, width= 600))),

        
        #6
        tabItem(tabName = 'Agencies_Favorite',
                h3("How to categoraize the matches by their odds?"),
                h4('Favorite result = The result with the minimum odd'),
                fluidRow(plotOutput('favor_count', height = 500, width= 600))),
        #7
        tabItem(tabName = 'drow_analysis',
                h3("What favored level are we likely see the drow result?"),
                fluidRow(plotOutput('drow_analysis', height = 500, width= 600))),
        
        #9
        tabItem(tabName = 'map',
                h3("European Leagues Favored Results win rates"),
                checkboxInput("show", "show max success rates", value = FALSE),
                fluidRow(leafletOutput('map', height = 500, width= 600))) 
        
        

      )
    )

)
)