# ##############################################
# # Twitch Graph -- 
# # Scraping Project @ NYC Data Science Academy
# # 
# #
# # Chao Shi
# # chao.shi.datasci@gmail.com
# # 5/7/2017
# ##############################################
# 
function(input, output, session) {
  
  
  c2g_n <- function() {
    
    # search from selected CHANNELS
    ind_c = which(cinfo$engid %in% input$channalname)
    c2g_c = c2g[c2g[,2] %in% (ind_c-1),]
    
    # search from selected TEAMS
    ind_g = which(ginfo$team_name %in% input$teamname)
    c2g_g = c2g[c2g[,3] %in% (ind_g-1),]
    
    # merge
    c2g_n = unique(rbind(c2g_c, c2g_g))
    
    if (input$expand) {
      for (i in seq(input$expand)){
        # c-2, g-3
        c2g_c = c2g[c2g[,2] %in% c2g_n[,2],]
        c2g_g = c2g[c2g[,3] %in% c2g_n[,3],]
        c2g_n = unique(rbind(c2g_c, c2g_g))
      }
    }
    c2g_n
    
  }
  
  # get_links <- function(c2g_n){
  get_links <- reactive({
    links      = data.frame(c2g_n())
    n          = dim(c2g_n())[1]
    links$X    = NULL
    links$wid  = rep_len(5,n)
    links
  })
  
  
  get_Nodes_cu <- reactive({
    
    links = get_links()
    
    Nodes_c      = data.frame(links$c,cinfo$display_name[links$c+1])
    Nodes_c$size = sqrt(cinfo$view_per_day[links$c+1])   
    
    Nodes_cu = unique.data.frame(Nodes_c)
    nc       = dim(Nodes_cu)[1]
    
    Nodes_cu$group = rep_len(1,nc)
    Nodes_cu$group = cinfo$last_game[Nodes_cu$link]
    
    Nodes_cu        = Nodes_cu[,c(1,2,4,3)]
    names(Nodes_cu) = c('link','name','group','size')
    
    Nodes_cu
  })
  
  
  get_Nodes_gu <- reactive({
    
    links = get_links()
    
    Nodes_g = data.frame(links$g,ginfo$team_name[links$g+1])
    Nodes_gu = unique.data.frame(Nodes_g)
    
    ng = dim(Nodes_gu)[1]
    
    Nodes_gu$group = rep_len('TEAMS',ng)
    Nodes_gu$size  = sqrt(ginfo$team_view_per_day[Nodes_gu$link+1])
    
    names(Nodes_gu) = c('link','name','group','size')
    Nodes_gu
  })
  
  
  
  
  GraphInfo <- reactive ({  
    links = get_links()
    
    Nodes_cu  = get_Nodes_cu() # nodes from channels
    Nodes_gu  = get_Nodes_gu() # nodes from teams / groups
    
    Nodes_gcu = rbind.data.frame(Nodes_gu,Nodes_cu)
    
    rownames(Nodes_gcu) <- 1:dim(Nodes_gcu)[1]-1
    
    # need to remap indecies here -- pointers now need to point to the subset of data
    links$g = match(links$g, Nodes_gu$link) - 1   # remapping, -1 is package specific
    links$c = match(links$c, Nodes_cu$link) + dim(Nodes_gu)[1] - 1  # cu comes after gu
    
    list(l = links, n = Nodes_gcu)
  })

  output$force <- renderForceNetwork({
    forceNetwork(Links = GraphInfo()$l, Nodes = GraphInfo()$n, Source = "c",
                 Target = "g", Value = "wid", NodeID = "name",
                 Group = "group", Nodesize = "size",opacity = input$opacity,
                 zoom = TRUE,legend = TRUE)
  })
  
  # # debug
  # output$test = renderPrint({
  #   print(GraphInfo())
  # })
  
  # I'll work on this later
    # # drop a marker for the counties highlighted in tab 2 data table
    # observe({
    # 
    #   s = input$channelinfotable_rows_selected   # '_rows_selected' is the leaflet syntax observing mouse click on data tables
    # 
    #   markers       = cinfo[s,"engid"]
    # 
    #   # label_content = as.data.frame(leafmap)[weighted_val()$i,][s,c("county_state")]
    # 
    #   proxy <- leafletProxy("map")
    #   proxy %>%
    #     clearMarkers() %>%
    #     addMarkers(lat = markers[,1], lng = markers[,2])
    #     # addMarkers(lat = markers[,1], lng = markers[,2], label = markers[,3])   # for some reason, the marker label doesn't work for me here
    # 
    # })
  


   output$channelinfotable = DT::renderDataTable({
     
     cinfo
   })

   output$teaminfotable = DT::renderDataTable({
     
     ginfo
     
   })

} # end of server.R