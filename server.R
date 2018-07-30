library(shiny); library(stringdist)
bigrams  = read.csv("bigrams.csv",  stringsAsFactors = F)
trigrams = read.csv("trigrams.csv", stringsAsFactors = F)
quadrigrams = read.csv("quadrigrams.csv", stringsAsFactors = F)

fuzzy.match = function(text, ngram) { ngram$Y[amatch(text, ngram$X, maxDist=Inf)] }

clean.text <- function(text, n = 1) {
  text <- trimws(text)
  if(n != 0) text <- paste0(tail(strsplit(text, split=" ")[[1]], n), collapse = " ")
  text <- gsub("[[:punct:]]", " ", text) # remove punctuation
  text <- tolower(text)
  
  n.words = length(strsplit(text," ")[[1]])
  
  if(text != "") {
    if(n == 0) {
      res = fuzzy.match(text, c(bigrams, trigrams, quadrigrams))
    } else if(n == 1) {
      res <- bigrams[bigrams$X==text,2:3][1:3,]
      res[is.na(res$Y),] <- bigrams[agrep(text, bigrams$X)[1:3],2:3]
      res$Y[is.na(res$Y)] <- ""
      res$freq[is.na(res$freq)] <- 0
    } else if(n == 2 & n.words == 2) {
      res <- trigrams[trigrams$X==text,2:3][1:3,]
      res[is.na(res$Y),] <- trigrams[agrep(text, trigrams$X)[1:3],2:3]
      res$Y[is.na(res$Y)] <- ""
      res$freq[is.na(res$freq)] <- 0
    } else if(n == 3 & n.words == 3) {
      res <- quadrigrams[quadrigrams$X==text,2:3][1:3,]
      res[is.na(res$Y),] <- quadrigrams[agrep(text, quadrigrams$X)[1:3],2:3]
      res$Y[is.na(res$Y)] <- ""
      res$freq[is.na(res$freq)] <- 0
    } else {
      res = data.frame(a = rep("",3), b = rep(0,3))
    }
  } else {
    if(n != 0) res = data.frame(a = rep("",3), b = rep(0,3))
    if(n == 0) res = "Say 'Hello!'"
  }
  if(length(res) > 1) { if(any(is.na(res$Y)) & n != 0) { res$Y[is.na(res$Y)] <- "-"; res$freq[is.na(res$freq)] <- 0 } }
  return(res)
}

shinyServer(function(input, output) {
  output$prediction <- renderPrint({
    clean.text(input$inputText, n = 0)
  })
  output$table.bigram <- renderPrint({
    tab <- knitr::kable(clean.text(input$inputText, n = 1), format = "html", row.names = F, col.names = c("Next word", "Frequency"))
    tab <- kableExtra::kable_styling(tab, "striped", full_width = T, position = "left")
    tab
  })
  output$table.trigram <- renderPrint({
    tab <- knitr::kable(clean.text(input$inputText, n = 2), format = "html", row.names = F, col.names = c("Next word", "Frequency"))
    tab <- kableExtra::kable_styling(tab, "striped", full_width = T, position = "left")
    tab
  })
  output$table.quadrigram <- renderPrint({
    tab <- knitr::kable(clean.text(input$inputText, n = 3), format = "html", row.names = F, col.names = c("Next word", "Frequency"))
    tab <- kableExtra::kable_styling(tab, "striped", full_width = T, position = "left")
    tab
  })
})
