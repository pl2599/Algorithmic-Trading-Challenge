# install.packages("fifer")
# install.packages("dplyr")
library("dplyr")
library("fifer")
setwd("C:/Users/wc2628/Downloads")

train <- read.csv("training.csv")
test <- read.csv("testing.csv")
save(train, file = "train.Rdata")
save(test, file = "test.Rdata")


load("train.Rdata")
load("test.Rdata")

train<-train[!train$security_id==81,]


set.seed(1)
sample <- train %>%
  group_by(security_id) %>%
  sample_n(size = round(50000/101))


unsampled <- train[!train$row_id %in% sample$row_id,]

test <- unsampled %>%
  group_by(security_id) %>%
  sample_n(size = round(10000/101))

table(sample$security_id)
table(test$security_id)

sample_train <- sample %>%
  group_by(security_id) %>%
  sample_frac(size = 0.75)
sample_test <- sample[!sample$row_id %in% sample_train$row_id,]

save(sample, file ="sample.Rdata")
save(test,file = "test.Rdata")
save(sample_train, file = "sample_train.Rdata")
save(sample_test, file = "sample_test.Rdata")
