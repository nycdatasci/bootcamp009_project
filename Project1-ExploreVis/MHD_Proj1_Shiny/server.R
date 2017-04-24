library(dplyr)
library(ggplot2)
library(plotly)
library(tidyr)
library(zoo)
library(rgdal)
library(rgeos)
library(leaflet)
library(shiny)

function(input, output, session) {
        
        observe({
                state_counties = merged_rent_value %>% filter(State == input$state) %>% select(CountyName) 
                county = as.character(sort(unique(state_counties$CountyName)))
                updateSelectizeInput(
                        session, "county",
                        choices = c("All Counties", county))
        })
       
        observe({
                if (input$county == "All Counties") {
                        county_cities = merged_rent_value %>% filter(State == input$state) %>% select(zip_city)
                        } else {
                                county_cities = merged_rent_value %>% filter(State == input$state & CountyName == input$county) %>% select(zip_city)
                                }
                city = sort(unique(county_cities$zip_city))
                updateSelectizeInput(
                        session, "city",
                        choices = c("All Cities", city))
                })
        
        data_set = reactive({
                if (input$county == "All Counties" & input$city == "All Cities") {
                        merged_rent_value %>%
                                filter(State == input$state) %>% 
                                arrange(Dates, desc(Rent_Value_Percent))
                        } else if (input$county != "All Counties" & input$city == "All Cities") {
                                merged_rent_value %>% 
                                        filter(State == input$state & CountyName == input$county) %>% 
                                        arrange(desc(Rent_Value_Percent))
                        } else if (input$county != "All Counties" & input$city != "All Cities") {
                                merged_rent_value %>% 
                                        filter(State == input$state & CountyName == input$county & zip_city == input$city) %>% 
                                        arrange(desc(Rent_Value_Percent))
                        } else if (input$county == "All Counties" & input$city != "All Cities") {
                                merged_rent_value %>% 
                                        filter(State == input$state & zip_city == input$city) %>% 
                                        arrange(desc(Rent_Value_Percent))
                                }
                })
        
        # data_set_bar_rent = reactive({
        #         if (nrow(data_set()) > 0) {
        #                 data_set() %>% 
        #                         filter(Dates == "Jan 2012" | Dates == "Dec 2016") %>% 
        #                         select(-(contains("Val"))) %>% 
        #                 group_by(Zipcode) %>% 
        #                         spread(key = "Dates", value = "Rent" ) %>%
        #                         mutate(Percent_Change = ((`Dec 2016` - `Jan 2012`)/`Jan 2012`) * 100, Source = "Rent")
        #                 } else { return (0) }
        #         }) 
        # 
        # data_set_bar_value = reactive({ 
        #         if (nrow(data_set()) > 0) {
        #                 data_set() %>% 
        #                         filter(Dates == "Jan 2012" | Dates == "Dec 2016") %>% 
        #                         select(-(contains("Rent"))) %>% 
        #                         group_by(Zipcode) %>% 
        #                         spread(key = "Dates", value = "Value" ) %>%
        #                         mutate(Percent_Change = ((`Dec 2016` - `Jan 2012`)/`Jan 2012`) * 100, Source = "Value")
        #         } else { return (0) }
        # }) 
        
        data_set_bar_rent1 = reactive({
                if (nrow(data_set()) > 0) {
                        data_set() %>% 
                                filter(Dates == as.yearmon(input$barslider[1]) | Dates == as.yearmon(input$barslider[2])) %>% 
                                select(-(contains("Val"))) %>% 
                                group_by(Zipcode) %>% 
                                spread(key = "Dates", value = "Rent" ) %>%
                                mutate_(Percent_Change = paste0("((`",as.yearmon(input$barslider[2]),"`"," - ","`",as.yearmon(input$barslider[1]),"`) / `", as.yearmon(input$barslider[1]), "`) * 100")) %>%
                                mutate(Source = "Rent")
                } else { return (0) }
        })  
        
        data_set_bar_value1 = reactive({
                if (nrow(data_set()) > 0) {
                        data_set() %>% 
                                filter(Dates == as.yearmon(input$barslider[1]) | Dates == as.yearmon(input$barslider[2])) %>% 
                                select(-(contains("Rent"))) %>% 
                                group_by(Zipcode) %>% 
                                spread(key = "Dates", value = "Value" ) %>%
                                mutate_(Percent_Change = paste0("((`",as.yearmon(input$barslider[2]),"`"," - ","`",as.yearmon(input$barslider[1]),"`) / `", as.yearmon(input$barslider[1]), "`) * 100")) %>%
                                mutate(Source = "Value")
                } else { return (0) }
                }) 
        
        data_set_bar_merge = reactive({
                if (nrow(data_set()) > 0) {
                        data_set_bar_rent1() %>%
                                full_join(.,
                                          data_set_bar_value1(),
                                          by = intersect(names(data_set_bar_rent1()),
                                                         names(data_set_bar_value1()))) %>% 
                                select(-starts_with("RegionID"))
                        } else { return () }
                })
        
        data_set_bar = reactive({
                if (nrow(data_set()) > 0) {
                        if (input$county == "All Counties" & input$city == "All Cities") {
                                data_set_bar_merge() %>% 
                                        group_by(CountyName, Source) %>% 
                                        summarise(change = mean(Percent_Change, na.rm = TRUE)) %>% 
                                        mutate(x_var = CountyName)
                                } else if (input$county != "All Counties" & input$city == "All Cities") {
                                        data_set_bar_merge() %>% 
                                                group_by(zip_city, Source) %>% 
                                                summarise(change = mean(Percent_Change, na.rm = TRUE)) %>% 
                                                mutate(x_var = zip_city)
                                } else if (input$county != "All Counties" & input$city != "All Cities") {
                                        data_set_bar_merge() %>% 
                                                group_by(Zipcode, Source) %>% 
                                                summarise(change = mean(Percent_Change, na.rm = TRUE)) %>% 
                                                mutate(x_var = Zipcode)
                                } else if (input$county == "All Counties" & input$city != "All Cities") {
                                        data_set_bar_merge() %>% 
                                                group_by(Zipcode, Source) %>% 
                                                summarise(change = mean(Percent_Change, na.rm = TRUE)) %>% 
                                                mutate(x_var = Zipcode)
                                }
                        } else { return() }
                })
        
        data_set_vars = reactive({
                if (input$plot_var == 1) {
                        data_set() %>% 
                                mutate(Y = Value)
                        } else if (input$plot_var == 2)  {
                                data_set() %>% 
                                        mutate(Y = Rent)
                        } else if (input$plot_var == 3) {
                                data_set() %>% 
                                        mutate(Y = Rent_Value_Percent)
                                }
                })
        
        data_set_plot = reactive({
                if (input$plot_options == 1) {
                        data_set_vars() %>% 
                                filter(Dates  >= as.yearmon(input$plotslider[1]) & Dates <= as.yearmon(input$plotslider[2])) %>%
                                group_by(Dates) %>% 
                                summarise(Y_var = mean(Y, na.rm = TRUE))
                        } else if (input$plot_options == 2)  {
                                data_set_vars() %>% 
                                        filter(Dates  >= as.yearmon(input$plotslider[1]) & Dates <= as.yearmon(input$plotslider[2])) %>%
                                        mutate(Y_var = Y)
                                }
                })
        
        data_set_map = reactive({
                if (nrow(data_set()) > 0) {
                        # ----- Create a subset of New York counties
                        subdat = dat2[dat2$GEOID10 %in% data_set()$Zipcode,]
                        # ----- Transform to EPSG 4326 - WGS84 (required)
                        subdat = spTransform(subdat, CRS("+init=epsg:4326"))
                        # ----- save the data slot
                        subdat_data = subdat@data[,c("GEOID10", "ALAND10")]
                        # ----- simplification yields a SpatialPolygons class
                        subdat = gSimplify(subdat,tol=0.01, topologyPreserve=TRUE)
                        # ----- to write to geojson we need a SpatialPolygonsDataFrame
                        subdat = SpatialPolygonsDataFrame(subdat, data = subdat_data)
                        return(subdat)
                } else { return() }
        })
        
        
        
        
        data_set_map1 = reactive({
                if (nrow(data_set()) > 0) {
                        subdat = data_set_map()
                        zips = data_set() %>% filter(Dates == as.yearmon(input$map1slider)) 
                        subdat@data = data.frame(subdat@data, zips[match(subdat@data[,"GEOID10"], zips[,"Zipcode"]),])
                        return(subdat)
                } else { return() }
        })
        
        data_set_map2 = reactive({
                if (nrow(data_set()) > 0) {
                        subdat = data_set_map()
                        zips = data_set() %>% filter(Dates == as.yearmon(input$map2slider)) 
                        subdat@data = data.frame(subdat@data, zips[match(subdat@data[,"GEOID10"], zips[,"Zipcode"]),])
                        return(subdat)
                } else { return() }
        })
        
        output$plot = renderPlotly({
                if (nrow(data_set()) > 0)  {
                        plot_ly(data = data_set_plot(),
                                x = ~as.Date(Dates), 
                                y =  ~Y_var, 
                                type = 'scatter', 
                                mode = ifelse(input$plot_options == 1, "lines", "markers"),
                                color = if (input$plot_options == 2) {
                                        as.factor(data_set_plot()$RegionName)
                                        },
                                marker = if (input$plot_options == 1) {
                                        list(color = 'blue')
                                        },
                                hoverinfo = 'text',
                                text = if (input$plot_options == 2) {
                                        ~paste('City: ', data_set_plot()$zip_city,
                                               '</br> County: ', data_set_plot()$CountyName,
                                               '</br> State: ', input$state,
                                               '</br> Zipcode: ', Zipcode,
                                               '</br> Date: ', Dates,
                                               '</br> Rent/Value (%): ', round(Rent_Value_Percent, digits = 4),
                                               '</br> Rent: ', Rent,
                                               '</br> Value: ', Value)
                                        } else {
                                                ~paste('City: ', input$city,
                                                       '</br> County: ', input$county,
                                                       '</br> State: ', input$state,
                                                       '</br> Date: ', Dates,
                                                       ifelse(input$plot_var == 1, '</br> Value: ',
                                                              ifelse(input$plot_var == 2, '</br> Rent: ',
                                                                                          '</br> Rent/Value (%): ')), round(Y_var, digits = 2)
                                                )
                                                }
                                ) %>%
                                hide_colorbar() %>%
                                layout(margin = list(t = 100,
                                                     b = 75),
                                        title = if (input$plot_options == 1) {
                                                if (input$plot_var == 1) {
                                                        "<b>Average Median Value over Time</b>"
                                                } else if (input$plot_var == 2) {
                                                        "<b>Average Median Rent over Time</b>"
                                                } else if (input$plot_var == 3) {
                                                        "<b>Average Median Rent to Value over Time (%)</b>"
                                                }
                                        } else if (input$plot_options == 2) {
                                                if (input$plot_var == 1) {
                                                        "<b>Median Value over Time</b>"
                                                } else if (input$plot_var == 2) {
                                                        "<b>Median Rent over Time</b>"
                                                } else if (input$plot_var == 3) {
                                                        "<b>Median Rent to Value over Time (%)</b>"
                                                }
                                        },
                                        
                                        showlegend = FALSE,
                                        xaxis = list(title = "<b>Time</b>",
                                                    showticklabels = TRUE,
                                                    tickangle = 0,
                                                    tickfont = list(size = 10), 
                                                    showgrid = TRUE),
                                        yaxis = list(title = ifelse(input$plot_var == 1, "<b>Value ($)</b>", ifelse(input$plot_var == 2, "<b>Rent ($)</b>", "<b>Rent/Value (%)</b>")), 
                                                    showticklabels = TRUE, 
                                                    range = if (input$plot_var == 1) {
                                                            c(0,750000)
                                                            } else if (input$plot_var == 2) {
                                                                    c(0,5000)
                                                            } else if (input$plot_var == 3) {
                                                                            c(0,3)
                                                                    }
                                                    )
                                )
                        } else { return() }
              })
        
        output$bar = renderPlotly({
                if (nrow(data_set()) > 0) {
                        plot_ly(data = data_set_bar(),
                                x = ~x_var,
                                y = ~round(change, digits = 2),
                                color = ~Source,
                                type = "bar") %>%
                                layout(title = paste("<b>",as.yearmon(input$barslider[1]), "to", as.yearmon(input$barslider[2]),"</b>"),
                                       margin = list(t = 100,
                                                     b = 150),
                                       xaxis = list(type="category", 
                                                    categoryorder="category ascending",
                                                    showticklabels = TRUE,
                                                    tickangle = 270,
                                                    side = "bottom",
                                                    title = ifelse(input$county == "All Counties" & input$city == "All Cities", 
                                                                   "<b>County</b>",
                                                                   ifelse(input$county != "All Counties" & input$city == "All Cities", 
                                                                          "<b>City</b>", "<b>Zipcode</b>"))),
                                       yaxis = list(title = "<b>Percent Change (%)</b>",
                                                    range = c(0, 100)
                                                    )
                                )
                        } else { return () }
                })
        
        output$map1 = renderLeaflet({
                if (nrow(data_set()) > 0) {
                         l =    leaflet(data_set_map1()) %>%
                                addTiles() %>%
                                addProviderTiles("Esri.WorldStreetMap")
                                
                                
                        if (input$map1_mark == 2) {
                                 l %>% addPolygons(color = "black",
                                            fillColor = if (length(unique(data_set()$Zipcode)) > 1) { 
                                                    if (input$map1_var == 1) {
                                                            ~colorQuantile("RdYlGn", n = 5, data_set_map1()$Value)(data_set_map1()$Value)
                                                    } else if (input$map1_var == 2) {
                                                            ~colorQuantile("RdYlGn", n = 5, data_set_map1()$Rent)(data_set_map1()$Rent)
                                                    } else if (input$map1_var == 3) {
                                                            ~colorQuantile("RdYlGn", n = 5, data_set_map1()$Rent_Value_Percent)(data_set_map1()$Rent_Value_Percent)
                                                    }
                                                    } else { ("yellow") },
                                                    
                                            highlightOptions = highlightOptions(color = "white", 
                                                                                weight = 2,
                                                                                bringToFront = TRUE),
                                            opacity = 10,
                                            fillOpacity = 1,
                                            weight = 0.5,
                                            label = if (input$map1_var == 1) {
                                        ~paste("City: ", zip_city,
                                               "| Zipcode: ", Zipcode,
                                               "| Value: ", Value)
                                        } else if (input$map1_var == 2) {
                                                ~paste("City: ", zip_city,
                                                       "| Zipcode: ", Zipcode,
                                                       "| Rent: ", Rent)
                                                } else if (input$map1_var == 3) {
                                                        ~paste("City: ", zip_city,
                                                               "| Zipcode: ", Zipcode,
                                                               "| Rent/Value (%): ", round(Rent_Value_Percent, digits = 2))
                                                })
                                } else if (input$map1_mark == 1) {
                                
                                l %>% addCircleMarkers(lng = data_set_map1()$longitude,
                                                        lat = data_set_map1()$latitude,
                                                        radius = 3,
                                                        opacity = 1,
                                                        color = if (length(unique(data_set()$Zipcode)) > 1) { 
                                                                if (input$map1_var == 1) {
                                                                        ~colorQuantile("RdYlGn", n = 5, data_set_map1()$Value)(data_set_map1()$Value)
                                                                } else if (input$map1_var == 2) {
                                                                        ~colorQuantile("RdYlGn", n = 5, data_set_map1()$Rent)(data_set_map1()$Rent)
                                                                } else if (input$map1_var == 3) {
                                                                        ~colorQuantile("RdYlGn", n = 5, data_set_map1()$Rent_Value_Percent)(data_set_map1()$Rent_Value_Percent)
                                                                }
                                                        } else { ("yellow") },
                                                        popup = paste('City: ', data_set_map1()$zip_city,
                                                               '</br> County: ', data_set_map1()$CountyName,
                                                               '</br> State: ', data_set_map1()$State,
                                                               '</br> Zipcode: ', data_set_map1()$Zipcode,
                                                               '</br> ',
                                                               '</br> Date: ', data_set_map1()$Dates,
                                                               '</br> ',
                                                               '</br> Rent/Value (%): ', round(data_set_map1()$Rent_Value_Percent, digits = 4),
                                                               '</br> ',
                                                               '</br> Rent: ', data_set_map1()$Rent,
                                                               '</br> Value: ', data_set_map1()$Value)
                                )}
                
                        } else { return() }
        })

        output$map2 = renderLeaflet({
                if (nrow(data_set()) > 0) {
                        l =    leaflet(data_set_map2()) %>%
                                addTiles() %>%
                                addProviderTiles("Esri.WorldStreetMap")
                        
                        
                        if (input$map2_mark == 2) {
                                l %>% addPolygons(color = "black",
                                                  fillColor = if (length(unique(data_set()$Zipcode)) > 1) { 
                                                          if (input$map2_var == 1) {
                                                                  ~colorQuantile("RdYlGn", n = 5, data_set_map2()$Value)(data_set_map2()$Value)
                                                          } else if (input$map2_var == 2) {
                                                                  ~colorQuantile("RdYlGn", n = 5, data_set_map2()$Rent)(data_set_map2()$Rent)
                                                          } else if (input$map2_var == 3) {
                                                                  ~colorQuantile("RdYlGn", n = 5, data_set_map2()$Rent_Value_Percent)(data_set_map2()$Rent_Value_Percent)
                                                          }
                                                  } else { ("yellow") },
                                                  
                                                  highlightOptions = highlightOptions(color = "white", 
                                                                                      weight = 2,
                                                                                      bringToFront = TRUE),
                                                  opacity = 10,
                                                  fillOpacity = 1,
                                                  weight = 0.5,
                                                  label = if (input$map2_var == 1) {
                                                          ~paste("City: ", zip_city,
                                                                 "| Zipcode: ", Zipcode,
                                                                 "| Value: ", Value)
                                                  } else if (input$map2_var == 2) {
                                                          ~paste("City: ", zip_city,
                                                                 "| Zipcode: ", Zipcode,
                                                                 "| Rent: ", Rent)
                                                  } else if (input$map2_var == 3) {
                                                          ~paste("City: ", zip_city,
                                                                 "| Zipcode: ", Zipcode,
                                                                 "| Rent/Value (%): ", round(Rent_Value_Percent, digits = 2))
                                                  })
                        } else if (input$map2_mark == 1) {
                                
                                l %>% addCircleMarkers(lng = data_set_map2()$longitude,
                                                       lat = data_set_map2()$latitude,
                                                       radius = 3,
                                                       opacity = 1,
                                                       color = if (length(unique(data_set()$Zipcode)) > 1) { 
                                                               if (input$map2_var == 1) {
                                                                       ~colorQuantile("RdYlGn", n = 5, data_set_map2()$Value)(data_set_map2()$Value)
                                                               } else if (input$map2_var == 2) {
                                                                       ~colorQuantile("RdYlGn", n = 5, data_set_map2()$Rent)(data_set_map2()$Rent)
                                                               } else if (input$map2_var == 3) {
                                                                       ~colorQuantile("RdYlGn", n = 5, data_set_map2()$Rent_Value_Percent)(data_set_map2()$Rent_Value_Percent)
                                                               }
                                                       } else { ("yellow") },
                                                       popup = paste('City: ', data_set_map2()$zip_city,
                                                                     '</br> County: ', data_set_map2()$CountyName,
                                                                     '</br> State: ', data_set_map2()$State,
                                                                     '</br> Zipcode: ', data_set_map2()$Zipcode,
                                                                     '</br> ',
                                                                     '</br> Date: ', data_set_map2()$Dates,
                                                                     '</br> ',
                                                                     '</br> Rent/Value (%): ', round(data_set_map2()$Rent_Value_Percent, digits = 4),
                                                                     '</br> ',
                                                                     '</br> Rent: ', data_set_map2()$Rent,
                                                                     '</br> Value: ', data_set_map2()$Value)
                                )}
                        
                } else { return() }
        })
        
}