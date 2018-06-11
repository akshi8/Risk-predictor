# UI file for shiny
library(plotly)
shinyUI(dashboardPage( skin = "blue",
                       
                       #Application title
                       dashboardHeader(title = "Online Sex-Work Risk Predictor",titleWidth = 450),
                       
                       # dashboard sidebar functions will be inserted here
                       dashboardSidebar(
                         
                         sidebarMenu(
                           menuItem("Predict",tabName = "predict",icon = icon("bar-chart-o")),
                           # menuItem("Plot",tabName = "plot",icon = icon("dashboard")),
                           menuItem("Data",tabName = "data",icon = icon("table")),
                           menuItem("Info",tabName = "info",icon = icon("info-circle"))
                         ),
                         sliderInput("age",
                                     label = "Age range:",
                                     min =  18,
                                     max = 87,
                                     step = 1,
                                     value = c(18,34),
                                     sep = ""),
                         sliderInput("last-login",
                                     label = "Last login: number of days ago",
                                     min =  1,
                                     max = 2402,
                                     step = 1,
                                     value = c(1,2402),
                                     sep = ""),
                         uiOutput("typeSelectOutput")
                       ),
                       # functions that must go in the body of the dashboard.
                       dashboardBody(
                         tabItems(
                           tabItem(tabName = "predict",
                                   plotOutput("thePlot"),
                                 
                                 downloadButton("download1", "Download predictions"),
                                 hr(),
                                 br(),
                                 br(),
                                 DT::dataTableOutput("prediction"),
                                 tags$head(
                                   tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
                                 )
                         ),
                         #   tabItem(tabName = "plot",
                         #           plotOutput("thePlot"),
                         #           br()
                         #           
                         #   ),
                           tabItem(tabName = "data",
                                   DT::dataTableOutput("gendata"),
                                   downloadButton("download2", "Download generated data"),
                                   hr()
                           ),
                           tabItem(tabName = "info",
                                   includeMarkdown("info.md"),
                                   hr()
                           )
                         )
                       )
)
)
