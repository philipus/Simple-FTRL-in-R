# DO WHAT WANT TO PUBLIC LICENSE
# Version 1, December 2015

# Copyright (C) 2015 Filip Floegel <floegel@gmail.com>

# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.

# DO WHAT YOU WANT TO PUBLIC LICENSE
# TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

# You just DO WHAT YOU WANT TO.

library(digest)

D <- 2^20

#feature hashing
hash <- function (s) { as.numeric(paste('0x',digest(s, algo='xxhash32'), sep="")) %% D + 1 }
#
make.predict <- function(alpha, beta, L1, L2, D) {
  
  predict <- function(x) {
    
    wTx <- 0
    for ( i in x ) {
      if (z[i] < 0 ) sign <- -1 
      else sign <- 1
      
      # build w on the fly using z and n, hence the name - lazy weights -
      if (sign * z[i] <= L1) {
        # w[i] vanishes due to L1 regularization
        w[i] <<- 0
      }
      else {
        # apply prediction time L1, L2 regularization to z and get w
        w[i] <<- (sign * L1 - z[i]) / ((beta + sqrt(n[i])) / alpha + L2)      
      }
      wTx <-  wTx + w[i]
      
    }
    # print(sprintf("sum of w -> %f",sum(w)))
    return( 1 / (1 + exp(-max(min(wTx, 35), -35))) )
  }
  return( predict )
}

logloss <- function(p, y){
  
  p = max(min(p, 1 - 10e-15), 10e-15)
  if (y == 1) return ( -log(p) ) 
  else return ( -log(1 - p)  )
}

make.update <- function(alpha) {
  
  update <- function(x, p, y) {
    
    # gradient under logloss
    g = p - y
    
    # update z and n
    for ( i in x ) {
      sigma <- ( sqrt(n[i] + g * g) - sqrt(n[i]) ) / alpha
      z[i] <<- z[i] + g - sigma * w[i]
      n[i] <<- n[i] + g * g      
    }
    # print(sprintf("sum of z: %f and sum of n: %f", sum(z), sum(n)))
    return (NULL)
  }
  
  return ( update )
}