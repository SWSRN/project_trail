library(shiny)
shinyUI(
  fluidPage(
  titlePanel("Do Trails Increase House Prices?"),

  tabsetPanel(
   tabPanel("Trails",     
     #titlePanel("Do Trails Increase House Prices?"),

     fluidRow(  #width=3,
        column(width=6,
            h3('Remove Outliers'),
            sliderInput("range", "Range", min = -250, max = 600, 
                        value = c(-190, 250))
            ),
        column(width=6, 
               plotOutput("densityPlt", height = "250px")
        )
    ),

    textOutput("text_wilcox"),  
    h6(' '),
    tableOutput("table_favstats"),  

    fluidRow(  #width=6,
        column(width=4,
               radioButtons("whichInfo", "Select data to map and calculate statistics", 
                     c("diff2014", "acre", "squarefeet", "no_half_baths", 
                        "walkscore", "bikescore", 
                       "price1998", "price2014"), 
                     selected = "diff2014", inline = FALSE),
                h6(' ')
                #actionButton("ButtonHelp", "?")
        ),
        column(width=8,
            plotOutput("mapPlt")
        )
    )
    
   ), #tabPanel Trails
    tabPanel("Documentation",     htmlOutput('htmlDoc'))    
  ) # tabsetPanel
  )  #FluidPage
)  # ShnyIU