# DO WHAT WANT TO PUBLIC LICENSE
# Version 1, December 2015

# Copyright (C) 2015 Filip Floegel <floegel@gmail.com>
  
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.

# DO WHAT YOU WANT TO PUBLIC LICENSE
# TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

# You just DO WHAT YOU WANT TO.

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
setwd("C:/Users/Filip/coursera/data science/kaggle ctr/");
train_con <- file("./data/train","r") # gzfile(train_file,"r")
#
namesLine <- readLines(train_con, n = 1, warn = FALSE)
nameVector <- (strsplit(namesLine, ","))

loss <<- 0
count = 0
t = 0

start = Sys.time()

mSkip <- 0
mNlines <- sample(0:99,1,replace=T)
t2 <- 0
system.time(
  while ( length(oneBlock <- scan(train_con, '', skip = mSkip, nlines = mNlines, quiet = TRUE, sep = '\n') ) > 0) {
    t2 <- t2 + mNlines + mSkip
    for (line in oneBlock) {
      myVector <- (strsplit(line, ","))
      ID <-  myVector[[1]][1]
      y <-  as.numeric(myVector[[1]][2])
      d <- paste("date_",substr(myVector[[1]][3],1,6),sep="")
      h <- paste("hour_",substr(myVector[[1]][3],7,8),sep="")
      tmp <- paste(nameVector[[1]][4:24] , "_" , myVector[[1]][4:24], sep="")
      x <- sapply( c(d,h,tmp), hash)
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
        update(x, p, y )    
      }
      if (t %% 2500 == 0 && t >= 1){
        print(sprintf("%s %d %d %f %d %f", as.character(Sys.time()), t2, t, loss, count, loss/count )) 
      }
    t <- t + 1
    }
    mSkip <- sample(100:999,1,replace=T)
    mNlines <- sample(1:99,1,replace=T)
  }
)
print(sprintf("%f %s", loss/count, as.character(Sys.time() - start) ))

close(train_con)

test_con <- file("./data/test","r")
subm_con <- file("./data/subm.csv","w")

namesTest <- readLines(test_con, n = 1, warn = FALSE)
nameVecTest <- (strsplit(namesTest, ","))

writeLines("id,click", subm_con)

t <- 0
while (length(oneLine <- readLines(test_con, n = 1, warn = FALSE)) > 0) {
  myVector <- (strsplit(oneLine, ","))
  ID <-  myVector[[1]][1]
  d <- paste("date_",substr(myVector[[1]][2],1,6),sep="")
  h <- paste("hour_",substr(myVector[[1]][2],7,8),sep="")
  tmp <- paste(nameVecTest[[1]][3:23] , "_" , myVector[[1]][3:23], sep="")
  x <- sapply( c(d,h,tmp), hash)
  p <- predict(x)  
  
  writeLines(sprintf("%s,%f", ID, p), subm_con) 
  t <- t + 1
}

close(subm_con)
close(test_con)
