library(ggplot2)

shinyServer <- function(input, output) {
  output$map = renderGvis({
    gvisGeoChart(Country_attacks, locationvar="Country", 
                 colorvar="Number_of_Attacks",
                 options=list(projection="kavrayskiy-vii",
                              width=500,
                              height=500))
    
  })
  
  output$graph = renderPlot({
    ggplot(top_10, aes(x= Country, y= Number_of_Attacks, fill=Country)) + geom_col(position= 'dodge') +
      ggtitle("Top 10 Shark Attacks by Country")

    
  })
  
  output$activity = renderPlot({
    ggplot(act, aes(Activity, Attacked_activity)) + geom_col(aes(fill=Activity)) + ggtitle("Attacks by Activity")
    
  })
  
  output$Type_attack = renderPlot({
    r = ggplot(type_attack, aes(x =Type, y=count, fill=Type)) + geom_col()
    r + coord_flip() + ggtitle("Nature of Attack")
    
  })
    

  
  scatter_input = reactive({
    
    switch(input$attack_type,
           "All Attacks"= all_year,
           "Fatal Attacks"= all_fatal,
           "Non-Fatal Attacks"= all_nonfatal
    )  }
  )

  output$scatter_all = renderPlot({
    attack_type = scatter_input()
    ggplot(attack_type, aes(x=Year, y=num_Attacks)) + geom_point() + geom_smooth() +
      ggtitle("Fatal vs. Non-Fatal Attacks")
  })

  
  
  }
  


