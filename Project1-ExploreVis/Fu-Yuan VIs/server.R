shinyServer(function(input, output){
  output$table <- DT::renderDataTable({
    datatable(data,rownames=FALSE, options = list(scrollX= TRUE)) %>% 
      formatStyle(input$selected, background="skyblue", fontWeight='bold')
  })
  
  
  output$delay <- renderPlot({
   
    data %>% group_by_(input$select_dis_1,"loan_F_status") %>% 
      summarise_(Num = interp(~mean(var, na.rm = TRUE),var = as.name(input$select_con_1))) %>%
      ggplot(aes_string(x=input$select_dis_1, y = "Num",fill = "loan_F_status")) + geom_bar(stat = 'identity', position = 'dodge')
    
  })
  output$demograph <- renderPlot({
    
    data %>% filter(year==input$year) %>% group_by(addr_state) %>% summarize(count=n()) %>% 
      merge(states, by.x = "addr_state", by.y = "region", all.y = TRUE) %>% 
      group_by(group) %>%
      arrange(order) %>%
      ungroup() %>%
      mutate(count=na.zero(count))%>%
      ggplot(aes(x = long, y = lat, fill=count)) +
      geom_polygon(aes(group = group))
    
  })
  })
#data %>% group_by(term,loan_F_status) %>% summarise(Num=mean(int_rate)) %>%
 # ggplot(aes(x= term, y = Num, fill =loan_F_status)) + geom_bar(stat = 'identity', position = 'dodge')
#group_by(loan_F_status)
