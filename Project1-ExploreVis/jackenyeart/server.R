## server.R ##
library(shiny)
library(shinydashboard)
library(ggvis)
library(DT)

shinyServer(function(input, output){
  
########## Accuracy, 1 Variable  
  
  output$mainpage <- renderImage({
    return(list(
      src = "pictures/Sportvu.png",
      contentType = "image/png",
      alt = "sportvu",
      width = 600,
      height = 400
    ))
  }, deleteFile = FALSE)
  
  output$subItemOne <- renderImage({
    if (is.null(input$selected1))
      return(NULL)
    
     if (input$selected1 == "SHOT_DIST") {
      return(list(
        src = "pictures/G1.png",
        contentType = "image/png",
        alt = "G1"
      ))
    } else if (input$selected1 == "SHOOTER_height") {
      return(list(
        src = "pictures/G2.png",
        filetype = "image/png",
        alt = "G2"
      ))
    } else if (input$selected1 == "CLOSE_DEF_DIST") {
      return(list(
        src = "pictures/G3.png",
        filetype = "image/png",
        alt = "G3"
      ))
    }
    
  }, deleteFile = FALSE)
  
  ##### Accuracy, 2 Variables
  
  output$subItemTwo <- renderImage({
    if (is.null(input$selected2a) | is.null(input$selected2b))
      return(NULL)
    
    if (input$selected2a == input$selected2b ) {
      return(NULL)
    } else if (all(sort(c(input$selected2a,input$selected2b)) == c("CLOSE_DEF_DIST","SHOT_DIST"))) {
      return(list(
        src = "pictures/G10.png",
        width = 600,
        height = 400,
        contentType = "image/png",
        alt = "G10"
      ))
    } else if (all(sort(c(input$selected2a,input$selected2b)) == c("SHOOTER_height","SHOT_DIST"))) {
      return(list(
        src = "pictures/G11.png",
        width = 600,
        height = 400,
        filetype = "image/png",
        alt = "G11"
      ))
    } else if (all(sort(c(input$selected2a,input$selected2b)) == c("CLOSE_DEF_DIST","SHOOTER_height"))) {
      return(list(
        src = "pictures/G12.png",
        width = 600,
        height = 400,
        filetype = "image/png",
        alt = "G12"
      ))
    }
    
  }, deleteFile = FALSE)
  
  ######### Frenquency, 1 Variable
  
  output$subItemThree <- renderImage({
    if (is.null(input$selected1))
      return(NULL)
    
    if (input$selected3 == "SHOT_DIST") {
      return(list(
        src = "pictures/G4.png",
        contentType = "image/png",
        alt = "G4"
      ))
    } else if (input$selected3 == "CLOSE_DEF_DIST") {
      return(list(
        src = "pictures/G5.png",
        filetype = "image/png",
        alt = "G5"
      ))
    } else if (input$selected3 == "SHOOTER_height") {
      return(list(
        src = "pictures/G6.png",
        filetype = "image/png",
        alt = "G6"
      ))
    }
    
  }, deleteFile = FALSE)
  
######## Frequency, 2 variables ########  
  
  output$subItemFour <- renderImage({
    if (is.null(input$selected4a) | is.null(input$selected4b))
      return(NULL)
    
    if (input$selected4a == input$selected4b ) {
      return(NULL)
    } else if (all(sort(c(input$selected4a,input$selected4b)) == c("CLOSE_DEF_DIST","SHOT_DIST"))) {
      return(list(
        src = "pictures/G7.png",
        width = 600,
        height = 400,
        contentType = "image/png",
        alt = "G7"
      ))
    } else if (all(sort(c(input$selected4a,input$selected4b)) == c("SHOOTER_height","SHOT_DIST"))) {
      return(list(
        src = "pictures/G8.png",
        width = 600,
        height = 400,
        filetype = "image/png",
        alt = "G8"
      ))
    } else if (all(sort(c(input$selected4a,input$selected4b)) == c("CLOSE_DEF_DIST","SHOOTER_height"))) {
      return(list(
        src = "pictures/G9.png",
        width = 600,
        height = 400,
        filetype = "image/png",
        alt = "G9"
      ))
    }
    
  }, deleteFile = FALSE)
  
#   inter1 <- reactive({
#    input$selected6a
#   })
#   inter2 <- reactive({
#     input$selected6b
#   })
#   
# fdata <- reactive({
#   trimmed1[,c(inter1(),inter2())]
# })  
# gdata = fdata %>%
#         group_by(.,names(fdata)[1]) %>%
#         summarise(.,avg = mean(fdata[2]))
# output$comparative <- renderPlot({
#   str(fdata())
# })

  
  output$ev <- renderImage({
    return(list(
      src = "pictures/EVP.png",
      contentType = "image/png",
      alt = "ev",
      width = 600,
      height = 400
    ))
  }, deleteFile = FALSE)  
  
  output$table <- DT::renderDataTable({
    datatable(topshooters, rownames=FALSE) %>% 
      formatStyle(input$selected7, background="skyblue", fontWeight='bold')
  })
  
})