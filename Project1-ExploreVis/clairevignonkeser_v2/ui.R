library(shinydashboard)

Agegroup = sort(unique(df$agegroup))
Gender = unique(df$gender)
Dayofweek = unique(df$dayofweek)
Startstationname = sort(unique(df$start.station.name))
Stopstationname = sort(unique(df$end.station.name))
Startrange = unique(df$startrange)

shinyUI(dashboardPage(
  dashboardHeader(title = 'CitiTinder'),
  
  #sidebar content
  dashboardSidebar(
    sidebarUserPanel(
      "Claire Vignon Keser",
      image = 'picture.png'),
    
    sidebarMenu(
      menuItem("Background & Data Analysis", tabName = "intro", icon = icon("book")),
      menuItem("Step 1- When", tabName = "when", icon = icon("calendar-times-o")),
      menuItem("Step 2- Where", tabName = "where", icon = icon("map-marker")),
      menuItem("Step 3- How", tabName = "how", icon = icon("map-signs")),
      menuItem("Woulda, Shoulda, Coulda", tabName = "wouldcouldshould", icon = icon("spinner"))
    )
  ),
  
  # body content
  dashboardBody(
    
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    
    tabItems(
      tabItem(tabName = "intro",
              wellPanel(fluidRow(
                column(6,
                  h1("Using NYC Citi Bike Data to Help Bike Enthusiasts Find their Mate"),
                  br(),
                  p("There is no shortage of analyses on the NYC bike share system. 
                     Most of them aim at predicting the demand for bikes and balancing bike stock, 
                     i.e forecasting when to remove bikes from fully occupied stations, and refill 
                     stations before the supply runs dry.", 
                     style= "font-size: 18px"),
                  br(),
                  p("This is why I decided to take a different approach and use the Citi Bike data 
                     to help its users instead.",
                    style= "font-size: 18px")),
                column(6,
                  img(src = 'https://d21xlh2maitm24.cloudfront.net/nyc/day-passes.png?mtime=20170331123924', 
                      width=450, height=300, alt="Citi Bike couple")))),

              wellPanel(fluidRow(
                column(6,
                  img(src = 'http://images2.miaminewtimes.com/imager/citi-bike-launches-in-miami-this-saturday/u/original/6505436/citibike_wynwood_colorful.jpg', 
                        width=450, height=300, alt="Citi Bike couple with graffiti in bg")),
                column(6,
                  h2("The Challenge"),
                  br(),
                  p("The online dating scene is complicated and unreliable: 
                      there is a discrepancy between what online daters say and what they do. 
                      Although this challenge is not relevant to me anymore - I am married - I wished that, as a bike enthusiast, 
                      I had a platform where I could have spotted like-minded people who did ride a bike (and not just pretend they did).", 
                      style= "font-size: 18px"),
                  br(),
                  p("The goal of this project was to turn the Citi Bike data into an app where a rider could identify the best 
                      spots and times to meet other Citi Bike users and cyclists in general.", 
                      style= "font-size: 18px")))),

              wellPanel(fluidRow(
                column(6,
                  h2("The Data"),
                  br(),
                  p("As of March 31, 2016, the total number of annual subscribers was 163,865, and Citi Bike 
                    riders took an average of 38,491 rides per day in 2016 (source:" ,a("wikipedia)", href= "https://en.wikipedia.org/wiki/Citi_Bike", target="_blank"), 
                  p("This is more than 14 million rides in 2016!", style= "font-size: 18px"), style= "font-size: 18px"),
                  br(),
                  p("I used the Citi Bike data for the month of May 2016 (approximately 1 million observations). Citi Bike provides 
                    the following variables:",style= "font-size: 18px"),
                  tags$div(tags$ul(
                    tags$li(tags$span("Trip duration (in seconds)")), 
                    tags$li(tags$span("Timestamps for when the trip started and ended")), 
                    tags$li(tags$span("Station locations for where the trip started and ended (both the names and coordinates)")),
                    tags$li(tags$span("Rider’s gender and birth year - this is the only demographic data we have.")),
                    tags$li(tags$span("Rider’s plan (annual subscriber, 7-day pass user or 1-day pass user)")),
                    tags$li(tags$span("Bike ID"))), style= "font-size: 18px")),
                column(6,
                  img(src = 'http://www.streetsblog.org/wp-content/uploads/2014/04/nycbikeshare_journeys.png', 
                      width=450, height=600, alt="Citi Bike Map")))),

              wellPanel(fluidRow(
                column(6,
                  plotOutput('histogram')),
                column(6,
                  h2("Riders per Age Group"),
                  br(),
                  p("Before moving ahead with building the app, I was interested in exploring the data and identifying patterns in relation 
                      to gender, age and day of the week. Answering the following questions helped identify which variables influence 
                      how riders use the Citi Bike system and form better features for the app:" ,style= "font-size: 18px"),
                    tags$div(tags$ul(
                    tags$li(tags$span("Who are the primary users of Citi Bike?")), 
                    tags$li(tags$span("What is the median age per Citi Bike station?")), 
                    tags$li(tags$span("How do the days of the week impact biking behaviours?"))), style= "font-size: 18px"), 
                  p("As I expected, based on my daily rides from Queens to Manhattan, 75% of the Citi Bike trips are taken by males. 
                      The primary users are 25 to 24 years old.", 
                      style= "font-size: 18px")))),

              wellPanel(fluidRow(
                column(6,
                  h2("Distribution of Riders per Hour of the Day (weekdays)"),
                  br(),
                  p("However, while we might expect these young professionals to be the primary users during the weekdays around 8-9am and 5-6pm 
                    (when they commute to and from work), and the older audience to take over the Citi Bike system midday, this hypothesis 
                    proved to be wrong. The tourists didn’t have anything to do with it; the short term customers only represent 10% of the dataset.",
                    style= "font-size: 18px")),
                column(6,
                  plotOutput('histogram_hourofday')))),

              wellPanel(fluidRow(
                column(6,
                  plotOutput('medianage')),
                column(6,
                    h2("Median Age per Departure"),
                    br(),
                    p("Looking at the median age of the riders for each station departure, we see the youngest riders 
                      in East Village, while older riders start their commute from Lower Manhattan. The age trends disappear 
                      when mapping the station arrival, above all in the financial district (in Lower Manhattan), which is 
                      populated by the young wolves of Wall Street.", style= "font-size: 18px"),
                    br(),
                    p("The map shows and confirms that the Citi Bike riders are mostly 
                      between 30 and 45 years old.", style= "font-size: 18px")))),

              wellPanel(fluidRow(
                column(6,
                  h2("Rides by Hour of the Day"),
                  br(),
                  p("Finally, when analyzing how the days of the week impact biking behaviours, I was surprised to see that Citi Bike users 
                    didn’t ride for a longer period of time during the weekend. However, there is a difference in peak hours; 
                    during the weekend, riders hop on a bike later during the day, with most of the rides happening midday while the peak 
                    hours during the weekdays are around 8-9am and 5-7pm when riders commute to and from work.",
                    style= "font-size: 18px")),
                column(3,
                  plotOutput('weekdays')),
                column(3,
                  plotOutput('weekends')))),

            wellPanel(fluidRow(
                column(6,
                    img(src = 'https://d21xlh2maitm24.cloudfront.net/nyc/The-Citi-Bike-App.png?mtime=20160420165732', 
                      width=450, height=233, alt="Citi Bike couple")),
                column(6,
                  h2("The App"),
                    br(),
                    strong("Where does this analysis leave us?",
                    style= "font-size: 18px"),
                    tags$div(tags$ul(
                    tags$li(tags$span("The day of the week and the hour of the day are meaningful variables which we need to take into account in the app. ")), 
                    tags$li(tags$span("Most of the users are between 30 and 45 years. This means that the age groups 25-34 and 35-44 
                                      won’t be granular enough when app users need to filter their search. We will let them filter by age instead."))), 
                    style= "font-size: 18px"),  
                    br(),
                    p("Head to the first step of the app to get started!",
                    style= "font-size: 20px"))))),
              
      tabItem(tabName = 'when',
              fluidRow(
                box(title = h3("Step 1- Find the best day and time of the day"),
                    plotlyOutput('heatmap', height = 600),
                    width = 8),
                box(
                  title = 'Filter your search',
                  selectInput(inputId = 'gender_heatmap', 
                              label = 'Gender:', 
                              choices = Gender, 
                              selected = Gender[1]),
                  selectInput(inputId = 'agegroup_heatmap', 
                              label = 'Age:', 
                              choices = Agegroup, 
                              selected = Agegroup[1]),
                  width = 4
                )
              )
      ),
      
      tabItem(tabName = "where",
              fluidRow(
                box(title = h3('Step 2- Locate the most concentrated areas'),
                    leafletOutput('tile', height = 600),
                    width = 8),
                box(
                  title = 'Filter your search',
                  selectInput(inputId = 'gender_tile', 
                              label = 'Gender:', 
                              choices = Gender, 
                              selected = Gender[1]),
                  sliderInput(inputId = "age_tile", 
                              label = "Age range:", 
                              17, 98, c(17,29)),
                  selectInput(inputId = 'dayofweek_tile', 
                              label = 'Day of week:', 
                              choices = Dayofweek, 
                              selected = Dayofweek[1]),
                  radioButtons(inputId = 'startstop_tile',
                               label = 'Time of day:',
                               choices = c('departing', 'arriving'),
                               inline = TRUE),
                  sliderInput(inputId = "time_tile", 
                              label = "", 
                              0, 24, c(6,10)),
                  width = 4
                )
              )
      ),
      
      
      tabItem(tabName = "how",
              fluidRow(infoBoxOutput("durationGoogle"),
                       infoBoxOutput("durationCitibike")),
              fluidRow(box(title = h3('Step 3- Plan your ride'),
                           leafletOutput('map', height = 500), 
                           width = 8),
                       
                       box(selectInput(inputId = 'start_map', 
                                       label = 'Departing from:', 
                                       choices = Startstationname, 
                                       selected = Startstationname[1]),
                           selectInput(inputId = 'stop_map', 
                                       label = 'Going to:', 
                                       choices = Stopstationname, 
                                       selected = Stopstationname[1]),
                           selectInput(inputId = 'dayofweek_map',
                                       label = 'Day of week:',
                                       choices = Dayofweek,
                                       selected = Dayofweek[1]),
                           selectInput(inputId = 'startrange_map',
                                       label = 'Leave at (time of the day):',
                                       choices = Startrange,
                                       selected = Startrange[1]),
                            width = 4)
              )),


            tabItem(tabName = "wouldcouldshould",
              wellPanel(fluidRow(
                column(6,
                  h1("Would Have, Should Have, Could Have"),
                    br(),
                    p("This is the first of the four projects from the NYC Data Science Academy Data Science Bootcamp program.
                    With a two-week timeline and only 24 hours in a day, some things gotta give... Below is a quick list of the analysis I
                    could have, would have and should have done if given more time and data:",
                    style= "font-size: 18px"),
                    tags$div(tags$ul(
                    tags$li(tags$span(strong("Limited scope"), ": I only took the data from May 2016. However, I expect the Citi Bike riders 
                                        to behave differently depending on the season, temperature, etc. Besides, the bigger the sample size
                                        the more reliable the insights are.")), 
                    tags$li(tags$span(strong("Missing data"),": There was no data on the docks available per station that could be scraped from the Citi Bike website.
                                      The map would have been more complete if the availability of docks had been displayed.")),
                    tags$li(tags$span(strong("Limited number of variables"),": I would have liked to have more demographics data (aside from gender and age); a dating app
                    with only the age and gender as filters is restrictive...")),
                    tags$li(tags$span("Finally, I would have liked to track unique users. Although users don't have a unique identifier 
                      in the Citi Bike dataset, I could have identified unique users by looking at their gender, age, zip and usual start/end stations."))), 
                    style= "font-size: 18px")),
                column(6,
                    img(src = 'http://www.freetoursbyfoot.com/wp-content/uploads/2014/10/Spring_Lafayette_citibike_opening_jeh.jpg', 
                      width=450, height=500, alt="Citi Bike Free Bike")))))
            ))
            )
)
