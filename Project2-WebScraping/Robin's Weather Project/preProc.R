library(dplyr)
library(stringr)

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
  Table$Month = strftime(Table$Date, '%m-%b')
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
  Table = summarize(group_by(Table,Date),temperature =mean(temperature),
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
COLORADO = formatData('./weatherThirtyYearsCOS1986.csv')
write.csv(COLORADO, file = "./COLORADO.csv")
NEWYORK = formatData('./weatherThirtyYearsJFK1986.csv')
write.csv(NEWYORK, file = "./NEWYORK.csv")

head(ALASKA)
head(DC)

class(ALASKA$temperature)

