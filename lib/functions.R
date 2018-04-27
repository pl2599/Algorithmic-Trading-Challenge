data_to_ts <- function(data){
  
  library(tidyr)
  
  # initiate matrix
  data_ts <- matrix(0,nrow=100,ncol=nrow(data)*2)
  
  # loop over overy row of dataset
  for (i in 1:nrow(data)) {
    row <- data[i,]
    bid <- row[,grepl("bid",colnames(data))]
    ask <- row[,grepl("ask",colnames(data))]
    bid <- gather(bid,"time","bid",1:100)
    ask <- gather(ask,"time","ask",1:100)
    data_ts[,2*i-1] <- unlist(bid[,2])
    data_ts[,2*i] <- unlist(ask[,2])
    print(i)
  }
  
  # check the updated matrix
  dim(data_ts)
  
  colname <- ifelse(seq(1,2* nrow(data)) %% 2, paste("row",seq(1,nrow(data),by = 0.5),"bid",sep = ""), 
                    paste("row",seq(1,2*nrow(data),by=0.5)-0.5,"ask",sep = ""))
  
  # save the matrix
  colnames(data_ts) <- colname
  return(data_ts)
}


