#simple ftrl implementation in R

This is a simple implementation of the ftrl algo in order to take part of the kaggle competition

http://www.kaggle.com/c/avazu-ctr-prediction

First I tried to use old fashion learning with lm  in R but it didn't work out because of the dimesnion of the data itself but also the matrix which was made by lm was simple to big (>10GB) even for a sample of 100k datasets.

I was faszinated by online learning algo in any case. so I tried a published implementation in python. I know some python and wanted to get a better experience in R programming.

so here is my first more serious code in R...

* avazu-ctr-train-predict.R
* function_4ftrl.R

before I do the introduction I should give some references

1) the original paper

http://www.eecs.tufts.edu/~dsculley/papers/ad-click-prediction.pdf

2) implementaion in python where I made a copy from

http://www.kaggle.com/c/avazu-ctr-prediction/forums/t/10927/beat-the-benchmark-with-less-than-1mb-of-memory


## introduction

* "mkdir data" in the directory where the R-Files are
* download the data from kaggle webpage http://www.kaggle.com/c/avazu-ctr-prediction/data into the data directory
* gunzip train.gz and test.gz
* run the program avazu-ctr-train-predict.R

I got a score of 0.3981133

##Comments on my experiences with R

Reading and writing files is extremely slow in R. In python reading the file must be must faster at least in comparison to R. In the python Implementation from above uses for "t, row in enumerate(DictReader(open(path))):" which is a realy nice construct.

I also tried parallelization using doSnow and foreach. After some tests I came to the conclusion that it would speedup the training.

so at last I implemented a random Sample while reading the train file in order to get result in time (< 4h). predicting the data in the test file took also quite long because of slow reading and writing in R

