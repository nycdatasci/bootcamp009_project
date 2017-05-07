shinyServer(function(input, output, session) {


  
##################################################################################################################
#####   Establish connection to database, see global.R #####  
  conn <- dbConnector(session, dbname = dbname)

##################################################################################################################
#####   Modifying dataframes in "All available products" tab based on user input #####  
  
#   Filter all the databases in "All available products" tab based on user input 
  filter_str_reactive <- reactive(
    paste("rating_n > ", input$rating_n-1,
          "AND ",
          "prod_price > ", input$price[1],
          "AND ",
          "prod_price < ", input$price[2],
          "AND ",
          "rating_val > ", rating_val_reactive()
    )
  )
  
#   Convert from star input to filter value for use in filter_str_reactive
  rating_val_reactive <- reactive(
    switch(input$rating_val,
           "all" = 0,
           "four" = 3.99,
           "three" = 2.99,
           "two" = 1.99,
           "one" = 0.99
           )
  )
  
##################################################################################################################
#####   Get datatables from pcpart.db for "All available products" tab #####  
  case_db <- reactive(dbGetData(conn = conn,
                                tblname = 'case_table',
                                spec_vec = c("prod_name as Name",
                                                "manufacturer as Manufacturer",
                                                "color as Color",
                                                "rating_val as `Average Rating`",
                                                "rating_n as `# of Ratings`",
                                                "prod_price as Price",
                                                "`motherboard compatibility` as `Motherboard Compatibility`",
                                                "`gpu limit in`"
                                             ),
                                filter_str_reactive()
                                ))
  
  cpu_db <- reactive(dbGetData(conn = conn,
                                tblname = 'cpu_table',
                                spec_vec = c("prod_name as Name",
                                             "manufacturer as Manufacturer",
                                             "rating_val as `Average Rating`",
                                             "rating_n as `# of Ratings`",
                                             "prod_price as Price",
                                             "socket as Socket"),
                               filter_str_reactive()
                               ))
  
  cooler_db <- reactive(dbGetData(conn = conn,
                               tblname = 'cooler_table',
                               spec_vec = c("prod_name as Name",
                                            "manufacturer as Manufacturer",
                                            "rating_val as `Average Rating`",
                                            "rating_n as `# of Ratings`",
                                            "prod_price as Price",
                                            "`supported sockets` as `Compatible Sockets`"),
                               filter_str_reactive()
                               ))
  
  gpu_db <- reactive(dbGetData(conn = conn,
                               tblname = 'gpu_table',
                               spec_vec = c("prod_name as Name",
                                            "manufacturer as Manufacturer",
                                            "rating_val as `Average Rating`",
                                            "rating_n as `# of Ratings`",
                                            "prod_price as Price",
                                            "chipset as Chipset",
                                            "`mem int` as `Memory (GB)`",
                                            "length"),
                               filter_str_reactive()
                               ))
  
  memory_db <- reactive(dbGetData(conn = conn,
                               tblname = 'memory_table',
                               spec_vec = c("prod_name as Name",
                                            "manufacturer as Manufacturer",
                                            "rating_val as `Average Rating`",
                                            "rating_n as `# of Ratings`",
                                            "prod_price as Price",
                                            "`num sticks` as `# of Sticks`",
                                            "`total mem` as `Total Memory (GB)`"),
                               filter_str_reactive()
                               ))
  
  motherboard_db <- reactive(dbGetData(conn = conn,
                                  tblname = 'motherboard_table',
                                  spec_vec = c("prod_name as Name",
                                               "manufacturer as Manufacturer",
                                               "rating_val as `Average Rating`",
                                               "rating_n as `# of Ratings`",
                                               "prod_price as Price",
                                               "`cpu socket` as Socket",
                                               "`form factor`",
                                               "`memory slots`"),
                                  filter_str_reactive()
                                  ))
  
  psu_db <- reactive(dbGetData(conn = conn,
                               tblname = 'psu_table',
                               spec_vec = c("prod_name as Name",
                                            "manufacturer as Manufacturer",
                                            "rating_val as `Average Rating`",
                                            "rating_n as `# of Ratings`",
                                            "prod_price as Price",
                                            "`watt n` as `Wattage (W)`"),
                               filter_str_reactive()
                               ))
  
  storage_db <- reactive(dbGetData(conn = conn,
                                       tblname = 'storage_table',
                                       spec_vec = c("prod_name as Name",
                                                    "manufacturer as Manufacturer",
                                                    "rating_val as `Average Rating`",
                                                    "rating_n as `# of Ratings`",
                                                    "prod_price as Price",
                                                    "`capacity total` as `Capacity (GB)`"),
                                   filter_str_reactive()
                                   ))
  
  
##################################################################################################################
#####   Output to UI datatables for "All available products" tab #####
  output$case_db <- renderDataTable({
    case_db()
  }, 
  options = list(scrollX = TRUE, pageLength = 10, searchDelay = 50))
  
  output$cpu_db <- renderDataTable({
    cpu_db()
  }, 
  options = list(scrollX = TRUE, pageLength = 10, searchDelay = 50))
  
  output$cooler_db <- renderDataTable({
    cooler_db()
  }, 
  options = list(scrollX = TRUE, pageLength = 10, searchDelay = 50))
  
  output$gpu_db <- renderDataTable({
    gpu_db()
  }, 
  options = list(scrollX = TRUE, pageLength = 10, searchDelay = 50))
  
  output$memory_db <- renderDataTable({
    memory_db()
  }, 
  options = list(scrollX = TRUE, pageLength = 10, searchDelay = 50))
  
  output$motherboard_db <- renderDataTable({
    motherboard_db()
  }, 
  options = list(scrollX = TRUE, pageLength = 10, searchDelay = 50))
  
  output$psu_db <- renderDataTable({
    psu_db()
  }, 
  options = list(scrollX = TRUE, pageLength = 10, searchDelay = 50))
  
  output$storage_db <- renderDataTable({
    storage_db()
  }, 
  options = list(scrollX = TRUE, pageLength = 10, searchDelay = 50))
  
##################################################################################################################
#####   Output to UI datatables for "Simple Build" tab #####
  output$simple_build_price <- renderValueBox(
    valueBox(subtitle = "Total build price",
      value = paste('$', cpu_db_2()[1, 'Price'] + 
        cooler_db_2()[1, 'Price'] +
        gpu_db_2()[1, 'Price'] +
        psu_db_2()[1, 'Price'] +
        memory_db_2()[1, 'Price'] +
        motherboard_db_2()[1, 'Price'] +
        storage_db_2()[1, 'Price'] + 
        case_db_2()[1, 'Price'],
        sep='')
    )
  )  
  
  output$simple_build_tdp <- renderValueBox(
    valueBox(subtitle = "Total estimated wattage",
             value = tdp_reactive()
    )
  )  
  
  
  cpu_db_2 <- reactive(dbGetData(conn = conn,
                                 tblname = 'cpu_table',
                                 spec_vec = c("prod_name as `CPU Name`",
                                              "manufacturer as `CPU Manufacturer`",
                                              "rating_val as `Average Rating`",
                                              "rating_n as `# of Ratings`",
                                              "prod_price as Price",
                                              "socket as Socket",
                                              "tdp"),
                                 orderby = c("ORDER BY rating_val DESC",
                                             "rating_n DESC ")
  ))
  
  output$simple_build_db_cpu <- renderDataTable({
    cpu_db_2()[1,]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:5), searchable = FALSE))))
  
  cooler_db_2 <- reactive(dbGetData(conn = conn,
                                 tblname = 'cooler_table',
                                 spec_vec = c("prod_name as `Cooler Name`",
                                              "manufacturer as `Cooler Manufacturer`",
                                              "rating_val as `Average Rating`",
                                              "rating_n as `# of Ratings`",
                                              "prod_price as Price"),
                                 orderby = c("ORDER BY rating_val DESC",
                                             "rating_n DESC "),
                                 filter_str = filter_str_cooler_simple()
  ))
  
  output$simple_build_db_cooler <- renderDataTable({
    cooler_db_2()[1,]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:4), searchable = FALSE))))
  
  case_db_2 <- reactive(dbGetData(conn = conn,
                                    tblname = 'case_table',
                                    spec_vec = c("prod_name as `Case Name`",
                                                 "manufacturer as `Case Manufacturer`",
                                                 "rating_val as `Average Rating`",
                                                 "rating_n as `# of Ratings`",
                                                 "prod_price as Price",
                                                 "type as Type",
                                                 "`internal 2.5in bays`",
                                                 "`internal 3.5in bays`",
                                                 "`external 3.5in bays`",
                                                 "`external 5.25in bays`"),
                                    orderby = c("ORDER BY rating_val DESC",
                                                "rating_n DESC "),
                                    filter_str = paste(filter_str_case_psu_simple(),
                                                       filter_case_plus())
  ))
  
  output$simple_build_db_case <- renderDataTable({
    case_db_2()[1, 1:6]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:5), searchable = FALSE))))
  
  gpu_db_2 <- reactive(dbGetData(conn = conn,
                                  tblname = 'gpu_table',
                                  spec_vec = c("prod_name as `GPU Name`",
                                               "manufacturer as `GPU Manufacturer`",
                                               "rating_val as `Average Rating`",
                                               "rating_n as `# of Ratings`",
                                               "prod_price as Price",
                                               "length as Length",
                                               "tdp"),
                                  orderby = c("ORDER BY rating_val DESC",
                                              "rating_n DESC ")
  ))
  
  output$simple_build_db_gpu <- renderDataTable({
    gpu_db_2()[1,]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:5), searchable = FALSE))))
  
  memory_db_2 <- reactive(dbGetData(conn = conn,
                                 tblname = 'memory_table',
                                 spec_vec = c("prod_name as `Memory Name`",
                                              "manufacturer as `Memory Manufacturer`",
                                              "rating_val as `Average Rating`",
                                              "rating_n as `# of Ratings`",
                                              "prod_price as Price",
                                              "speed",
                                              "`mem type`"),
                                 orderby = c("ORDER BY rating_val DESC",
                                             "rating_n DESC "),
                                 filter_str = filter_str_memory_simple()
  ))
  
  output$simple_build_db_memory <- renderDataTable({
    memory_db_2()[1,]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:4), searchable = FALSE))))
  
  motherboard_db_2 <- reactive(dbGetData(conn = conn,
                                    tblname = 'motherboard_table',
                                    spec_vec = c("prod_name as `Motherboard Name`",
                                                 "manufacturer as `Motherboard Manufacturer`",
                                                 "rating_val as `Average Rating`",
                                                 "rating_n as `# of Ratings`",
                                                 "prod_price as Price",
                                                 "`DDR type`",
                                                 "`memory type`",
                                                 "`form factor` as `Form Factor`",
                                                 "`max mem int`",
                                                 "`memory slots`"),
                                    orderby = c("ORDER BY rating_val DESC",
                                                "rating_n DESC "),
                                    filter_str = filter_str_motherboard_simple()
  ))
  
  output$simple_build_db_motherboard <- renderDataTable({
    motherboard_db_2()[1,]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:5), searchable = FALSE))))
  
  psu_db_2 <- reactive(dbGetData(conn = conn,
                                 tblname = 'psu_table',
                                 spec_vec = c("prod_name as `PSU Name`",
                                              "manufacturer as `PSU Manufacturer`",
                                              "rating_val as `Average Rating`",
                                              "rating_n as `# of Ratings`",
                                              "prod_price as Price",
                                              "`watt n` as `Power (W)`"),
                                 orderby = c("ORDER BY rating_val DESC",
                                             "rating_n DESC "),
                                 filter_str = paste(filter_str_case_psu_simple(),
                                                    filter_power_plus())
  ))
  
  output$simple_build_db_psu <- renderDataTable({
    psu_db_2()[1,]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:4), searchable = FALSE))))
  
  storage_db_2 <- reactive(dbGetData(conn = conn,
                                 tblname = 'storage_table',
                                 spec_vec = c("prod_name as `Storage Name`",
                                              "manufacturer as `Storage Manufacturer`",
                                              "rating_val as `Average Rating`",
                                              "rating_n as `# of Ratings`",
                                              "prod_price as Price"),
                                 orderby = c("ORDER BY rating_val DESC",
                                             "rating_n DESC "),
                                 filter_str = filter_str_storage_simple()
  ))
  
  output$simple_build_db_storage <- renderDataTable({
    storage_db_2()[1,]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:4), searchable = FALSE))))
  
