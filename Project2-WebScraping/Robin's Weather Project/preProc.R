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
COLORADO = formatData('./weatherThirtyYearsCOS1986.csv')
write.csv(COLORADO, file = "./COLORADO.csv")
NEWYORK = formatData('./weatherThirtyYearsJFK1986.csv')
write.csv(NEWYORK, file = "./NEWYORK.csv")
LA = formatData("./weatherThirtyYearsLAX1986.csv")

head(LA)
head(ALASKA)
head(DC)

class(ALASKA$temperature)

#for (location in c(ALASKA,DC,NEWYORK,CHICAGO)){
#  print (head(location)) #(location[["humidity"]])
for (measure1 in c(ALASKA$WeeklyAverages,ALASKA$precipitation,ALASKA$temperature,ALASKA$humidity,ALASKA$pressure,ALASKA$windSpeed)){
    for (measure1 in c(ALASKA$WeeklyAverages,ALASKA$precipitation,ALASKA$temperature,ALASKA$humidity,ALASKA$pressure,ALASKA$windSpeed)){
      if(measure1 != measure2)
      {
        if (summary(lm(measure1 ~ measure2, data=ALASKA))$r.squared > 0.25)
            print (paste(ALASKA,measure1,measure2))

      }
    }
      
#  }
}

dat_y<-(ALASKA[,c(2:1130)])

for(i in names(dat_y)){
  y <- ALASKA[i]
  model[[i]] = lm( y~humidity, data=dat_y )
}

for(i in names(ALASKA)){
  print (lm(humidity ~ i, data=ALASKA))
}
lapply( ALASKA[,c(3,4)], function(x) summary(lm(ALASKA$temperataure ~ x)) )
lapply( mtcars[,-1], function(x) summary(lm(mtcars$mpg ~ x)) )


models <- lapply(names(ALASKA)[3:7], function(x) {
  print (x)
  print(summary(lm(substitute(WeeklyAverages ~ i, list(i = as.name(x))), data = ALASKA))$r.squared)
})

Rsquared = function(x) {
  print (x)
  print(summary(lm(substitute(temperature ~ i, list(i = as.name(x))), data = ALASKA))$r.squared)
}

x = lapply(names(DC)[5:7],Rsquared)
for (location in c(ALASKA,DC,NEWYORK,CHICAGO)){
  print(lapply(names(location)[3:7],Rsquared))
}
