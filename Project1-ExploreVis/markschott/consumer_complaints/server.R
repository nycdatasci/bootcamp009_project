function(input, output, session) {
    
#####################################################
  ########### For the bar plot tab
#####################################################
    grouped_complaints <- reactive ({

        #This is for the bar plots. group_by_ can handle a character as an argument unlike
        # it's un-underscored counterpart.
        # In order to incorporate functionality for the top_n of a primary and secondary variable,
        # I first have to create a list of all the top_n primary variables, and then filter the
        # data frame to include only those ones before doing the top_n function on the secondary 
        # variable. 
        primary_counts = (complaints %>% group_by_(input$primary) %>% 
          summarize(total_count = n()) %>% top_n(as.integer(input$n1)))
        ## Trickery to get the primary to be a vector of characters
        top_n_primaries = as.character(sapply(primary_counts[,input$primary], as.character))
        
        ### Convoluted way to do filter because input variables are characters
        secondary_counts = complaints %>% filter(complaints[,input$primary] %in% top_n_primaries) %>%
          group_by_(input$primary, input$secondary) %>% 
          summarize(Count = n()) %>% top_n(as.integer(input$n2))
        
        ### Now I want to normalize the counts by the primary counts to show the probability of each 
        ### secondary value in the first. These values will be merged into the data frame for easy 
        ### switching back and forth
        ### Repeat the primary_counts by the secondary counts before doing a column bind then mutate
        secondary_counts = inner_join(secondary_counts, primary_counts, by = input$primary)
        secondary_counts = secondary_counts %>% mutate(Probability = round(Count/total_count,4)) %>%
          select(-c(total_count)) %>% arrange(desc(Probability))
        ## Factorize so that they appear nicely in the plot
        #secondary_counts$Probability = factor(secondary_counts$Probability)
    })
    
    output$df <- renderDataTable(
      datatable(grouped_complaints(), filter="top", selection="multiple", escape=FALSE,
                ## Strange arguments to disable global search
                ## Explanation from stack overflow...
                ## The syntax is a bit quirky, but basically the above says that 
                ## f, l, r and t options are to be placed in the top div with the 
                ## i and p options in the bottom div. Please refer to the docs at 
                ## http://legacy.datatables.net/usage/options for a more thorough explanation
                options = list(sDom  = '<"top">lrt<"bottom">ip', sScrollX = '100%'))
    )
    
    ### Legend position for the bar plot
    leg_pos <- eventReactive(input$no_leg, {
      if (input$no_leg) {
        'none' 
      } else {
        'bottom'
      }
    })
    
    observeEvent(input$probs, {
      if(input$probs) {
        ind_var = 'Probability'
        
      } else {
        ind_var = 'Count'
      }
      #grouped_complaints()[,input$primary] = factor((grouped_complaints() %>% arrange_(ind_var))[,input$primary])
        output$bars <- renderPlot(
          ggplot(grouped_complaints(), aes_string(input$primary, ind_var)) +
            geom_bar(stat='identity', aes_string(fill = input$secondary)) +
            theme(axis.text.x = element_text(angle=90, size = 13),
                axis.text.y = element_text(size = 13),
                axis.title = element_text(size = 15),
                legend.position = leg_pos(), legend.title = element_blank(),
                panel.grid.major.y = element_line(color = 'black')) + 
            ggtitle(paste('Counts for',input$primary,'Filled by',input$secondary,collapse = ' '))
    )
    })
    
#################################################
    ### for the Map tab
#################################################
    observe({
      ### Depending on the extra variable chosen, display the corresponding components of that variable
      if (input$map_var == "All") {
        dep_list = ""
      } else { 
        dep_list = sort(unique(complaints[,input$map_var]))
      }
          updateSelectizeInput(
            session, "dep_list",
            choices = dep_list,
          selected = dep_list[1])
    })
    
    filter_dates <- reactive({
      ## Filter out the data frame by the input dates. This is the first level of filtering. 
      complaints %>% filter(Date.received < input$dateRange[2] &
                            Date.received > input$dateRange[1])
    })
    
    event_counts <- reactive({
      filter_dates() %>% group_by_(input$map_var) %>% summarize(event_count = n())
    })
    
    filter_custom_var <- reactive({
      ## Filter data by user input variables. If variable is "All" don't do any filtering, (AKA 
      ## include all variables). This level of filtering is done after the dates.
      if (input$map_var == "All") {
        filter_dates()
      } else {
      filter_dates() %>% filter(filter_dates()[,as.character(input$map_var)] %in% input$dep_list)
      }
    })
    
    plt <- reactive({
      ## Group filtered data frame by the Date.received and compute the counts
      filter_custom_var() %>% group_by(Date.received) %>% summarize(Count = n())
    })
    
    xts_for_TSplot <- reactive({
      ## Create xts object for plotting
      switch(as.integer(input$period),
             apply.daily(xts(plt()$Count, order.by = plt()$Date.received), input$period_func),
             apply.weekly(xts(plt()$Count, order.by = plt()$Date.received), input$period_func),
             apply.monthly(xts(plt()$Count, order.by = plt()$Date.received), input$period_func),
             apply.quarterly(xts(plt()$Count, order.by = plt()$Date.received), input$period_func)
      )
    })
    
    filter_states <- reactive ({
      ## group the filtered data by State and count them for later merging into the SPDF
      ## to display on the map.
      tmp = filter_custom_var() %>% group_by(State, add=TRUE) %>% summarize(count = n())
      
      ### Inner join to get state names and population then compute new normalized counts
      ### by population
      tmp = inner_join(tmp, pops, by = c('State' = 'abbreviation')) %>%
        ### Multiply by a one hundred thousand to avoid fractional people
        mutate(norm_count = round(100000*(count/population_2016)))
      
      ### Drop old columns before adding new ones
      states@data = states@data %>% select(-c(COUNT,NORM_COUNT))
      states@data = full_join(states@data, tmp, by = c('NAME' = 'region'))
      
      ## Drop unneccesary columns and upper case all column names
      states@data = states@data %>% select(-c(State))
      colnames(states@data) = toupper(colnames(states@data))
      states
      
    })
    
    weekday_freq = reactive({
      wdf = filter_custom_var() %>% group_by(Date.received) %>%
        mutate(day = weekdays(Date.received)) %>%
        group_by(day, add = FALSE) %>% summarize(Count = n())
      
      wdf$day = factor(wdf$day, levels = c("Monday","Tuesday","Wednesday","Thursday",
                                           "Friday","Saturday","Sunday"))
      
      wdf[order(wdf$day),]
    })
    
    month_freq = reactive({
      mf = filter_custom_var() %>% group_by(Date.received) %>%
        mutate(month = months(Date.received)) %>%
        group_by(month, add = FALSE) %>% summarize(Count = n())
      
      mf$month = factor(mf$month, levels= c("January", "February", "March", "April", "May", 
                                               "June", "July", "August", "September", "October",
                                            "November","December"))
      
      mf[order(mf$month),]
    })
    
    counts = reactive({
      if (input$normalize) {
        filter_states()$NORM_COUNT
      } else {
        filter_states()$COUNT
      }
    })
    
    html_text = reactive({
      if (input$normalize) {
        "<strong>%s</strong><br/>%g complaints per 100K persons"
      } else {
        "<strong>%s</strong><br/>%g complaints"
      }
    })
    
    legend_title = reactive({
      if (input$normalize) {
        "Complaints per 100K"
      } else {
        "Total Complaints"
      }
    })
      
    output$usmap <- renderLeaflet({
      ## palette to color delay
      pal <- colorNumeric(palette = "viridis", domain = counts(), na.color = "#808080")
      labels <- sprintf(
        html_text(),
        filter_states()$NAME, counts()
      ) %>% lapply(htmltools::HTML)
      
      leaflet(filter_states()) %>% 
        setView(-96, 37.8, 3) %>%
        addTiles() %>%
        addPolygons(
          stroke = FALSE,
          smoothFactor = 0.2,
          color = ~pal(counts()),
          weight = 2,
          dashArray = "3",
          fillOpacity = 4,
          highlight = highlightOptions(
            weight = 5,
            color = "#666",
            dashArray = "",
            fillOpacity = 0.7,
            bringToFront = TRUE),
          label = labels,
          labelOptions = labelOptions(
            style = list("font-weight" = "normal", padding = "3px 8px"),
            textsize = "15px",
            direction = "auto")) %>%
        addLegend("bottomright", pal = pal, values = ~counts(),
                  title = legend_title(),
                  labFormat = labelFormat(prefix = ""),
                  opacity = 1)
    })
    
    output$ts_plot = renderPlot({
      
      # ggplot(counts_for_TSplot(), aes(Date.received, Count)) +
      #   geom_jitter()
    plot(xts_for_TSplot(), type = 'l', main = 'Counts over Time', 
           ylab = 'Count', tick = 1)
    })
      
    output$day_freq = renderPlot({
      
      weekday_freq() %>% ggplot(aes(x=day, y=Count, fill = day)) + 
        geom_bar(stat='identity') + theme(axis.text.x = element_text(angle = 90), 
                                          legend.position = 'none') +
        ggtitle('Counts for each Weekday based on Inputs')
      
    })
    
    output$month_freq = renderPlot({
      
      month_freq() %>% ggplot(aes(x=month, y=Count, fill = month)) + 
        geom_bar(stat='identity') + theme(axis.text.x = element_text(angle = 90),
                                          legend.position='none') +
        ggtitle('Counts for each Month based on Inputs')
      
    })

    ################################
    ## For the mosaic plot tab
    ######################################
    
    observe({
      ### Depending on the extra variable chosen, display the corresponding components of that variable
      mosaic_list1 = sort(unique(complaints[,input$mosaic_var1]))

      updateSelectizeInput(
        session, "mosaic_list1",
        choices = mosaic_list1,
        selected = mosaic_list1[1])
    })
    
    observe({
      ### Depending on the extra variable chosen, display the corresponding components of that variable
      mosaic_list2 = sort(unique(complaints[,input$mosaic_var2]))
      
      updateSelectizeInput(
        session, "mosaic_list2",
        choices = mosaic_list2,
        selected = mosaic_list2[1])
    })

    mosaic_df = reactive({
      ## Filter the data frame to a reasonable amount for the mosaicplot
      complaints %>% select_(input$mosaic_var1, input$mosaic_var2) %>%
        filter(.[,input$mosaic_var1] %in% input$mosaic_list1) %>%
        filter(.[,input$mosaic_var2] %in% input$mosaic_list2) 
    })
    
    output$mosaic = renderPlot({
      ### las = 2 makes the axis labels display perpendicular to the axis
      mosaicplot(table(mosaic_df()), shade = T,  las = 2, main = NULL)
    })
################################
    ## For the word cloud tab
######################################
    
    observe({
      ### Depending on the extra variable chosen, display the corresponding components of that variable
      if (input$wordcloud_var == "All") {
        wc_list = ""
      } else { 
        wc_list = sort(unique(complaints[,input$wordcloud_var]))
      }
      updateSelectizeInput(
        session, "wordcloud_dep_list",
        choices = wc_list
        #selected = dep_list[1]
      )
    })
    
    # Define a reactive expression for the document term matrix
    terms <- reactive({
        # Change when the "update" button is pressed...
        input$update
        # ...but not for anything else
        isolate({
            withProgress({
              setProgress(message = "Processing corpus...")
                narratives = complaints %>% 
                  filter(complaints[,as.character(input$map_var)] %in% input$dep_list) %>%
                  #group_by_(input$map_var) %>% 
                  select_(input$map_var, 'Consumer.complaint.narrative') %>%
                  filter(Consumer.complaint.narrative != "") %>%
                  summarise(text = paste0(Consumer.complaint.narrative,collapse='')) %>%
                  # Make a new column with the number of characters
                  mutate(chars = nchar(text)) %>%
                  # Make another new column with the number of words total
                  mutate(words = sapply(gregexpr("\\W+", text),length)) %>%
                  arrange(desc(chars))
                narr = Corpus(VectorSource(narratives[, 'text']))
                narr = tm_map(narr, stripWhitespace)
                narr = tm_map(narr, tolower)
                narr = tm_map(narr, removeWords,stopwords('english'))
                narr = tm_map(narr, removeWords, 'xxxx')
            })
        })
    })
    
    output$bubbles <- renderPlot({
        v <- terms()

        wordcloud(v, scale=c(5,0.5), max.words=input$max, min.freq = input$freq,
                  random.order=FALSE, rot.per=0.35, 
                  use.r.layout=FALSE, colors=brewer.pal(8, "Dark2"))
    })
  
}
