library(shinydashboard)

dashboardPage(skin = "red",
  dashboardHeader(title = "Healthcare Quality and Community Health",
                  titleWidth = 450),
  dashboardSidebar(
    sidebarMenu(
<<<<<<< HEAD
      menuItem("Cities and Hospital", tabName = "cities", icon = icon("map")),
      menuItem("Quality and Community Health", tabName = "quality", icon = icon("th"))
=======
      menuItem("Hospital Overview", tabName = "hospital", icon = icon("hospital-o")),
      menuItem("Prevention", tabName = "Prevention", icon = icon("map")),
      menuItem("Health Behavior", tabName = "Health", icon = icon("map")),
      menuItem("Disease Prevalence", tabName = "Disease", icon = icon("map")),
      menuItem("Quality and Community Health", tabName = "quality", icon = icon("plus-square "))
>>>>>>> ef6b0d9d111f070a260be6500e4502ce5e9d1e6a
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
<<<<<<< HEAD
        tabName = "cities",
        fluidRow(
          box(title = "Criteria",
=======
        tabName = "Prevention",
        fluidRow(
          box(title = "Preventative Indicators",
>>>>>>> ef6b0d9d111f070a260be6500e4502ce5e9d1e6a
            sliderInput("insurance", "Health Insurance Coverage %:", min = 0, max = 96, value = 0, step= 1),
            sliderInput("checkup","Health Routine Checkup %", min = 0, max = 83, value = 0, step = 1),
            sliderInput("chol","High Cholesterol Screening %", min = 0, max = 84, value = 0, step = 1),
            sliderInput("elderly","% of Elderly Men Up to Date with Preventative Care", min = 0, max = 49, value = 0, step = 1),
            sliderInput("elderlyf","% of Elderly Women Up to Date with Preventative Care", min = 0, max = 44, value = 0, step = 1),
<<<<<<< HEAD
            sliderInput("breast","Breast Cancer Screening %", min = 0, max = 85, value = 0, step = 1),
            sliderInput("cervical","Cervical Cancer Screening %", min = 0, max = 88, value = 0, step = 1),
=======
            width = 4),
          box(leafletOutput("map"),
              width = 8
              ),
          box(
            checkboxGroupInput("checkGroup", label = "Average Hospital Star Rating", 
                               choices = c("1 Star" = 1, "2 Stars" = 2, "3 Stars" = 3, "4 Stars" = 4, "5 Stars" = 5),
                               inline = TRUE, selected = c(1,2,3,4,5)),
            selectInput("graph_v",label = "Select mean or median hospital rating",choices = c("Mean","Median"),selected = "Mean")
          )
          )
        ),
      tabItem(
        tabName = "Health",
        fluidRow(
          box(title = "Health Behaviors",
            width = 3,
>>>>>>> ef6b0d9d111f070a260be6500e4502ce5e9d1e6a
            sliderInput("binge","Binge Drinking %", min = 0, max = 26, value = 0, step = 1),
            sliderInput("smoking","Smoking %", min = 0, max = 31, value = 0, step = 1),
            sliderInput("exercise","No Exercise %", min = 0, max = 40, value = 0, step = 1),
            sliderInput("obesity","Obesity %", min = 0, max = 39, value = 0, step = 1),
<<<<<<< HEAD
            sliderInput("sleep","Insufficient Sleep %", min = 0, max = 52, value = 0, step = 1),
            width = 2
          ),
          box(
            checkboxGroupInput("checkGroup", label = "Average Hospital Star Rating", 
                               choices = list("1 Star" = 1, "2 Stars" = 2, "3 Stars" = 3, "4 Stars" = 4, "5 Stars" = 5),
                               inline = TRUE, selected = c(1,2,3,4,5))
          ),
          box(
            leafletOutput("map"),
            textOutput("number"),
            width = 9
=======
            sliderInput("sleep","Insufficient Sleep %", min = 0, max = 52, value = 0, step = 1)),
          box(
            leafletOutput("map_h"),
            width = 9,
            checkboxGroupInput("checkGroup1", label = "Average Hospital Star Rating", 
                               choices = list("1 Star" = 1, "2 Stars" = 2, "3 Stars" = 3, "4 Stars" = 4, "5 Stars" = 5),
                               inline = TRUE, selected = c(1,2,3,4,5)),
            selectInput("graph_v1",label = "Select mean or median hospital rating",choices = c("Mean","Median"),selected = "Mean")
>>>>>>> ef6b0d9d111f070a260be6500e4502ce5e9d1e6a
          )
        )
      ),
      tabItem(
<<<<<<< HEAD
=======
        tabName = "Disease",
        fluidRow(
          box(
            title = "Disease Prevalence",
            sliderInput("hbp","High Blood Pressure Prevalence", min = 0, max = 52, value = 0, step = 1),
            sliderInput("cancer","Cancer Prevalence", min = 0, max = 10, value = 0, step = 1),
            sliderInput("asthma","Asthma Prevalence", min = 0, max = 15, value = 0, step = 1),
            sliderInput("chd","Coronary Heart Disease Prevalence", min = 0, max = 10, value = 0, step = 1),
            sliderInput("copd","Chronic Obstructive Pulmonary Disease Prevalence", min = 0, max = 12, value = 0, step = 1),
            sliderInput("dia","Diabetes Prevalence", min = 0, max = 21, value = 0, step = 1),
            sliderInput("hc","High Cholesterol Prevalence", min = 0, max = 45, value = 0, step = 1),
            sliderInput("mh","Mental Health Prevalence", min = 0, max = 19, value = 0, step = 1),
            sliderInput("stk","Stroke Prevalence", min = 0, max = 7, value = 0, step = 1),
            width=3),
          box(
            leafletOutput("map_d"),
            width = 9,
            checkboxGroupInput("checkGroup2", label = "Average Hospital Star Rating", 
                               choices = c("1 Star" = 1, "2 Stars" = 2, "3 Stars" = 3, "4 Stars" = 4, "5 Stars" = 5),
                               inline = TRUE, selected = c(1,2,3,4,5)),
            selectInput("graph_v2",label = "Select mean or median hospital rating",choices = c("Mean","Median"),selected = "Mean")
          )
          )
        ),
      tabItem(
>>>>>>> ef6b0d9d111f070a260be6500e4502ce5e9d1e6a
        tabName = "quality",
        fluidRow(
          box(
            title = "Health Indicators",
            selectInput("y-value","Select the health indicator of interest",
                        choices=c("Healthcare Access", "Routine Doctor Checkup","Cholesterol Screening",
                                  "Colorectal Cancer Screening","Preventative Care among Elderly (Men)",
                                  "Preventative Care among Elderly (Women)","Breast Cancer Screening",
                                  "Cervical Cancer Screening","Binge Drinking","Smoking","No Exercise",
<<<<<<< HEAD
                                  "Obesity","Insufficient Sleep")),
=======
                                  "Obesity","Insufficient Sleep","High Bloodpressure Prevalence",
                                  "Cancer Prevalence", "Asthma Prevalence","Coronary Heart Disease Prevalence",
                                  "Chronic Obstructive Pulmonary Disease Prevalence","Diabetes Prevalence", 
                                  "High Cholesterol", "Mental Health Condition Prevalence","Stroke Prevalence")),
>>>>>>> ef6b0d9d111f070a260be6500e4502ce5e9d1e6a
            width = 3
          ),
          box(
            plotOutput("boxplot"),
            width = 9
          ),
          box(
            title = "Health Indicators based on Hospital Ownership Type",
            plotOutput("boxplot_by_owner"),
            width = 12
          )
        )
      )
    )
  )
)