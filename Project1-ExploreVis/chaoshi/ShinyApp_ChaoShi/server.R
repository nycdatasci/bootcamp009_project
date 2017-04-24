##############################################
# Geospatial Data Digester Prototyped in R -- 
# A Shiny Project @ NYC Data Science Academy
# 
#
# Chao Shi
# chao.shi.datasci@gmail.com
# 4/23/2017
##############################################

function(input, output, session) {


  # data filtering and score generation module
  weighted_val <- eventReactive(input$do, {
    
    # ======================================================================================
    # =====================  Core computational piece for the map  =========================
    # =====================                  ---                   =========================
    # =====================  filtering and weighted average calc   =========================
    # ======================================================================================
    
    #  ------------------------- data treatment BEFORE calling this function ----------------------
    #
    # a) each numeric column is normalized to a [0,scalar] range, with 'scalar' defined in global.R
    #
    # b) the column are pre-treated so that the larger number direction is aligned with what people
    #    normally want, for example: 
    #    air quality measurement PM 2.5 is normalized so that a SMALL number gets a HIGH score,
    #    while for income, LARGE number gets a HIGH score
    #
    #    HOWEVER, addtional user input is needed for data categories like politics. 
    #    user need to choose preferred side
    #
    # c) nan or null are fixed, so the weighted average would make sense
    
    # ----------------------------------------- work flow -----------------------------------------
    # 1) check which categories are checked by user  (input$ck)
    # 2) check the 'positive' direction definition by user, modify data if needed  (scalar - x)
    # 3) get ranges for each category from sliderInputs, for row filtering
    # 4) get (lat,lng) from mouse click, calculate for all mapped grids (counties in this case)
    #    the distance towards this (lat,lng) location
    # 5) row filtering based on the slider inputs (distance from step 4 is NOT used by design)
    # 6) weighted average calculation
    # 7) return $v -- a numeric vector of score for each location (county in this case)
    #           $i -- index vector for kept rows of data (to generate filtered data table for tab 2)
    #           $p -- for googleVis pie chart
    # ----------------------------------------------------------------------------------------------
    
    
    ## 1) which boxes are checked --> column filter
    box_vec = c(input$ck1, input$ck2, input$ck3, input$ck4, input$ck5, input$ck6, input$ck7,  #### <- additional filter input,b4 mouse input
                input$ck100)                                                                  ####     ck100
    colskeep = which(box_vec)  # each county in the data frame is a row, while different data categories are columns
                               # user input from the checkboxes are used as column filters, hence 'colskeep'
    
    i_dyn   = 8                                                                           #### <- this needs to change will additional checkbox
                                                                                          ####    it stores the location of ck100 in box_vec
                                                                                          ####    distance value calculated based on user mouse
                                                                                          ####    click will not be used as a filter, by design
    ## 2) flip values following user's input
    radio_chk = c(input$radio2 == 2, input$radio7 == 2)  # need manual change if the order of fluidRow items are changed in ui.R
    cols_flip = c(2,7)[radio_chk]
    
    if (length(cols_flip)!=0) mydf_norm[,cols_flip] = scalar - mydf_norm[,cols_flip]

    # get weights for the weighted average step later
    wtskeep = c(as.numeric(input$w1),as.numeric(input$w2),as.numeric(input$w3),
                as.numeric(input$w4),as.numeric(input$w5),as.numeric(input$w6),
                as.numeric(input$w7),                                                     #### <- additional input here, BEFORE w100 mouse data
                as.numeric(input$w100))[colskeep]

    # reshape it as a matrix with only 1 column, this is for the vectorized weighted average
    wts = matrix(wtskeep, length(colskeep),1)
    
    ## 3) get the ranges from all sliders
    ranges = rbind(input$sl1,input$sl2,input$sl3,input$sl4,input$sl5,input$sl6,input$sl7) ##### <- need to modify with additional input fluidRow

    # ----------------------------------------------------------------------------------------------------------------- #
    # Most data is loaded during global.R call, in a way 'static' (values may be filtered out, but they do not change), #
    # while the mouse-click based distance calculation requires frequent update, hence 'dynamic' (value will change)    #
    #                                                                                                                   #
    # The desire to add this dynamic data generation has made the logic and algorithm in server.R more complicated --   #
    #                                                                                                                   #
    #       >> I DO NOT want the distance data to enter the row filtering process                                       #
    #           -- easily done by human eyes on a map, value added for user is low                                      #
    #           -- added value might not justify the effort to achieve satisfying user experience                       #
    #           -- this is a 2-wk project, many other 'low-hanging-fruit' features need to be developed                 #
    #                                                                                                                   #
    #       >> I DO want the distance data to enter the weighted average scoring process.                               #
    #                                                                                                                   #
    #                                               **********************                                              #
    # The dynamic distance or TRAVEL TIME estimation will be very useful when applying this data digestion framework    #
    # on things like New York City real estate value analysis, with google map API calls, or for a TRAVEL COST feature  #
    # based on Kayak API (?) calls.                                                                                     #
    #                                               **********************                                              #
    #                                                                                                                   #
    # the solution I prototyped here may be far from ideal.                                                             #
    #                                                                                                                   #
    # one motivation behind this project is to develop something general enough to keep reusing                         #
    # your thoughts on improving this data digestion engine, especially the computational part are highly appreciated.  #
    # ----------------------------------------------------------------------------------------------------------------- #
    
    ## 4) get (lat,lng) input from mouse click
    latlonclk = rbind(c(-91.5, 35))  # default if no mouse click yet
    latlonclk = clicklatlon()
    
    dist_vec   = NULL
    radar_vars = c(names(dummy2), 'distance')
    
    if(input$ck100) {
      
      dist_vec = distm (lon_lat_county_mat, latlonclk, 
                        fun = distHaversine)    # from 'geosphere' package
      
      dist_vec = normalize(dist_vec) * scalar   # normalize to [0,scalar],    scalar is defined in global.R
                                                # normalization for other 'static' data is done in global.R
                                                # (or a separate file, as more polished version might separate the data cleaning steps)
      if (input$radio100 == 1) dist_vec = scalar - dist_vec     # check user input, this needs to be changed accordingly.
                                                                # as user might choose to either stay 'close to' or 'away from' the location
    }

    
    ## 5) row filtering

    # get 2 vectors of row numbers:   rowskeep,   rowsout
    # filtered mydf_norm_norm will be a n(rowskeep)-by-n(colskeep) matrix, 
    
    # dumb version
    i=1
    keeper = rep(TRUE, nrow(dummy2))
    totchk = length(colskeep)
    
    # ---------------------------------------------------------- special note ----------------------------------------------------------
    # the logic here is to make sure the row filtering is successful in all these situations
    # a) multiple 'static' data chosen, distance data NOT chosen (this is the usual case before adding the distance calculation)
    # b) multiple 'static' data AND the dynamic distance are chosen --> the distance value does not filter things
    # c) NO 'static' data is chosen, but dynamic distance calc IS chosen --> totchk == 1, but no filtering
    # d) nothing is chosen at all, no row filtering
    # ----------------------------------------------------------------------------------------------------------------------------------

    # a loop structure is chosen here, since during the project I keep increasing the total number of sliders
    while(totchk) {
      if (colskeep[i] != i_dyn) {
        keeper = keeper & (dummy2[,colskeep[i]]>=ranges[colskeep[i],1] & dummy2[,colskeep[i]]<=ranges[colskeep[i],2])
      }
      i = i+1
      if(i>totchk) break
    }
    # ----------------------------------------------------------------------------------------------------------------------------------
    
    rowskeep = which(keeper)
    #rowsout  = which(!keeper)     # for some reason I keep thinking this might be useful

    ## 6) weighted average calculation -- getting the score for each county
    
    # as.matrix(mydf_norm) %*% wts / sum(wts)             # first version of weighted sum, WITHOUT filtering
    # as.matrix(mydf_norm[,colskeep]) %*% wts / sum(wts)  # now with column filtering
    
    weighted_score =  rep(NaN, nrow(dummy2))
    
    # weighted sum, with col and row filtering, AND dist_vec attached (when dist_vec is empty this still works)
    weighted_score[rowskeep] =cbind(as.matrix(mydf_norm[rowskeep,]),dist_vec[rowskeep,])[,colskeep] %*% wts / sum(wts)  
    # weighted_score[rowskeep] = as.matrix(mydf_norm[rowskeep,][,colskeep]) %*% wts / sum(wts)  # weighted sum, with both col and row filtering
                                                                                           # BEFORE introducing the dynamic distance calc
    
    # generate data for the pie chart -- names of inputs considered in the score calc, and their weights
    PieInput = data.frame("Parameters" = radar_vars[box_vec], "Weights" = wts)
    
    ## 7) return: $v the score, $i the row ind for tab 2, $p for pie chart
    list(v = weighted_score, i = rowskeep, p = PieInput)    # for a while I do round(weighted_score,0) here, but when combined with 
                                                            # heavy filtering (resulting in a small amount of data with very little
                                                            # value variation), rounding here caused issue for quantile color plots
                                                            # ('bin not unique' error).
    
  }) # end of weighted_val

  
  # ======================================================================================
  # ================                                                  ====================
  # ================   Filtering and weighted average function ENDS   ====================
  # ================                                                  ====================
  # ======================================================================================
  
  
  # ======================= #
  #    floating pie chart   #    chosen inputs and weights visual reminder
  # ======================= #
  
  output$pie <- renderGvis({
    gvisPieChart(weighted_val()$p, options=list(title ="Input Categories and Weights"))
    # gvisPieChart(weighted_val()$p, options=list(width=400, height=450))
  })
  
  # ============================================== #
  #              THE MAP -- popup prep             #
  # ============================================== #
  
  # Format popup data for leaflet map.
  popup_dat <- reactive({
    paste0("<strong>County: </strong>",
           leafmap$county_state,
           "<br><strong>Score: </strong>",
           round(weighted_val()$v,0),
           "<br><strong>Air Quality (PM 2.5 µg/m³): </strong>",
           leafmap$airqlty,                                                        # leaflet popup info preparation
           "<br><strong>dem%-gop% 2016: </strong>",
           leafmap$perdiff,
           "<br><strong>Income ($/yr): </strong>",
           leafmap$median_household_income_2015,
           "<br><strong>Cost ($/yr): </strong>",
           leafmap$twoatwoc,
           "<br><strong>Income to Cost Ratio: </strong>",
           leafmap$r_inc_cos,
           "<br><strong>Crime Rate (per 100k people): </strong>",
           leafmap$crime_rate_per_100k,
           "<br><strong>Population Density: log(pop/area) </strong>",
           leafmap$pop_den_log                                                                                    
    )
  }) # end of popup_dat

  
  # ============================================== #
  #           THE MAP -- initialization            #
  # ============================================== #
  
  output$map <- renderLeaflet({
    # data <- popup_weight()
    leaflet() %>% 
      addProviderTiles("Thunderforest.Transport") %>%      #Thunderforest.Transport   Stamen.TonerLite
      addPolygons(data=leafmap,                              # we addPolygons during the initialization for 2 reasons
                  fillColor = 'transparent',                 #     1) county boundaries
                  fillOpacity = 0.8,                         #     2) we use '_shape_click' for mouse click detection, we need a 'shape' layer
                  color = "#BDBDC3",
                  weight = 1) %>% 
      setView(lng = -91.5, lat = 35, zoom = 5)
    # proxy <- leafletProxy("map", data = leafmap)
    # print(str(proxy))
  }) # end of renderLeaflet
  
  
  # =========================================================== #
  #  THE MAP -- polygon refresh after each action button click  #           #
  # =========================================================== #

  observeEvent(input$do,{
    
    mypallete    = mypallete_spec_10
    mycolorlabel = labels_spec_10
    colortitle   = 'Score'
    
    # quantile palletes are not suitable when the number of data points is very low
    # while the 'where to live', 'look for top 5' mentality very often leads to a very small data size --> this will cause a session FREEZE
    #
    # quantile color palletes has its obvious advantage though, so I let some alternative lines here just for fun
    #
    pal <- colorBin(mypallete, c(0,100), bins = 10, pretty = FALSE, na.color = "transparent", alpha = FALSE, reverse = TRUE)
    # pal <- colorQuantile("YlOrRd", NULL, n = 20)
    # pal <- colorQuantile(mypallete, NULL, n = 20, reverse = TRUE, na.color = "transparent")
    # pal <- colorBin("RdBu", c(-10,10), bins = 11, pretty = TRUE, na.color = "#808080", alpha = FALSE, reverse = FALSE)
    
    
    # ------------------------------------------------------------ special note -------------------------------------------------------
    # About the color bar
    #
    # When user select more than 1 input categories (check more than 1 boxes), the color is a weighted average based on normalized data
    # where the data itself loses units and specific physical meaning, in which case a general spectral color pallete is selected
    #
    # HOWEVER -- 
    #
    # When user only seclets 1 input category, this might be the time to plot the original data (pre-norm), so it could be digested with
    # the proper units. If this is the case, the color bar might also need to be specifically adjusted, for example:
    #
    # Traditionally, when plotting political data from the US, blue represents the Democratic Party (DEM), and red the Republican (GOP),
    # when plotting the voting difference (dem% - gop%), one might want to set blue to >0, red to <0
    #
    # This is purely based on user experience consideration.
    # ----------------------------------------------------------------------------------------------------------------------------------
    
    if (input$ck2 == TRUE & !any(input$ck1,input$ck3,input$ck4,input$ck5,input$ck6,input$ck7,input$ck100)) {
      
      # slider inputs should still have an impact as row filters
      color_val                   = rep(NaN, nrow(dummy2))
      color_val[weighted_val()$i] = dummy2[weighted_val()$i,2]
      
      mypallete    = mypallete_RdBu_10
      mycolorlabel = labels_RdBu_10
      colortitle   = '2016 Election'
      
      # fine tune color selection
      pal <- colorBin(mypallete, c(-1,1), bins = 10, na.color = "transparent", alpha = FALSE, reverse = FALSE)
    } else color_val = as.vector(weighted_val()$v)
    
                                                                                               #### <- additional special color palletes
    # ----------------------------------------------------------------------------------------------------------------------------------
      
      # polygon update module
    proxy <- leafletProxy("map")
    proxy %>%
      clearShapes() %>%
      addPolygons(data=leafmap, fillColor = pal(color_val), fillOpacity = 0.8, color = "#BDBDC3", weight = 1, popup = popup_dat()) %>%
      addLegend("bottomleft", title= colortitle, colors = mypallete, labels = mycolorlabel, layerId="colorLegend")
      #pal=pal, values=color_val,
    
  }) # end of observe
  
  # ======================================== #
  #     interaction with tab 2 data table    #
  # =========================================#
  
  # drop a marker for the counties highlighted in tab 2 data table
  observe({
    
    s = input$leafmaptable_rows_selected   # '_rows_selected' is the leaflet syntax observing mouse click on data tables
    
    markers       = mydf[weighted_val()$i,][s,c("lat","lon","county_state")]

    # label_content = as.data.frame(leafmap)[weighted_val()$i,][s,c("county_state")]

    proxy <- leafletProxy("map")
    proxy %>% 
      clearMarkers() %>% 
      addMarkers(lat = markers[,1], lng = markers[,2])
      # addMarkers(lat = markers[,1], lng = markers[,2], label = markers[,3])   # for some reason, the marker label doesn't work for me here

  })
  
  
  # getting lat lon from mouse click
  clicklatlon <- function () {                                     # some Shiny-learning self notes
    # clicklonlat <-- eventReactive(input$map_shape_click,{        # this doe NOT work
    # clicklonlat <-- reactive({                                   # this doe NOT work
    # observe({                                                    # this works
    # observeEvent(input$map_shape_click,{                         # this works
    
    rbind(c(input$map_shape_click$lng, input$map_shape_click$lat))
    
  }
  
  
  # reder text for the (lat,lng) from mouse click to UI
  output$click_lat_lon = renderPrint({
    if (!is.null(input$map_shape_click)) {
      cat(input$map_shape_click$lat, input$map_shape_click$lng)                           # observe mouse click, render lat lng as text
    }
  })
 
 # drop marker if the dynamic distance box is checked
 observe({                                                                                # observe mouse click, and put a marker on map
   s = input$map_shape_click
   if(input$ck100 & (!is.null(s))) {     # stay close to  --> red heart icon
     labelinfo = 'stay close to'
     myUrl = 'http://www.clker.com/cliparts/5/4/e/f/133831998776815806Red%20Heart.svg'    
     if (input$radio100 == 2) {          # stay away from --> blue broken heart...
       labelinfo = 'stay away from'
       myUrl = 'http://cdn.mysitemyway.com/etc-mysitemyway/icons/legacy-previews/icons-256/blue-jelly-icons-culture/024890-blue-jelly-icon-culture-heart-broken1-sc44.png'
       } 
     
     # drop marker
     proxy <- leafletProxy("map",data=leafmap)                                            
     proxy %>%
       clearMarkers() %>%
       addMarkers(lng = s$lng, lat = s$lat,
                  icon = icons(iconUrl = myUrl,
                               iconWidth = 30, iconHeight = 30),
                  label = labelinfo)
   }
   
 })
 
 
 # ========================= #
 #    floating radar chart   #     a quick visual strength / weakness multi-variable plot
 # ========================= #
 
 # output$radar <- renderChartJSRadar({                # this is supposed to work, but not stable from my experience
 output$radar <- renderUI({
   
   # ------------------------------------------------- thoughts about the radar chart --------------------------------------------
   # The radar chart here is designed to help understanding the strengh and weakness for the top ranked locations.
   # We will plot many measurements for the chosen location, EVEN IF the user decides not to include certain input data, 
   # by leaving some boxes in the control panel unchecked.
   #
   # I prefer to look at the full strenth/weakness, when a small number of final candidates survived through the filtering and 
   # digestion funnel, and we are very close to a final conclusion (winner) -- in case certain neglected aspects are so extreme
   # that should trigger a second thought.
   #
   # In other words, this is a "what we've missed before I sign the contract' visualization.
   #
   #                                                      -------------------------
   #
   # The 25%, 50%, 75% quantile are also plotted, so there is a visual reminder of what the benchmark crowd might look like
   #
   # When trying to choose top 5-10 from 3000+ counties, we are really often looking for outliers. I think it would be helpful
   # to have some info reminding the user what a "average America range" looks like.
   #
   #
   #                                                      -------------------------
   #
   # The chartJSRadar is flexible enough, that one can click on the name tags of plotted polygons, to toggle them on and off.
   # This is a very nice design by the author of the package, as radar charts are very hard to read when too many things are plotted.
   # -----------------------------------------------------------------------------------------------------------------------------

   # flip values following user's input -- this is the same thing in the weighted_val()
   radio_chk = c(input$radio2 == 2, input$radio7 == 2)
   cols_flip = c(2,7)[radio_chk]
   
   if (length(cols_flip)!=0) mydf_norm[,cols_flip] = scalar - mydf_norm[,cols_flip]        # render radar chart
   
   radardf       = mydf_norm                      # potential memory waste -- worth some additional thought when I revisit. Now it works...
   radardf$score = weighted_val()$v
   
   radardf$county_names = mydf$county_state
   
   radardf <- radardf %>%
     filter(!is.na(score)) %>%
     arrange(desc(score))
   
   radardf_plot <- radardf[,c(1,2,3,4,5,6,7)]                                                  ####### room for improvement
   
   scores_top        = as.data.frame(t(head(radardf_plot,3)))                                        
   names(scores_top) = head(radardf$county_names,3)
   labs              = c("air","vote","income","cost","income/cost","crime rate","pop den")    ####### room for improvement
   
   # quantile data
   qt = lapply(mydf_norm, quantile, name=FALSE, na.rm=TRUE)
   dd = as.data.frame(matrix(unlist(qt), nrow=length(unlist(qt[1]))))
   
   scores_qt        = as.data.frame(t(dd[2:4,]))
   names(scores_qt) = c("25%", "median", "75%")

   scores_plot = cbind(scores_top, scores_qt)
   
   tagList(chartJSRadar(scores_plot, labs , maxScale = NULL))             # the use of tagList here is worth noting
                                                                          # this is a trick from one of Joe Cheng's online reply that
                                                                          # would make this renderUI work
 }) # end of renderUI (or renderChartJSRadar if it is more stable in the future)
 
 
 
 
 # ======================================================================================
 # ======================================================================================
 # ====================              Tab 2 STARTS               =========================
 # ======================================================================================
 # ======================================================================================
 
 # -------------------------------------------------------------------------------------
 # Tab 2 is a searchable data table
 # The key features are
 #    1) the rows displayed in tab 2 is the filterd result from tab 1 sliders
 #    2) user can click on multiple rows here on the data table, there is a logic above
 #       taking the (lat, lng) from highlighted rows, and drop markers on the tab 1 map
 # -------------------------------------------------------------------------------------
 
 output$leafmaptable = DT::renderDataTable({
   
   # render FILTERED data table for tab 2, with dynamically calculated SCORE ADDED 
   #   -- calculated score is attached, so user can sort by the dynamic score
   cbind("score" = round(weighted_val()$v[weighted_val()$i],0), as.data.frame(leafmap)[weighted_val()$i,])

 })

 
 # ======================================================================================
 # ====================         Map related logic ENDS          =========================
 # ====================                                         =========================
 # ====================      Tab 3 Corr Plot Logic STARTS       =========================
 # ======================================================================================
 
 # the motivation for the correlation matrix analysis is that,
 # certain variables people usually consider while making a ranking decision might be highly CORRELATED.
 # this is an effort to detect them with an interactive interface
 
 # -----------------------------------------------------------------------------
 # The correlation matrix tab is largely adapted from saurfang's
 #            https://github.com/saurfang/shinyCorrplot
 # The whole thing is a very flexible and interactive correlation matrix plotter
 # -----------------------------------------------------------------------------
 
 dataset <- reactive({
   mydf
 })
 
 numericColumns <- reactive({
   df <- dataset()
   colnames(df)[sapply(df, is.numeric)]                                             # get col names
 })
 
 correlation <- reactive({
   data <- dataset()
   variables <- input$variables
   if(is.null(data) || !length(intersect(variables, colnames(data)))) {
     NULL
   } else {
     cor(dataset()[,input$variables], use = input$corUse, method = input$corMethod) # computational core -- corr calc
   }
 })
 
 sigConfMat <- reactive({
   val <- correlation()
   if(!is.null(val))
     corTest(val, input$confLevel)                                                  # calling correlation function, 
                                                                                    # send to corTest then calc for p-value and CI
 })
 
 ## Data and Correlation Validation and UI Updates ##########
 
 #Update hclust rect max
 observe({
   val <- correlation()
   if(!is.null(val))
     updateNumericInput(session, "plotHclustAddrect", max = nrow(val))
 })
 
 #Update variable selection
 observe({
   updateCheckboxGroupInput(session, "variablesCheckbox", choices = numericColumns(), selected = numericColumns())
   
   updateSelectInput(session, "variables", choices = numericColumns(), selected = numericColumns())
 })
 
 #Link Variable Selection
 observe({
   if(input$variablesStyle == "Checkbox") {
     updateCheckboxGroupInput(session, "variablesCheckbox", selected = isolate(input$vairables))
   }
 })
 observe({
   updateSelectInput(session, "variables", selected = input$variablesCheckbox)
 })
 
 output$warning <- renderUI({
   val <- correlation()
   if(is.null(val)) {
     tags$i("Waiting for data input...")
   } else {
     isNA <- is.na(val)
     if(sum(isNA)) {
       tags$div(
         tags$h4("Warning: The following pairs in calculated correlation have been converted to zero because they produced NAs!"),
         helpText("Consider using an approriate NA Action to exclude missing data"),
         renderTable(expand.grid(attr(val, "dimnames"))[isNA,]))
     }
   }
 })
 
 ## Correlation Plot ####################################
 
 output$corrPlot <- renderPlot({
   val <- correlation()
   if(is.null(val)) return(NULL)
   
   val[is.na(val)] <- 0
   args <- list(val,
                order = if(input$plotOrder == "manual") "original" else input$plotOrder, 
                hclust.method = input$plotHclustMethod, 
                addrect = input$plotHclustAddrect,
                
                p.mat = sigConfMat()[[1]],
                sig.level = if(input$sigTest) input$sigLevel else NULL,
                insig = if(input$sigTest) input$sigAction else NULL,
                
                lowCI.mat = sigConfMat()[[2]],
                uppCI.mat = sigConfMat()[[3]],
                plotCI = if(input$showConf) input$confPlot else "n")
   
   if(input$showConf) {
     do.call(corrplot, c(list(type = input$plotType), args))
   } else if(input$plotMethod == "mixed") {
     do.call(corrplot.mixed, c(list(lower = input$plotLower,
                                    upper = input$plotUpper),
                               args))
   } else {
     do.call(corrplot, c(list(method = input$plotMethod, type = input$plotType), args))
   }
 }) # end of renderPlot to output$corrPlot
 
 # ======================================================================================
 # ====================                                         =========================
 # ====================          Corr Plot Logic Ends           =========================
 # ====================                                         =========================
 # ======================================================================================
 
} # end of server.R