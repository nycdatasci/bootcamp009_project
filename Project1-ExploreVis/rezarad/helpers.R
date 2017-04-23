

getFaresData = function() {
  dbname = "db.sqlite"
  conn = DBI::dbConnect(RSQLite::SQLite(), dbname)
  
  turnstile_tbl = tbl(conn,"turnstile_data")
  fares_tbl = tbl(conn,"fares_data")
  
  fares_by_date = fares_tbl %>%
    select(`Date Range` = DATE_RANGE,
           Station = STATION,
           `Full Fare` = FF,
           `Senior Citizen/Disabled` = SEN.DIS,
           `7 Day Unlimited AFAS (ADA FARECARD ACCESS SYSTEM)` = X7.D.AFAS.UNL,
           `30 Day Unlimited AFAS (ADA FARECARD ACCESS SYSTEM)` =  X30.D.AFAS.RMF.UNL,
           `Joint Rail Road Ticket` = JOINT.RR.TKT,
           `7 Day Unlimited` = X7.D.UNL,
           `30 Day Unlimited` = X30.D.UNL,
           `14 Day Unlimited (Reduced Fare Media)` = X14.D.RFM.UNL,
           `1 Day Unlimited/Funpass` = X1.D.UNL,
           `14 Day Unlimited` = X14.D.UNL, 
           `7 Day Express Bus` = X7D.XBUS.PASS,
           `Transit Check Metro Card` = TCMC,
           `Reduced Fare 2 Trip` = RF.2.TRIP,
           `Rail Road Unlimited (No Trade?)` = RR.UNL.NO.TRADE,
           `Transit Check Metro Card (Annual)` = TCMC.ANNUAL.MC,
           `Mail and Ride Easy Pay (Express)` = MR.EZPAY.EXP,
           `Mail and Ride Easy Pay (Unlimited)` = MR.EZPAY.UNL,
           `PATH 2 Trip` = PATH.2.T,
           `Airtrain Full Fare` = AIRTRAIN.FF,
           `Airtrain 30 Day` = AIRTRAIN.30.D,
           `Airtrain 10 Trip` = AIRTRAIN.10.T,
           `Airtrain Monthly` = AIRTRAIN.MTHLY,
           `Student Fare` = STUDENTS,
           `NICE (Nassau Inter-County Express) 2 Trip` = NICE.2.T,
           `CUNY Unlimited Commuter Card` = CUNY.120 
    ) %>% 
    group_by(Station)
  
  fares_by_date = collect(fares_by_date) %>%
    separate(`Date Range`, c("Start Date", "End Date"), sep="-", remove = TRUE) %>%
    mutate(`Week Of` = as.Date(`Start Date`,format = "%m/%d/%Y")) %>% 
    group_by(Station) %>% 
    summarise_all(max)
  
  fares_by_date
}