finalmeetups$group_members <- log(finalmeetups$group_members)
finalmeetups$upcoming_meeting_price <- log(finalmeetups$upcoming_meeting_price)
finalmeetups$group_reviews <- log(finalmeetups$group_reviews)
finalmeetups$upcoming_meetings <- log(finalmeetups$upcoming_meetings)
finalmeetups$past_meetings <- log(finalmeetups$past_meetings)
finalmeetups$len_group_descript <- log(finalmeetups$len_group_descript)
finalmeetups$upcoming_meeting_rsvp <- log(finalmeetups$upcoming_meeting_rsvp)

shinyServer(function(input, output){
  finalmeetups$ID <- seq.int(nrow(finalmeetups))
  # ----- Max Box ------
  output$maxBox <- renderInfoBox({
    df_filter <- finalmeetups[finalmeetups$category == input$cat_select & finalmeetups$city == input$city_select,]
    max_value <- max(finalmeetups[finalmeetups$category == input$cat_select & 
                       finalmeetups$city == input$city_select, input$selected],
        na.rm= TRUE)
    tempmax_groupvec <- df_filter$group_name[df_filter[,input$selected] == max_value]
    max_group <- tempmax_groupvec[!is.na(tempmax_groupvec)]
    infoBox(max_group[1], exp(max_value), icon = icon("hand-o-up"))
  })
  # ------ Min Box ------ 
  output$minBox <- renderInfoBox({
    df_filter <- finalmeetups[finalmeetups$category == input$cat_select & finalmeetups$city == input$city_select,]
    min_value <- min(finalmeetups[finalmeetups$category == input$cat_select & 
                                    finalmeetups$city == input$city_select, input$selected],
                     na.rm= TRUE)
    tempmin_groupvec <- df_filter$group_name[df_filter[,input$selected] == min_value]
    min_group <- tempmin_groupvec[!is.na(tempmin_groupvec)]
    infoBox(min_group[1], exp(min_value), icon = icon("hand-o-down"))
  })
  
  output$barcharts <- renderPlot({
    inputvar <- input$selected2
    finalmeetups[complete.cases(finalmeetups[,inputvar]),]  %>% group_by(category) %>% summarise(count =n()) %>% 
      ggplot(aes(x=reorder(category,count), y=count)) + geom_bar(stat="identity", fill ="dark blue") + coord_flip() + 
      ylab(paste("Count", inputvar)) + xlab("Category") + ggtitle(paste("Count", inputvar, "per Category"))
  })
  
  hist1 <- reactive({
    hists_df <- finalmeetups %>% filter(!is.na(input$selected) & city==input$city_select) 
    hists_df
  })
  
  hist2 <- reactive({
    hists_df <- finalmeetups %>% filter(!is.na(input$selected) & city==input$city_select_2)
    hists_df
  })
  # ----- Histogram 1 ------
  output$histogram1 <- renderPlot({
      title <- input$city_select
      ggplot(hist1(), aes_string(x=input$selected)) + geom_histogram(fill='red') +
      xlab(input$selected) + ggtitle(paste("City:", title))
  })
  # ----- Histogram 2----------
  output$histogram2 <- renderPlot({
    title <- input$city_select_2
    ggplot(hist2(), aes_string(x=input$selected)) + geom_histogram(fill='dark green') +
      xlab(input$selected) + ggtitle(paste("City:", title))
  })
  
  output$ttest <- renderPrint({
    city1 <- hist1()
    city2 <- hist2()
    feature <- input$selected
    t_list <- t.test(city1[,feature], city2[,feature], alternative = "two.sided")
    paste("The T-Statistic", round(t_list$statistic, 2))
  })
  output$pvalue <- renderPrint({
    city1 <- hist1()
    city2 <- hist2()
    feature <- input$selected
    t_list <- t.test(city1[,feature], city2[,feature], alternative = "two.sided")
    paste("The P-Value",round(t_list$p.value[1], 30))
  })
  
 
  # -------Leaflet map ----------
  output$map <- renderLeaflet({
    leaflet(finalmeetups %>% filter(upcoming_address != "")) %>% addTiles() %>% 
      setView(lng = -98.583333, lat = 39.833333, zoom = 4 ) %>% addMarkers(clusterOptions = markerClusterOptions())
  })

  meetups <- reactive({

    cat <- input$cat_select2
    x_test <-  input$xvar
    y_test <- input$yvar
    print(x_test)
    print(y_test)
    # Apply filter
    cat_df <- finalmeetups[complete.cases(finalmeetups[,c(input$xvar,input$yvar)]),]
    if (input$cat_select2 != "All") {
      cat_df <- cat_df %>%
        filter(category == cat)
    }
    
    cat_df <- as.data.frame(cat_df)
    print(dim(cat_df))
    cat_df
  })
  
  meetup_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$ID)) return(NULL)
    
    # Pick out the movie with this ID
    all_meetups <- isolate(meetups())
    meetup <- all_meetups[all_meetups$ID == x$ID, ]
    
    paste0("<b>", meetup$group_name, "</b><br>",
           "Group members: ",exp(meetup$group_members), "<br>",
           "City: ", format(meetup$city, big.mark = ",", scientific = FALSE)
    )
  }
  
  # A reactive expression with the ggvis plot
  vis <- reactive({
    # Lables for axes
    xvar_name <- names(choice)[choice == input$xvar]
    yvar_name <- names(choice)[choice == input$yvar]
  
    # Normally we could do something like props(x = ~BoxOffice, y = ~Reviews),
    # but since the inputs are strings, we need to do a little more work.
    xvar <- prop("x", as.symbol(input$xvar))
    yvar <- prop("y", as.symbol(input$yvar))

    meetups %>%
      ggvis(x = xvar, y = yvar) %>%
      layer_points(size := 50, size.hover := 200,
                   fillOpacity := 0.2, fillOpacity.hover := 0.5, fillOpacity.hover := 0.5,
                   stroke := "red",
                   key := ~ID) %>%
      add_tooltip(meetup_tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      add_axis("y", title = yvar_name) %>%
      layer_smooths() %>% 
      set_options(width = 800, height = 600)
  })
  
  vis %>% bind_shiny("plot1")
  
  output$corr <- renderText({ 
    test_df <- meetups()
      cor(x = test_df[,input$xvar], y = test_df[,input$yvar])
    })
  
  
  
})