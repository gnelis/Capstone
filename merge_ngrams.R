## This script reads the ngrams and generates a single ngram/prediction database 
## using the top 3 most frequent predictions for each base.

library(dplyr)
library(data.table)

merge_grams<-function(grams,n){
    news<-paste(grams,'grams_news.rds',sep='')
    blogs<-paste(grams,'grams_blogs.rds',sep='')
    twitter<-paste(grams,'grams_twitter.rds',sep='')
    
    data_news<-data.table(data.frame(readRDS(news)),keep.rownames = TRUE)
    setnames(data_news, new= c("ngram", "freq"))
    
    data_blogs<-data.table(data.frame(readRDS(blogs)),keep.rownames = TRUE)
    setnames(data_blogs, new= c("ngram", "freq"))
    
    data_twitter<-data.table(data.frame(readRDS(twitter)),keep.rownames = TRUE)
    setnames(data_twitter, new= c("ngram", "freq"))
    
    merged<-full_join(data_news,data_blogs,by='ngram') %>% 
        full_join(data_twitter,by='ngram')
    
    merged$total_freq<-rowSums(merged[ , 2:4], na.rm=TRUE)
    
    bases<-sprintf("t%s",seq(1:(n-1)))
    fbases<-c(bases,'Prediction')
    
    merged[,  c(sprintf("t%s",seq(1:(n-1))),'Prediction') := tstrsplit(ngram, "_", fixed=TRUE, keep=c(1:n))]
    merged[, base := paste(t1,t2, sep = "_")]
    
    
    
    merged[,c("ngram","freq.x","freq.y","freq",sprintf("t%s",seq(1:(n-1)))):=NULL]
    
    result<-setorder(setDT(merged), base, -total_freq)[, indx := seq_len(.N), by = base][indx <= 3]
    
    result[,c("indx","total_freq"):=NULL]
    return(result)
}


data<-merge_grams('tri',3)
saveRDS(data,"threegrams.rds")

#Special case for n=2
merged<-data.table(data.frame(readRDS('bigrams.rds')),keep.rownames = TRUE)
setnames(merged, new= c("ngram", "total_freq"))
merged[,  c('base','Prediction') := tstrsplit(ngram, "_", fixed=TRUE, keep=c(1:2))]
result<-setorder(setDT(merged), base, -total_freq)[, indx := seq_len(.N), by = base][indx <= 3]
result[,c("indx","total_freq","ngram"):=NULL]