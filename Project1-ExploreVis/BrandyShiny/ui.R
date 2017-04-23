##############################################
###  Data Science Bootcamp 9               ###
###  Project 1 - Exploratory Visualization ###
###  Brandy Freitas  / April 23, 2017      ###
###     Trends in Risk Behavior in NYC     ###
###           Teens from 2001-2015         ###
##############################################

shinyUI(dashboardPage(
  dashboardHeader(title = "Risk Behavior in Teens"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Basic Information", tabName = "map_leaf", icon = icon("map-o")),
      menuItem("Drug Use", tabName = "drug", icon = icon("glass")),
      menuItem("Depression", tabName = "suicide", icon = icon("meh-o")),
      menuItem("Obesity", tabName = "obesity", icon = icon("heartbeat")),
      menuItem("Explore the Table", tabName = "data", icon = icon("newspaper-o")),
      menuItem("About This App", tabName = "about", icon = icon("info")))
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map_leaf",
              leafletOutput("leaflet_map"),
              box(title = "Overview of Racial Demographics in the Five Boroughs", status = "info", width = 12,
                  tags$p("According to the 2010 US Census, the breakdown of race in the five boroughs is as follows:"),
                  tags$i("Manhattan: 48% White, 13% Black, 11% Asian, 25% Hispanic"),
                  tags$br(),
                  tags$i("Brooklyn: 36% White, 32% Black, 10% Asian, 20% Hispanic"),
                  tags$br(),
                  tags$i("Queens: 28% White, 18% Black, 23% Asian, 28% Hispanic"),
                  tags$br(),
                  tags$i("Bronx: 11% White, 30% Black, 3% Asian, 54% Hispanic"),
                  tags$br(),
                  tags$i("Staten Island: 64% White, 10% Black, 7% Asian, 17% Hispanic"),
                  tags$br(),
                  tags$br(),
                  tags$b("Click the markers on this map above to see the racial distribution among teens going to school in the five boroughs."))),
      tabItem(tabName = "drug",
              h2("Drug Use Over Time by Boro"),
              fluidRow(
                column(width = 12,
                  box(status = 'info',
                    selectInput(inputId = "drugChoice",
                                label = "Select drug",
                                choices = c("Marijuana", "Cocaine", "Heroin", "Meth", "Molly"),
                                selected = "Marijuana"), width = NULL),
                  box(status = 'primary',
                    plotOutput("drugPlot"), width = NULL
                  ),
                  box(status = "warning",
                      tags$b("For reference:"),
                      tags$i("The CDC reports the following trends in teen drug use nationally from 2001-2015:"),
                      tags$br(),
                      tags$ul(
                        tags$li("Marijuana: Decreased"), 
                        tags$li("Heroin: Decreased"), 
                        tags$li("Ecstasy (Molly): No change"),
                        tags$li("Methamphetamines (Meth): Decreased"), 
                        tags$li("Cocaine: Decreased")), 
                      width = NULL)
                ))),
      tabItem(tabName = "suicide",
              h2("Suicidal Ideation by Gender and Boro Over Time"),
              fluidRow(
                column(width = 12,
                       box(status = 'info',
                         selectInput(inputId = "yearChoose",
                                     label = "Select Year",
                                     choices = c('2003', '2005', '2007', '2009', '2011', '2013', '2015'),
                                     selected = '2003'), width = NULL),
                       box(status = 'primary',
                         plotOutput("sadPlot"), width = NULL),
                       box(status = "warning",
                           tags$b("For reference:"),
                           tags$i("The National Suicide Prevention Reasource Center estimates that 3.7% of the US Population
                                  have suicidal thoughts, and 0.5% attempt suicide every year"), width = NULL
                           ),
                       box(status = 'info',
                         selectInput(inputId = "sexChoice",
                                     label = "Select Gender",
                                     choices = c('Male', 'Female'),
                                     selected = 'Male'), width = NULL),
                       box(status = 'primary',
                         plotOutput("sexPlot"), width = NULL)
                       ))),
      tabItem(tabName = "obesity",
              h2("Obesity by Grade Level and Boro Over Time"),
              fluidRow(
                column(width = 12,
                       box(status = 'info',
                         selectInput(inputId = "yearChoice",
                                     label = "Select Year",
                                     choices = c('2003', '2005', '2007', '2009', '2011', '2013', '2015'),
                                     selected = '2003'), width = NULL),
                       box(status = 'primary',
                         plotOutput("gradePlot"), 
                         width = NULL),
                       box(status = 'warning',
                         tags$b("For reference"),
                         tags$br(),
                         tags$p("According to the CDC, a teen is considered overweight with a BMI of 21-25, and
                                obese above 26. Also, please note that this analysis focuses on the mass of the distribution, not the tails."),
                         tags$a(href="https://nccd.cdc.gov/dnpabmi/Calculator.aspx",
                                "CDC: BMI Percentile Calculator for Child and Teen"), 
                         width = NULL
                       )
                ))),
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"), width = 12))),
      tabItem(tabName = "about",
              box(title = "About this App", status = 'info', width = 12,
                  tags$p("This app explores NYC Teen Youth Risk Behavior Survey data from the CDC from 2003 to 2015.
                         It attempts to elucidate trends in behavior over time of our changing population."),
                  tags$b("About the Youth Risk Behavior Survey:"),
                  tags$p("The national Youth Risk Behavior Survey (YRBS) monitors what the CDC refers to as priority health risk behaviors 
                         that contribute to death, disability and social problems among teens and adults."),
                  tags$b("How is the Study Given?"),
                  tags$p("The study is conducted by the CDC once every two years in the Spring. A representative group of 
                         9th through 12th grade students in public and private schools from urban and rural areas are included. 
                         The survey is anonymous, and data and trend reports are published on the CDC's website."),
                  tags$a(href = "https://www.cdc.gov/healthyyouth/data/yrbs/data.htm",
                         "Data & Documentation"),
                  tags$p("Questions on the survey are typically asked in the following manner:"),
                  tags$p("During the past 30 days, how many times did you ride in a car or other vehicle driven by
                         someone who had been drinking alcohol?"),
                  tags$ul(
                      tags$li("A. 0 times"),
                      tags$li("B. 1 time"),
                      tags$li("C. 2 or 3 times"),
                      tags$li("D. 4 or 5 times"),
                      tags$li("E. 6 or more times")),
                  tags$b("Motivation of this App:"),
                  tags$p("I was interested in studying this survey originally as a way to challenge some of my own 
                         preconcieved notions about the teens of NYC today. I find myself very interested in answering 
                         questions about how inequalities in health, safety, and education affect our youth. Unpacking 
                         this data, analyzing trends, and distributing the information in an accesible way will give 
                         us a better understanding of the youth in our communitites, their issues, and point us toward 
                         ways we can help them."),
                  tags$b("Data Acquisition and Filtering:"),
                  tags$p("Data on youth behavior was downloaded in ASCII format from the YRBS's website, and converted 
                         to CSV using an SPSS script and IBM's SPSS software package. Using R, data were filtered based 
                         on location (specfically the five NYC boroughs) and cleaned up to remove missing values in key 
                         variable columns (grade, age, sex, etc). The data was also recoded to make it easier to understand, 
                         as most of the variables included were coded for simplicity (ie, 1 = Female, 2 = Male). Data analyzed 
                         consisted of about 60,000 rows and 200 variables. I chose to focus on questions related to weight, 
                         eating habits, drug use, and depression. In the future, I would like to dive deeper into related 
                         trends in that data, especially those around violence, safety concerns, and their link to depression 
                         and drug use.")
                  
          )
        )  
    )
  )
))