######################################################################################## 
##### Hidden compatibility checks #####
  #(note: CPU has `includes cpu cooler` column for cheap builds)
  # CPU-motherboard: 'socket'-'cpu socket type'
  filter_str_motherboard_simple <- reactive(
    paste("rating_n > 0 ",
          "AND ",
          "prod_price > 0 ",
          "AND ",
          "`cpu socket type` = '", cpu_db_2()[1,'Socket'], "'",
          sep=''
    )
  )
  
  # CPU-cooler: 'socket'-'supported sockets' 
  filter_str_cooler_simple <- reactive(
    paste("rating_n > 0 ",
          "AND ",
          "prod_price > 0 ",
          "AND ",
          "`supported sockets` LIKE '%", cpu_db_2()[1,'Socket'], "%'",
          sep=''
    )
  )
  
  #Motherboard-PSU compatibility
  #PSUs have the following columns:
  #Micro ATX compatibility, Mini ITX compatibility, EATX compatibility, ATX compatibility
  
  # Motherboard-Case compatibility
  # Cases have the following columns:
  # ATX compatibility,	Micro ATX compatibility,	Mini ITX compatibility,	
  # EATX compatibility,	SSI EEB compatibility
  
  #Can use the same code for both:
  filter_str_case_psu_simple <- reactive(
    paste("rating_n > 0 ",
          "AND ",
          "prod_price > 0 ",
          "AND ",
          "`", motherboard_db_2()[1, 'Form Factor'],
          " compatibility` = 1",
          sep=''
    )
  )
  
  # Case-GPU
  # Case has `gpu limit in` column, gpu has `length` column, both may be missing values
  # Need to append this to the previous filter
  filter_case_plus <- reactive(
    paste(" AND ",
          "`gpu limit in` > ",
          gpu_db_2()[1, 'Length'],
          sep='')
  )
  
  # Case-Storage
  #`2.5in form` and `3.5in form` are boolean columns in storage
  filter_str_storage_simple <- reactive(
    paste("rating_n > 0 ",
          "AND ",
          "prod_price > 0 ",
          "AND ",
          "`2.5in form` <= ",
          case_db_2()[1, 'internal 2.5in bays'],
          " AND ",
          "(`3.5in form` <= ",
          case_db_2()[1, 'internal 3.5in bays'],
          " OR ",
          "`3.5in form` <= ",
          case_db_2()[1, 'external 3.5in bays'],
          ")",
          sep=''
    )
  )
  
  #Motherboard-Memory: memory['speed'] is mem_speed
  # def mobo_ram_compatibility(mem_speed):
  #     mem_type = int(re.search('^DDR([234])', mem_speed).group(1))
  #       temp_bool_type = [mem_type == x for x in motherboard['DDR type']]
  # 
  #     mem_n = re.search('([0-9]{2,4})', mem_speed).group(1)
  #       temp_bool_n = [(mem_n in x) for x in motherboard['memory type']]
  #   return ([a and b for a, b in zip(temp_bool_type, temp_bool_n)])
  
  filter_str_memory_simple <- reactive(
    paste("rating_n > 0 ",
          "AND ",
          "prod_price > 0 ",
          "AND ",
          "`speed type` = ",
          motherboard_db_2()[1, 'DDR type'],
          " AND '",
          motherboard_db_2()[1, 'memory type'],
          "' LIKE '%' || `speed n` || '%'",
          " AND `total mem` < ",
          motherboard_db_2()[1, 'max mem int'],
          " AND '",
          motherboard_db_2()[1, 'memory slots'],
          "' LIKE '%' || `mem type` || '%'",
          sep=''
    )
  )
  
  ### Last compatibility: Power usage:
  # CPU = 'tdp'
  # GPU = 'tdp'
  # Cooler = 10 for standard, 15 for liquid cooled
  # Motherboard = 60 for old, 70 for new
  # Memory = 9 for DDR3, 7 for DD4 (per stick)
  # Storage = 20 for HDD, 10 for SSD
  # Not full implemented, using max for each discrete range, e.g. 20 for storage
  filter_power_plus <- reactive(
    paste(" AND ",
          "`Power (W)` > ",
          tdp_reactive(),
          sep=''
    )
  )
  
  tdp_reactive <- reactive(
    as.integer(gpu_db_2()[1,'tdp']) + as.integer(cpu_db_2()[1, 'tdp']) +
      15 + 70 + 36 + 20
  )
  
