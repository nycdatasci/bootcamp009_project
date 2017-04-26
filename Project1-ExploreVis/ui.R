library(shiny)
library(shinydashboard)
library(googleVis)
library(leaflet)
library(geojsonio)

shinyUI(dashboardPage(
  dashboardHeader(title = tags$a(href='https://www.airbnb.com',
                                 tags$img(src='https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Airbnb_Logo_Bélo.svg/2000px-Airbnb_Logo_Bélo.svg.png',width="100px",hight="50px"))),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Instruction", tabName = "instruction", icon = icon("sticky-note")),
      menuItem("Neighbourhood vs Room Type", tabName = "fact1", icon = icon("star-o")),
      menuItem("Hot Areas", tabName = "fact2", icon = icon("star-o")),
      menuItem("Popular Host Names", tabName = "fact3", icon = icon("star-o")),
      menuItem("Best Long Term Listings", tabName = "fact4", icon = icon("star-o")),
      menuItem("Red Flag Hosts", tabName = "fact5", icon = icon("star-o")),
      menuItem("Data", tabName = "data", icon = icon("building")),
      menuItem("Source Link", icon = icon("file-code-o"), 
               href = "http://insideairbnb.com")
      )
    ),
     
  dashboardBody(
    tabItems(
      tabItem(tabName = "instruction",
              h1("New York Airbnb Listing Facts"),
              img(src="https://s-media-cache-ak0.pinimg.com/originals/6b/9e/97/6b9e97c4d24cb7ec9893a60f0266fec1.jpg",height="70%", width="70%"),
              p(h4("Any start-up looking to shake up an industry will inevitably face a regulatory thicket, and Airbnb is no different. 
                   The short-term rental company became a Federal Trade Commission target last summer after three senators asked for an investigation into how companies like Airbnb affect soaring housing costs.")),
              p(h4("New York City enacted a new law in October of 2016 that makes it illegal to advertise a short-term rental that is prohibited by the MDL( New York State Multiple Dwelling Law). 
                   This includes listing such rentals on Airbnb and other online short-term rental platforms. 
                   However, A recent study found that over 50% of all units used as private short-term rentals on Airbnb appeared to violate both state and local laws.")),
              p(h4("The tussle is heating up before a possible initial public offering of Airbnb. 
                Airbnb will be ready to go public in a year, and investors estimate its value to be about $30 billion. By comparison, Hilton’s market capitalization is $19 billion, and Marriott’s is $35 billion.")),
              p(h4("The project includes some interesting facts of the New York area Airbnb listing in. The dataset is updated in April 2017."))
              ),
      
      tabItem(tabName = "fact1",
              fluidRow(titlePanel("Listings and Room Type in Different Neighborhoods"),
                       checkboxGroupInput("fact1_1", "Neighbourhood",inline=TRUE,selected=roomtype_neigh$neighbourhood_group,
                                   choices = unique(roomtype_neigh$neighbourhood_group)
                          )),
                fluidRow(plotOutput("fact1_2"),
                         p(h3("The Entire home in Manhattan is more than Private room, which is different than other neighbourhoods."))
                         )
                       ),
      
      tabItem(tabName = "fact2",
              fluidRow(titlePanel("In each neighhourhood, which area has the most listings？"),
                       selectInput("fact2_1", "Neighbourhood", selected = "Manhattan",
                                   choices = unique(roomtype_neigh[, "neighbourhood_group"]))),
              fluidRow(
                column(3,plotOutput("fact2_2")),
                column(12,offset=8,infoBoxOutput("hotareabox"))
                )
              ),
              
     tabItem(tabName = "fact3",
             fluidRow(titlePanel("Does the host with popular name have more chance to rent?"),
                      htmlOutput("top_names"),
                      box(h1("T-test:"), 
                     htmlOutput("text3"),background = "blue",width = 12)
                      )
             ),
     
     tabItem(tabName = "fact4",
             fluidRow(titlePanel("Best Listings: Rent more than 30 days and have good reviews."),
                      p(h3("There are 166 listings that offer long term rent with more than average reviews. The average price is 155 dollars per night.")),
                      leafletOutput("map",width = "100%", height = 800))),
     
     tabItem(tabName = "fact5",
             fluidRow(titlePanel("Are they threatening the local hotel business?"),
                      p(h4("These hosts have more than 3 listings. The amount is 12% of the total listings in New York. Probably they do Airbnb business for living. ")),
                      sliderInput("fact5_1", label = h4("Total Listings"), min = 3, 
                                  max = 32, value = range(multi_list_bnb$count)),
                      leafletOutput("map2",width = "100%", height = 500))),
           
      tabItem(tabName = "data",
             # fluidRow(box(dataTableOutput("table"),width = 20)))
              fluidRow(
                dataTableOutput('table'),width = 20))
      
  ))
))


