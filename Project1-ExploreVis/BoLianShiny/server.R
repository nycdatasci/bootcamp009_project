library(shiny)


function(input, output){
  
  # show data using DataTable
  output$table <- DT::renderDataTable({
    datatable(mental, rownames=FALSE,options = list(scrollX = TRUE)) %>% 
      formatStyle(input$selected, background="skyblue", fontWeight='bold',
        pageLength=50, scrollX='400px', filter='top')
  })
  
  output$population <- renderPlot({
    ggplot(data = country_10,aes(x=reorder(country,count), y=count))+
      geom_point(aes(color=country),size=5)+
      coord_cartesian(ylim = c(0, 1000))+coord_flip()+ggtitle("Top 10 Surveyee Countries (Total: 46)")+xlab("Country")+ylab('Number of Surveyees')+geom_text(aes(label=count),size=3,vjust=2.5)
  })
  
  # show map using googleVis
  output$map <- renderGvis({
    gvisGeoChart(state, "state", "surveyee",
                 options=list(region="US", displayMode="regions", 
                              resolution="provinces",
                              width=460, height=380))
  })
  
  output$age <- renderPlot({
    gage+ geom_histogram(aes(y =..density..),bins = 60, fill='green',color='black')+
      geom_density(col=1)+coord_cartesian(xlim = c(15, 75))+
      ggtitle("Surveyee Age")+xlab("Surveyee Age")+ylab('Age Distribution')
    
  }) 
  
  output$agebox <- renderPlot({
    ggplot(data = mental, aes(x= treatment, y= age))+ geom_boxplot()+
      ggtitle("Age and Mental Illness")+xlab("Treatment: Menal Health Condition")+ylab('Surveyee Age')
    
  }) 
  output$comparison <- renderPlot({
    ggplot(data = filter(mental,mental[,input$selected] !='NA'), aes(x= filter(mental,mental[,input$selected] !='NA')[,input$selected]))+ geom_bar(aes(fill= treatment),position= 'dodge',width = 0.2)+ggtitle("X-Factor and Mental Health")+xlab("Treatment: Mental Health Condition")+ylab('Treatment Count')
    
  }) 
  
  output$comparison1 <- renderPlot({
    ggplot(data = filter(mental,mental[,input$selected] !='NA'), aes(x= filter(mental,mental[,input$selected] !='NA')[,input$selected]))+ geom_bar(aes(fill= treatment),position= 'fill',width = 0.2)+ggtitle("X-Factor and Mental Health")+xlab("Treatment: Mental Health Condition")+ylab('Treatment Ratio')
    
  }) 
  
 
  
  # show statistics using infoBox
  output$X_Square<- renderInfoBox({
    a <- as.vector(chisq.test(filter(mental,mental[,input$selected] !='NA')$treatment,filter(mental,mental[,input$selected] !='NA')[,input$selected]))
    infoBox(paste('Chi-Square: '), format(round(a[[1]],2), nsmall=2), icon = icon("times"), color = 'red')
  })
  
  output$DF <- renderInfoBox({
    a <- as.vector(chisq.test(filter(mental,mental[,input$selected] !='NA')$treatment,filter(mental,mental[,input$selected] !='NA')[,input$selected]))
    
    infoBox(paste('D of Freedom: '), a[[2]], icon = icon("arrow-circle-o-up"),color = 'red')
  })

  output$P_Value <- renderInfoBox({
    a <- as.vector(chisq.test(filter(mental,mental[,input$selected] !='NA')$treatment,filter(mental,mental[,input$selected] !='NA')[,input$selected]))
    infoBox(paste('P Value: '), format(a[[3]],scientific = T), icon = icon("calculator"), color = 'red')
})}