

# initiate matrix
train_mat <- matrix(0,nrow=100,ncol=nrow(sample_train)*2)

# loop over overy row of dataset
for (i in 1:nrow(sample_train)) {
  row <- sample_train[i,]
  bid <- row[,grepl("bid",colnames(sample_train))]
  ask <- row[,grepl("ask",colnames(sample_train))]
  bid <- gather(bid,"time","bid",1:100)
  ask <- gather(ask,"time","ask",1:100)
  train_mat[,2*i-1] <- unlist(bid[,2])
  train_mat[,2*i] <- unlist(ask[,2])
  print(i)
}

# check the updated matrix
dim(train_mat)
train_mat[1:100,1:6]

# save the matrix
save(train_mat,file ="train_mat.RData")