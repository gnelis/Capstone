##This function reads the raw data, construct a corpus object, tokenizes it and calculates n-grams.
##The final product is n-gram/frequency vector which is then used in merge_grams.R

readFiles<-function(file_name){
    con <- file(file_name, open = "rb"); 
    data <- readLines(con, encoding = "UTF-8", skipNul = TRUE); 
    close(con)
    data
}

library(ggplot2)
library(stringi)
library(quanteda)
quanteda_options(threads = 10)

# blogs<-readFiles('Data/en_US.blogs.txt')
# twitter<-readFiles('Data/en_US.twitter.txt')
data<-readFiles('Data/en_US.twitter.txt')

# blogs_corpus<-corpus(blogs,docnames = sprintf("blogs[%s]",seq(1:length(blogs))))
# twitter_corpus<-corpus(twitter,docnames = sprintf("twitter[%s]",seq(1:length(twitter))))

big_corpus<-corpus(data)

rm(data)


tokens<-tokens(big_corpus,
               what = "word",
               remove_punct = TRUE,
               remove_symbols = TRUE,
               remove_numbers = TRUE,
               remove_url = TRUE,
               remove_separators = TRUE,
               split_hyphens = TRUE)
rm(big_corpus)

tokens<-tokens_ngrams(tokens, n = 5)

df <- dfm(tokens)
df <- dfm_trim(df_bigram, min_termfreq = 2)
gram_vector<- sort(colSums(df),decreasing=TRUE)

saveRDS(gram_vector, "fivegrams_twitter.rds")
rm(list=ls())
