dashboardPage(
  dashboardHeader(title = "University ROI"),
  dashboardSidebar(
    sidebarMenu(
      #menuitems shown on sidebarMenu
      menuItem("Earnings by City", 
               tabName = "earningsByCity", 
               icon = icon("institution")),
      
      #inputs on sidebarMenu
      selectizeInput("city", "Select a city:",
                     cc100DT$City), 
      
      selectizeInput("name", 
                     "Select a college or university:",
                     univDT_Cut$Name),
      
      menuItem("Salary Range, by University", 
               tabName = "datatable", 
               icon = icon("institution")),
      
      menuItem("Salary, ROI by City", 
               tabName = "datatable1", 
               icon = icon("institution")),
      
      menuItem("Earnings in the US", 
               tabName = "earnings", 
               icon = icon("map-o")),
      
      menuItem("University Location",
               tabName = "univMenu",
               icon = icon("map-o")),

      menuItem("STEM by ROI", 
               tabName = "StemDegrees", 
               icon = icon("institution")),
      
      menuItem("Private Tuition by ROI", 
               tabName = "private", 
               icon = icon("institution")),
      
      menuItem("Research Institute Ranking", 
               tabName = "ResearchUniv", 
               icon = icon("institution"))
      )
            ),
  #boxplots showing earnings by university
  dashboardBody(
    tabItems(
      tabItem(tabName = "earningsByCity",
          fluidRow(
                box(title = "Private Tuition by Private ROI", 
                    status = "primary", 
                    solidHeader = TRUE,
                    collapsible = FALSE, 
                    plotOutput("boxy2"),
                    width = '100%'
                )
              )
      ),
     #map showing university locations in the US
     tabItem(tabName = "univMenu",
             fluidRow(
               box(title = "Locations of US Universities",
                   status = "primary",
                   solidHeader = TRUE,
                   collapsible = FALSE,
                   leafletOutput("mapy2"),
                   width = '100%'
                     )
                   )
             ),
  #map showing difference in salary for one-year (BA-HS)
  tabItem(tabName = "earnings",
          fluidRow(
            box(title = "Annual salary difference by geography (BA - HS)", 
                status = "primary", 
                solidHeader = TRUE,
                collapsible = FALSE, 
                leafletOutput("mapy3"),
                width = '100%'
            )
          )
  ),
  #table showing salary range by university
  tabItem(tabName = "datatable",
          fluidRow(
            box(title = "Salary Range, by University", 
                status = "primary", 
                solidHeader = TRUE,
                collapsible = FALSE, 
                dataTableOutput("datatable"),
                width = '100%'
            )
          )
  ),
  #table showing average salary, roi for many universities in a city
  tabItem(tabName = "datatable1",
          fluidRow(
            box(title = "Average Salary (1 Yr), Return on Investment (20 Yrs)", 
                status = "primary", 
                solidHeader = TRUE,
                collapsible = FALSE, 
                dataTableOutput("datatable1"),
                width = '100%'
            )
          )
  ),
    #boxplot showing earnings by university
    tabItem(tabName = "private",
            fluidRow(
              box(title = "Earnings, by University", 
                  status = "primary", 
                  solidHeader = TRUE,
                  collapsible = FALSE, 
                  plotOutput("boxy3"),
                  width = '100%'
              )
            )
    ),
  #boxplot showing share of stem degrees by private ROI
  tabItem(tabName = "StemDegrees",
          fluidRow(
            box(title = "Share of stem degrees by Private ROI", 
                status = "primary", 
                solidHeader = TRUE,
                collapsible = FALSE, 
                plotOutput("boxy4"),
                width = '100%'
            )
          )
  ), 
  #boxplot showing research universities by private ROI
  tabItem(tabName = "ResearchUniv",
          fluidRow(
            box(title = "University Research Ranking by Private ROI (List: wikipedia.org/wiki/List_of_research_universities_in_the_United_States)", 
                status = "primary", 
                solidHeader = TRUE,
                collapsible = FALSE, 
                plotOutput("boxy6"),
                width = '100%'
            )
          )
  ) 

    )
  )
)