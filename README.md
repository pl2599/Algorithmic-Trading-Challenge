# Spring2018


# Project 4: Algorithmic Trading Challenge

----


### [Project Description](doc/project4_desc.md)

Term: Spring 2018

![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/cover.jpg)

+ Project title: Develop new models to accurately predict the market response to large trades
+ Team Number: Group 3 
+ Team Members: Kai Li, Jiongjiong Li, Wanting Cheng, Chunzi Wang, Pak Kin Lai
+ Project summary: This is a forecasting project that aims to develop new models to predict the stock market's short-term response following large trades. We'll derive empirical models to predict the behaviour of bid and ask prices following such "liquidity shocks". 
+ Background information: Liquidity is the ability of market participants to trade large amounts of shares at low cost and quickly. Market resiliency (also known as liquidity replenishment) is the time component of liquidity and refers to how a market recovers after liquidity has been consumed. Resiliency is very important to market participants, particularly traders wishing to reduce their market impact costs by splitting large orders across time. Modelling market resiliency will improve trading strategy evaluation methods by increasing the realism of backtesting simulations, which currently assume zero market resiliency.

![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/Liquidity%20Replenishment.png)

### A Glimpse of the Data

The price fluctuation of security 25, 50, 75, 100 are as follows:

Bid Price:
![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/price_bid_train.png)

Ask Price:
![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/price_ask_train.png)

Volume Weighted Average Price for all securities:

Training set:
![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/vwap_train.png)

Test set:
![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/vwap_test.png)

### Data Sampling and Pre-Processing

#### Stratified Sampling

+ test.csv only contains the first 50 time periods of prices and do not disclose the actual prices of the prices of t51-100. 
+ We believe security_id is an important factor in the prediction.
+ We used stratified sampling to get equal proportion of security_id's.

#### Data Pre-Processing for Time Series Modeling

+ There're 101 securities in total. 
+ In training set, every security has 371 rows. In test set, 124 rows.
+ Every row has 100 bid prices and 100 ask prices. For time series modeling, we created a time series matrix by combining all the bid and ask price of rows belong to the same security into a long column, bid and ask separately. So the dimension of training matrix is 371*100 rows and 101*2 columns and the test matrix is 124*100 rows and 101*2 columns. 

### Feature extraction

1. PCA
2. Semantically meaningful features

#### PCA

Note that PCA normally deals with all numerical data whereas in our case we have categorical data (e.g security_id) and binary data (e.g initiator). This requires us to perform a slightly different way of decomposing the dimensions.

#### Semantically meaningful features

- Price (information about the bid/ask normalized price time series)
- Liquidity book (information about the depth of the liquidity book)
- Spread (information about the bid/ask spread)
- Rate (information about the arrival rate of orders and/or quotes)

Price
- Exponential moving average (distribute different weights to different days)
- Number of price increments during the past 5 days

Liquidity book
- Bid and ask price increase between two consecutive quotes

Spread
- Bid/ask price spread on Day50 

Rate
- Number of quotes over number of trades during the last n events

### Models we used

- Linear Regression
- Random Forest
- ARIMA Time Series
- Lasso Regression
- GBM
- SVM

For each model, a security will have 100 prediction numbers as outputs, 50 for buy prices from t=51 to t=100, and the other 50 for sell prices from t=51 to t=100. 

Model Underlying hypothesis:
Future events will depend on post-liquidity shock events to be predicted. In this way, the prediction error will tend to increase with the distance from the liquidity shock.

#### Linear Regression

Separate data into Buyer Initiated and Seller Initiated subsets
Use Trade Volume Weighted Average Price, Bid 41, Bid 50, Ask 50 as Predictor Variables
Total of 200 Models are used to calculate the buy and ask price from t=51 to t=100
(50 x 2 x 2) ??? (Time x Buyer/Seller Initiated x Bid/Ask)

#### Random Forest

Same predictor chosen as Linear Regression
Trade Volume Weighted Average Price, Bid 41, Bid 50, Ask 50 as Predictor Variables
Models
+ Total of 200 Models are used to calculate the buy and ask price from t=51 to t=100 (50 x 2 x 2) ??? (Time x Buyer/Seller Initiated x Bid/Ask)
Advantages
+ Reduction in overfitting
+ Less in variance
Disadvantages
+ High Computation cost

#### ARIMA Time Series

First Attempt:
+ Making each row two time series, one for bid and one for ask.
+ Non-stationary, non-seasonal, and extremely skewed.
+ Prediction result around RMSE = 2

Second Attempt:

Since each row only have 100 data points, that???s too limited to produce meaningful forecasting results, so we combined every row of each security together to train arima model using the whole training data and input the new test data predictors to predict the response and compare with the original response. It returns better prediction results than the original attempt.

Time Series Plots:

Short TS:

![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/Short%20ts.png)

Long TS:

![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/Long%20ts.png)

#### Lasso Regression

Benefits of Lasso:
Shrink unimportant variables to 0 so we could see which variables are important.
E.g. for security 1, 96 predictor coefficients are 0 (104 predictors in total). Trade_vwap, bid1, bid5, bid34, bid50 are important variables.

Limitations of Lasso: 
Imputed data must be matrix.
So we only use p_tcount, p_value, trade_vwap, trade_volume, 50 bid and ask prices as predictors, and this arrangement will lose information on initiator and transtype of per bid and ask. That's the trade-off. 

Modeling:
For each security, we trained a lasso model based on predictors and responses and used cross validation to choose the best lambda. Then we used this model to predict the responses on test data given the predictors and compare it with original responses.

#### GBM and SVM

Same predictor chosen as Linear Regression
Trade Volume Weighted Average Price, Bid 41, Bid 50, Ask 50 as Predictor Variables
Result

Models
Total of 200 Models are used to calculate the buy and ask price from t=51 to t=100 (50 x 2 x 2) ??? (Time x Buyer/Seller Initiated x Bid/Ask)

Advantages
GBM models are expressive
SVM is very efficient

Disadvantages
The error is high compared with other models

### Model Performance Evaluation

+ Performance evaluation will be conducted using root mean square error.
+ For each prediction, RMSE will be separately calculated for the bid and ask at each time step following a liquidity shock. 
+ The lower, the better.

### Taking a closer look into rmse

TS RMSE distribution by security + bid/ask:

![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/rmse%20histogram%20-%20ts.png)

calculate rmse for each column to plot a histogram of rmse to see the distribution. 
It's obvious that the majority of rmse for each security is below 2. There're some outliers that impact our result. Here we tried to remove the outliers and calculate the mean rmse overall and it's around 0.96.

Lasso RMSE distribution by security:

![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/rmse%20distribution%20lasso.png)

calculate rmse for each security to plot a histogram of rmse to see the distribution. 
It's obvious that the majority of rmse for each security is below 5. There're some outliers that impact our result. Here we tried to remove the outliers and calculate the mean rmse overall and it's around 1.94.

LR RMSE by security:

![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/LR_RMSE_by_Sec.png)

LR_PCA RMSE by security:

![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/LR_PCA_RMSE_by_Sec.png)

Final result:

![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/results.jpeg)
