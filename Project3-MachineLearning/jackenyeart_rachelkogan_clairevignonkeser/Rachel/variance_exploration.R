train_cleaned_no_price = train_cleaned %>% select(-price_doc, -logprice)

train_sd <- sapply(train_cleaned_no_price, sd, na.rm=TRUE)

test_sd <- sapply(test_cleaned, sd, na.rm=TRUE)


sd_diff <-data.frame(matrix(unlist(train_sd-test_sd)/
                              colMeans(rbind(train_sd, test_sd), na.rm=T), 
  nrow = 291, byrow=T), stringsAsFactors=FALSE, index_test= names(test_cleaned), 
  index_train = names(train_cleaned_no_price))


names(sd_diff) <- c('sd_diff', 'index_test', 'index_train')


sd_diff$cp <- ifelse(sd_diff$sd_diff > 0, 'train', 'test')

View(sd_diff)

sd_diff$sd_diff <- abs(sd_diff$sd_diff)
sd_diff %>% dplyr::arrange(desc(sd_diff)) %>% head(40)


par(mfrow = c(2, 1))
ggplot(data=train_cleaned, aes(x=kindergarten_km)) + geom_histogram(bins=100)
ggplot(data=test_cleaned, aes(x=kindergarten_km)) + geom_histogram(bins=100)

dim(test_cleaned[test_cleaned$kindergarten_km > 20,])

unique(test_cleaned[test_cleaned$kindergarten_km > 20,"sub_area"])

dim(test_cleaned[test_cleaned$sub_area %in% 
      unique(test_cleaned[test_cleaned$kindergarten_km > 20,"sub_area"]),])

ggplot(data=train_cleaned, aes(x=full_sq, y=logprice)) + geom_point(aes(color=sub_area)) +
  geom_smooth() + xlim(0, 250)

train_cleaned %>% group_by(sub_area) %>% 
  summarise(avg=mean(logprice)) %>% arrange(desc(avg))

sort(unique(train_cleaned$sub_area))[1:10] 
?sort

train_clean_filt <- train_cleaned %>% 
  filter(sub_area %in% sort(unique(train_cleaned$sub_area))[31:35])

ggplot(data=train_clean_filt, aes(x=full_sq, y=logprice)) + 
  geom_point(aes(color=sub_area)) +
  xlim(0, 150)
