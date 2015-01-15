# DO WHAT WANT TO PUBLIC LICENSE
# Version 1, December 2015

# Copyright (C) 2015 Filip Floegel <floegel@gmail.com>
  
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.

# DO WHAT YOU WANT TO PUBLIC LICENSE
# TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

# You just DO WHAT YOU WANT TO.

setwd("C:/Users/Filip/coursera/data science/kaggle ctr/");

source("function_4ftrl.R")
#
alpha <- 0.1
beta <- 1
L1 <- 1
L2 <- 1
D <- 2^20
#
predict <- make.predict(alpha, beta, L1, L2, D)
update <- make.update(alpha)
#
holdout <- 100
#
n <- vector ("numeric", D)
z <- vector ("numeric", D )
w <- vector ("numeric", D )
  
#
library(data.table)
setwd("C:/Users/Filip/coursera/data science/kaggle ctr/");

#
train <- fread( "./data/train", colClasses="character", nrows=1 )
nameVector <- names(train)

loss <<- 0
count = 0
t = 0

mRows = 10000000
mSkip = 1

start = Sys.time()

system.time(
    while( t < 20000000 && length(train <- fread( "./data/train", colClasses="character", skip = mSkip, nrows=mRows )) > 0) {
      ID <-  train[,1]
      y <-  apply(train[,2, with = FALSE],1,as.numeric)
      d <- apply(t(train[,3, with = FALSE]), 1, function(x) { paste("date_",substr(x,1,6),sep="")})
      h <- apply(t(train[,3, with = FALSE]), 1, function(x) { paste("hour_",substr(x,7,8),sep="")})
      tmp <- t(apply(train[,4:24, with = FALSE], 1, function(x) { paste(nameVector[4:24],"_", as.character(x),sep="")}))
      x <- apply(cbind(d,h,tmp),c(1,2), hash)
      for (i in 1:nrow(train) ) {
        p <- predict(x[i,])  
        if (t %% holdout == 0) {
          # step 2-1, calculate holdout validation loss
          #           we do not train with the holdout data so that our
          #           validation loss is an accurate estimation of
          #           the out-of-sample error
          loss <- loss + logloss(p, y[i])
          count <- count + 1    
        }
        else{
          # step 2-2, update learner with label (click) information
          update(x[i,], p, y[i] )    
        }
        if (t %% 250000 == 0 && t >= 1){
          print(sprintf("%s %d %f %d %f", as.character(Sys.time()), t, loss, count, loss/count ))
        }
      t <- t + 1
      }
      mSkip <- mSkip + mRows
    }
)
print(sprintf("%f %s", loss/count, as.character(Sys.time() - start) ))

subm_con <- file("./data/subm2.csv","w")

test <- fread( "./data/test", colClasses="character", nrows=1 )
nameVecTest <- names(test)

writeLines("id,click", subm_con)

mRows = 500000
mSkip = 1
t <- 0
while ( length(test <- fread( "./data/test", colClasses="character", skip = mSkip, nrows=mRows )) > 0) {
  for (i in 1:nrow(test) ) {
    ID <-  test[i,1, with = FALSE]
    d <- paste("date_",substr(test[i,2, with = FALSE],1,6),sep="")
    h <- paste("hour_",substr(test[i,2, with = FALSE],7,8),sep="")
    tmp <- paste(nameVecTest[3:23] , "_" , as.character(test[i,3:23, with = FALSE]), sep="")
    x <- sapply( c(d,h,tmp), hash)
    p <- predict(x)    
    writeLines(sprintf("%s,%f", ID, p), subm_con) 
    t <- t + 1
  }
  mSkip <- mSkip + mRows
}

close(subm_con)
