This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:

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

    ## Loading required package: lattice
    ## Loading required package: ggplot2

    ## Loading required package: foreach
    ## Loading required package: iterators
    ## Loading required package: randomForest
    ## randomForest 4.6-10
    ## Type rfNews() to see new features/changes/bug fixes.

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
