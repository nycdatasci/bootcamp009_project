# server.R

shinyServer(function(input, output, session) {
    
    observe({
        tickers <- unique(fundamentals[fundamentals$Sector == input$selectSector, "Ticker"])
        updateSelectizeInput(
            session, "selectCompany",
            choices = tickers,
            selected = tickers[1])
    })
    sectorData <- reactive({
        fundamentals %>% 
            filter(Sector == input$selectSector)
    })
    companyData <- reactive({
        fundamentals %>% 
            filter(Sector == input$selectCompany)
    })
    
    output$all <- renderPlotly({
        #plot_ly(mtcars, x = ~mpg, y = ~wt)
        
        #plot_ly(diamonds, x = ~carat, y = ~price, color = ~carat,
        #        size = ~carat, text = ~paste("Clarity: ", clarity))
        #plot_ly(dataInput, x = ~EP, y = ~ZScore)
        
        plot_ly(fundamentals, y = ~ZScore, color = ~Sector, 
                type = "box", boxmean = TRUE, 
                marker= list(symbol = "hexagon-open")
        ) %>% 
        layout( 
            height = 500,
            margin = list(t = 0, r = 0, b = 20, l= 35, pad = 0), 
            showlegend = FALSE, 
            xaxis = list(
                        type = "category",
                        ticks = "inside",
                        showticklabels= TRUE,
                        autorange = FALSE,
                        tickmode = "auto",
                        nticks = 3,
                        tickcolor = toRGB("blue")
                    )
            ) 
    })
    output$sector <- renderPlotly({
        
        p <- sectorData() %>% 
                plot_ly(x = ~Ticker, y = ~ZScore, alpha = 0.5) 
        subplot(
                add_markers(p, color = ~factor(ZScore), 
                                colors = colorRamp(c("red", "blue"))
                        )
        ) %>% 
            layout(title = input$selectSector,
                   margin = list(t = 30, r = 0, b = 80, l= 35, pad = 0),
                   showlegend = FALSE,
                   yaxis = list(title = "Z-Score"),
                   xaxis = list(title = "Company Symbol")
                 )
                 
    })
    output$company <- renderPlotly({
        companyData() %>% 
            plot_ly(x = ~ZScore, y = ~Close) 
       
    })
    
})