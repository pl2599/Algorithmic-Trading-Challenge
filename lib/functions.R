


# Linear regression processing data

LR_data_process <- function(data) {
  
  #Only include day 1 and last 50k
  #data1 <- data[1:107907,]
  #data2 <- data[(nrow(data)- 49999):nrow(data),]
  #data <- rbind(data1, data2)
  data <- data[1:107907,]
  
  return(data)
}




# Create Linear regression models

create_LR_models <- function(data) {
  
  #Separate Seller Initiated and Buyer Initiated Transactions
  buyer <- data[data$initiator == "B",]
  seller <- data[data$initiator == "S",]
  
  
  buyer_models_bid <- list()
  buyer_models_ask <- list()
  seller_models_bid <- list()
  seller_models_ask <- list()
  
  #Create models with columns 5 170 206 207 as predict
  
  for(i in 51:100)
  {
    print(i)
    buyer_models_bid[[i]] <- lm(eval(parse(text = paste("bid", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = 
                                  buyer)
    seller_models_bid[[i]] <- lm(eval(parse(text = paste("bid", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = 
                                   seller)
    buyer_models_ask[[i]] <- lm(eval(parse(text = paste("ask", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = 
                                  buyer)
    seller_models_ask[[i]] <- lm(eval(parse(text = paste("ask", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = 
                                   seller)
  }
  
  models <- list(buyer_models_bid = buyer_models_bid, seller_models_bid = seller_models_bid,
                 buyer_models_ask = buyer_models_ask, seller_models_ask = seller_models_ask)
  
  return(models)
} 




# Create linear regression model using PCA features

create_LR_PCA_models <- function(data, pca) {
  
  #Separate Seller Initiated and Buyer Initiated Transactions
  buyer <- cbind(data[data$initiator == "B",], pca[data$initiator == "B",])
  seller <- cbind(data[data$initiator == "S",], pca[data$initiator == "S",])
  
  
  buyer_models_bid <- list()
  buyer_models_ask <- list()
  seller_models_bid <- list()
  seller_models_ask <- list()
  
  #Create models with columns 5 170 206 207 as predict
  
  for(i in 51:100)
  {
    print(i)
    buyer_models_bid[[i]] <- lm(eval(parse(text = paste("bid", i, sep = ""))) ~ PC1 + PC2, data = 
                                  buyer)
    seller_models_bid[[i]] <- lm(eval(parse(text = paste("bid", i, sep = ""))) ~ PC1 + PC2, data = 
                                   seller)
    buyer_models_ask[[i]] <- lm(eval(parse(text = paste("ask", i, sep = ""))) ~ PC1 + PC2, data = 
                                  buyer)
    seller_models_ask[[i]] <- lm(eval(parse(text = paste("ask", i, sep = ""))) ~ PC1 + PC2, data = 
                                   seller)
  }
  
  models <- list(buyer_models_bid = buyer_models_bid, seller_models_bid = seller_models_bid,
                 buyer_models_ask = buyer_models_ask, seller_models_ask = seller_models_ask)
  
  return(models)
} 





# make linear regression predictions

make_LR_predictions <- function(models, test) {
  
  prediction <- data.frame(NA, ncol = 100, nrow = nrow(test))
  
  for(i in 1:nrow(test))
  {
    print(i)
    newdata <- data.frame(trade_vwap = test[i, "trade_vwap"], bid41 = test[i, "bid41"],
                          bid50 = test[i, "bid50"], ask50 = test[i, "ask50"])
    
    #Checks if initiator is Buyer
    if(test[i, "initiator"] == "B")
    {
      for(j in 51:100)
      {
        prediction[i, (j-50)*2-1] <- predict(models$buyer_models_bid[[j]], newdata)
        prediction[i, (j-50)*2] <- predict(models$buyer_models_ask[[j]], newdata)
      }
    } else
    {
      for(j in 51:100)
      {
        prediction[i, (j-50)*2-1] <- predict(models$seller_models_bid[[j]], newdata)
        prediction[i, (j-50)*2] <- predict(models$seller_models_ask[[j]], newdata)
      }
    }
  }
  
  return(prediction)
}




# make linear regression predictions on PCA features

make_LR_PCA_predictions <- function(models, test, pca) {
  
  prediction <- data.frame(NA, ncol = 100, nrow = nrow(test))
  
  for(i in 1:nrow(test))
  {
    print(i)
    newdata <- data.frame(PC1 = pca[i, "PC1"], PC2 = pca[i, "PC2"])
    
    #Checks if initiator is Buyer
    if(test[i, "initiator"] == "B")
    {
      for(j in 51:100)
      {
        prediction[i, (j-50)*2-1] <- predict(models$buyer_models_bid[[j]], newdata)
        prediction[i, (j-50)*2] <- predict(models$buyer_models_ask[[j]], newdata)
      }
    } else
    {
      for(j in 51:100)
      {
        prediction[i, (j-50)*2-1] <- predict(models$seller_models_bid[[j]], newdata)
        prediction[i, (j-50)*2] <- predict(models$seller_models_ask[[j]], newdata)
      }
    }
  }
  
  return(prediction)
}





# calculate RMSE

evaluate_RMSE <- function(prediction, test) {
  
  test_values <- test[,208:307]
  dim(test_values)
  
  return(sqrt(mean((prediction - test_values)^2)))
}






# transform data into time series matrix

data_to_ts <- function(data,ts_matrix){
  
  library(tidyr)
  
  # loop over every security of dataset
  for (i in c(1:80,82:102)) {
    sec <- data %>% filter(security_id==i)
    for (j in 1:nrow(sec)) {
      row <- sec[j,]
      bid <- row[,grepl("bid",colnames(data))]
      ask <- row[,grepl("ask",colnames(data))]
      bid <- gather(bid,"time","bid",1:100)
      ask <- gather(ask,"time","ask",1:100)
      ts_matrix[(100*(j-1)+1):(100*j),2*i-1] <- unlist(bid[,2])
      ts_matrix[(100*(j-1)+1):(100*j),2*i] <- unlist(ask[,2])
    }
    print(i)
  }
  
  # add colname
  colname <- ifelse(seq(1,2*102) %% 2, paste("sec",seq(1,102,by = 0.5),"bid",sep = ""), paste("sec",seq(1,2*102,by=0.5)-0.5,"ask",sep = ""))
  
  colnames(ts_matrix) <- colname
  
  # delete the empty columns saved for non-existing security 81
  ts_matrix <- ts_matrix[,c(-161,-162)]
  
  return(ts_matrix)
}





# time series prediction

predict_ts <- function(train,pred_matrix) {
  
  for (i in 1:ncol(train)) {
    
    # create an individual time series object and fit arima model every column
    train_ts <- ts(diff(train[,i]))
    fit <- auto.arima(train_ts,xreg=train_ts)
    
    for (j in 1:124) {
      
      test_ts <- ts(pred_matrix[((j-1)*100+1):((j-1)*100+50),i])
      fcast <- predict(fit,n.ahead=50,newxreg=test_ts)
      pred_matrix[((j-1)*100+51):(j*100),i] <- fcast$pred
      
    }
    print(i)
  }
  
  return(pred_matrix)
}





# lasso modeling and prediction

predict_lasso <- function(train,pred_matrix) {
  
  library(glmnet)
  
  # set grid for choosing the best lambda
  grid <- 10^seq(10,-2,length=100)
  
  # Build one lasso model for each security. Write a for loop to build models per security and do prediction
  # loop over 101 securities
  for (i in 1:101) {
    # loop over 100 responses
    for (j in 105:204) {
      
      lasso.mod <- glmnet(train[(371*(i-1)+1):(371*i),1:(j-1)],train[(371*(i-1)+1):(371*i),j],family="gaussian",alpha=1,lambd=grid)
      
      # cross validation to choose the best lambda
      cv.out <- cv.glmnet(train[(371*(i-1)+1):(371*i),1:(j-1)],train[(371*(i-1)+1):(371*i),j],family="gaussian",alpha=1)
      bestlam.lasso <- cv.out$lambda.min
      
      pred <- predict(lasso.mod,s=bestlam.lasso,newx=pred_matrix[(124*(i-1)+1):(124*i),1:(j-1)])
      pred_matrix[(124*(i-1)+1):(124*i),j] <- pred
    }
    print(i)
  } 
  return(pred_matrix)
}





# build random forest models

rf_train<-function(train_data){
  
  # install packages needed
  # input: train dataframe
  # output: model list 
  
  if(!suppressWarnings(require('randomForest')))
  {
    install.packages('randomForest')
    require('randomForest')
  }
  library("randomForest")
  
  # create list needed
  data<-train_data
  buyer_model_bid<-list()
  buyer_model_ask<-list()
  seller_model_bid<-list()
  seller_model_ask<-list()
  
  buyer <- data[data$initiator == "B",]
  seller <- data[data$initiator == "S",]
  
  # train the models
  
  for(i in 51:100){
    print(i)
    seller_model_bid[[i]]<-randomForest(eval(parse(text = paste("bid", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = seller, ntree=100)
  }
  for(i in 51:100){
    print(i)
    buyer_model_bid[[i]]<-randomForest(eval(parse(text = paste("bid", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = buyer, ntree=100)
  }
  for(i in 51:100){
    print(i)
    seller_model_ask[[i]]<-randomForest(eval(parse(text = paste("ask", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = seller, ntree=100)
  }
  for(i in 51:100){
    print(i)
    buyer_model_ask[[i]]<-randomForest(eval(parse(text = paste("ask", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = buyer, ntree=100)
  }
  #final result return
  model <- list(buyer_model_bid = buyer_model_bid, seller_model_bid = seller_model_bid,
                buyer_model_ask = buyer_model_ask, seller_model_ask = seller_model_ask)
  
  return(model)
}


# RF predicts

test_data_acutal <- function (sample_test){
  #Categorize data by buyer or seller
  buyer_test  <- sample_test[sample_test$initiator == "B",] 
  seller_test <- sample_test[sample_test$initiator == "S",]
  
  #Categorize data by bid or ask for each buyer/seller data
  
  #Actual prediction 
  #Buyer--bid
  ind1 <- seq(1,100,2)
  actual_buyer_bid <- buyer_test[,208:307]
  actual_buyer_bid <- actual_buyer_bid[,ind1]
  
  
  #Seller-bid
  actual_seller_bid <- seller_test[,208:307]
  actual_seller_bid <- actual_seller_bid[,ind1]
  
  #Buyer-ask 
  ind2 <- seq(2,100,2)
  actual_buyer_ask <- buyer_test[,208:307]
  actual_buyer_ask <- actual_buyer_ask[,ind2]
  
  
  #Seller-ask
  actual_seller_ask <- seller_test[,208:307]
  actual_seller_ask <- actual_seller_ask[,ind2]
  
  actual_repsonse <- list(actual_buyer_bid=actual_buyer_bid, actual_seller_bid=actual_seller_bid, 
                          actual_buyer_ask=actual_buyer_ask, actual_seller_ask=actual_seller_ask)
  return(actual_repsonse)
}

test_data <- function (models,sample_test){
  buyer_test  <- sample_test[sample_test$initiator == "B",] 
  seller_test <- sample_test[sample_test$initiator == "S",]
  #Test subdata  for buyer
  buyer_test <- cbind(buyer_test$trade_vwap, buyer_test$bid41, buyer_test$bid50, buyer_test$ask50)
  
  #Test subdata for seller
  seller_test <- cbind(seller_test$trade_vwap, seller_test$bid41, seller_test$bid50, seller_test$ask50)
  
  colnames(buyer_test)<- c("trade_vwap","bid41","bid50","ask50")
  colnames(seller_test)<- c("trade_vwap","bid41","bid50","ask50")
  
  test_data <- list(buyer_test=buyer_test, seller_test=seller_test)
  
  buyer_bid_predict <- predict_RF(RF_models$buyer_models_bid,test_data$buyer_test)
  buyer_ask_predict <- predict_RF(RF_models$buyer_models_ask,test_data$buyer_test)
  seller_bid_predict <- predict_RF(RF_models$seller_models_bid,test_data$seller_test)
  seller_ask_predict <- predict_RF(RF_models$seller_models_ask,test_data$seller_test)
  return(list(buyer_bid_predict = buyer_bid_predict, buyer_ask_predict=buyer_ask_predict,
              seller_bid_predict=seller_bid_predict, seller_ask_predict=seller_ask_predict))
}





predict_RF  <- function (model, test){
  library(randomForest)
  predict_RF <- matrix(NA, nrow = nrow(test), ncol=100)
  
  for (j in 51:100){
    predict_RF[,j] = predict(model[[j]], newdata = test)
    print(j)
  }
  return(predict_RF)
}

RF_eval <- function(RF_predict, test_data_actual) {
  library("Metrics")
  rmse1 <- rmse(test_data_actual$actual_buyer_bid, RF_predict$buyer_bid_predict[,51:100])
  rmse2 <- rmse(test_data_actual$actual_buyer_ask, RF_predict$buyer_ask_predict[,51:100])
  rmse3 <- rmse(test_data_actual$actual_seller_bid, RF_predict$seller_bid_predict[,51:100])
  rmse4 <- rmse(test_data_actual$actual_seller_ask, RF_predict$seller_ask_predict[,51:100])
  
  
  
  return(mean(rmse1,rmse2,rmse3,rmse4))
}




# build SVM models

svm_train<-function(train_data){
  # install packages needed
  # input: train dataframe
  # output: model list 
  if(!suppressWarnings(require('e1071')))
  {
    install.packages('e1071')
    require('e1071')
  }
  library("e1071")
  
  # create list needed
  data<-train_data
  buyer_svm_model_bid<-list()
  buyer_svm_model_ask<-list()
  seller_svm_model_bid<-list()
  seller_svm_model_ask<-list()
  
  buyer <- data[data$initiator == "B",]
  seller <- data[data$initiator == "S",]
  
  # train the models
  
  for(i in 51:100){
    print(i)
    seller_svm_model_bid[[i]]<-svm(eval(parse(text = paste("bid", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = seller)
  }
  for(i in 51:100){
    print(i)
    buyer_svm_model_bid[[i]]<-svm(eval(parse(text = paste("bid", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = buyer)
  }
  for(i in 51:100){
    print(i)
    seller_svm_model_ask[[i]]<-svm(eval(parse(text = paste("ask", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = seller)
  }
  for(i in 51:100){
    print(i)
    buyer_svm_model_ask[[i]]<-svm(eval(parse(text = paste("ask", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = buyer)
  }
  #final result return
  model <- list(buyer_svm_model_bid = buyer_svm_model_bid, seller_svm_model_bid = seller_svm_model_bid,
                buyer_svm_model_ask = buyer_svm_model_ask, seller_svm_model_ask = seller_svm_model_ask)
  
  return(model)
  
}






# build SVM model using PCA features

svm_train_PCA<-function(train_data){
  # install packages needed
  # input: train dataframe
  # output: model list 
  if(!suppressWarnings(require('e1071')))
  {
    install.packages('e1071')
    require('e1071')
  }
  library("e1071")
  
  svm_pca_bid<-list()
  svm_pca_ask<-list()
  
  # train the models
  
  for(i in 51:100){
    print(i)
    svm_pca_bid[[i]]<-svm(eval(parse(text = paste("bid", i, sep = ""))) ~ PC1+PC2, data = train_data)
  }
  for(i in 51:100){
    print(i)
    svm_pca_ask[[i]]<-svm(eval(parse(text = paste("ask", i, sep = ""))) ~ PC1+PC2, data = train_data)
  }
  
  #final result return
  model <- list(svm_pca_bid = svm_pca_bid, svm_pca_ask = svm_pca_ask)
  
  return(model)
  
}







# build GBM model

gbm_train<-function(train_data){
  # install packages needed
  # input: train dataframe
  # output: model list 
  if(!suppressWarnings(require('gbm')))
  {
    install.packages('gbm')
    require('gbm')
  }
  library("gbm")
  
  # create list needed
  data<-train_data
  buyer_gbm_model_bid<-list()
  buyer_gbm_model_ask<-list()
  seller_gbm_model_bid<-list()
  seller_gbm_model_ask<-list()
  
  buyer <- data[data$initiator == "B",]
  seller <- data[data$initiator == "S",]
  
  # train the models
  
  for(i in 51:100){
    print(i)
    seller_gbm_model_bid[[i]]<-gbm(eval(parse(text = paste("bid", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = seller,distribution = "gaussian",n.trees=200)
  }
  for(i in 51:100){
    print(i)
    buyer_gbm_model_bid[[i]]<-gbm(eval(parse(text = paste("bid", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = buyer,distribution = "gaussian",n.trees=200)
  }
  for(i in 51:100){
    print(i)
    seller_gbm_model_ask[[i]]<-gbm(eval(parse(text = paste("ask", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = seller,distribution = "gaussian",n.trees=200)
  }
  for(i in 51:100){
    print(i)
    buyer_gbm_model_ask[[i]]<-gbm(eval(parse(text = paste("ask", i, sep = ""))) ~ trade_vwap + bid41 + bid50 + ask50, data = buyer,distribution = "gaussian",n.trees=200)
  }
  #final result return
  model <- list(buyer_gbm_model_bid = buyer_gbm_model_bid, seller_gbm_model_bid = seller_gbm_model_bid,
                buyer_gbm_model_ask = buyer_gbm_model_ask, seller_gbm_model_ask = seller_gbm_model_ask)
  
  return(model)
  
}




# build GBM model using PCA features

gbm_train_PCA<-function(train_data){
  # install packages needed
  # input: train dataframe
  # output: model list 
  if(!suppressWarnings(require('gbm')))
  {
    install.packages('gbm')
    require('gbm')
  }
  library("gbm")
  gbm_pca_bid<-list()
  gbm_pca_ask<-list()
  # train the models
  
  for(i in 51:100){
    print(i)
    gbm_pca_bid[[i]]<-gbm(eval(parse(text = paste("bid", i, sep = ""))) ~ PC1+PC2, data = train_data,distribution = "gaussian",n.trees=200)
  }
  for(i in 51:100){
    print(i)
    gbm_pca_ask[[i]]<-gbm(eval(parse(text = paste("ask", i, sep = ""))) ~ PC1+PC2, data = train_data,distribution = "gaussian",n.trees=200)
  }
  
  #final result return
  model <- list(gbm_pca_bid = gbm_pca_bid, gbm_pca_ask = gbm_pca_ask)
  
  return(model)
  
}


# GBM prediction

make_GBM_predictions <- function(model, test){
  library(gbm)
  prediction <- matrix(NA, nrow = nrow(test), ncol=100)
  
  for(i in 1:nrow(test))
  {
    print(i)
    newdata <- as.data.frame(cbind(test$trade_vwap[i],test$bid41[i],test$bid50[i] , test$ask50[i]))
    colnames(newdata)<- c("trade_vwap", "bid41","bid50","ask50")
    
    #Checks if initiator is Buyer
    if(test[i, "initiator"] == "B")
    {
      for(j in 51:100)
      {
        prediction[,(j-50)*2-1] = predict(model$buyer_gbm_model_bid[[j]],  newdata,  n.trees=200)
        prediction[,(j-50)*2]   = predict(model$buyer_gbm_model_ask[[j]],  newdata , n.trees=200)
      }
      
    } else
    {
      for(j in 51:100)
      {
        prediction[,(j-50)*2-1] = predict(model$seller_gbm_model_bid[[j]], newdata, n.trees=200)
        prediction[,(j-50)*2]   = predict(model$seller_gbm_model_ask[[j]], newdata, n.trees=200)
      }
    }
  }
  return(prediction)
}



# generage exponential moving average feature

EMA<-function(data_in,lambda=0.9){
  i=seq(0,4,1)
  y=lambda^i
  result<-(data_in$bid50+y[1]*data_in$bid49+y[2]*data_in$bid48+y[3]*data_in$bid47+y[4]*data_in$bid46)/(sum(y))
  data_in$EMA_bid<-result
  result2<-(data_in$ask50+y[1]*data_in$ask49+y[2]*data_in$ask48+y[3]*data_in$ask47+y[4]*data_in$ask46)/(sum(y))
  data_in$EMA_ask<-result
  return(data_in)
}




# generate price increment feature

increment<-function(data_in) {
  
  a<-array()
  hehe<-c(206,202,198,194)
  for(i in 1:nrow(data_in)){
    a[i]<-0
    for(j in hehe){
      tmp<-data_in[i,j]-data_in[i,j-4]
      a[i]<-a[i]+ifelse(tmp>0,1,0)
    }
  }
  data_in$bid_incre<-a
  b<-array()
  hehe2<-c(207,203,199,195)
  for(i in 1:nrow(data_in)){
    b[i]<-0
    for(j in hehe2){
      tmp<-data_in[i,j]-data_in[i,j-4]
      b[i]<-b[i]+ifelse(tmp>0,1,0)
    }
  }
  data_in$ask_incre<-b
  return(data_in)
}




# generate spread (price difference between bid and ask) feature

spread<-function(data_in){
  tmp<-array()
  tmp<-data_in$bid50-data_in$ask50
  data_in$spread<-tmp
  return(data_in)
}






