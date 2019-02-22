#' Visualize a Single Sneaker Prices
#'
#' This routine visualizes only one type of sneaker from its original data.
#' 
#' @param table Pricing information
#' 
#' @return A `list` with a `ggplot2` object.
#' @importFrom ggplot2 ggplot aes geom_line facet_wrap theme element_blank labs
#' @export
data_for_visualization = function(table) {
  Date = Price = NULL
  
  g1 = ggplot(table) + 
    aes(x = Date, y = Price) +
    geom_line() + 
    facet_wrap( ~ Size) + 
    theme(panel.grid = element_blank()) + 
    labs(title = "Date versus Price",
         y = "Price",
         x = "Date")
  result = list(g1 = g1)
  return (result)
}

#' Visualize Two Sneaker Prices
#'
#' This visualizes compares sales of two kind of shoes
#' 
#' @param name1,name2 Names of the sneakers to use for visualization.
#' 
#' @return A `list` with a `ggplot2` object.
#' 
#' @importFrom ggplot2 ggplot aes geom_bar facet_wrap theme element_blank element_text labs 
#' @importFrom utils read.csv
#' @export
data_for_visualization2 = function(name1, name2) {
  
  table1 = read.csv(file.path("data", paste0(name1, "_after.csv")))
  table2 = read.csv(file.path("data", paste0(name2, "_after.csv")))
  
  table_all = rbind(table1, table2)
  table_all$Month = as.factor(table_all$Month)
  
  levels(table_all$Month) = month.abb
  
  Month = Name = NULL
  
  g1 = ggplot(table_all) + 
    aes(x = Month, fill = Name) + 
    geom_bar() + 
    facet_wrap( ~Size) +
    theme(panel.grid = element_blank(),
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(
      title = "Quantity of Sneakers Available Over Time Given Foot Size",
      y = "Frequency",
      x = "Months"
    )
  
  result = list(g1 = g1)
  
  return(result)
}


#' Model and Visualize Sneaker Prices
#' 
#' Given a sneaker table and sneaker size, this routine attempts to 
#' create a model for future prices and visualize it simultaneously.
#' 
#' @param table1 Table containing sneaker pricing information
#' @param size   Size of the Sneaker
#' 
#' @details 
#' This function is for making predictions and plotting the predictions
#' given by the table after calculating mean value of shoes in the same day and
#' same size. Result will consists of three parts, first one is plot
#' second and third one are strings indicating the result of maximum value and
#' minimum value separately
#' 
#' @importFrom stats ts
#' @importFrom forecast forecast auto.arima
#' @importFrom ggplot2 ggplot aes geom_line theme labs element_blank theme annotate
#' @export
data_for_prediction = function(table1, size) {
  if (!size %in% table1$Size) {
    stop("This size is not available in this sneaker!")
  }
  
  table = table1[table1$Size == size, ]
  amount = nrow(table)
  table$Size = as.factor(table$Size)
  table$Date = as.Date(table$Date)
  interval = as.numeric(table$Date[nrow(table)] - table$Date[1]) / (nrow(table) - 1)
  fit1 = auto.arima(ts(data = table$Price, frequency = 24))
  predict1 = forecast(fit1)$fitted
  len = length(predict1)
  
  table_predict = data.frame(
    Date = table$Date[len] + (1:len) * interval,
    Size = rep(table$Size[1], len),
    Price = predict1,
    condition = "Predict Price"
  )
  
  table$condition = rep("Real Data", amount)
  table_combined = rbind(table, table_predict)
  max = max(table_predict$Price)
  min = min(table_predict$Price)
  maxDate = table_predict$Date[table_predict$Price == max]
  maxDate = maxDate[1]
  minDate = table_predict$Date[table_predict$Price == min]
  minDate = minDate[length(minDate)]
  
  Date = Price = condition = NULL
  
  
  if (min == max) {
    minMessage = "There is no maximum price and minimum price in our prediction since sources prices are too few to make the prediction."
    
    g1 = ggplot(table_combined) +
      geom_line(aes(x = Date, y = Price)) +
      geom_line(aes(x = Date, y = Price, color = condition)) +
      theme(panel.grid = element_blank()) +
      labs(title = "Predicted Result",
           y = "Sneaker Price",
           x = "Date",
           color = "Data Type")
    
    maxMessage = "There is no maximum price and minimum price in our prediction since sources prices are too few to make the prediction."
  } else {
    minMessage = paste0(
      "The minimum price of our prediction is ",
      round(min, 2),
      ", which will be in ",
      minDate,
      "."
    )
    maxMessage = paste0(
      "The maximum price of our prediction is ",
      round(max, 2),
      ", which will be in ",
      maxDate,
      "."
    )
    
    g1 = ggplot(table_combined) +
      geom_line(aes(x = Date, y = Price)) +
      geom_line(aes(x = Date, y = Price, color = condition)) +
      theme(panel.grid = element_blank()) +
      annotate("text", x = maxDate, y = max, label = "Max Price") + 
      annotate("text", x = minDate, y = min, label = "Min Price") +
      labs(title = "Predicted Result",
           y = "Sneaker Price",
           x = "Date",
           color = "Data Type")
  }
  result = list(g1 = g1,
                minMessage = minMessage,
                maxMessage = maxMessage)
  return (result)
}