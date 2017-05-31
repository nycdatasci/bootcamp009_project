train = read.csv('../../data/train_total.csv')
test = read.csv('../../data/test_total.csv')
max_room = lm(data = train, formula = log_price ~ max_floor)
x=train$max_floor[!(is.na(train$max_floor))]
plot(train$max_floor, train$log_price)
abline(coef(max_room), col = 2)

