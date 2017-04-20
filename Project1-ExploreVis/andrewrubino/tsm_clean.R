library(dplyr)
library(lubridate)
library(data.table)

claims2010 <- read.table("claims_2010-2013.tsv", header = T, sep = '\t')
claims2014 <- read.table("claims_2014.tsv", header = T, sep = '\t')
claims2015 <- read.table("claims_2015.tsv", header = T, sep = '\t')

nrow(claims2010) #20945
nrow(claims2014) #4815
nrow(claims2015) #7472

# I want to do an rbind to these datasets assuming that they have same column names and types.

#check if column names are identical
names(claims2010)
names(claims2014)
names(claims2015)

# Change "Incident.D" to "Incident.Date" in claims2015 data 
names(claims2015)[3] = "Incident.Date"
# for some reason, the dplyr rename function was making R crash.

# Let's make the column structures of each dataset identical.
claims2010$Claim.Number <- as.factor(claims2010$Claim.Number)
claims2014$Claim.Number <- as.factor(claims2014$Claim.Number)
claims2015$Claim.Number <- as.factor(claims2015$Claim.Number)

# Convert Date.Received & Incident.Date. Use lubridate!
claims2015$Date.Received <- as.Date(claims2015$Date.Received, format = "%m/%d/%Y")
#head(guess_formats(claims2015$Date.Received, "dmy"))dates

claims2010$Date.Received <- as.Date(claims2010$Date.Received, "%d-%b-%y")
claims2010$Incident.Date <- as.Date(parse_date_time(claims2010$Incident.Date, "mdy HM"), "%m-%d-%Y")

claims2014$Date.Received <- as.Date(claims2014$Date.Received, "%d-%b-%y")
claims2014$Incident.Date <- as.Date(claims2014$Incident.Date, "%d-%b-%y")

claims2015$Date.Received <- as.Date(claims2015$Date.Received, "%d-%b-%y")
claims2015$Incident.Date <- as.Date(claims2015$Incident.Date, "%d-%b-%y")


# Okay. Combine datasets.
claims <- rbind(claims2010, claims2014, claims2015)

# More transformation. Make Close.Amount numeric
claims$Close.Amount <- as.numeric(sub('\\$', '', claims$Close.Amount))

# total missing rows. We want to replace the -'s with NAs
sum(is.na(claims))

# We need to do something aout the Item.Category column...too many combinations of
# the same category. Look later. For now...

claims %>% group_by(Airport.Name) %>%
  summarise(total_claims = n()) %>%
  top_n(20, total_claims) %>%
  arrange(desc(total_claims))

# save temp dataframe removing NA's from Close.Amount column
temp <- claims[!is.na(claims$Close.Amount),]

temp %>% group_by(Airport.Name) %>%
  summarise(total_close_amount = sum(Close.Amount),
            total_claims = n()) %>%
  arrange(desc(total_close_amount)) %>%
  top_n(20)

temp %>% group_by(Airline.Name) %>%
  summarise(total_close_amount = sum(Close.Amount),
            total_claims = n()) %>%
  arrange(desc(total_close_amount)) %>%
  top_n(20)
 


## use a set on Item.Category
# for loop through the column to count the category and add it to the new columns

y = strsplit(x, split = ";")

count = c()

for (i in 1:length(y)) {
  if (grep("Cosm", y[i]) == 1) {
    count[i] = 1
  }
  print(count)
}

sum(count)



ft <- claims$Item.Category[1:10]
ft <- as.character(ft)

dtf <- data.frame(it = ft)
Cosmetics.And.Grooming <- rep(0,nrow(dtf))
Cameras <- rep(0, nrow(dtf))
Other <- rep(0, nrow(dtf))
dtf <- cbind(dtf, Cosmetics.And.Grooming, Cameras, Other)

class(dtf$it)

if (grep("Cosm", dtf$it[1]) == 1) {
  dtf$Cosmetics.And.Grooming[1] = 1
}


