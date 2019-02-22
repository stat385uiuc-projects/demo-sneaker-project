#' Import Raw Data in SQL Data Base
#' 
#' This function is used for handle raw data, add variables, and extract value by SQL to make predictions.
#' 
#' @param input The name of the file without the `.csv` extension.
#' @return A `data.frame` and have the side effect of writing a new table to
#' disk.
#' @importFrom stringr str_extract str_replace str_sub
#' @importFrom tidyr separate
#' @importFrom sqldf sqldf
#' @importFrom utils read.csv write.csv
#' @export
handle_rawdata = function(input) {
  filename = file.path("data", paste0(input, ".csv"))
  shoebrand = str_extract(input, "[:alpha:]*[:space:]")
  shoename = str_replace(input, shoebrand, "")
  shoebrand = str_replace(shoebrand, " ", "")
  table1 = read.csv(filename)
  table1 = table1[, -1]
  colnames(table1)[1] = "Date"
  colnames(table1)[2] = "Size"
  colnames(table1)[3] = "Price"
  table1$Name = shoename
  table1$Brand = shoebrand
  table1 = separate(table1, "Date", c("Date", "Time"), sep = "T")
  table1$Year = str_sub(table1$Date, 1, 4)
  table1$Month = str_sub(table1$Date, 6, 7)
  table1$Day = str_sub(table1$Date, 9, 10)
  table1$Date = as.Date(table1$Date)
  table1$Number_Price = as.numeric(table1$Price)
  table1$Size = as.factor(table1$Size)
  filenameAfter = file.path("data", paste0(input, "_after", ".csv"))
  write.csv(table1, filenameAfter)
  
  sqry = "
  SELECT Date, Size, AVG(Number_Price) as Price
  FROM table1
  GROUP BY Date, Size;"
  table2 = sqldf::sqldf(sqry)
  
  return(table2)
}
