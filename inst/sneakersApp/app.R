library(sneakers)
library(shiny)

# Define Cached Shoes
shoe.name <- c("Adidas NMD",
               "Adidas Yeezy 700",
               "Adidas Yeezy Wave Runner 700",
               "Nike Air Force 1",
               "Nike Air Jordan 12 Master",
               "Nike Air Jordan 4 Travis", 
               "Nike Air Jordan 4 Royalty")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Sneakerhead Gear"),
    tabsetPanel(
      tabPanel("Prediction",
               sidebarLayout(
                 sidebarPanel(
                   selectizeInput("shoe",
                     "Please choose your sneakers:",
                     choices = shoe.name,
                     options = list(
                       placeholder = 'Please select an option below',
                       onInitialize = I('function() { this.setValue(""); }')
                     )
                   ),
                   sliderInput("size",
                               "Please specify a size:",
                               value = 9,
                               min = 4, max = 14, step = 0.5),
                   actionButton(inputId = "bt", label = "Apply")
                 ),
                 mainPanel(
                   imageOutput("image"),
                   plotOutput("pred"),
                   uiOutput("info"))
               )),
      tabPanel("Comparision", 
               sidebarLayout(
                 sidebarPanel(
                   selectizeInput("pair",
                                  "Please select sneakers to compare:",
                                  choices = shoe.name,
                                  multiple = TRUE, options = list(maxItems = 2)
                   ),
                   actionButton(inputId = "bt2", label = "Apply")
                 ),
                 mainPanel(plotOutput("comp"))
               )),
      tabPanel("Search Live", 
               sidebarLayout(
                 sidebarPanel(
                   textInput("name", 
                             label = "Please enter your sneaker"),
                   actionButton(inputId = "bt3", label = "Apply")
                 ),
                 
                 mainPanel(imageOutput("liveimg"),
                           tableOutput("table"))
               ))
    )
)

server <- function(input, output) {

    active_dataset =
        eventReactive(input$bt3, {
          list = scrape_sneaker_info(input$name)
          return(list)
        })
    
    active_sneakername = 
      eventReactive(input$bt, {
        input$shoe
      })
    
    active_sneakername2 = 
      eventReactive(input$bt2, {
        input$pair
      })
    
    active_size =  
      eventReactive(input$bt, {
        input$size
      })
    
    output$image <- renderImage({
      list(src = paste0('img/', active_sneakername(), '.png'),
           wisth = 385,
           height = 385)
    }, deleteFile = FALSE)
    
    output$pred <- renderPlot({
      table = handle_rawdata(active_sneakername())
      table = data_for_prediction(table, active_size())
      table$g1
    })
    
    output$info <- renderUI({
      table = handle_rawdata(active_sneakername())
      table = data_for_prediction(table, active_size())
      
      div(h3("For buyers"), table$minMessage, br(), h3("For sellers"), table$maxMessage)
    })
    
    output$comp <- renderPlot({
      temp = data_for_visualization2(active_sneakername2()[1],
                                     active_sneakername2()[2])
      temp$g1
    })

    output$table <- renderTable({
      table = active_dataset()$table
      colnames(table) = c("Size", "Price", "Date", "Time")
      table
    })
    
    output$liveimg <- renderImage({
      list(src = active_dataset()$image,
           wisth = 385,
           height = 385)
    }, deleteFile = TRUE)
    
}

# Run the application
shinyApp(ui = ui, server = server)