z = unlist(strsplit(as.character(dtf$it[3][[1]]), split = ";"))
zz = unlist(strsplit(as.character(dtf$it[8][[1]]), split = ";"))

for (i in 1:nrow(dtf)) {
  if (dtf$it[i] %like% "Camera") {
    print("hello")
  }
}


for (i in 1:nrow(dtf)) {
  if (dtf$it[i] %like% "Camera") {
    count1 = c()
    for (j in 1:length(unlist(strsplit(as.character(dtf$it[i][[1]]), split = ";")))) {
      if (grep("Cam", unlist(strsplit(as.character(dtf$it[i][[1]]), split = ";"))[j]) == 1) {
        count1[j] = 1
      }
    dtf$Cameras[i] = length(count1)
    }
  }
  
  if (dtf$it[i] %like% "Cosmetics") {
    count2 = c()
    for (j in 1:length(unlist(strsplit(as.character(dtf$it[i][[1]]), split = ";")))) {
      if (grep("Cosm", unlist(strsplit(as.character(dtf$it[i][[1]]), split = ";"))[j]) == 1) {
        count2[j] = 1
      }
    dtf$Cosmetics.And.Grooming[i] = length(count2)
    }
  }
  
  if (dtf$it[i] %like% "Other") {
    count3 = c()
    for (j in 1:length(unlist(strsplit(as.character(dtf$it[i][[1]]), split = ";")))) {
      if (grep("Other", unlist(strsplit(as.character(dtf$it[i][[1]]), split = ";"))[j]) == 1) {
        count3[j] = 1
      }
    dtf$Other[i] = length(count3)
    }
  }
}

# Use data.table
temp <-data.table(claims, keep.rownames = TRUE)

# Try adding one column
temp[, Audio.Video := 0]

# Now try two
temp[, c("Automobile.Parts.Accessories", "Baggage.Cases.Purses") := list(0,0)]

# Now the rest
temp[, c("Books.Magazines.Other",
         "Cameras",
         "Clothing",
         "Computer.Accessories",
         "Cosmetics.Grooming",
         "Crafting.Hobby",
         "Currency",
         "Food.Drink",
         "Home.Decor",
         "Household.Items",
         "Hunting.Fishing.Items",
         "Jewelry.Watches",
         "Medical.Science",
         "Musical.Instruments.Accessories",
         "Office.Equipment.Supplies",
         "Other",
         "Outdoor.Items",
         "Personal.Accessories",
         "Personal.Electronics",
         "Personal.Navigation",
         "Sporting.Equipment.Supplies",
         "Tools.Home.Improvement.Supplies",
         "Toys.Games",
         "Travel.Accessories") := list(rep(0, each = 24))]

# cool. Time for this gnarly for loop. If you're copying and pasting from sublime,
# be wary of indentation erros

for (i in 1:nrow(temp)) {
  if (temp$Item.Category[i] %like% "Bagg") {
    countx = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Bagg", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        countx[j] = 1
      }
    temp$Baggage.Cases.Purses[i] = length(countx)
    }
  }
}

# Took a while. Let's try three at a time

for (i in 1:nrow(temp)) {
  if (temp$Item.Category[i] %like% "Camera") {
    count1 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Cam", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count1[j] = 1
      }
    temp$Cameras[i] = length(count1)
    }
  }
  
  if (temp$Item.Category[i] %like% "Cosmetics") {
    count2 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Cosm", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count2[j] = 1
      }
    temp$Cosmetics.Grooming[i] = length(count2)
    }
  }
  
  if (temp$Item.Category[i] %like% "Other") {
    count3 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Other", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count3[j] = 1
      }
    temp$Other[i] = length(count3)
    }
  }
}

## Took a while but worked. I think that, because of my paranoia, I'm going to run these
## loops with three columns at a time because I don't want to crash or break anything. 
## Maybe I'll do four at a time...

