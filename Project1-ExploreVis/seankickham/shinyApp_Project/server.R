library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(DT)
library(googleVis)
library(RColorBrewer)

shinyServer(function(input, output, session){
  ########################
  ### overview ###########
  ########################
  
  output$overviewtext = renderText({
    'The OkCupid dataset contains 59,946 observations and 31 variables 
    of active San Francisco users from June 26, 2012.
    The dataset contains user information on 
    gender, age, physical attributes, 
    sexual orientation, ethnicity, religion, 
    diet and drinking habits, children and pets, 
    responses to personal questions, and more. 
    OkCupid publishes findings from their own analyses on their 
    blog (https://theblog.okcupid.com/). OkCupid founder Christian Rudder 
    can be seen describing insights in the video below. \n'
  })
  
  output$overviewvideo = renderUI({
    tags$iframe(width="640", height="360", 
    src="https://www.youtube.com/embed/U0-PFWGQEAA?ecver=1", 
    frameborder="0")
  })
 
  output$overviewtext2 = renderText({
    '\n
    For my own analysis, I simplified much of the dataset 
    by taking out some of the ambiguity in ethnicity, 
    religion, education, pets, astrological sign, and offspring. 
    For ethnicity, I first knocked off the category "other" and then changed 
    any remaining cells of multiple ethnicities to "multiethnic." 
    Since both religion and astrology sign measure seriousness of the user, 
    I created new columns that assign a numerical value 
    as a level of seriousness. (For religion, 4 = "very serious", 3 = "somewhat", 2 = "not too", 1 = "laughing", 0 = unanswered.)
    (For sign, 3 = "matters a lot", 2 = "think it\'s fun, 1 = "doesn\'t matter", 0 = unanswered.) 
    For pets, I separated the information into dogs and cats. \n'
  })
  
  ########################
  ### findings ###########
  ########################
  
  #Average users
  output$groupbytable = DT::renderDataTable({
    currentgroup = p3 %>%
      group_by_(input$groupbyCat, input$groupbyCat2) %>%
      summarise(Observations = n(), Proportion = round(Observations/nrow(p3) * 100,1)) %>%
      arrange(desc(Observations))
    datatable(currentgroup, rownames = T, options = list(scrollX = TRUE)) %>%
      formatStyle(input$groupbyCat,
                  background = 'skyblue',
                  fontWeight = 'bold')
    
  })
  
  output$average = renderImage({
    list(src = 'www/average.png', width = '100%', height = 500)
  }, delete = FALSE)
  
  output$averagetext = renderText({
    '
    \n'
  })
  
  #gender findings
  
  output$genderimage = renderImage({
    list(src = 'www/educationbygender.png', width = 550, height = 450)
  }, delete = FALSE)
  
  output$genderimage2 = renderImage({
    list(src = 'www/agegender.png', width = 550, height = 450)
  }, delete = FALSE
  )
  
  output$gendertext = renderText({
    
  })
  
  #age findings
  output$ageimage = renderImage({
    list(src = 'www/agedrinks.png', width = 550, height = 450)
  }, delete = FALSE)
  
  output$ageimage2 = renderImage({
    list(src = 'www/ageethnicity.png', width = 550, height = 450)
  }, delete = FALSE)
  
  output$agetext = renderText({
    
  })
  
  
  #orientation findings
  
  output$orientationimage = renderImage({
    list(src = 'www/orientationbyethnicity.png', width = 550, height = 450)
  }, delete = FALSE)
  
  output$orientationimage2 = renderImage({
    list(src = 'www/orientationreligion.png', width = 550, height = 450)
  }, delete = FALSE)
  
  output$orientationtext = renderText({
    
  })
  
  
  #essay analysis
  
  output$menWC = renderImage({
    list(src = 'www/wcMennofriendsorfamily.png', width = 300, height = 300)
  }, delete = FALSE)
  
  output$womenWC = renderImage({
    list(src = 'www/wcWomenNofreidnsorfamily.png', width = 300, height = 300)
  }, delete = FALSE)
  
  output$christianWC = renderImage({
    list(src = 'www/wordcloudChristian.png', width = 400, height = 300)
  }, delete = FALSE)
  
  output$atheistWC = renderImage({
    list(src = 'www/wordcloudAtheists.png', width = 400, height = 300)
  }, delete = FALSE)
  
  
  #conclusions and questions
  output$conclusiontext = renderText({
    'The data has shown that there are some interesting (and possibly stereotypical) trends among different groups of people. However, 
    there are areas of the population which are not accurately represented in OkCupid\'s user base. For instance, Asians make up 33% of the 
    San Francisco population, yet only 10.4% of the OkCupid Dataset. Also, in a population of equal parts men and women, men outnumber women 3
    to 2 on the dating website. I wonder if this is due to message rates between men and women.'
  })
  
  output$questiontext = renderText({
    'Although this data has been interesting to examine, many questions remain unanswered. 
    If the goal of OkCupid is to cause successfull interactions between two adults, then analysis 
    of those interactions should be conducted. For instance, messaging rates and reply rates could be analyzed 
    based on demographics and message content. Do people more often respond to those who ascribe to certain groups, or the same groups as themselves? 
    Are there any particular trends in successful first messages or in the 
    profiles of those most often messaged or replied to? If OkCupid wants users to stick with their service, 
    providing relevant information to users on the effectiveness of certain profile or message attributes is important. 
    Additionally, I would find information on the average lifespan of a user profile interesting and if there are
    certain trends in users that never return to complete a profile.'
  })
  
  ########################
  ### gender #############
  ########################
  output$femaleBox = renderInfoBox({
    percent = round(length(p2$sex[p2$sex == 'f'])/59946 * 100)
    infoBox('Female', paste0(percent, '%'), icon = icon('tachometer'))
  })
  
  output$maleBox = renderInfoBox({
    percent = round(mean(p3$Income[p3$Gender == 'm'], na.rm = TRUE))
    infoBox('Male Average Income', paste0('$', percent), icon = icon('tachometer'))
  })
  
  output$sexBox = renderInfoBox({
    percent = round(mean(p3$Income[p3$Gender == 'f'], na.rm = TRUE))
    infoBox('Female Average Income', paste0('$', percent), icon = icon('tachometer'))
  })
  
  
  output$sexBar = renderPlot({
    
    ggplot(p3, aes(x = Gender)) +
      geom_bar(aes_string(fill = input$sexAgainst), position = input$sexPosition) +
      coord_flip()
    
    
  }, height = 350)
  
  output$sexBoxPlot = renderPlot({
    ggplot(p3, aes_string(x = 'Gender', y = input$sexBoxPlotCat)) +
      coord_trans(y = input$sexBoxPlotTrans) +
      geom_violin(aes(color = Gender))
    
    
  }, height = 350)
  
  
  ########################
  ### orientation ########
  ########################
  output$straightBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'straight'])/59946 * 100)
    infoBox('Straight', paste0(percent, '%'), icon = icon('tachometer'))
  })

  output$gayBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'gay'])/59946 * 100)
    infoBox('Gay', paste0(percent, '%'), icon = icon('tachometer'))
  })

  output$bisexualBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'bisexual'])/59946 * 100)
    infoBox('Bisexual', paste0(percent, '%'), icon = icon('tachometer'))
  })
  
  output$orientationBar = renderPlot({
      ggplot(p3, aes(x = Orientation)) +
        geom_bar(aes_string(fill = input$orientationAgainst), 
                 position = input$orientationPosition)
    
    
  }, height = 350)
  
  output$orientationBoxPlot = renderPlot({
    ggplot(p3, aes_string(x = input$orientationBoxPlotCat)) +
      coord_trans(x = input$orientationBoxPlotTrans) +
      geom_density(aes(color = Orientation))
    
    
  }, height = 350)
  
  
  
  ########################
  ### ethnicity ##########
  ########################
  output$whiteBox = renderInfoBox({
    percent = round(length(p3$Ethnicity[p3$Ethnicity == 'white' & !is.na(p3$Ethnicity)])/59946 * 100)
    infoBox('White', paste0(percent, '%'), icon = icon('tachometer'))
  })
  
  output$multiethnicBox = renderInfoBox({
    percent = round(length(p3$Ethnicity[p3$Ethnicity == 'multiethnic' & !is.na(p3$Ethnicity)])/59946 * 100)
    infoBox('Multiethnic', paste0(percent, '%'), icon = icon('tachometer'))
  })
  
  output$otherBox = renderInfoBox({
    percent = round(length(p3$Ethnicity[is.na(p3$Ethnicity)])/59946 * 100)
    infoBox('No Response', paste0(percent, '%'), icon = icon('tachometer'))
  })
  
  
  output$ethnicityBar = renderPlot({
    ggplot(p3, aes(x = Ethnicity)) +
      geom_bar(aes_string(fill = input$ethnicityAgainst),
               position = input$ethnicityPosition)
    
    
  }, height = 350)
  
  output$ethnicityBoxPlot = renderPlot({
    ggplot(p3, aes_string(x = 'Ethnicity', y = input$ethnicityBoxPlotCat)) +
      coord_trans(y = input$ethnicityBoxPlotTrans) +
      geom_boxplot(aes(color = Ethnicity))+
      scale_fill_brewer(palette = "Paired")
    
    
  }, height = 350)
  
  
  
  ########################
  ### religion ###########
  ########################
  output$religiousBox = renderInfoBox({
    percent = round(length(p3$Religion[(p3$Religion == 'atheism' | p3$Religion == 'agnosticism') & !is.na(p3$Religion)])/59946 * 100)
    infoBox('Agnostic or Atheist', paste0(percent, '%'), icon = icon('tachometer'))
  })
  
  output$relseriousBox = renderInfoBox({
    percent = round(length(p3$Religion.Serious[(p3$Religion.Serious == 3 | p3$Religion.Serious == 4) & !is.na(p3$Religion)])/59946 * 100)
    infoBox('Somewhat or Very Serious', paste0(percent, '%'), icon = icon('tachometer'))
  })
  
  output$christianBox = renderInfoBox({
    percent = round(length(p3$Religion[p3$Religion == 'christianity' & !is.na(p3$Religion)])/59946 * 100)
    infoBox('Christian', paste0(percent, '%'), icon = icon('tachometer'))
  })
  
  
  output$religionBar = renderPlot({
    ggplot(p3, aes(x = Religion)) +
      geom_bar(aes_string(fill = input$religionAgainst), 
               position = input$religionPosition) +
      coord_flip() +
      scale_fill_brewer(palette = "Set3")
    
    
  }, height = 350)
  
  output$religionBoxPlot = renderPlot({
    ggplot(p3, aes_string(x = 'Religion', y = input$religionBoxPlotCat)) +
      coord_trans(y = input$religionBoxPlotTrans) +
      geom_boxplot(aes(color = Religion)) +
      scale_fill_brewer(palette = "Set3")
    
    
  }, height = 350)
  
  
  
  ########################
  ### age ################
  ########################
  
  output$ageBox1 = renderInfoBox({
    percent = round(mean(p3$Income[p3$Age <30 & p3$Age > 24], na.rm = TRUE))
    infoBox('Average Income in Late 20s', paste0('$', percent), icon = icon('tachometer'))
  })
  
  output$ageBox2 = renderInfoBox({
    highestincome = p3 %>% group_by(Age) %>% summarise(Mean = mean(Income, na.rm = TRUE)) %>% arrange(desc(Mean))
    infoBox('Highest Earning Age', paste0(highestincome[[1,1]]), icon = icon('tachometer'))
  })
  
  output$ageBox3 = renderInfoBox({
    lowestincome = p3 %>% group_by(Age) %>% summarise(Mean = mean(Income, na.rm = TRUE)) %>% arrange(Mean)
    infoBox('Lowest Earning Age', paste0(lowestincome[[1,1]]), icon = icon('tachometer'))
  })
  
  
  output$ageHist = renderPlot({
    ggplot(p3, aes(x = Age)) +
      geom_density(aes_string(color = input$ageAgainst)) +
      xlim(15, 75) +
      scale_fill_brewer(palette = "Set3")
  }, height = 350)
  
  output$ageScatter = renderPlot({
    ggplot(p3, aes_string(x = 'Age', y = input$ageScatter)) +
      geom_point(position = 'jitter', 
                 aes_string(alpha = '.1', color = input$ageScatterColor)) +
      geom_smooth() + 
      xlim(15, 75) +
      coord_trans(y = input$ageScatterTrans)+
      scale_fill_brewer(palette = "Set3")
  }, height = 350)
  
  ########################
  ### word cloud #########
  ########################
  
  
  
  ########################
  ### data ###############
  ########################

  output$table = DT::renderDataTable({
    datatable(p3, rownames = T, options = list(scrollX = TRUE)) %>%
      formatStyle(input$selected,
                  background = 'skyblue', 
                  fontWeight = 'bold')

  })
  
  ###############################
  #EXAMPLES
  ##############################
 
  
})