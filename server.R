# Server file for shiny


shinyServer(function(input,output) {
  # select cities to compare
  output$typeSelectOutput <- renderUI({
    selectInput("typeInput","Select Sexual Orientation/(s):",
                sort(unique(dat$Sexual_orientation)),
                multiple = TRUE,
                selected = c("Homosexual","Heterosexual","bicurious","bisexual","None"))
  })
  
  # creates a reactive data table
  predict_reactive <- reactive({
    # data_React <- data %>% filter(year >= input$year[1],
    #                               year <= input$year[2])
    # if(nrow(data_React)==0){
    #   return(NULL)
    # }
    # data_React
    dat = dat %>% filter(Age >= input$age[1], Age <= input$age[2]) %>% 
      filter(Sexual_orientation %in% input$typeInput) %>% 
      filter(Last_login >= input$`last-login`[1], Last_login <= input$`last-login`[2])
    
    df <- dat %>% filter(Risk=="unknown_risk") %>% 
      mutate(time_spent=period_to_seconds(hms(`Time_spent_chating_H:M`)))
    temp <- dat %>% filter(Risk!="unknown_risk") %>% 
      mutate(time_spent=period_to_seconds(hms(`Time_spent_chating_H:M`)))
    
    dat2 <- rbind(temp,df[sample(1:nrow(df), 90),])
    test <- dat2 %>% filter(Risk=="unknown_risk") %>% mutate(Risk = '') %>% 
      select(-User_ID,-`Time_spent_chating_H:M`, -Points_Rank,-Member_since) %>%
      as.tibble()
    train <- dat2 %>% 
      filter(Risk!="unknown_risk") %>% 
      select(-User_ID,-`Time_spent_chating_H:M`, -Points_Rank,-Member_since) %>% 
      as.tibble()
    train = train %>% 
      mutate_if(is.character, as.factor)
    test = test %>% 
      mutate_if(is.character, as.factor)
    
    # realigning factor levels of test and train method
    levels(test$Risk) = levels(train$Risk)
    levels(test$Verification) = levels(train$Verification)
    levels(test$Sexual_polarity) = levels(train$Sexual_polarity)
    levels(test$Sexual_orientation) = levels(train$Sexual_orientation)
    allvalues <- unique(union(test$Location,train$Location)) 
    train$Location <- factor(train$Location, levels = allvalues)
    levels(test$Location) = levels(train$Location)
    levels(test$Location) = levels(train$Location)
    
    m <- randomForest(Risk ~ ., data = train, importance=TRUE, proximity=TRUE, ntree=22)
    output <- test
    pred <- predict(m,test)
    output$Risk <- pred
    output %>% select(Risk,Gender, Age, Location, Verification,Sexual_orientation,Sexual_polarity,Looking_for,Last_login)
  })
  
  # creates a reactive city data wise data table
  input_reactive <- reactive({
    dat
  })
  
  # function to compute the city wise line plot
  output$thePlot <- renderPlot({
    # plot <- ggplot(data_reactive()) + 
    #   xlab("year") + 
    #   ylab(paste0(input$parameter))
    
    plot <- ggplot(predict_reactive(),aes(x = Looking_for,color=Risk,y = Location)) + 
      geom_jitter(alpha=0.7) + 
      scale_color_manual(breaks = c('N','Y'),
                         values = c("Green","Red"),
                         labels = c('Not at Risk','At Risk')) + 
      theme_minimal() + 
      xlab("Looking For")

    
    plot
  })
  
  # renders the resulting data table 
  output$prediction <- DT::renderDataTable(
    predict_reactive(),
    options = list(scrollX = TRUE)
  )
  
  output$gendata <- DT::renderDataTable(
    input_reactive(),
    options = list(scrollX = TRUE)
  )
  
  # a download option for downloading CSV
  output$download1 <- downloadHandler(
    filename = function() {
      "data.csv"
    },
    content = function(con) {
      write.csv(predict_reactive(), con)
    }
  )
  
  output$download2 <- downloadHandler(
    filename = function() {
      "data.csv"
    },
    content = function(con) {
      write.csv(input_reactive(), con)
    }
  )
  
  
})