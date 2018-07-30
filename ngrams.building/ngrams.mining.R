setwd("d:/Work/Projects/Coursera/data-science-project/capstone/NextWordPrediction")

library(tm); library(dplyr); library(compare)
BigramTokenizer     <- function(x) RWeka::NGramTokenizer(x, RWeka::Weka_control(min = 2, max = 2))
TrigramTokenizer    <- function(x) RWeka::NGramTokenizer(x, RWeka::Weka_control(min = 3, max = 3))
QuadrigramTokenizer <- function(x) RWeka::NGramTokenizer(x, RWeka::Weka_control(min = 4, max = 4))


d.blog.src <- readLines("./data/en_US.blogs.txt",   encoding="UTF-8",  skipNul = T)
d.twit.src <- readLines("./data/en_US.twitter.txt", encoding="UTF-8",  skipNul = T)
d.news.src <- readLines("./data/en_US.news.txt",    encoding="UTF-16", skipNul = T)

d.src <- c(d.blog.src, d.twit.src, d.news.src)
writeLines(d.src,"./data/data.src.txt")
rm(d.blog.src, d.twit.src, d.news.src)

if(length(dir(pattern = "*.csv|*.mined"))) {
  file.remove(c("bigrams.csv","bigrams.mined","trigrams.csv","trigrams.mined","quadrigrams.csv","quadrigrams.mined"))
}

for(x in 1:floor(length(d.src)/1e3)) {
  print(sprintf("%s/%s", x, floor(length(d.src)/1e3)))
  if(x == 1) { x.start = 1; x.end = x*1e3-1 } else if(x == floor(length(d.src)/1e3)) { x.start = x*1e3; x.end = length(d.src)
  } else { x.start = (x-1)*1e3; x.end = x*1e3-1 }
  
  d <- d.src[x.start:x.end]
  writeLines(d,"./data/data.txt")
  
  d = gsub("can't", "can", d)
  d = gsub("n't", "", d)
  d = gsub("'ll", " will", d)
  d = gsub("'re", " are", d)
  d = gsub("'ve", " have", d)
  d = gsub("'s", "", d)
  d = gsub("'d", " would", d)
  d = gsub("'m", " am", d)
  
  Encoding(d) <- "latin1"
  d <- iconv(d, "latin1", "ASCII", sub="")
  d <- gsub("\\d", " ", d) # remove digits
  d <- gsub("^\\s*<U\\+\\w+>\\s*", "", d) # remove special unicode chars
  d <- gsub("'s", "", d) # remove special unicode chars
  d <- gsub("[[:punct:]]", " ", d) # remove punctuation
  d <- enc2utf8(d)
  d <- tolower(d)
  d <- gsub("’.*|“.*|‚.*|„.*|”.*|‘.*", "", d) # remove strange punctuation
  #d <- gsub('\\b\\w{1,1}\\b','', d) # remove 1-char words
  d <- gsub("^ +|[[:space:]]+| +$", " ", d, perl = TRUE) # remove multiple spaces
  d <- gsub("^\\s+|\\s+$", "", d) # remove leading and trailing spaces
  d <- if(length(which(d == " " | d == "")) > 0) { d[-which(d == " " | d == "")] } else { d }
  
  writeLines(d,"./data/cleaned_data.txt")
  #d = readLines("./data/cleaned_data.txt")
  
  corpus <- VCorpus(VectorSource(d))
  #corpus <- tm(removeWords, stopwords("en"))
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
  #bigrams <- bigrams[bigrams$freq > 1,]
  if(file.exists("bigrams.csv")) {
    old.bigrams = read.csv("bigrams.csv",  stringsAsFactors = F)
    load(file = "bigrams.mined")
    bigrams = rbind(old.bigrams, bigrams)
    bigrams %<>% group_by(X,Y) %>% mutate(freq = sum(freq)) %>% ungroup %>% unique %>% as.data.frame
    distinct(bigrams, Y, .keep_all = TRUE) %>% arrange(desc(freq)) -> bigrams
    bigrams.mined = rbind(bigrams.mined, data.frame(x = x, nrow = nrow(bigrams)))
    save(bigrams.mined, file = "bigrams.mined")
  } else {
    bigrams.mined = data.frame(x = x, nrow = nrow(bigrams))
    save(bigrams.mined, file = "bigrams.mined")
  }
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
  #trigrams <- trigrams[trigrams$freq > 1,]
  if(file.exists("trigrams.csv")) {
    old.trigrams = read.csv("trigrams.csv",  stringsAsFactors = F)
    load(file = "trigrams.mined")
    trigrams = rbind(old.trigrams, trigrams)
    trigrams %<>% group_by(X,Y) %>% mutate(freq = sum(freq)) %>% ungroup %>% unique %>% as.data.frame
    distinct(trigrams, Y, .keep_all = TRUE) %>% arrange(desc(freq)) -> trigrams
    trigrams.mined = rbind(trigrams.mined, data.frame(x = x, nrow = nrow(trigrams)))
    save(trigrams.mined, file = "trigrams.mined")
  } else {
    trigrams.mined = data.frame(x = x, nrow = nrow(trigrams))
    save(trigrams.mined, file = "trigrams.mined")
  }
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
  #quadrigrams <- quadrigrams[quadrigrams$freq > 1,]
  if(file.exists("quadrigrams.csv")) {
    old.quadrigrams = read.csv("quadrigrams.csv",  stringsAsFactors = F)
    load(file = "quadrigrams.mined")
    quadrigrams = rbind(old.quadrigrams, quadrigrams)
    quadrigrams %<>% group_by(X,Y) %>% mutate(freq = sum(freq)) %>% ungroup %>% unique %>% as.data.frame
    distinct(quadrigrams, Y, .keep_all = TRUE) %>% arrange(desc(freq)) -> quadrigrams
    quadrigrams.mined = rbind(quadrigrams.mined, data.frame(x = x, nrow = nrow(quadrigrams)))
    save(quadrigrams.mined, file = "quadrigrams.mined")
  } else {
    quadrigrams.mined = data.frame(x = x, nrow = nrow(quadrigrams))
    save(quadrigrams.mined, file = "quadrigrams.mined")
  }
  write.csv(quadrigrams, "quadrigrams.csv", row.names = F)
}

# разобраться с плоттингом - неправильно ведь считает

load(file = "bigrams.mined"); plot(bigrams.mined$x, bigrams.mined$nrow)
load(file = "trigrams.mined"); plot(trigrams.mined$x, trigrams.mined$nrow)
load(file = "quadrigrams.mined"); plot(quadrigrams.mined$x, quadrigrams.mined$nrow)

bigrams = read.csv("bigrams.csv",  stringsAsFactors = F)
distinct(bigrams, Y, .keep_all = TRUE) %>% arrange(desc(freq)) -> bigrams
write.csv(bigrams, "bigrams.csv", row.names = F)

trigrams = read.csv("trigrams.csv",  stringsAsFactors = F)
distinct(trigrams, Y, .keep_all = TRUE) %>% arrange(desc(freq)) -> trigrams
write.csv(trigrams, "trigrams.csv", row.names = F)

quadrigrams = read.csv("quadrigrams.csv",  stringsAsFactors = F)
distinct(quadrigrams, Y, .keep_all = TRUE) %>% arrange(desc(freq)) -> quadrigrams
write.csv(quadrigrams, "quadrigrams.csv", row.names = F)

