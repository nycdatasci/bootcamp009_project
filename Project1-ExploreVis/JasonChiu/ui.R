library(shinydashboard)

dashboardPage(skin = "red",
  dashboardHeader(title = "Healthcare Quality and Community Health",
                  titleWidth = 450),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Cities and Hospital", tabName = "cities", icon = icon("map")),
      menuItem("Quality and Community Health", tabName = "quality", icon = icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "cities",
        fluidRow(
          box(title = "Criteria",
            sliderInput("insurance", "Health Insurance Coverage %:", min = 0, max = 96, value = 0, step= 1),
            sliderInput("checkup","Health Routine Checkup %", min = 0, max = 83, value = 0, step = 1),
            sliderInput("chol","High Cholesterol Screening %", min = 0, max = 84, value = 0, step = 1),
            sliderInput("elderly","% of Elderly Men Up to Date with Preventative Care", min = 0, max = 49, value = 0, step = 1),
            sliderInput("elderlyf","% of Elderly Women Up to Date with Preventative Care", min = 0, max = 44, value = 0, step = 1),
            sliderInput("breast","Breast Cancer Screening %", min = 0, max = 85, value = 0, step = 1),
            sliderInput("cervical","Cervical Cancer Screening %", min = 0, max = 88, value = 0, step = 1),
            sliderInput("binge","Binge Drinking %", min = 0, max = 26, value = 0, step = 1),
            sliderInput("smoking","Smoking %", min = 0, max = 31, value = 0, step = 1),
            sliderInput("exercise","No Exercise %", min = 0, max = 40, value = 0, step = 1),
            sliderInput("obesity","Obesity %", min = 0, max = 39, value = 0, step = 1),
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
          )
        )
      ),
      tabItem(
        tabName = "quality",
        fluidRow(
          box(
            title = "Health Indicators",
            selectInput("y-value","Select the health indicator of interest",
                        choices=c("Healthcare Access", "Routine Doctor Checkup","Cholesterol Screening",
                                  "Colorectal Cancer Screening","Preventative Care among Elderly (Men)",
                                  "Preventative Care among Elderly (Women)","Breast Cancer Screening",
                                  "Cervical Cancer Screening","Binge Drinking","Smoking","No Exercise",
                                  "Obesity","Insufficient Sleep")),
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