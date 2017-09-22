library(ggplot2)
library(dplyr)
library(zoo)

full_train = read.csv("Desktop/NYCDataScience/BootCamp/Projects/Project3_MachineLearning/data/train.csv")
full_test = read.csv("Desktop/NYCDataScience/BootCamp/Projects/Project3_MachineLearning/data/test.csv")

train = read.csv("Desktop/NYCDataScience/BootCamp/Projects/Project3_MachineLearning/data/train_df3.csv")
test = read.csv("Desktop/NYCDataScience/BootCamp/Projects/Project3_MachineLearning/data/test_df3.csv")

full = read.csv("Desktop/NYCDataScience/BootCamp/Projects/Project3_MachineLearning/data/full_data_kaggle.csv")


# Exploratory Data Analysis

# kindergarten_km and price_doc
ggplot(data = full_train, aes(x = kindergarten_km, y = price_doc)) + 
        geom_point(color = "blue") + 
        theme_bw() +
        xlab("Distance (km)") +
        ylab("Price (ruble)") +
        ggtitle(" Price by Distance to Kindergarten") +
        theme(legend.position = "none")

# school_km and price_doc
ggplot(data = full_train, aes(x = school_km, y = price_doc)) + 
        geom_point(color = "blue") + 
        theme_bw() +
        xlab("Distance (km)") +
        ylab("Price (ruble)") +
        ggtitle(" Price by Distance to the High School") +
        theme(legend.position = "none")

# metro_km_avto and price_doc
ggplot(data = full_train, aes(x = metro_km_avto, y = price_doc)) + 
geom_point(color = "blue") + 
theme_bw() +
xlab("Distance (km)") +
ylab("Price (ruble)") +
ggtitle(" Price by Car Distance to the Subway") +
theme(legend.position = "none")

# public_healthcare_km and price_doc
ggplot(data = full_train, aes(x = public_healthcare_km, y = price_doc)) + 
geom_point(color = "blue") + 
theme_bw() +
xlab("Distance (km)") +
ylab("Price (ruble)") +
ggtitle(" Price by Car Distance to Public Healthcare") +
theme(legend.position = "none")

# Transactions by Month
month = train %>% group_by(month) %>% summarize(avg_month_price = mean(price_doc), num_trans = n())
month$month_abb = month.abb[month$month]
month$month_abb = factor(month$month_abb, levels = month$month_abb)

ggplot(data =  month, aes(x = month_abb, y = num_trans)) +
        geom_bar(stat = "identity", color = "black", fill = "gray") +
        theme_bw() +
        xlab("Month") +
        ylab("Number of Transactions") +
        ggtitle("Transactions by Month") +
        theme(legend.position = "none") 

ggplot(data =  month, aes(x = month_abb, y = avg_month_price, fill = month_abb)) +
        geom_bar(stat = "identity", color = "black", fill = "gray") +
        theme_bw() +
        xlab("Month") +
        ylab("Average Price (Ruble)") +
        ggtitle("Average Price by Month") +
        theme(legend.position = "none") 

train$month = as.factor(train$month)
train$month2 = month.abb[train$month]
train$month2 = factor(train$month2, levels = unique(month$month_abb))

ggplot(data = train, aes(x = month2, y = price_doc)) + 
        geom_boxplot(fill = "gray") + 
        xlab("Month") +
        ylab("Price") + 
        ggtitle('Price by Month') + 
        theme_bw()

# Transactions by Year

year = train %>% group_by(year) %>% summarize(avg_year_price = mean(price_doc), num_trans = n())
year$year = as.factor(year$year)
year

ggplot(data = year, aes(x = year, y = num_trans)) +
        geom_bar(stat = "identity", color = "black", fill = "gray") +
        theme_bw() +
        xlab("Year") +
        ylab("Number of Transactions") +
        ggtitle("Transactions by Year") +
        theme(legend.position = "none") 

ggplot(data = year, aes(x = year, y = avg_year_price)) +
        geom_bar(stat = "identity", color = "black", fill = "gray") +
        theme_bw() +
        xlab("Year") +
        ylab("Average Price (Ruble)") +
        ggtitle("Average Price by Year") +
        theme(legend.position = "none") 

# Transaction for both Training and Test Sets
train$type = "TRAIN"
test$type = "TEST"

test$price_doc = NA

train$year = as.character(train$year)
test$year = as.character(test$year)

full = rbind(select(train, -month2), test)

unique(full$year)

full$month2 = month.abb[full$month]
full$month2 = factor(full$month2, levels = unique(month$month_abb))
full$year = as.factor(full$year) 

full2 = full %>% 
        group_by(year, type) %>% 
        summarize(num_transactions = n())

full2$type = as.factor(full2$type)

ggplot(data = full2, aes(x = year, y = num_transactions, fill = type)) + 
        geom_bar(stat = "identity") + 
        xlab("Year") +
        ylab("Number of Transactions") + 
        ggtitle('Transactions by Year') + 
        theme_bw() +
        scale_fill_brewer(palette="Set1")

# Transactions by sub_area

sub = train %>% group_by(sub_area) %>% summarise(avg_sub_price = mean(price_doc), num_transactions = n())

ggplot(data = sub, aes(x = reorder(sub_area, avg_sub_price), y = avg_sub_price)) +
        geom_bar(stat = "identity", color = "black", fill = "#F39C12") + 
        theme_bw() + 
        ylab("Average Price") +
        xlab("Sub Area") + 
        ggtitle("Average Price by Sub Area") + 
        coord_flip()

ggplot(data = sub, aes(x = reorder(sub_area, num_transactions), y = num_transactions)) +
        geom_bar(stat = "identity", color = "black", fill = "#F39C12") + 
        theme_bw() + 
        ylab("Number of Transactions") +
        xlab("Sub Area") + 
        ggtitle("Number of Transactions by Sub Area") + 
        coord_flip()


full3 = full %>% group_by(sub_area, product_type) %>% summarise(num_transactions = n())

ggplot(data = full3, aes(x = reorder(sub_area, num_transactions), y = num_transactions, fill = product_type)) +
        geom_bar(stat = "identity") + 
        theme_bw() + 
        ylab("Number of Transactions") +
        xlab("Sub Area") + 
        ggtitle("Product Type by Sub Area") + 
        coord_flip()

train$distances = train$kindergarten_km + train$school_km + train$metro_km_avto + train$public_healthcare_km
train$distances2 = (train$kindergarten_km + train$school_km + train$metro_km_avto + train$public_healthcare_km) / 4


ggplot(data = train, aes(x = distances, y = price_doc)) + geom_point() + theme_bw()
ggplot(data = train, aes(x = distances2, y = price_doc)) + geom_point() + theme_bw()

