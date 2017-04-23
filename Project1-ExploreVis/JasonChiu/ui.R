library(shinydashboard)

dashboardPage(skin = "red",
              dashboardHeader(title = "Healthcare Quality and Community Health",
                              titleWidth = 450),
              dashboardSidebar(
                sidebarMenu(
                  menuItem("Mapping Health Disparities", tabName = "Health", icon = icon("map")),
                  menuItem("Healthcare Quality", tabName = "quality", icon = icon("plus-square ")),
                  menuItem("City Health Profile", tabName = "profile", icon = icon("hospital-o"))
                )
              ),
              dashboardBody(
                tabItems(
                  tabItem(tabName = "Health",
                          box(selectInput("type","Select Health Indicators",choices = c("Health Behavior",
                                                                                        "Disease Prevalence",
                                                                                        "Preventative Care"),
                                          selected = "Preventative Care", selectize = TRUE),
                              conditionalPanel(
                                condition = "input.type == 'Health Behavior'",
                                sliderInput("binge","Binge Drinking %", min = 0, max = 26, value = 0, step = 1),
                                sliderInput("smoking","Smoking %", min = 0, max = 32, value = 0, step = 1),
                                sliderInput("exercise","No Exercise %", min = 0, max = 42, value = 0, step = 1),
                                sliderInput("obesity","Obesity %", min = 0, max = 48, value = 0, step = 1),
                                sliderInput("sleep","Insufficient Sleep %", min = 0, max = 52, value = 0, step = 1)
                                ),
                              conditionalPanel(
                                condition = "input.type == 'Disease Prevalence'",
                                sliderInput("hbp","High Blood Pressure Prevalence", min = 0, max = 48, value = 0, step = 1),
                                sliderInput("cancer","Cancer Prevalence", min = 0, max = 7, value = 0, step = 1),
                                sliderInput("asthma","Asthma Prevalence", min = 0, max = 15, value = 0, step = 1),
                                sliderInput("chd","Coronary Heart Disease Prevalence", min = 0, max = 9, value = 0, step = 1),
                                sliderInput("copd","Chronic Obstructive Pulmonary Disease Prevalence", min = 0, max = 12, value = 0, step = 1),
                                sliderInput("dia","Diabetes Prevalence", min = 0, max = 19, value = 0, step = 1),
                                sliderInput("hc","High Cholesterol Prevalence", min = 0, max = 39, value = 0, step = 1),
                                sliderInput("mh","Mental Health Prevalence", min = 0, max = 19, value = 0, step = 1),
                                sliderInput("stk","Stroke Prevalence", min = 0, max = 6, value = 0, step = 1)
                                ),
                              conditionalPanel(
                                condition = "input.type == 'Preventative Care'",
                                sliderInput("insurance", "Health Insurance Coverage %:", min = 0, max = 96, value = 0, step= 1),
                                sliderInput("checkup","Health Routine Checkup %", min = 0, max = 81, value = 0, step = 1),
                                sliderInput("chol","High Cholesterol Screening %", min = 0, max = 77, value = 0, step = 1),
                                sliderInput("elderly","% of Elderly Men Up to Date with Preventative Care", min = 0, max = 50, value = 0, step = 1),
                                sliderInput("elderlyf","% of Elderly Women Up to Date with Preventative Care", min = 0, max = 45, value = 0, step = 1),
                                sliderInput("breast","Breast Cancer Screening", min = 0, max = 89, value = 0, step = 1),
                                sliderInput("cervical","Cervical Cancer Screening", min = 0, max = 90, value = 0, step = 1)
                                ),
                              width = 4),
                          box(
                            leafletOutput("map"),
                            width = 8
                          ),
                          box(
                            width = 8,
                            checkboxGroupInput("checkGroup", label = "Average Hospital Star Rating", 
                                               choices = c("1 Star" = 1, "2 Stars" = 2, "3 Stars" = 3, "4 Stars" = 4, "5 Stars" = 5),
                                               inline = TRUE, selected = c(1,2,3,4,5)),
                            selectInput("mm",label = "Select mean or median hospital rating",choices = c("Mean","Median"),selected = "Mean"))
                  ),
                  tabItem(
                    tabName = "quality",
                    fluidRow(box(selectInput("type1","Select Health Indicators",
                                             choices = c("Health Behavior",
                                                         "Disease Prevalence",
                                                         "Preventative Care"),
                                             selected = "Preventative Care", 
                                             selectize = TRUE),
                                 conditionalPanel(
                                   condition = "input.type1 == 'Preventative Care'",
                                   selectInput("prevent", "Select Preventative Care Measures", 
                                               choices = c("Health Insurance Coverage",
                                                           "Colorectal Cancer Screening",
                                                           "Preventative Care Coverage among Elderly Men",
                                                           "Preventative Care Coverage among Elderly Women"),
                                               selected = "Health Insurance Coverage", 
                                               selectize = TRUE)),
                                 conditionalPanel(
                                   condition = "input.type1 == 'Disease Prevalence'",
                                   selectInput("disease", "Select Disease Prevalence",
                                               choices = c("High Blood Pressure Prevalence",
                                                           "Asthma Prevalence",
                                                           "COPD Prevalence",
                                                           "Coronary Heart Disease Prevalence",
                                                           "Diabetes Prevalence", 
                                                           "High Cholesterol Prevalence",
                                                           "Mental Health Conditions Prevalence",
                                                           "Stroke Prevalence"), 
                                               selected = "High Blood Pressure Prevalence",
                                               selectize= TRUE)),
                                 conditionalPanel(
                                   condition = "input.type1 == 'Health Behavior'",
                                   selectInput("behavior", "Select Health Behavior",
                                               choices = c("Binge Drinking",
                                                           "Smoking",
                                                           "Insufficient Exercise",
                                                           "Insufficient Sleep"),
                                               selected = "Binge Drinking",
                                               selectize = TRUE))
                        )
                        ),
                    fluidRow(
                      box(plotlyOutput("boxplot")),
                      box(plotlyOutput("density"))
                    )
                        ),
                  tabItem(
                    tabName = "profile",
                    fluidRow(
                      box(
                          selectInput("citystate","Please select a city:",choices = city_list,selectize = T,
                                      selected = "New York, NY"),
                          width = 4),
                      box(
                          h1(textOutput("city_state")),
                          width = 8)
                    ),
                    fluidRow(
                      infoBoxOutput("avg_star"),
                      infoBoxOutput("total"),
                      infoBoxOutput("n_hosp")
                    ),
                    fluidRow(
                      box(plotlyOutput("quality_chart"))
                    )
                  )
                  )
                )
              )