for (i in 1:nrow(temp)) {
  if (temp$Item.Category[i] %like% "Audio") {
    count1 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Audio", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count1[j] = 1
      }
    temp$Audio.Video[i] = length(count1)
    }
  }
  
  if (temp$Item.Category[i] %like% "Automobile") {
    count2 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Auto", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count2[j] = 1
      }
    temp$Automobile.Parts.Accessories[i] = length(count2)
    }
  }
  
  if (temp$Item.Category[i] %like% "Books") {
    count3 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Books", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count3[j] = 1
      }
    temp$Books.Magazines.Other[i] = length(count3)
    }
  }
  
  if (temp$Item.Category[i] %like% "Clothing") {
    count4 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Clothing", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count4[j] = 1
      }
    temp$Clothing[i] = length(count4)
    }
  }
}

## Takes about 6 minutes. Next one, let's try 5.

for (i in 1:nrow(temp)) {
  if (temp$Item.Category[i] %like% "Computer") {
    count1 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Computer", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count1[j] = 1
      }
    temp$Computer.Accessories[i] = length(count1)
    }
  }
  
  if (temp$Item.Category[i] %like% "Crafting") {
    count2 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Craft", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count2[j] = 1
      }
    temp$Crafting.Hobby[i] = length(count2)
    }
  }
  
  if (temp$Item.Category[i] %like% "Currency") {
    count3 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Currency", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count3[j] = 1
      }
    temp$Currency[i] = length(count3)
    }
  }
  
  if (temp$Item.Category[i] %like% "Food") {
    count4 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Food", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count4[j] = 1
      }
    temp$Food.Drink[i] = length(count4)
    }
  }
  
  if (temp$Item.Category[i] %like% "Decor") {
    count5 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Decor", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count5[j] = 1
      }
    temp$Home.Decor[i] = length(count5)
    }
  }
}

# Cool. Again

for (i in 1:nrow(temp)) {
  if (temp$Item.Category[i] %like% "Household") {
    count1 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Household", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count1[j] = 1
      }
    temp$Household.Items[i] = length(count1)
    }
  }
  
  if (temp$Item.Category[i] %like% "Hunting") {
    count2 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Hunting", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count2[j] = 1
      }
    temp$Hunting.Fishing.Items[i] = length(count2)
    }
  }
  
  if (temp$Item.Category[i] %like% "Jewelry") {
    count3 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Jewelry", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count3[j] = 1
      }
    temp$Jewelry.Watches[i] = length(count3)
    }
  }
  
  if (temp$Item.Category[i] %like% "Medical") {
    count4 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Medical", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count4[j] = 1
      }
    temp$Medical.Science[i] = length(count4)
    }
  }
  
  if (temp$Item.Category[i] %like% "Musical") {
    count5 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Musical", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count5[j] = 1
      }
      temp$Musical.Instruments.Accessories[i] = length(count5)
    }
  }
}


# WRITE THIS DATAFRAME TO A CSV AFTER!!!!


for (i in 1:nrow(temp)) {
  if (temp$Item.Category[i] %like% "Office") {
    count1 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Office", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count1[j] = 1
      }
    temp$Office.Equipment.Supplies[i] = length(count1)
    }
  }
  
  if (temp$Item.Category[i] %like% "Outdoor") {
    count2 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Outdoor", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count2[j] = 1
      }
    temp$Outdoor.Items[i] = length(count2)
    }
  }
  
  if (temp$Item.Category[i] %like% "Personal.Accessories") {
    count3 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Personal.Accessories", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count3[j] = 1
      }
    temp$Personal.Accessories[i] = length(count3)
    }
  }
  
  if (temp$Item.Category[i] %like% "Personal.Electronics") {
    count4 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Personal.Electronics", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count4[j] = 1
      }
    temp$Personal.Electronics[i] = length(count4)
    }
  }
  
  if (temp$Item.Category[i] %like% "Personal.Navigation") {
    count5 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Personal.Navigation", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count5[j] = 1
      }
    temp$Personal.Navigation[i] = length(count5)
    }
  }
}

## LAST LOOPS!!!

