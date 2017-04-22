library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(googleVis)

shinyUI(dashboardPage(
  dashboardHeader(title ='OKCupid Profiles'),
  
  dashboardSidebar(
    sidebarUserPanel('Sean Kickham',
                     image = 'https://yt3.ggpht.com/-04uuTMHfDz4/AAAAAAAAAAI/AAAAAAAAAAA/Kjeupp-eNNg/s900-c-k-no-mo-rj-c0xffffff/photo.jpg'),
    sidebarMenu(
      menuItem('Map', tabName = 'map', icon = icon('map')),
      menuItem('Gender', tabName = 'sex', icon = icon('venus-mars')),
      menuItem('Sexual Orientation', tabName = 'orientation', icon = icon('heart')),
      menuItem('Ethnicity', tabName = 'ethnicity', icon = icon('globe')),
      menuItem('Religion', tabName = 'religion', icon = icon('map')),
      menuItem('Age', tabName = 'age', icon = icon('group')),
      menuItem('Word Clouds', tabName = 'wordcloud', icon = icon('database')),
      menuItem('Data', tabName = 'data', icon = icon('database'))),
    
    selectizeInput('selected',
                   'Select Item to Display',
                   choice)
    ),
  
  
  dashboardBody(
    tags$head(tags$script(src = 'scroll.js')),
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = 'scroll.css')),
    tabItems(
      
      tabItem(tabName = 'map',
              fluidRow(),
              fluidRow()),

      
      tabItem(tabName = 'sex',
              fluidRow(infoBoxOutput('femaleBox'),
                       infoBoxOutput('maleBox'),
                       infoBoxOutput('sexBox')),
              fluidRow(box(plotOutput('sexBar'),
                           height = 500),
                       box(plotOutput('sexBoxPlot'),
                           height = 500)),
              fluidRow(column(3, selectizeInput('sexAgainst',
                                                'Bar Chart Category to Plot',
                                                choices = c('ethnicity', 'job', 
                                                            'religion', 'smokes', 
                                                            'drugs', 'drinks', 
                                                            'offspring', 'education',
                                                            'sex', 'status'),
                                                width = 200)),
                       column(3, radioButtons('sexPosition',
                                              'Graph Positions',
                                              choices = c('fill', 'dodge'),
                                              width = 100)),
                       
                       column(3, selectizeInput('sexBoxPlotCat',
                                                'Box Plot Category to Plot',
                                                choices = c('income', 'age', 
                                                            'height', 'religion_serious', 
                                                            'sign_serious'),
                                                width = 200))
              )),
      
      
      tabItem(tabName = 'orientation',
              fluidRow(infoBoxOutput('straightBox'),
                       infoBoxOutput('gayBox'),
                       infoBoxOutput('bisexualBox')),
              fluidRow(box(plotOutput('orientationBar'),
                           height = 500),
                       box(plotOutput('orientationBoxPlot'),
                           height = 500)),
              fluidRow(column(3, selectizeInput('orientationAgainst',
                                      'Bar Chart Category to Plot',
                                      choices = c('ethnicity', 'job', 
                                                  'religion', 'smokes', 
                                                  'drugs', 'drinks', 
                                                  'offspring', 'education',
                                                  'sex', 'status'),
                                      width = 200)),
                       column(3, radioButtons('orientationPosition',
                                              'Graph Positions',
                                              choices = c('fill', 'dodge'),
                                              width = 100)),
                       
                       column(3, selectizeInput('orientationBoxPlotCat',
                                      'Box Plot Category to Plot',
                                      choices = c('income', 'age', 
                                                  'height', 'religion_serious', 
                                                  'sign_serious'),
                                      width = 200))
                       )),
      
      
      tabItem(tabName = 'ethnicity',
              fluidRow(infoBoxOutput('whiteBox'),
                       infoBoxOutput('multiethnicBox'),
                       infoBoxOutput('otherBox')),
              fluidRow(box(plotOutput('ethnicityBar'),
                           height = 500),
                       box(plotOutput('ethnicityBoxPlot'),
                           height = 500)),
              fluidRow(column(3, selectizeInput('ethnicityAgainst',
                                                'Bar Chart Category to Plot',
                                                choices = c('ethnicity', 'job', 
                                                            'religion', 'smokes', 
                                                            'drugs', 'drinks', 
                                                            'offspring', 'education',
                                                            'sex', 'status'),
                                                width = 200)),
                       column(3, radioButtons('ethnicityPosition',
                                              'Graph Positions',
                                              choices = c('fill', 'dodge'),
                                              width = 100)),
                       
                       column(3, selectizeInput('ethnicityBoxPlotCat',
                                                'Box Plot Category to Plot',
                                                choices = c('income', 'age', 
                                                            'height', 'religion_serious', 
                                                            'sign_serious'),
                                                width = 200))
              )),
      
      
      tabItem(tabName = 'religion',
              fluidRow(infoBoxOutput('religiousBox'),
                       infoBoxOutput('relseriousBox'),
                       infoBoxOutput('christianBox')),
              fluidRow(box(plotOutput('religionBar'),
                           height = 500),
                       box(plotOutput('religionBoxPlot'),
                           height = 500)),
              fluidRow(column(3, selectizeInput('religionAgainst',
                                                'Bar Chart Category to Plot',
                                                choices = c('ethnicity', 'job', 
                                                            'religion', 'smokes', 
                                                            'drugs', 'drinks', 
                                                            'offspring', 'education',
                                                            'sex', 'status'),
                                                width = 200)),
                       column(3, radioButtons('religionPosition',
                                              'Graph Positions',
                                              choices = c('fill', 'dodge'),
                                              width = 100)),
                       
                       column(3, selectizeInput('religionBoxPlotCat',
                                                'Box Plot Category to Plot',
                                                choices = c('income', 'age', 
                                                            'height', 'religion_serious', 
                                                            'sign_serious'),
                                                width = 200))
              )),
      
      
      tabItem(tabName = 'age',
              h1('Age')),
      
      
      tabItem(tabName = 'wordcloud',
              h1('Essay Word Cloud')),
      
      
      tabItem(tabName = 'data',
              fluidRow(DT::dataTableOutput('table'),
                           width = '100%'))
      )
    )
  
  ))

