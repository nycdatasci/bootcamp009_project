
function(input, output, session){

    # Reactive expression to generate the requested distribution.
    # This is called whenever the inputs change. The output
    # functions defined below then all use the value computed from
    # this expression
   
     mapdata <- reactive({
         df <-map %>%
              filter(
                    Genres %in% input$Genres,
                    Year >=input$Year[1],
                    Year<=input$Year[2],
                    Score >=input$Score[1],
                    Score<=input$Score[2]
)
     })
     
     
     ###########draw the map################     
     output$map <- renderLeaflet({
         map<-leaflet() %>%
             setView(lng = -73.94197, lat = 40.73638, zoom = 12) %>%#change view by selection
             addProviderTiles("CartoDB.Positron") %>%
             addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                      attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')
         map%>%
             addLegend("topright", pal = pal, values =  c("Action","Adventure","Biography","Comedy","Crime",
                                                          "Documentary","Drama","Horror","Romance","Sci-Fi"),
                       title = "Genres",
                       opacity = 1)
     })

     observe({
         print(mapdata()$Images)
          leafletProxy("map", data = mapdata()) %>%
              clearShapes() %>%
              addCircles(lng = ~longtitude, 
                         lat = ~latitude,
                         radius=120,stroke = FALSE, fillOpacity =0.5,color = ~pal(Genres),
                        popup = ~paste( "<strong> Film Name: </strong>",Film,"<br/>",
                                       "<strong> Genres: </strong>",Genres,"<br/>",
                                       "<strong> IMDB Score: </strong> ", Score,"<br/>",
                                       "<strong> Director: </strong> ", Director,"<br/>",
                                       paste0("<img src = ", Images, " style=width:200px;height:233px;>")
                                       )
                                       )
     })
     
    output$yearbar <- renderPlot({
         
         ggplot(mapdata(), aes(Year, ..count..)) +
             geom_bar(aes(fill = Genres),width = 2)+
            scale_fill_manual(values=brewer.pal(n = 10, "Paired"))+
             labs(y="Count",x="Year")
         
     })
    
    output$scorebar <- renderPlot({
        
        ggplot(mapdata(), aes(Score, ..count..)) +
            geom_bar(aes(fill = Genres),width = 0.2)+
            scale_fill_manual(values=brewer.pal(n = 10, "Paired"))+
            labs(y="Count",x="IMDB Score")
        
    })
    
    ######## Generate the wordcloud ########
 
    
    rwd<-reactive({movie_names})
    
    wordcloud_rep <- repeatable(wordcloud)
    
    output$wordcloud<- renderPlot({
        wordcloud_rep(words = rwd()$word, freq = rwd()$X1, scale=c(5,1),
                      min.freq = input$rfreq,
                      max.words=input$rmax,
                      rot.per=0.2,
                      random.order=F,
                      colors=brewer.pal(n = 10, "Dark2"))
    })
    
    
    ########## table1 output ###########
    
    output$tbl <- DT::renderDataTable({
        df <- movie_t %>%
            group_by(Director) %>%
            summarise(freq = n()) %>%
            top_n(n = input$dn, wt = freq) %>%
            inner_join(y = movie_t, by = "Director")
        DT::datatable(df, class = 'cell-border stripe', escape = FALSE)
    })

    
    
}
    

