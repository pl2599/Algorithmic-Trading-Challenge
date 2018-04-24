library("xts")
library("dygraphs")
library("tseries")
library("forecast")
library(MASS)
library("car")



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

pred <- apply(train_xts[1:50,1:10],2,arima)
temp <- train_xts[,1:10]


