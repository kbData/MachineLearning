removeIrrelevantColumns<-function (d,naColumns){
        return(d[-c(1,3:7, naColumns)])
}

pml_write_files = function(x){
        n = length(x)
        for(i in 1:n){
                filename = paste0("problem_id_",i,".txt")
                write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
        }
}
download.file(url = "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv", destfile = "training.csv", method="curl")
download.file(url = "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv", destfile = "testing.csv", method="curl")
trainingCsv<-read.csv("training.csv")
testingCsv<-read.csv("testing.csv")
noNewWindowTraining<-trainingCsv[trainingCsv$new_window == "no",]
#list of columns in the training dataset
columns<-as.list(noNewWindowTraining)
#find columns in the training dataset containing only NAs
naColumns<-which(sapply(columns, function(c) all(is.na(c) | c=='')))
naColumns<-as.vector(naColumns)

trainingAll<-removeIrrelevantColumns(noNewWindowTraining , naColumns)
resultTesting<-removeIrrelevantColumns(testingCsv, naColumns)

library("caret")
set.seed(13323)
inTrain<-createDataPartition(y<-trainingAll$classe, p=0.60, list=FALSE)
training<-trainingAll[inTrain, ]
testing<-trainingAll[-inTrain,]

ctrl<-trainControl(number=2)
library(parallel); library(doParallel)
registerDoParallel(clust <- makeForkCluster(detectCores()))

fit<-train(data = training, classe ~ . , method='rf', trControl = ctrl)
stopCluster(clust)

predicted<-predict(fit, newdata=testing)
confusionMatrix(predicted, testing$classe)

finalValues<-predict(fit, newdata=resultTesting)

finalValues<-as.character(finalValues)

pml_write_files(finalValues)