######################################################################################## 
##### More rigorous build generator #####  
  
#######################################################################################
#####   Output to UI datatables for "Rigorous Build" tab #####
  output$rig_build_price <- renderValueBox(
    valueBox(subtitle = "Total build price",
             value = paste('$', cpu_db_3()[1, 'Price'] + 
                             cooler_db_3()[1, 'Price'] +
                             gpu_db_3()[1, 'Price'] +
                             psu_db_3()[1, 'Price'] +
                             memory_db_3()[1, 'Price'] +
                             motherboard_db_3()[1, 'Price'] +
                             storage_db_3()[1, 'Price'] + 
                             case_db_3()[1, 'Price'],
                           sep='')
    )
  )  
  
  output$rig_build_tdp <- renderValueBox(
    valueBox(subtitle = "Total estimated wattage",
             value = tdp_reactive()
    )
  )
  
  output$rig_average_rating <- renderValueBox(
    valueBox(subtitle = "Average rating of all parts",
             value = round(as.numeric(paste(cpu_db_3()[1, 'Average Rating'] + 
                             cooler_db_3()[1, 'Average Rating'] +
                             gpu_db_3()[1, 'Average Rating'] +
                             psu_db_3()[1, 'Average Rating'] +
                             memory_db_3()[1, 'Average Rating'] +
                             motherboard_db_3()[1, 'Average Rating'] +
                             storage_db_3()[1, 'Average Rating'] + 
                             case_db_3()[1, 'Average Rating'],
                           sep=''))/8.0,2))
  )
  
  
  cpu_db_3 <- reactive(dbGetData(conn = conn,
                                 tblname = 'cpu_table',
                                 spec_vec = c("prod_name as `CPU Name`",
                                              "manufacturer as `CPU Manufacturer`",
                                              "`operating frequency` as `Freq. (GHz)`",
                                              "lithography as `Litho Node (nm)`",
                                              "rating_val as `Average Rating`",
                                              "rating_n as `# of Ratings`",
                                              "prod_price as Price",
                                              "socket as Socket",
                                              "tdp"),
                                 orderby = order_cpu(),
                                 filter_str = paste(filter_str_cpu_rig(),
                                                    filter_overclock_cpu())
  ))
  
  output$rig_build_db_cpu <- renderDataTable({
    cpu_db_3()[1,1:7]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:6), searchable = FALSE))))
  
  cooler_db_3 <- reactive(dbGetData(conn = conn,
                                    tblname = 'cooler_table',
                                    spec_vec = c("prod_name as `Cooler Name`",
                                                 "manufacturer as `Cooler Manufacturer`",
                                                 "`numeric size` as `Size (mm)`",
                                                 "rating_val as `Average Rating`",
                                                 "rating_n as `# of Ratings`",
                                                 "prod_price as Price",
                                                 "`liquid cooled`"),
                                    orderby = order_cooler(),
                                    filter_str = paste(filter_str_cooler_rig(),
                                                       filter_liquid_cooled())
  ))
  
  output$rig_build_db_cooler <- renderDataTable({
    cooler_db_3()[1,1:6]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:5), searchable = FALSE))))
  
  case_db_3 <- reactive(dbGetData(conn = conn,
                                  tblname = 'case_table',
                                  spec_vec = c("prod_name as `Case Name`",
                                               "manufacturer as `Case Manufacturer`",
                                               "type as Type",
                                               "rating_val as `Average Rating`",
                                               "rating_n as `# of Ratings`",
                                               "prod_price as Price",
                                               "`internal 2.5in bays`",
                                               "`internal 3.5in bays`",
                                               "`external 3.5in bays`",
                                               "`external 5.25in bays`",
                                               "`front panel usb 3.0 ports` as usb3"),
                                  orderby = order_case(),
                                  filter_str = paste(filter_str_case_psu_rig(),
                                                     filter_case_plus_rig(),
                                                     filter_usb3())
  ))
  
  output$rig_build_db_case <- renderDataTable({
    case_db_3()[1,1:6]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:5), searchable = FALSE))))
  
  gpu_db_3 <- reactive(dbGetData(conn = conn,
                                 tblname = 'gpu_table',
                                 spec_vec = c("prod_name as `GPU Name`",
                                              "manufacturer as `GPU Manufacturer`",
                                              "`mem int` as `VRAM (GB)`",
                                              "`core n` as `Freq. (GHz)`",
                                              "rating_val as `Average Rating`",
                                              "rating_n as `# of Ratings`",
                                              "prod_price as Price",
                                              "length as Length",
                                              "tdp"),
                                 orderby = order_gpu(),
                                 filter_str = paste(filter_str_gpu_rig(),
                                                     filter_overclock_gpu())
  ))
  
  output$rig_build_db_gpu <- renderDataTable({
    gpu_db_3()[1,1:7]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:6), searchable = FALSE))))
  
  memory_db_3 <- reactive(dbGetData(conn = conn,
                                    tblname = 'memory_table',
                                    spec_vec = c("prod_name as `Memory Name`",
                                                 "manufacturer as `Memory Manufacturer`",
                                                 "speed as Type",
                                                 "size as Size",
                                                 "rating_val as `Average Rating`",
                                                 "rating_n as `# of Ratings`",
                                                 "prod_price as Price",
                                                 "`mem type`"),
                                    orderby = order_memory(),
                                    filter_str = filter_str_memory_rig()
  ))
  
  output$rig_build_db_memory <- renderDataTable({
    memory_db_3()[1,1:7]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:6), searchable = FALSE))))
  
  motherboard_db_3 <- reactive(dbGetData(conn = conn,
                                         tblname = 'motherboard_table',
                                         spec_vec = c("prod_name as `Motherboard Name`",
                                                      "manufacturer as `Motherboard Manufacturer`",
                                                      "`form factor` as `Form Factor`",
                                                      "rating_val as `Average Rating`",
                                                      "rating_n as `# of Ratings`",
                                                      "prod_price as Price",
                                                      "`DDR type`",
                                                      "`memory type`",
                                                      "`max mem int`",
                                                      "`memory slots`",
                                                      "`onboard usb 3.0 header(s)` as usb3"),
                                         orderby = order_motherboard(),
                                         filter_str = paste(filter_str_motherboard_rig(),
                                                            filter_usb3())
  ))
  
  output$rig_build_db_motherboard <- renderDataTable({
    motherboard_db_3()[1,1:6]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:5), searchable = FALSE))))
  
  psu_db_3 <- reactive(dbGetData(conn = conn,
                                 tblname = 'psu_table',
                                 spec_vec = c("prod_name as `PSU Name`",
                                              "manufacturer as `PSU Manufacturer`",
                                              "`watt n` as `Power (W)`",
                                              "rating_val as `Average Rating`",
                                              "rating_n as `# of Ratings`",
                                              "prod_price as Price"),
                                 orderby = order_psu(),
                                 filter_str = paste(filter_str_case_psu_rig(),
                                                    filter_power_plus_rig())
  ))
  
  output$rig_build_db_psu <- renderDataTable({
    psu_db_3()[1,]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:5), searchable = FALSE))))
  
  storage_db_3 <- reactive(dbGetData(conn = conn,
                                     tblname = 'storage_table',
                                     spec_vec = c("prod_name as `Storage Name`",
                                                  "manufacturer as `Storage Manufacturer`",
                                                  "capacity as `Capacity (GB)`",
                                                  "rating_val as `Average Rating`",
                                                  "rating_n as `# of Ratings`",
                                                  "prod_price as Price"),
                                     orderby = order_storage(),
                                     filter_str = filter_str_storage_rig()
  ))
  
  output$rig_build_db_storage <- renderDataTable({
    storage_db_3()[1,]
  }, 
  options = list(scrollX = FALSE,
                 dom  = 't',
                 ordering = FALSE,
                 columnDefs = list(list(targets = c(0:5), searchable = FALSE))))
  
