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
    ggplot(top_10, aes(x= Country, y= Number_of_Attacks)) + geom_col() +
      ggtitle("Top 10 Shark Attacks by Country") + theme_solarized() + scale_fill_solarized()
    
  })
  
  output$activity = renderPlot({
    ggplot(act, aes(Activity, Attacked_activity)) + geom_col(aes(fill=Activity)) + ggtitle("Attacks by Activity") +
      theme_stata() + scale_fill_stata()
    
  })
  
  output$Type_attack = renderPlot({
    r = ggplot(type_attack, aes(x =Type, y=count, fill=Type)) + geom_col()
    r + coord_flip() + ggtitle("Nature of Attack")
    r + theme_economist() + scale_fill_economist()
    
  })
  
  output$Fatal_Activity = renderPlot({
    ggplot(fatal_act, aes(x=Activity, y= Most_fatal, fill=Activity)) + geom_col(aes(color=Activity)) + ggtitle('Fatal Attacks by Type of Activity')
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
  
  
  outlier = reactive({
    switch(input$go,
           '1' = "Attempting to kill a shark with explosives",
           '2'= "Washing horses",
           '3' = 'Suicide',
           '4'= 'Defecating in water beneath the docks',
           '5'= 'Surfing on air mattress',
           '6'= 'Bathing with sister',
           '7' = 'Dynamite fishing')
  })
  
  output$text1 = renderPrint({
    outlier()
    
  })
  
  
}

  


