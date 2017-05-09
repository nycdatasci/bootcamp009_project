library(shiny)
library(randomForest)
require(shiny)
require(rCharts)
library(shinythemes)
require(tm)
require(SnowballC)
library(rCharts)


wine_v= read.csv('reviews_c.csv')
ranking= read.csv('reviews_vintage.csv')
ranking$description= NULL

# wine_c = wine_v%>%group_by(description)%>%tally(sort=TRUE)
# 
# wine_c = cSplit(wine_c, "description", " ", "long")

#write it into another csv file for later wordcount use
#the most frequent words are the and of, I removed them because they do not serve the theme purpose
#read the names table for the word count feature

des_wine = read.csv(file='./wordCount.csv', header = TRUE, stringsAsFactors = FALSE)
des_wine$X = NULL



wine<-read.table("winequality-red.csv",sep=";",header=T)
set.seed(12345)
fit.rf<-randomForest(quality~.,data=wine)



cols<-c("#666666","#666666","#006600","#99FF99","#FFCC00","#FF6600","#FF0000","#0033FF")
p<-"#000000"


shinyServer(
	function (input, output) {
	    
	    
####################################### wordcloud ################################################

	    
	    rwd<-reactive({des_wine})

	    wordcloud_rep <- repeatable(wordcloud)

	    output$wordcloud<- renderPlot({
	        wordcloud_rep(words = rwd()$word, freq = rwd()$X1, scale=c(5,1),
	                      min.freq = input$rfreq,
	                      max.words=input$rmax,
	                      rot.per=0.2,
	                      random.order=F,
	                      colors=brewer.pal(n = 8, "Dark2"))
	    })

	
#########################################  wine recommendation system ###########################################
	
	
	
	    values <- reactiveValues()
	    updateData <- function() {
	        values <- source('update.R')
	    }
	    
	    updateData()
	    
	    
	    datasetInput <- reactive({
	        as.character(input$w)
	    })
	    
	    dataInput <- reactive({
	        if (input$button == 0) return(cat(''))
	        
	        GetRandomWords()
	    })
	    
	    output$words <- renderPrint({
	        text <- dataInput()
	        cat(text)
	    })
	    output$Plot <- renderChart({
	        text <- datasetInput()
	        result <- RankWineProbabilities(text)
	        p <- nPlot(Probability ~ Wine, group = 'type', data = result, type = 'multiBarChart')
	        p$chart(color = c('#7F1734','#F7E7CE')) # map reds and whites to their correct colors.
	        p$addParams(width = 1100, height = 400, dom = 'Plot')
	        return(p)
	    })
	    
	    ########## table1 output ###########
	    
	    output$tbl <- DT::renderDataTable({
	        df <- ranking %>%
	            arrange(desc(points)) %>%
	        DT::datatable(df, class = 'cell-border stripe', escape = FALSE)
	    })
	    
	    
	
	
	#end of function
	

	
	}
	
	
	
)