library(shiny)
library(shinydashboard)
# put some text words
dashboardPage( skin='red',
  dashboardHeader(title = h3("Exloring Mental Health Conditions in Tech Workplace"),titleWidth = 700),
  
  dashboardSidebar(
    
    sidebarUserPanel(h2("Bo Lian"),
                     image = "http://tempemosque.com/wp-content/uploads/2017/02/shutterstock_96612451.jpg"),
    br(),
    
    sidebarMenu(
      menuItem("Project", tabName = "project", icon = icon("eye")),
      br(),
      menuItem("Data", tabName = "data", icon = icon("table")),
      br(),
      menuItem("Surveyee Population", tabName = "population", icon = icon("globe")),
      br(),
      menuItem("Surveyee Age", tabName = "age", icon = icon("users")),
     
      br(),
      menuItem("Treatment: Mental Health", tabName = "treatment", icon = icon("user-md")),

      selectizeInput("selected",
                   "Select a Factor VS 
                    Mental Health",choices= choice1),
      br(),
      menuItem("Conclusions & Future Work", tabName = "con", icon = icon("smile-o")))
    
    ),
  
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    
    
    tabItems(
      
      tabItem(tabName = "project",
              wellPanel(fluidRow(
                column(6,
                       h1("Background and Motivation"),
                       br(),
                       h3('Mental illness: high prevalance & severe health outcomes'),
                       br(),
                       p("One in four adults suffers from a diagnosable mental illness in
                        any given year (National Alliance on Mental Health, 2013). In
                         tech, 50% of individuals have sought treatment for mental illness,
                         according to(Finkler, 2015).", style= "font-size: 20px"),
                       br(),
                       p("Actions has to be taken: the 2014 Mental Health in Tech Survey from Open Sourcing Mental Illness.",
                         style= "font-size: 20px")),
                column(6.6,
                       img(src = 'https://c.tribune.com.pk/2014/10/774345-Mentalhealth-1413136730-603-640x480.JPG', 
                           width=320, height=240)),
                br(),
                column(6,
                       img(src = 'https://d4z6dx8qrln4r.cloudfront.net/image-56d366cb93749-default.png', 
                           width=200, height=200)))),
              
              # fluidRow(tags$iframe(src="", 
              #                      width="480", height="270"))
              
              h2("The Data"),
              br(),
              p("~1300 responses, the 2014 Mental Health in Tech Survey is the largest survey done on mental health in the tech industry.", style= "font-size: 20px"),
              br(),
              h2('27 factors'),
              h3('1. Demographics : age, gender, country, state etc.'),
              h3('2. Mental Health Condition : treatment, work interference, faimily history etc.'),
              h3('3. Employment Background : tech, remote, employee number, size etc.'),
              h3('4. Organizational Policies on Mental Health : benefit, wellness program etc.'),
              h3('5. Openness about Mental Health : self, coworkers, supervisors, openess to discuss.')
              
              ),
      
     
      
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"), width = 12))),
 
      tabItem(tabName = "population", 
             
            fluidRow(box(plotOutput("population"), height = 500),
                        box(h3("States: US Employees"),
                            htmlOutput("map"), height = 500))
         

              ),
      
 
      
      tabItem(tabName = "age",
              fluidRow(box(plotOutput("age"), height = 500),
                       box(plotOutput("agebox"), height = 500) )
              ),
      
      tabItem(tabName = "treatment",
              fluidRow(infoBoxOutput("X_Square"),
                       infoBoxOutput("DF"),
                       infoBoxOutput("P_Value")),
              br(),
              fluidRow(box(plotOutput("comparison"),height = 600),
                           box(plotOutput("comparison1"),height = 600) )
              
              ),
      
      tabItem(tabName = "con", 
            h1('Statistical Results:'),
            br(),
            h2('Significant Factors'),
            h3('gender,familiy history,work interference,benefits,care,interview etc.'),
            br(),
            h2('Insignificant Factors'),
            h3('self_employeed, remote work, no_employees, tech, supervisors etc.'),
            br(),
            h1('Future Work'),
            h3('More Visualization'),
            h3('Complexity,subjectivity, location specifity'),
            h3('Integrating ongoing survey data'),
            h3('Interaction among factors'),
            h3('Prediction with multivariates')
            
      )
      
    
    )
  )
)
