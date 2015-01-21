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
x <- vector ("numeric", 23)
#
library(ff)
setwd("C:/Users/Filip/coursera/data science/kaggle ctr/");

#
nRows <- 1000000
mRows <- 100000

train_colcl <- vector(mode="character", length=24)
train_colcl[1] <- "factor"
train_colcl[2] <- "numeric"
train_colcl[3:24] <- "factor"

train_data <- read.csv.ffdf(file="./data/train",header=TRUE,
                          VERBOSE=TRUE, first.rows=mRows,next.rows=mRows,colClasses=train_colcl)
nameVector <- names(train_data)

loss <<- 0
count = 0
t = 0

start = Sys.time()

system.time(
  for (ch in chunk(train_data, by = mRows )) { 
    # read data 
    train <- train_data[ch,, drop=FALSE ] 
    # do your thing with the data
    for (i in 1:nrow(train) ) {
      # ID <-  train[i,1]
      y <-  train[i,2]
      x[1] <- hash(paste("date_",substr(train[i,3],1,6),sep=""))
      x[2] <- hash(paste("hour_",substr(train[i,3],7,8),sep=""))
      x[3:23] <- sapply(paste(nameVector[4:24],"_", train[i,4:24],sep=""),hash)
      # x <- sapply(c(d,h,tmp),hash)
      
      p <- predict(x)  
      if (t %% holdout == 0) {
        # step 2-1, calculate holdout validation loss
        #           we do not train with the holdout data so that our
        #           validation loss is an accurate estimation of
        #           the out-of-sample error
        loss <- loss + logloss(p, y)
        count <- count + 1    
      }
      else{
        # step 2-2, update learner with label (click) information
        update(x, p, y)    
      }
      if (t %% 2500000 == 0 && t >= 1){
        print(sprintf("%s %d %f %d %f", as.character(Sys.time()), t, loss, count, loss/count ))
      }
      t <- t + 1
    }
    # clean up 
    rm(train) 
    gc() 
  } 
)
  
print(sprintf("%f %s", loss/count, as.character(Sys.time() - start) ))

nRows <- 1000000
mRows <- 100000

test_colcl <- train_colcl[c(1,3:24)]
test_data <- read.csv.ffdf(file="./data/test",header=TRUE,
                            VERBOSE=TRUE, first.rows=mRows,next.rows=mRows,colClasses=test_colcl)


nameVecTest <- names(test_data)


subm_con <- file("./data/subm_ffdf.csv","w")
writeLines("id,click", subm_con)

t <- 0

start = Sys.time()

system.time(
  for (ch in chunk(test_data, by = mRows)) { 
    # read data 
    test <- test_data[ch,,drop=FALSE ] 
    # do your thing with the data
    for (i in 1:nrow(test) ) {
      ID <-  test[i,1]
      x[1] <- hash(paste("date_",substr(test[i,2],1,6),sep=""))
      x[2] <- hash(paste("hour_",substr(test[i,2],7,8),sep=""))
      x[3:23] <- sapply(paste(nameVecTest[3:23],"_", test[i,3:23],sep=""),hash)
      # x <- sapply(c(d,h,tmp),hash)
      p <- predict(x)
      writeLines(sprintf("%s,%f", ID, p), subm_con) 
      if (t %% 250000 == 0 && t >= 1){
        print(sprintf("%s %d", as.character(Sys.time()), t ))
      }
      t <- t + 1
    }
    # clean up 
    rm(test) 
    gc() 
  } 
)

close(subm_con)
