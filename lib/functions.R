LR_data_process <- function(data) {
  
  #Only include day 1 and last 50k
  #data1 <- data[1:107907,]
  #data2 <- data[(nrow(data)- 49999):nrow(data),]
  #data <- rbind(data1, data2)
  data <- data[1:107907,]
  
  return(data)
}

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

evaluate_RMSE <- function(prediction, test) {
  
  test_values <- test[,208:307]
  dim(test_values)
  
  return(sqrt(mean((prediction - test_values)^2)))
}