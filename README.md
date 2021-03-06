This document describes the machine learning algorithm developed to predict the manner in which the exercise was performed by different pearsons under test. The dataset is described under <http://groupware.les.inf.puc-rio.br/har>.

We download the dataset form the internet and read the downloaded CSV files into R.

``` r
download.file(url = "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv", destfile = "training.csv", method="curl")
download.file(url = "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv", destfile = "testing.csv", method="curl")
trainingCsv<-read.csv("training.csv")
testingCsv<-read.csv("testing.csv")
```

Now we want to remove columns with data, which is irrelevant for the prediection. The rows having a column "new\_window" = "yes" are special rows which summarize data within some time window. We are not asked to predict for such time windows, so such rows must not be used for training. We remove all these rows from the dataset. Further more, we remove all columns which have all NA values, since they do not represent any information gain at all. Also we remove columns containing timestamp, time windows number and row number for the same reason.

``` r
noNewWindowTraining<-trainingCsv[trainingCsv$new_window == "no",]
#list of columns in the training dataset
columns<-as.list(noNewWindowTraining)
#find columns in the training dataset containing only NAs
naColumns<-which(sapply(columns, function(c) all(is.na(c) | c=='')))
naColumns<-as.vector(naColumns)

removeIrrelevantColumns<-function (d,naColumns){
        return(d[-c(1,3:7, naColumns)])
}
trainingAll<-removeIrrelevantColumns(noNewWindowTraining , naColumns)
resultTesting<-removeIrrelevantColumns(testingCsv, naColumns)
```

We build a tesing and traing dataset. 60% of the data is used for training.

``` r
library("caret")
set.seed(13323)
inTrain<-createDataPartition(y<-trainingAll$classe, p=0.60, list=FALSE)
training<-trainingAll[inTrain, ]
testing<-trainingAll[-inTrain,]
```

For machine learning we choose random forest algorithm, which is simple to implement and performs good for classification problems with multiple predictors. To improve the computation speed we use only 2 resampling iterations, but stil produce acceptable results. Note that we parallelize computations (on multicore hardware) with the help of doParallel library.

``` r
ctrl<-trainControl(number=2)
library(parallel); library(doParallel)
registerDoParallel(clust <- makeForkCluster(detectCores()))

fit<-train(data = training, classe ~ . , method='rf', trControl = ctrl)
stopCluster(clust)
```

See the confusion matrix for the test data below. The cross validations estimates the accuracy on the out of sample data to be more than 99%, which is acceptable for us.

``` r
predicted<-predict(fit, newdata=testing)
confusionMatrix(predicted, testing$classe)
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction    A    B    C    D    E
    ##          A 2182   10    0    0    0
    ##          B    2 1473   18    0    0
    ##          C    0    4 1322   23    0
    ##          D    0    0    0 1233    1
    ##          E    4    0    0    2 1410
    ## 
    ## Overall Statistics
    ##                                           
    ##                Accuracy : 0.9917          
    ##                  95% CI : (0.9894, 0.9936)
    ##     No Information Rate : 0.2847          
    ##     P-Value [Acc > NIR] : < 2.2e-16       
    ##                                           
    ##                   Kappa : 0.9895          
    ##  Mcnemar's Test P-Value : NA              
    ## 
    ## Statistics by Class:
    ## 
    ##                      Class: A Class: B Class: C Class: D Class: E
    ## Sensitivity            0.9973   0.9906   0.9866   0.9801   0.9993
    ## Specificity            0.9982   0.9968   0.9957   0.9998   0.9990
    ## Pos Pred Value         0.9954   0.9866   0.9800   0.9992   0.9958
    ## Neg Pred Value         0.9989   0.9977   0.9972   0.9961   0.9998
    ## Prevalence             0.2847   0.1935   0.1744   0.1637   0.1836
    ## Detection Rate         0.2840   0.1917   0.1720   0.1605   0.1835
    ## Detection Prevalence   0.2853   0.1943   0.1756   0.1606   0.1843
    ## Balanced Accuracy      0.9977   0.9937   0.9912   0.9900   0.9992
