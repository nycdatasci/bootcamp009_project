function(input, output, session) {
  observe({
    univ <- unique(univDT_Cut[City.x == input$city, "Name"])
    updateSelectizeInput(
      session, "name",
      choices = univ)
  })

  #call from input$city to change univerities shown on boxplot
  output$boxy2 <- renderPlot(
    univDT_Cut %>% 
      filter(City.x == input$city & 
               !is.na(Earning_10Perc_Af6Yr) &
               !is.na(Earning_25Perc_Af6Yr) &
               !is.na(Earning_Med_Af6Yr) &
               !is.na(Earning_75Perc_Af6Yr) &
               !is.na(Earning_90Perc_Af6Yr)) %>%
      arrange(desc(Earning_Med_Af6Yr)) %>% 
      head(20) %>% 
      ggplot(aes(x=reorder(Name,
                 Earning_Med_Af6Yr),
                 ymin = Earning_10Perc_Af6Yr,   
                 lower = Earning_25Perc_Af6Yr, 
                 middle = Earning_Med_Af6Yr, 
                 upper = Earning_75Perc_Af6Yr,
                 ymax = Earning_90Perc_Af6Yr,
                 fill = PrivPrice_4YRs4,
                 order = Earning_Med_Af6Yr)) +
      geom_boxplot(stat = "identity") + 
      coord_flip() +
      scale_y_continuous(
        name = "Income after 6 Years (for graduates)", 
        labels = comma) + 
      scale_x_discrete(
        name = "Names of Universities"
      ) +
      scale_fill_gradient(low = "snow", high = "skyblue", 
                          name="Earnings by University, by City", 
                          labels=c("0-25k","25-50k","50-75k", 
                                   "75-100k", "100-125k", "125-150k", "150-175k", 
                                   "175-200k", "200k+"), 
                          breaks = c(0, 25000, 50000, 75000, 100000,
                                     125000, 150000, 175000, 200000)
      ) +
      theme(
        #legend.position='top',
             axis.text.x = element_text(size = 14),
             axis.text.y = element_text(size = 14),
              axis.title = element_text(size = 16)
            ) +
      geom_text(aes(label = comma(Earning_Med_Af6Yr), 
                    y = Earning_Med_Af6Yr), 
                position = position_stack(vjust = 0.8),
                size = 5
                #position=position_dodge(width=0.9)
                )
      )
  
  #map showing locations/clusters of all universities. centered at the middle of US
  output$mapy2 <- renderLeaflet({
    leaflet(univDT_Cut) %>%
      setView(lng = -97.348603,
              lat = 37.684592,
              zoom = 4) %>%
      addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
      addMarkers(
        clusterOptions = markerClusterOptions()
      )
  })
  #map showing difference in salary for BA recipients and HS grads
  output$mapy3 <- renderLeaflet({
    leaflet(usMetrosJson5Simp) %>%
          setView(lng = -97.348603,
                  lat = 37.684592,
                  zoom = 4) %>%
      addTiles() %>%
      addPolygons(stroke = FALSE, 
                  smoothFactor = 0.3, fillOpacity = 1, 
                  weight = 0,
                  fillColor = ~pal(as.numeric(metroJoin_DifBAHS15)),
                  label = ~paste0(NAMELSAD, ": ",
                                  formatC(as.numeric(metroJoin_DifBAHS15), 
                                          big.mark = ",",
                                          digits = 7),
                                  " HS: ",
                                  formatC(metroJoin_HSorGED15,
                                          big.mark = ",",
                                          digits = 7),
                                  " BA: ", 
                                  formatC(metroJoin_Bachelorsdegree15,
                                          big.mark = ",",
                                          digits = 7),
                                  " "
                                  ),
                  labelOptions = labelOptions(noHide = T, 
                                              direction = 'top',
                                              offset=c(0,-45))
                  )
         })
  #based on input$name, data table showing range of university earnings
  output$datatable = renderDataTable({
    univDT_Cut[Name == input$name,
           c('Name',
             'Earning_10Perc_Af6Yr',
             'Earning_25Perc_Af6Yr',
             'Earning_Med_Af6Yr',
             'Earning_Mean_Af6Yr' ,
             'Earning_75Perc_Af6Yr',
             'Earning_90Perc_Af6Yr'
             ), drop = FALSE]
  })
  #based on input$city, table showing earnings and roi 
  #by universities in select city
  output$datatable1 = renderDataTable({
    univDT_Cut[City.x == input$city,
             c('Name', 
               'Earning_Med_Af6Yr',
               'Earning_Mean_Af6Yr',
               'Instate_ROIb',
               'Oustate_ROIb',
               'Pub_ROIb',
               'Priv_ROIb'), drop = FALSE]
   })
  #boxplot showing private tuition compared to roi
  output$boxy3 <- renderPlot(
    univDT_Cut %>% 
      filter(City.x == input$city & 
               !is.na(PrivPrice_4YRs) &
               !is.na(Priv_ROIb) &
               !is.na(Priv_ROIb_Cut)
             ) %>%
      group_by(Priv_ROIb_Cut) %>% 
      summarise(md_Private_ROIb = 
                  median(Priv_ROIb, na.rm = F),
                P10_Private_ROIb = 
                  quantile(Priv_ROIb, .1, na.rm = F),
                P25_Private_ROIb = 
                  quantile(Priv_ROIb, .25, na.rm = F),
                P75_Private_ROIb = 
                  quantile(Priv_ROIb, .75, na.rm = F),
                P90_Private_ROIb = 
                  quantile(Priv_ROIb, .90, na.rm = F)
      ) %>% 
      ggplot(aes(x =Priv_ROIb_Cut,
                 ymin = P10_Private_ROIb,
                 lower = P25_Private_ROIb,
                 middle = md_Private_ROIb,
                 upper = P75_Private_ROIb,
                 ymax = P90_Private_ROIb,
                 fill = Priv_ROIb_Cut)) + 
      geom_boxplot(stat = "identity") + 
      xlab("Private University Price, for 4 years") +
      scale_y_continuous(
        name = "Private University ROI, For 20 Years", 
        limits = c(-100000, 750000), 
        labels = comma) + 
      scale_fill_gradient(low = "snow", high = "skyblue", 
            name="Priv. Univ. Cost", 
            #labels=c("0-25k","25-50k","50-75k", 
            #         "75-100k", "100-125k", "125-150k", "150-175k", 
            #         "175-200k", "200k+"), 
            breaks = c(0, 25000, 50000, 75000, 100000,
                       125000, 150000, 175000, 200000)
      ) + 
      theme(
        #legend.position='top',
        axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title = element_text(size = 16)
      ) +
      geom_text(aes(label = comma(md_Private_ROIb), 
                    y = md_Private_ROIb), 
                position = position_stack(vjust = 0.8),
                size = 5)
  )
  #boxplot showing median earnings by 20% share of stem degrees
  output$boxy4 <- renderPlot(
    univDT_Cut %>% 
       filter(City.x == input$city & 
                !is.na(Stem_Perc) &
                !is.na(Priv_ROIb)) %>%
      ggplot(aes(Stem_Perc, Priv_ROIb)) +
      geom_boxplot(aes(group = Stem_Perc)) +
      theme(
        axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title = element_text(size = 16)
      ) +
      xlab("Share of Stem Degrees Awarded, in 20% intervals") +
      scale_y_continuous(
        name = "Private University ROI, For 20 Years", 
        #limits = c(-100000, 750000), 
        labels = comma) + 
      scale_fill_gradient(low = "snow", high = "skyblue", 
                          name="Share of Stem Degrees by ROI")
   )
  #boxplot showing median earnings by rank of research institution
  output$boxy6 <- renderPlot(
    univDT_Cut %>% 
      filter(City.x == input$city & 
               !is.na(researchUni) &
               !is.na(Priv_ROIb)) %>%
      ggplot(aes(researchUni, Priv_ROIb)) +
      geom_boxplot(aes(group=researchUni)) +
      theme(
        axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.title = element_text(size = 16)
      ) +
      xlab("Ranking of Research Institution, R1, R2, R3") +
      scale_y_continuous(
        name = "Private University ROI, For 20 Years", 
        #limits = c(-100000, 750000), 
        labels = comma) + 
      scale_fill_gradient(low = "snow", high = "skyblue", 
                          name="Institution Rank by ROI")
  )
 
}