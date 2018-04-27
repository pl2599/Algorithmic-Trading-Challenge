
library("xts")
library("dygraphs")
library("tseries")
library("forecast")
library(MASS)
library("car")
library("Metrics")

install.packages("PCAmixdata")
library("PCAmixdata")
library("dplyr")
install.packages("FactoMineR")
library("FactoMineR")

install.packages("dummies")
library("dummies")

setwd("/Users/wcheng/Desktop/Spring 2018/data science/project-4-open-project-group3/doc")

train_mat <- data_to_ts(sample_train)
save(train_mat,file ="../data/train_mat.RData")
test_mat <- data_to_ts(sample_test)
save(test_mat, file = "../data/test_mat.Rdata")



times <- seq(as.Date("2017-05-01"),length=100,by="days")
train_xts <- xts(train_mat,order.by = times)
save(train_xts, file = "train_xts.Rdata")

# Check that the data is good to go
sum(is.na(train_xts))
sum(is.nan(train_xts))
sum(is.infinite(train_xts))
sum(train_xts<=0)

# It can be seen that the time series is non-stationary
dygraph(train_xts[,1:4],main = 'Sharpe Ratio Maximised Portfolio') %>%
  dyRangeSelector()  %>% 
  dyOptions(axisLineWidth = 1.5, fillGraph = FALSE, drawGrid = T, rightGap=50)

# Doing ARIMA prediction for the first time series
# Check by Dickey-fuller test, we cannot reject the null hypothesis
adf.test(train_xts[,1], "stationary")

# auto.arima automatically searches for the optimal p and q to be used in the ARIMA model
fit <- auto.arima(train_xts[,1], seasonal = F, max.p = 10, max.q = 10)

tsdisplay(residuals(fit), lag.max=45, main='(2,2,2) Model Residuals')

# See how the model would perform on the 51-100 time interval
hold <- window(ts(train_xts[,1]), start=51)

fit_first_half = auto.arima(train_xts[1:50,1])

fcast_second_half <- forecast(fit_first_half,h=50)
plot(fcast_second_half, main=" ")
lines(ts(train_xts[,1]))

# Problem: data is not normal, acutally highly skewed
hist(train_xts[,1])

# Apply the ARIMA model to the entire dataset
arima <- function(x){
  fit <- auto.arima(x,seasonal = F, max.p = 10, max.q = 10)
  fcast <- forecast(fit, h = 50)
  fcast <- fcast$mean
}

train_pred <- apply(train_xts[1:50,],2,arima)
save(train_pred, file = "../output/train_pred.Rdata")
rmse(train_mat[51:100,],train_pred)

times <- seq(as.Date("2017-05-01"),length=100,by="days")
test_xts <- xts(test_mat,order.by = times)
test_pred <- apply(test_xts[1:50,],2,arima)
save(test_pred, file = "../output/test_pred.Rdata")
rmse(test_mat[51:100,],test_pred)

#######################################################################################################


# I first tried automatically using PCA mix
train_clean <- sample_train[,1:207]
train_clean <- train_clean[,!(grepl("time",colnames(train_clean)) | grepl("transtype",colnames(train_clean)))]
train_clean <- train_clean[,-1]
train_clean$security_id <- as.factor(train_clean$security_id)
X.quali <- train_clean %>%
  select(c(security_id,initiator))
X.quali <- apply(as.matrix(X.quali),2,as.character)
X.quanti <- train_clean[,-c(1,6)]
X.quanti <- apply(as.matrix(X.quanti),2,as.numeric)
X.quanti <- scale(X.quanti)

PCA <- PCAmix(X.quanti, X.quali, rename.level = F, graph = T)
PCA$quanti$contrib
# we can see that p_tcount, p_value, trade_vwap and trade_volume are the most important ones for dimension 2-5.


# Get the PCA new predictors as features for train and for test
train_pca <- dummy.data.frame(as.data.frame(train_clean), names = c("security_id","initiator"))
prin_comp <- prcomp(train_pca, scale. = T)
prop_varex <- prin_comp$sdev ^ 2/sum(prin_comp$sdev ^ 2)
plot(prop_varex, xlab = "Principal Component",
     ylab = "Proportion of Variance Explained",
     type = "b")
train_pca <- prin_comp$x[,c(1,2)]

test_clean <- sample_test[,1:207]
test_clean <- test_clean[,!(grepl("time",colnames(test_clean)) | grepl("transtype",colnames(test_clean)))]
test_clean <- test_clean[,-1]
test_pca <- dummy.data.frame(as.data.frame(test_clean), names = c("security_id","initiator"))
test_pca <- predict(prin_comp,test_pca)
test_pca <- test_pca[,c(1,2)]

save(train_pca, file = "../output/train_pca.Rdata")
save(test_pca, file = "../output/test_pca.Rdata")


