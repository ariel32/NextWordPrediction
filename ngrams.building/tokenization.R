setwd("d:/Work/Projects/Coursera/data-science-project/capstone/NextWordPrediction")
rm(list = ls())
library(tm); library(dplyr)
BigramTokenizer     <- function(x) RWeka::NGramTokenizer(x, RWeka::Weka_control(min = 2, max = 2))
TrigramTokenizer    <- function(x) RWeka::NGramTokenizer(x, RWeka::Weka_control(min = 3, max = 3))
QuadrigramTokenizer <- function(x) RWeka::NGramTokenizer(x, RWeka::Weka_control(min = 4, max = 4))

d = readLines("./data/cleaned_data.txt")

corpus <- VCorpus(VectorSource(d))

########## bigram
bigrams <- TermDocumentMatrix(corpus, control = list(tokenize = BigramTokenizer))

m.bigrams <- as.matrix(bigrams)
m.bigrams <- sort(rowSums(m.bigrams), decreasing=TRUE)
m.bigrams <- data.frame(word = names(m.bigrams), freq=m.bigrams)
m.bigrams$word <- as.character(m.bigrams$word)

head(m.bigrams, 10)

bigrams <- strsplit(m.bigrams$word, split=" ")
bigrams <- do.call(rbind, bigrams)
bigrams <- data.frame(X = bigrams[,1], Y = bigrams[,2], freq = m.bigrams$freq)

head(bigrams)
bigrams <- bigrams[bigrams$freq > 1,]
write.csv(bigrams, "bigrams.csv", row.names = F)

############# trigram
trigrams <- TermDocumentMatrix(corpus, control = list(tokenize = TrigramTokenizer))

m.trigrams <- as.matrix(trigrams)
m.trigrams <- sort(rowSums(m.trigrams), decreasing=TRUE)
m.trigrams <- data.frame(word = names(m.trigrams), freq=m.trigrams)
m.trigrams$word <- as.character(m.trigrams$word)

head(m.trigrams, 10)

trigrams <- strsplit(m.trigrams$word, split=" ")
trigrams <- do.call(rbind, trigrams)
trigrams <- data.frame(X = paste0(trigrams[,1]," ",trigrams[,2]), Y = trigrams[,3], freq = m.trigrams$freq)

head(trigrams)
trigrams <- trigrams[trigrams$freq > 1,]
write.csv(trigrams, "trigrams.csv", row.names = F)

############# quadrigram
quadrigrams <- TermDocumentMatrix(corpus, control = list(tokenize = QuadrigramTokenizer))

m.quadrigrams <- as.matrix(quadrigrams)
m.quadrigrams <- sort(rowSums(m.quadrigrams), decreasing=TRUE)
m.quadrigrams <- data.frame(word = names(m.quadrigrams), freq=m.quadrigrams)
m.quadrigrams$word <- as.character(m.quadrigrams$word)

head(m.quadrigrams, 10)

quadrigrams <- strsplit(m.quadrigrams$word, split=" ")
quadrigrams <- do.call(rbind, quadrigrams)
quadrigrams <- data.frame(X = paste0(quadrigrams[,1]," ",quadrigrams[,2]," ",quadrigrams[,3]), Y = quadrigrams[,4], freq = m.quadrigrams$freq)

head(quadrigrams)
quadrigrams <- quadrigrams[quadrigrams$freq > 1,]
write.csv(quadrigrams, "quadrigrams.csv", row.names = F)
