library(shiny)
library(data.table)
library(stringr)
library(shinythemes)
library(shinydashboard)

ui <- dashboardPage(skin = "red",
    dashboardHeader(title = "Text Predictor App"),
                dashboardSidebar(
                        sidebarMenu(
                            menuItem("Prediction", tabName = "pred", icon = icon("dashboard")),
                            menuItem("About the App", tabName = "app", icon = icon("th")),
                            menuItem("About the Model", tabName = "model", icon = icon("cog", lib = "glyphicon"))
                        )
                ),

                    dashboardBody(
                        
                        tabItems(
                            # First tab content
                            tabItem(tabName = "pred",
                                    fluidRow(
                                        box(h3("Instructions"),
                                            p(HTML("If you come from <b>Coursera</b>, you know the drill: start typing and check the predictions!")),
                                            p(HTML('If you come from anywhere else, this is the final Capstone project from the <b>Data Science</b> Specialization by the John Hopkins University. This app was built from scratch using <b>R</b> and <b>Shiny</b>, and it will predict the next word based on the input phrase you provide. So <b>Get Creative</b> 😊')),
                                            h3('Important!'),
                                            p('The app takes a couple seconds to load the database. Keep an eye on the progress bar on the lower right corner to check the progress, or wait for the "Start typing!" prompt. The first prediction also takes a couple seconds, but after that, predictions will start flowing instantly!')
                                            ),
                                        
                                        box(
                                            textInput(inputId = "words",
                                                      label = "Your phrase goes here!",
                                                      value = ""),
                                            br(),
                                            h4("Your next word is:"),
                                            htmlOutput("prediction")
                                            )
                                        )
                                    ),
 
                            # Second tab content
                            tabItem(tabName = "app",
                                    h3('Capstone'),
                                    p(HTML("This app serves as the culmination of 10 courses to obtain the <a href='https://www.coursera.org/learn/data-science-project'> Data Science specialization </a> from Jhon Hopkins University and Coursera. The objective was to build a predictive model to predict the next word from any given phrase provided by the user. The model must be fast and responsive, since it needed to mimic the performance of <a href='https://www.microsoft.com/en-us/swiftkey'> Microsoft SwiftKey </a>, which runs on mobile phones.")),
                                    h3('Dataset'),
                                    p("To build this app, we used a large text corpus from Twitter, Blogs and News sites in Enligsh. The corpus contained over 4 millions of texts, which posed a real challenge to our data science skills!"),
                                    p("The corpus was analized, processed and used as an input for our predictive model. If you're interested in knowing a little bit more about the dataset, please check the complete exploratory data analysis I made!. The code is also there, so you can see how I dealt with the huge dataset"),
                                    actionButton(inputId='rpub', label="Data Analysis",
                                                 icon = icon("th"),
                                                 class = "btn-danger btn-lg active",
                                                 onclick ="window.open('https://rpubs.com/gnelis/707645')")
                            ),
                        
                            tabItem(tabName = "model",
                                     h3('Greedy Back-off Model'),
                                    p(HTML("I opted for a greedy back-off model. It's fairly similar to the <a href='https://www.aclweb.org/anthology/D07-1090.pdf'> Stupid Back-off model proposed by Brants et al.</a> It's based on n-grams and finds the prediction on a large collection of base-prediction pairs derived from a corpus dataset. For this case, the model uses n-grams from n=4 to n=2.")),
                                    p("In simple terms, for a given input, the prediction model performs the following steps: "),
                                    tags$ul(
                                        tags$li("Extracts the last 3 words (3-gram)"),
                                        tags$li("Looks up this 3-gram in the 4-gram dataset, matching the words in the 'base' column. If a match is found, save the prediction."),
                                        tags$li("If the number of predictions is less than 3, performs the same steps but for the last 2 words in the 3-grams database"),
                                        tags$li("Keeps the process until the number of predictions is larger or equal than 3, or until all the database is checked."),
                                        tags$li("Return the predicted words")),
                                    p("The greediness is related to the stop criterion: the model stops as soon as it finds 3 or more predictions. It does not check all the n-grams datasets. Moreover, the datasets only contain the three most frequent predictions for each n-gram. The stupid back-off model, on the other hand, finds a large anumber of candidates and assigns them a score based on relative frequency and back-off weights."),
                                    p(HTML('Why did I use a greedy approach? Well, the Stupid Back-off model was really popular, and I just wanted to test if using a simpler model delivered good results. And according to this <a href="https://github.com/hfoffani/dsci-benchmark"> benchmark </a>, it sacrifices around 2% accuracy compared to a Stupid Back-off model. A fair trade-off, if you ask me 😀')),
                                    h3('Source Code'),
                                    p('The most challenging part of the model was building the prediction database from the corpus. We built all possible ngrams in each corpus, and built a base-prediction database which is easy to use. If you are interested in the data-preprocessing and how I built the database, please go to the github repo!'),
                                    actionButton(inputId='repo', label="Github",
                                              icon = icon("cog", lib = "glyphicon"),
                                              class = "btn-danger btn-lg active",
                                              onclick ="window.open('https://github.com/gnelis/Capstone')")
                                    )
                        )
                        
                    )
                    
                    
                )


server <- function(input, output) {
    
    withProgress(message = 'Loading database', value = 0, {
        # Number of times we'll go through the loop
        n <- 3
        incProgress(0, detail = "Loading 2-grams")
        bigrams<-readRDS('bigrams_prediction.rds')
        incProgress(1/n, detail = "Loading 3-grams")
        trigrams<-readRDS('threegrams_prediction.rds')
        incProgress(1/n, detail = "Loading 4-grams")
        fourgrams<-readRDS('fourgrams_prediction.rds')
        incProgress(1/n, detail = "Ready!")
    }
    )
    
    
    
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
    
    predict <- reactive({find.pred(input$words)})
    
    output$prediction <-  renderText(HTML(paste("<h3><b>",predict(),"</b></h3>")))
}

# Run the application 
shinyApp(ui = ui, server = server)