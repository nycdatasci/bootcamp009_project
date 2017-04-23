library(shinydashboard)

shinyServer(
  function(input, output, session) {
    
    signals <- reactiveValues(dayofweek_map = TRUE,
                              startrange_map = TRUE,
                              leaflet_map = TRUE)
    
    heatmap_df = reactive({
      df = df %>% select(gender, agegroup, dayofweek, startrange) %>% 
        filter(gender == input$gender_heatmap, 
               agegroup == input$agegroup_heatmap) %>%
        group_by(gender, 
                 agegroup, 
                 startrange, 
                 dayofweek) %>% 
        summarise(count = n())
      
      df$dayofweek = factor(df$dayofweek, 
                            levels = c("Sunday", "Saturday", "Friday", "Thursday", "Wednesday", "Tuesday", "Monday"))
      
      colnames(df)[which(names(df) == "startrange")] <- "Time"
      colnames(df)[which(names(df) == "dayofweek")] <- "Day"
      colnames(df)[which(names(df) == "count")] <- "Count"

      df
    })
    
    
    tile_df = reactive({
      melt_df = melt_df[sample(nrow(melt_df),replace=F,size=0.1*nrow(melt_df)),]
      
      melt_df %>% filter(gender == input$gender_tile, 
                         age > input$age_tile[1], age < input$age_tile[2], 
                         hour > input$time_tile[1], hour < input$time_tile[2], 
                         dayofweek == input$dayofweek_tile, 
                         time == switch(input$startstop_tile,'departing' = 'start','arriving' = 'stop'))
    })
    
    observeEvent(input$start_map, {
      
      choices <- dir_df %>%
        filter(start.station.name == input$start_map) %>%
        select(end.station.name)
      
      choices <- sort(unique(choices[,1]))
      
      updateSelectInput(session = session, 
                        inputId = 'stop_map', 
                        choices = choices, 
                        selected = choices[2])
      signals$dayofweek_map <- FALSE
      signals$leaflet_map <- FALSE
    })
    
    observeEvent(signals$dayofweek_map, {
      signals$dayofweek_map <- TRUE
      choices <- dir_df %>%
        filter(start.station.name == input$start_map,
               end.station.name == input$stop_map) %>%
        select(dayofweek)
      
      choices <- levels(dir_df$dayofweek)
      choices <- unique(choices[,1])
      
      updateSelectInput(session = session,
                        inputId = 'dayofweek_map',
                        choices = choices,
                        selected = choices[1])
      signals$startrange_map <- FALSE
      signals$leaflet_map <- FALSE
    })
    
    observeEvent(signals$startrange_map, {
      signals$startrange_map <- TRUE
      choices <- dir_df %>%
        filter(start.station.name == input$start_map,
               end.station.name == input$stop_map,
               dayofweek == input$dayofweek_map) %>%
        select(startrange)
      
      choices <- sort(unique(choices[,1]))
      
      updateSelectInput(session = session,
                        inputId = 'startrange_map',
                        choices = choices,
                        selected = choices[1])
      signals$leaflet_map <- FALSE
    })
    
    map_df = reactive({
      dir_df %>%
        filter (start.station.name == input$start_map,
                end.station.name == input$stop_map,
                dayofweek == input$dayofweek_map,
                startrange == input$startrange_map) %>%
        group_by(start.lat_long, end.lat_long) %>%
        summarise(avg_duration = mean(tripduration.min))
    })
    
    output$histogram = renderPlot({
      ggplot(data = df, aes(x=agegroup, fill= gender)) + 
        geom_histogram(stat='count') + 
        labs(x = "", y = "", title = '') +
        theme_pander() +
        theme(axis.line=element_blank(),
              axis.text.y=element_blank(),
              axis.ticks=element_blank(),
              plot.title = element_text(size = 20, 
                                        face = 'bold',
                                        color = 'grey28',
                                        margin = margin(10,0,10,0),
                                        family = 'Helvetica',
                                        hjust = 0.025),
              legend.title = element_blank(),
              legend.position="bottom",
              strip.text.x = element_blank()) +
        facet_grid(~gender)
    })


    output$histogram_hourofday = renderPlot({
      weekdays_agegroup = df %>% 
    filter(!dayofweek %in% c('Saturday', 'Sunday')) %>% 
    group_by(starthour, agegroup) %>% 
    summarise(count = n())

    ggplot(data = weekdays_agegroup, aes(x=starthour, y = count, fill = agegroup)) + 
        geom_histogram(stat = 'identity', position = 'fill') +
        labs(x = "", y = "", title = '') +
        scale_fill_economist() +
        theme_pander() +
        theme(axis.line=element_blank(),
              axis.ticks=element_blank(),
              plot.title = element_text(size = 20, 
                                        face = 'bold',
                                        color = 'grey28',
                                        margin = margin(10,0,10,0),
                                        family = 'Helvetica',
                                        hjust = 0.025),
              legend.title = element_blank(),
              legend.position="bottom",
              strip.text.x = element_blank()) +
        scale_x_continuous(breaks = seq(min(weekdays_agegroup$starthour), 
                                        max(weekdays_agegroup$starthour), by = 4)) 
            })

    # output$duration_med = renderTable({
    # duration_table = df %>% 
    #                     group_by(gender, agegroup) %>% 
    #                     summarise(Median = round(median(tripduration.min),1))

    # dcast(duration_table, agegroup ~ gender)
    # }, caption=paste("Median Trip Duration (minutes) per Age Group and Gender")
    # )

    output$weekdays = renderPlot({
      weekdays = df %>% 
      filter(!dayofweek %in% c('Saturday', 'Sunday')) %>% 
      group_by(starthour) %>% 
      summarise(count = n())
    
    ggplot(data = weekdays, aes(x=starthour, y = count)) + 
      geom_histogram(stat = 'identity', color = "dodgerblue3", fill = "dodgerblue3") +
      labs(x = "", y = "", title = 'Weekdays') +
      theme_pander() +
      theme(axis.line=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks=element_blank(),
            plot.title = element_text(size = 18, 
                                      face = 'bold',
                                      color = 'grey28',
                                      margin = margin(10,0,10,0),
                                      family = 'Helvetica',
                                      hjust = 0.5),
            legend.title = element_blank(),
            strip.text.x = element_blank()) +
        scale_x_continuous(breaks = seq(min(weekdays$starthour), 
                                      max(weekdays$starthour), by = 4))
    })
    
    output$weekends = renderPlot({
    weekends = df %>% 
      filter(dayofweek %in% c('Saturday', 'Sunday')) %>% 
      group_by(starthour) %>% 
      summarise(count = n())
    
    ggplot(data = weekends, aes(x=starthour, y = count)) + 
      geom_histogram(stat = 'identity', color = "dodgerblue3", fill = "dodgerblue3") +
      labs(x = "", y = "", title = 'Weekends') +
      theme_pander() +
      theme(axis.line=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks=element_blank(),
            plot.title = element_text(size = 18, 
                                      face = 'bold',
                                      color = 'grey28',
                                      margin = margin(10,0,10,0),
                                      family = 'Helvetica',
                                      hjust = 0.5),
            legend.title = element_blank(),
            strip.text.x = element_blank()) +
      scale_x_continuous(breaks = seq(min(weekends$starthour), 
                                      max(weekends$starthour), by = 4))
    })

    output$medianage = renderPlot({
      medianage_df = df %>% 
        select(age, start.station.latitude, start.station.longitude) %>% 
        group_by (start.station.latitude, start.station.longitude) %>%
        summarize(median = median(age))
      
      # medianage_df = medianage_df[sample(nrow(medianage_df),replace=F,size=0.5*nrow(medianage_df)),]
      
      ggmap(ggmap::get_map("New York City", zoom = 14)) + 
        geom_point(data=medianage_df, aes(x=start.station.longitude,
                                          y=start.station.latitude, 
                                          color = median), size=8, alpha=0.8) + 
        theme_map() +
        labs(x = "", y = "", title = '') +
        theme(axis.line=element_blank(),
              axis.ticks=element_blank(),
              plot.title = element_text(size = 20, 
                                        face = 'bold',
                                        color = 'grey28',
                                        margin = margin(10,0,10,0),
                                        family = 'Helvetica',
                                        hjust = 0.025),
              legend.title = element_blank(),
              strip.text.x = element_blank()) + 
        scale_color_gradient(low = "#ffffff", high = "#133145")
      })

    output$heatmap = renderPlotly({
       g = ggplot(heatmap_df(), aes(x=Time, y=Day, fill=Count)) +
         geom_tile(color="white", size=0.1) +
         scale_x_discrete(expand = c(0, 0)) +
         labs(x=NULL, y=NULL) +
         scale_fill_gradient(low = "#deebf7", high = "#3182bd", name = "# Riders") +
         theme_tufte(base_family="Helvetica") +
         theme(plot.title=element_text(hjust=0)) +
         theme(axis.ticks=element_blank()) +
         theme(axis.text=element_text(size=10)) +
         theme(legend.title=element_text(size=12)) +
         theme(legend.text=element_text(size=10)) +
         theme(legend.key.size=unit(0.2, "cm")) +
         theme(legend.key.width=unit(1, "cm"))
    
       ggplotly(g) %>% config(displayModeBar = F)
     })
    
      output$tile = renderLeaflet({
        
        leaflet(data = tile_df()) %>% 
          addTiles() %>% 
          addMarkers(~longitude, 
                     ~latitude, 
                     popup = ~name, 
                     label = ~name, 
                     icon = bike_icon) %>% 
          addProviderTiles('Esri.NatGeoWorldMap')
      })
      
      output$map <- renderLeaflet({
        coords <- dir_df %>%
          filter (start.station.name == isolate(input$start_map),
                  end.station.name == input$stop_map) %>%
          select(start.lat_long,
                 end.lat_long)
        origin = coords$start.lat_long[1]
        destination = coords$end.lat_long[1]
        
        res = google_directions(origin = origin,
                                destination = destination,
                                key = key)
        
        print(paste(origin, destination))
        print(res)
        
        df_polyline = decode_pl(res$routes$overview_polyline$points)
        
        leaflet() %>%
          addTiles() %>%
          addPolylines(data = df_polyline, lat = ~lat, lng = ~lon)
      })
      
      output$durationGoogle = renderInfoBox({
        coords <- dir_df %>%
          filter (start.station.name == isolate(input$start_map),
                  end.station.name == input$stop_map) %>%
          select(start.lat_long,
                 end.lat_long)
        origin = coords$start.lat_long[1]
        destination = coords$end.lat_long[1]
        google_time = select(mapdist(origin, destination, mode='bicycling'), minutes)
        infoBox("Google estimated duration:", paste(round(google_time,1), 'min'), icon = icon("google"), color = 'orange', fill = TRUE)
      })
      
      output$durationCitibike = renderInfoBox({
        citibike_time = dir_df %>%
          filter (start.station.name == input$start_map,
                  end.station.name == input$stop_map,
                  dayofweek == input$dayofweek_map,
                  startrange == input$startrange_map) %>%
          group_by(start.lat_long, end.lat_long, startrange, dayofweek) %>%
          summarise(avg_duration = mean(tripduration.min, na.rm=TRUE))
        
        if(length(citibike_time$avg_duration)==0){
          tmp = 'Not provided'
        }else{
          tmp = paste(round(citibike_time$avg_duration,1), 'min')
        }
        
        infoBox("CitiBike estimated duration:",
                tmp, 
                icon = icon("bicycle"), fill = TRUE)
      })
      
  }
    )
    
    