######################################################################################## 
##### Hidden compatibility checks: rigorous build #####
  #(note: CPU has `includes cpu cooler` column for cheap builds)
  # CPU-motherboard: 'socket'-'cpu socket type'
  filter_str_motherboard_rig <- reactive(
    paste("rating_n >= ",
          input$min_rating_n,
          " AND ",
          "rating_val >= ",
          input$min_rating,
          " AND ",
          "prod_price > 0 ",
          "AND ",
          "`cpu socket type` = '", cpu_db_3()[1,'Socket'], "'",
          sep=''
    )
  )
  
  filter_str_gpu_rig <- reactive(
    paste("rating_n >= ",
          input$min_rating_n,
          " AND ",
          "rating_val >= ",
          input$min_rating,
          " AND ",
          "prod_price > 0 ",
          sep=''
    )
  )
  
  filter_str_cpu_rig <- reactive(
    paste("rating_n >= ",
          input$min_rating_n,
          " AND ",
          "rating_val >= ",
          input$min_rating,
          " AND ",
          "prod_price > 0 ",
          sep=''
    )
  )
  
  # CPU-cooler: 'socket'-'supported sockets' 
  filter_str_cooler_rig <- reactive(
    paste("rating_n >= ",
          input$min_rating_n,
          " AND ",
          "prod_price > 0 ",
          " AND ",
          "rating_val >= ",
          input$min_rating,
          " AND ",
          "`supported sockets` LIKE '%", cpu_db_3()[1,'Socket'], "%'",
          sep=''
    )
  )
  
  #Motherboard-PSU compatibility
  #PSUs have the following columns:
  #Micro ATX compatibility, Mini ITX compatibility, EATX compatibility, ATX compatibility
  
  # Motherboard-Case compatibility
  # Cases have the following columns:
  # ATX compatibility,	Micro ATX compatibility,	Mini ITX compatibility,	
  # EATX compatibility,	SSI EEB compatibility
  
  #Can use the same code for both:
  filter_str_case_psu_rig <- reactive(
    paste("rating_n >= ",
          input$min_rating_n,
          " AND ",
          "rating_val >= ",
          input$min_rating,
          " AND ",
          "prod_price > 0 ",
          " AND ",
          "`", motherboard_db_3()[1, 'Form Factor'],
          " compatibility` = 1",
          sep=''
    )
  )
  
  # Case-GPU
  # Case has `gpu limit in` column, gpu has `length` column, both may be missing values
  # Need to append this to the previous filter
  filter_case_plus_rig <- reactive(
    paste(" AND ",
          "`gpu limit in` > ",
          gpu_db_3()[1, 'Length'],
          sep='')
  )
  
  # Case-Storage
  #`2.5in form` and `3.5in form` are boolean columns in storage
  filter_str_storage_rig <- reactive(
    paste("rating_n >= ",
          input$min_rating_n,
          " AND ",
          "rating_val >= ",
          input$min_rating,
          " AND ",
          "prod_price > 0 ",
          "AND ",
          "`2.5in form` <= ",
          case_db_3()[1, 'internal 2.5in bays'],
          " AND ",
          "((`3.5in form` <= ",
          case_db_3()[1, 'internal 3.5in bays'],
          ") OR (",
          "`3.5in form` <= ",
          case_db_3()[1, 'external 3.5in bays'],
          "))",
          sep=''
    )
  )
  
  #Motherboard-Memory: memory['speed'] is mem_speed
  # def mobo_ram_compatibility(mem_speed):
  #     mem_type = int(re.search('^DDR([234])', mem_speed).group(1))
  #       temp_bool_type = [mem_type == x for x in motherboard['DDR type']]
  # 
  #     mem_n = re.search('([0-9]{2,4})', mem_speed).group(1)
  #       temp_bool_n = [(mem_n in x) for x in motherboard['memory type']]
  #   return ([a and b for a, b in zip(temp_bool_type, temp_bool_n)])
  
  filter_str_memory_rig <- reactive(
    paste("rating_n >= ",
          input$min_rating_n,
          " AND ",
          "rating_val >= ",
          input$min_rating,
          " AND ",
          "prod_price > 0 ",
          "AND ",
          "`speed type` = ",
          motherboard_db_3()[1, 'DDR type'],
          " AND '",
          motherboard_db_3()[1, 'memory type'],
          "' LIKE '%' || `speed n` || '%'",
          " AND `total mem` < ",
          motherboard_db_3()[1, 'max mem int'],
          " AND '",
          motherboard_db_3()[1, 'memory slots'],
          "' LIKE '%' || `mem type` || '%'",
          sep=''
    )
  )
  
  ### Last compatibility: Power usage:
  # CPU = 'tdp'
  # GPU = 'tdp'
  # Cooler = 10 for standard, 15 for liquid cooled
  # Motherboard = 60 for old, 70 for new
  # Memory = 9 for DDR3, 7 for DD4 (per stick)
  # Storage = 20 for HDD, 10 for SSD
  # Not full implemented, using max for each discrete range, e.g. 20 for storage
  filter_power_plus_rig <- reactive(
    paste(" AND ",
          "`Power (W)` > ",
          tdp_reactive(),
          " AND ",
          "modular = '",
          input$modular_psu,
          "' ",
          "AND ",
          "`rating str` = '",
          input$efficiency_rating,
          "'",
          sep=''
    )
  )
  
  tdp_reactive <- reactive(
    as.integer(gpu_db_3()[1,'tdp']) + as.integer(cpu_db_3()[1, 'tdp']) +
      15 + 70 + 36 + 20
  ) 
