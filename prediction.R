##This function reads the datasets and deliver the predictions!

library(data.table)
library(stringr)

find.pred<-function(expr){
    clear.output<-function(prediction){
        prediction<-unique(prediction)
        return(paste('|',paste(prediction, collapse = ' | '),'|'))
    }
    
    expr<-str_trim(gsub("(?!')[[:punct:]]",'',tolower(expr),perl=TRUE))
    if(expr==""){return("Start Typing!")}
    splitted<-str_split(expr,"\\s+")
    
    result<-NULL
    
    tolook<-paste(tail(splitted[[1]],n=3),collapse='_')
    pred<-fourgrams[base==tolook,Prediction]
    result<-c(result,pred)
    if(length(result)>2) {return(clear.output(result))}
    
    tolook<-paste(tail(splitted[[1]],n=2),collapse='_')
    pred<-trigrams[base==tolook,Prediction]
    result<-c(result,pred)
    if(length(result)>2) {return(clear.output(result))}
    
    tolook<-tail(splitted[[1]],n=1)
    pred<-bigrams[base==tolook,Prediction]
    result<-c(result,pred)
    if(length(result)>2) {return(clear.output(result))}
    
    result<-c(result,'the')
    return(return(clear.output(result)))
    
}

bigrams<-readRDS('bigrams_prediction.rds')
trigrams<-readRDS('threegrams_prediction.rds')
fourgrams<-readRDS('fourgrams_prediction.rds')
fivegrams<-readRDS('fivegrams_prediction.rds')

find.pred("When you breathe, I want to be the air for you. I'll be there for you, I'd live and I'd")