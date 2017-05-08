library(dplyr)
library(stringr)
#this function reduces the size of the data and cleans it up
formatData = function(file){
  Table = read.csv(file, stringsAsFactors = FALSE)
  #this might be necessary for earlier tables
  #Table = select(Table, -conditions, -events )
  Table$temperature = as.numeric(Table$temperature)
  Table$Date = as.Date(Table$Date,'%A, %b %d, %Y')
  Table$time = strptime(Table$time, "%I:%M %p" )
  Table$hour = strftime(Table$time, "%I-%p")
  #time uses today's date and is stored as a unix object
  #we're only interested in the hour so we remove the rest from our table
  Table = select(Table, -time)
  #this gets weekly averages as a string (daily is difficult to plot quickly)
  Table$WeeklyAveragesString = strftime(Table$Date, '%Y-%U-%m')
  #this gets weekly averages as numeric so we can perform regression
  Table$WeeklyAverages = as.numeric(as.POSIXct(Table$Date), origin="1970-01-01")
  Table$Year = strftime(Table$Date, '%Y')
  Table$precipitation[Table$precipitation == "N/A"] = "0"
  Table$windSpeed[Table$windSpeed == 'Calm'] = "0"
  Table$precipitation = as.numeric(Table$precipitation)
  Table$pressure = as.numeric(Table$pressure)
  Table$windSpeed = as.numeric(Table$windSpeed)
  Table$humidity = gsub("%","",Table$humidity)
  Table$humidity = as.numeric(Table$humidity)
  # a small percentage of rows are missing data
  Table = na.omit(Table)
  Table = summarize(group_by(Table,WeeklyAveragesString),
                    WeeklyAverages=mean(WeeklyAverages),
                    temperature =mean(temperature),
                    precipitation=sum(precipitation),
                    humidity=mean(humidity),
                    pressure=mean(pressure),
                    windSpeed=mean(windSpeed))
  return (Table)
}

ALASKA = formatData('./weatherThirtyYearsANC1986.csv')
write.csv(ALASKA, file = "./ALASKA.csv")
DC = formatData('./weatherThirtyYearsDCA1986.csv')
write.csv(DC, file = "./DC.csv")
CHICAGO = formatData('./weatherThirtyYearsORD1986.csv')
write.csv(CHICAGO, file = "./CHICAGO.csv")
NEWYORK = formatData('./weatherThirtyYearsJFK1986.csv')
write.csv(NEWYORK, file = "./NEWYORK.csv")
LA = formatData("./weatherThirtyYearsKLAX1986.csv")
write.csv(LA, file = "./LA.csv")
MIAMI = formatData("./weatherThirtyYearsKMIA1986.csv")
write.csv(MIAMI, file = "./MIAMI.csv")
SANFRANCISCO = formatData("./weatherThirtyYearsSFO1986.csv")
write.csv(SANFRANCISCO, file = "./SANFRANCISCO.csv")