######################################################################################## 
##### Metrics for rigorous build #####
# Case: 'rating_val', 'front panel usb 3.0 ports' (YN), 'internal 2.5in bays', 
#       'internal 3.5in bays', 'rating_n'
# Algorithm: 1) simple filter, rest) sort desc
  

  
#USB 3.0 compatibility: motherboard and case
  filter_usb3 <- reactive(
    ifelse(input$usb3, ' AND usb3 = \'Yes\'', '')
  )

#Case weighted input - currently boolean
  order_case <- reactive(
    ifelse(input$case_spec_weight, 
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "rating_val DESC"),
             "rating_n DESC",
             "prod_price ASC"),
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "`internal 2.5in bays` DESC"),
             "`internal 3.5in bays` DESC",
             "rating_val DESC",
             "prod_price ASC",
             "rating_n DESC"))
  )
  
# CPU: 'rating_val', 'operating frequency', 'max turbo frequency', 'cores', 'lithography',
# CPU cont.: 'l1 total', 'l2 total', 'l2-2 total', 'l3 total', 'rating_n'
# Algorithm: 1) simple filter on rating_val
#            2) weighted average based on freq's, cores and litho
#            3) sort by l's
  order_cpu <- reactive(
    ifelse(input$cpu_spec_weight, 
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "rating_val DESC"),
             "lithography ASC",
             "`operating frequency` DESC",
             "prod_price ASC",
             "rating_n DESC "),
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "lithography ASC"),
             "cores DESC",
             "`l3 total` DESC",
             "`l2 total` DESC",
             "`l1 total` DESC",
             "`operating frequency` DESC",
             "`max turbo frequency` DESC",
             "rating_val DESC",
             "prod_price ASC",
             "rating_n DESC"))
  )
  
  #Overclockable when max turbo > 0
  filter_overclock_cpu <- reactive(
    ifelse(input$overclock_cpu,
           ' AND `max turbo frequency` > 0',
           '')
  )
  
