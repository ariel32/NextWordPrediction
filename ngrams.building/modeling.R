setwd("d:/Work/Projects/Coursera/data-science-project/capstone/NextWordPrediction")
bigrams  = read.csv("bigrams.csv",  stringsAsFactors = F)
trigrams = read.csv("trigrams.csv", stringsAsFactors = F)
quadrigrams = read.csv("quadrigrams.csv", stringsAsFactors = F)


bigrams$Y[bigrams$X=="why"][1:4]
trigrams$Y[trigrams$X=="who is"][1:4]
quadrigrams$Y[quadrigrams$X=="what is his"][1:4]


