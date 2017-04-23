# server.R

shinyServer(function(input, output) {
    
    #input$tickerSearch
    #input$searchButton
    dataInput <- reactive({
        filter(fundamentals, Sector == input$selectSector)
    })
    output$plot <- renderPlotly({
        #plot_ly(mtcars, x = ~mpg, y = ~wt)
        
        #plot_ly(diamonds, x = ~carat, y = ~price, color = ~carat,
        #        size = ~carat, text = ~paste("Clarity: ", clarity))
        #plot_ly(dataInput, x = ~EP, y = ~ZScore)
        
        plot_ly(fundamentals, y = ~ZScore, color = ~Sector, 
                type = "box", boxmean = TRUE, 
                marker= list(symbol = "hexagon-open")
        ) %>% 
                layout( showlegend = FALSE, 
                        #autosize = TRUE,
                        #width = 700,
                        height = 500,
                        margin = list(t = 0, r = 0, b = 20, l= 35, pad = 0), 
                        xaxis = list(
                            type = "category",
                            ticks = "inside",
                            showticklabels= TRUE,
                            
                            autorange = FALSE,
                            tickmode = "auto",
                            nticks = 3,
                            #tick0 = 'Industrials',
                            tickcolor = toRGB("blue")
                        )
                    ) 
                
                        
                        
                        
                
                        
                
                              
                              
        
        #plot_ly(fundamentals, x = ~Sector, y = ~ZScore, alpha = 0.5) %>% 
        #subplot(
        #         add_markers(p, color = ~factor(ZScore), showlegend = FALSE,
        #                     colors = colorRamp(c("red", "blue"))
        #                     )
        #    )
        
    })
    
})