for (i in 1:nrow(temp)) {
  if (temp$Item.Category[i] %like% "Sport") {
    count1 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Sport", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count1[j] = 1
      }
    temp$Sporting.Equipment.Supplies[i] = length(count1)
    }
  }
  
  if (temp$Item.Category[i] %like% "Tools") {
    count2 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Tools", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count2[j] = 1
      }
    temp$Tools.Home.Improvement.Supplies[i] = length(count2)
    }
  }
  
  if (temp$Item.Category[i] %like% "Toys") {
    count3 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Toys", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count3[j] = 1
      }
    temp$Toys.Games[i] = length(count3)
    }
  }
  
  if (temp$Item.Category[i] %like% "Travel") {
    count4 = c()
    for (j in 1:length(unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";")))) {
      if (grepl("Travel", unlist(strsplit(as.character(temp$Item.Category[i][[1]]), split = ";"))[j]) == 1) {
        count4[j] = 1
      }
      temp$Travel.Accessories[i] = length(count4)
    }
  }
}

### OKAY TIME TO WRITE THIS!!
write.table(temp, file = "parsed_claims.csv")
write.table(claims, file = "parsed_claims.tsv")

claims = temp
summary(claims)
claims$rn = NULL
# Let's take a look into the missing values. What should we do about these.

# In Item.Category, make any entry "-" equal to "Other"
# Where claims$Disposition == "-", make those "Deny", and make the associated missing 
# Close Amounts = 0.00

claims$Item.Category <- as.character(claims$Item.Category)
claims$Item.Category[claims$Item.Category == "-"] = "Other"
claims$Item.Category <- as.factor(claims$Item.Category)

claims$Disposition <- as.character(claims$Disposition)
claims$Disposition[claims$Disposition == "-"] = "Deny"
claims$Disposition <- as.factor(claims$Disposition)

# What to do with remaining NA's?
# Remove Incident Dates with NAs (only 1)
claims <- claims[!is.na(claims$Incident.Date),]

# Remove 209 missing airport names/codes
claims <- claims[claims$Airport.Code != "-",]

# Remove 2281 missing airline names
claims <- claims[claims$Airline.Name != "-",]

# remove missing claim.types
claims <- claims[claims$Claim.Type != "-",]

#remove missing claims.sites
claims <- claims[claims$Claim.Site != "-",]

# Here's where it gets a little tricky. We have 6672 rows with missing Closing Amounts.
# 99 were approved in full, 6432 were denied, and 139 were settled. Replace missing 
# Deny rows with 0.00

for (i in 1:nrow(claims)) {
  if (is.na(claims$Close.Amount[i] == TRUE) & claims$Disposition[i] == "Deny") {
    claims$Close.Amount[i] = 0.00
  }
}

# The others are tricky...debating removing them...
claims %>% filter(Disposition == "Approve in Full" & Close.Amount >= 0) %>%
  summarise(mean(Close.Amount)) # $124.29

claims %>% filter(Disposition == "Approve in Full" & Close.Amount >= 0) %>%
  summarise(median(Close.Amount)) #69.58


claims %>% filter(Disposition == "Settle" & Close.Amount >= 0) %>%
  summarise(mean(Close.Amount)) # $230.13

claims %>% filter(Disposition == "Settle" & Close.Amount >= 0) %>%
  summarise(median(Close.Amount)) # $170.08

# Erring on the safe side and replacing missing Close Amounts with median values

for (i in 1:nrow(claims)) {
  if (is.na(claims$Close.Amount[i] == TRUE) & claims$Disposition[i] == "Approve in Full") {
    claims$Close.Amount[i] = 69.58
  }
  
  if (is.na(claims$Close.Amount[i] == TRUE) & claims$Disposition[i] == "Settle") {
    claims$Close.Amount[i] = 170.08
  }
}

claims <- claims[!is.na(claims$Close.Amount),]

# How many missing values do we now have??
sapply(claims, function(x) sum(is.na(x)))
#7005 in Date.Received, but I'm alright with that. Data is tidy finally!!!

write.table(claims, file = "tidy_claims.tsv")

## open
claims <- read.table("tidy_claims.tsv", header = T, sep = " ") # space separated for some reason





