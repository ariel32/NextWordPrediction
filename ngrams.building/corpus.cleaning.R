setwd("d:/Work/Projects/Coursera/data-science-project/capstone/NextWordPrediction")
rm(list = ls())

set.seed(1)
d.blog <- readLines("./data/en_US.blogs.txt",   encoding="UTF-8",  skipNul = T)
d.twit <- readLines("./data/en_US.twitter.txt", encoding="UTF-8",  skipNul = T)
d.news <- readLines("./data/en_US.news.txt",    encoding="UTF-16", skipNul = T)

d.blog <- d.blog[sample(1:length(d.blog), length(d.blog)*0.0015)]
d.twit <- d.twit[sample(1:length(d.twit), length(d.twit)*0.0015)]
d.news <- d.news[sample(1:length(d.news), length(d.news)*0.0015)]

d <- c(d.blog, d.twit, d.news)
writeLines(d,"./data/data.txt")
rm(d.blog, d.twit, d.news); gc()

d <- gsub("\\d", " ", d) # remove digits
d <- gsub("[[:punct:]]", " ", d) # remove punctuation
d <- enc2utf8(d)
d <- tolower(d)
d <- gsub("’.*|“.*|‚.*|„.*|”.*|‘.*", "", d) # remove strange punctuation
d <- gsub('\\b\\w{1,1}\\b','', d) # remove 1-char words
d <- gsub("^ +|[[:space:]]+| +$", " ", d, perl = TRUE) # remove multiple spaces
d <- gsub("^\\s+|\\s+$", "", d) # remove leading and tailing spaces
d <- if(length(which(d == " " | d == "")) > 0) { d[-which(d == " " | d == "")] } else { d }

writeLines(d,"./data/cleaned_data.txt")
rm(list = ls()); gc()