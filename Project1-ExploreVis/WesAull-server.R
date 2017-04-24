#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


shinyServer(function(input, output, session){

  
  output$plot1 <- renderPlot({
      g <- ggplot(data=subset(a,!is.na(rt_0.36) & spin_year == input$spin_year1), aes(x=rt_0.36, y=reorder(Company,rt_0.36))) + geom_segment(aes(yend=Company), xend = 0, colour =" grey50",) + geom_point(size = 3, aes(color = rt_0.36)) + scale_colour_gradientn(name = "CAGR", colours = c('red','blue'), values=c(0,.4,1)) + theme_bw() + theme( panel.grid.major.y = element_blank()) + xlab('Compounded Annual Growth Rate - Forward Return Window') + ylab('Company Name')
      g
  })

  output$relplot1 <- renderPlot({
    ggplot(data=subset(a,!is.na(rt_rel_sp_0.36) & spin_year == input$spin_year2), aes(x=rt_rel_sp_0.36, y=reorder(Company,rt_rel_sp_0.36))) + geom_segment(aes(yend=Company), xend = 0, colour =" grey50",) + geom_point( size = 3, aes(color = rt_0.36)) + scale_colour_gradientn(name = "CAGR", colours = c('red','blue'), values=c(0,.4,1)) + theme_bw() + theme( panel.grid.major.y = element_blank()) + xlab('Compounded Annual Outperformance(Under-) vs. Benchmark - Forward Return Window') + ylab('Company Name')
  })
  
  output$denscurve <- renderPlot({
      xlabel = names(axis_vars)[axis_vars == input$densxvar]
      min_densxval = quantile(b[[input$densxvar]],0.0,na.rm=TRUE)
      max_densxval = quantile(b[[input$densxvar]],.98,na.rm=TRUE)
      ggplot(data = b, aes_string(x=input$densxvar)) + geom_density(fill ="deeppink4", alpha =.8) + theme_tufte() + theme(panel.grid.major = element_line(color = 'gray95'), panel.grid.minor = element_line(color = 'gray98')) + xlim(min_densxval,max_densxval) + scale_x_continuous(name=xlabel,labels=comma)
})


  # Filter the spins, returning a data frame
  output$predictor_plot <- renderPlot({
 
    start_point <- input$start_point
    min_market_value <- input$market_value[1]
    max_market_value <- input$market_value[2]
    xscatter <- input$xscatter
    min_xcut <- (input$xcut[1] / 100)
    max_xcut <- (input$xcut[2] / 100)
    zvar <- input$zvar
    yscatter <- 'rt_rel_sp_0.36'

    ## Translate inputs to compatible form for later code.
    if (start_point == '6 Months Post-Spin') {
      all_spins = b
    } else {
      all_spins = d
    }

    min_predxval = quantile(all_spins[[input$xscatter]],min_xcut,na.rm=TRUE)
    max_predxval = quantile(all_spins[[input$xscatter]],max_xcut,na.rm=TRUE)
    break1_predzval = quantile(all_spins[[input$zvar]],.10,na.rm=TRUE)
    break2_predzval = quantile(all_spins[[input$zvar]],.80,na.rm=TRUE)
    limit1_predzval = quantile(all_spins[[input$zvar]],.05,na.rm=TRUE)
    limit2_predzval = quantile(all_spins[[input$zvar]],.99,na.rm=TRUE)
    xtitle = names(axis_vars)[axis_vars == input$xscatter]
    ytitle = 'Compounded Annual Outperformance % Rate'
    ztitle = names(axis_vars)[axis_vars == input$zvar]
    
    ggplot(data = all_spins, aes_string(x=xscatter,y=yscatter)) + geom_point(aes_string(color=zvar)) + geom_smooth() + theme_dark() + scale_colour_gradientn(colours = c('blue','purple','red','orange','white'),values=c(0,.30,.70,1), limits=c(limit1_predzval,limit2_predzval)) + xlim(min_predxval,max_predxval) + xlab(xtitle) + ylab(ytitle) + labs(color=ztitle)
})
  
    
# Info boxes for Return Overview
  output$medianBox <- renderInfoBox({
    infoBox(HTML(paste("Median Compounded Annual",br(),"Growth Rate %")),
            formatC(median(a$rt_0.36[a$spin_year == input$spin_year1],na.rm=TRUE)), 
            icon = icon("stats",lib='glyphicon'),width = 160, fill = TRUE, color = 'purple')
  })
  output$avgBox <- renderInfoBox({
    infoBox(HTML(paste("Average Compounded Annual",br(),"Growth Rate %")),
            formatC(mean(a$rt_0.36[a$spin_year == input$spin_year1],na.rm=TRUE)), 
            icon = icon("stats",lib='glyphicon'),width = 160, fill = TRUE, color = 'purple') 
  })
# Info boxes for Return vs Benchmark
  output$avgrelBox <- renderInfoBox({
    infoBox(HTML(paste("Avg. Compounded Annual",br(),"Outperformance Rate (%)", br(), "Compared to Benchmark")),
            formatC(mean(a$rt_rel_sp_0.36[a$spin_year == input$spin_year2],na.rm=TRUE)), 
            icon = icon("stats",lib='glyphicon'),width = 160, fill = TRUE, color = 'purple')

})
}
)

