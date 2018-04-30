# Spring2018


# Project 4: Algorithmic Trading Challenge

----


### [Project Description](doc/project4_desc.md)

Term: Spring 2018

![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/cover.jpg)

+ Project title: Develop new models to accurately predict the market response to large trades
+ Team Number: Group 3 
+ Team Members: Kai Li, Jiongjiong Li, Wanting Chenting, Chunzi Wang, Pak Kin Lai
+ Project summary: This is a forecasting project that aims to develop new models to predict the stock market's short-term response following large trades. We'll derive empirical models to predict the behaviour of bid and ask prices following such "liquidity shocks". 
+ Background information: Liquidity is the ability of market participants to trade large amounts of shares at low cost and quickly. Market resiliency (also known as liquidity replenishment) is the time component of liquidity and refers to how a market recovers after liquidity has been consumed. Resiliency is very important to market participants, particularly traders wishing to reduce their market impact costs by splitting large orders across time. Modelling market resiliency will improve trading strategy evaluation methods by increasing the realism of backtesting simulations, which currently assume zero market resiliency.

![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/Liquidity%20Replenishment.png)

### A Glimpse of the Data

The price fluctuation of security 25, 50, 75, 100 are as follows:

Bid Price:
![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/price_bid_train.png)

Ask Price:
![](https://github.com/GU4243-ADS/project-4-open-project-group3/blob/master/figs/price_ask_train.png)

Contribution statement: [default](doc/a_note_on_contributions.md) All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement.

### Feature extraction
1. PCA
2. Semantically meaningful features
Price (information about the bid/ask normalized price time series)
Liquidity book (information about the depth of the liquidity book)
Spread (information about the bid/ask spread)
Rate (information about the arrival rate of orders and/or quotes)

Price
Exponential moving average (distribute different weights to different days)
Number of price increments during the past 5 days
Liquidity book
Bid and ask price increase between two consecutive quotes
Spread
Bid/ask price spread on Day50 
Spread
Number of quotes over number of trades during the last n events

