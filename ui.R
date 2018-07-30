#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny); library(kableExtra)


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Text prediction app"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      helpText("Enter a text..."),
      textInput("inputText", "Sentence:",value = ""),
      tags$b(helpText("You can try:")),
      helpText("I want to go"),
      helpText("Do you know"),
      helpText("Will we")
      ),
    # Show a plot of the generated distribution
    mainPanel(
      h4(tags$b('Word prediction by approximate string matching:')),
      h3(strong(code(textOutput('prediction')))),
      h4(tags$b('Word prediction by bigram:')),
      tableOutput('table.bigram'),
      h4(tags$b('Word prediction by trigram:')),
      tableOutput('table.trigram'),
      h4(tags$b('Word prediction by quadrigram:')),
      tableOutput('table.quadrigram')
    )
  )
))