# Cooler: 'rating_val', 'numeric size','liquid cooled' (YN), 'fan rpm max'
  order_cooler <- reactive(
    ifelse(input$cooler_spec_weight, 
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "rating_val DESC"),
             "rating_n DESC "),
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "`numeric size`"),
             "rating_val DESC",
             "prod_price ASC",
             "rating_n DESC"))
  )
  
  #Liquid cooled filter
  filter_liquid_cooled <- reactive(
    ifelse(input$liquid, ' AND `liquid cooled` = 1', ' AND `liquid cooled` = 0')
  )
  
# GPU: 'rating_val', 'mem int', 'core n', 'boost n'
  # Missing large number of boost n values -- consider those with = overclockable
  order_gpu <- reactive(
    ifelse(input$cooler_spec_weight, 
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "rating_val DESC"),
             "`mem int` DESC",
             "rating_n DESC "),
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "`mem int` DESC"),
             "`core n` DESC",
             "rating_val DESC",
             "prod_price ASC",
             "rating_n DESC"))
  )
  
  #Overclock filter
  filter_overclock_gpu <- reactive(
    ifelse(input$overclock_gpu,
           ' AND `boost n` > 0',
           '')
  )

  # Memory: 'rating_val', 'total mem', price/gb (doesnt exist), 'num sticks'
  order_memory <- reactive(
    ifelse(input$memory_spec_weight,
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "rating_val DESC"),
             "`total mem` DESC",
             "`num sticks` ASC",
             "prod_price ASC",
             "rating_n DESC "),
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "`total mem` DESC"),
             "`num sticks` ASC",
             "prod_price ASC",
             "rating_val DESC",
             "rating_n DESC "))
  )
  
  # Motherboard: 'rating_val', 'max mem int', 'sata 6 gb/s', 'sata express', 'u.2', 'max gpus'
  order_motherboard <- reactive(
    ifelse(input$motherboard_spec_weight,
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "rating_val DESC"),
             "`max mem int` DESC",
             "`sata 6 gb/s` DESC",
             "prod_price ASC",
             "rating_n DESC "),
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "`max mem int` DESC"),
             "`sata 6 gb/s` DESC",
             "prod_price ASC",
             "rating_val DESC",
             "rating_n DESC "))
  )
  
  # Power: 'rating_val', 'watt n'/price, 'rating str'
  order_psu <- reactive(
    ifelse(input$psu_spec_weight,
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "rating_val DESC"),
             "`watt n` DESC",
             "prod_price ASC",
             "rating_n DESC "),
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "`watt n` DESC"),
             "prod_price ASC",
             "rating_val DESC",
             "rating_n DESC "))
  )
  
  # Storage: 'rating_val', 'capacity', 'price/gb'
  order_storage <- reactive(
    ifelse(input$storage_spec_weight,
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "rating_val DESC",
                   sep=''),
             "`capacity total` DESC",
             "prod_price ASC",
             "rating_n DESC "),
           c(paste("ORDER BY ",
                   price_priority_react(),
                   "`capacity total` DESC"),
             "prod_price ASC",
             "rating_val DESC",
             "rating_n DESC "))
  )
  
  price_priority_react <- reactive(
    ifelse(input$price_priority,
           'prod_price ASC,',
           '')
  )
  
})
