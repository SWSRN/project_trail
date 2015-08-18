require(shiny)
packageVersion('shiny')
require(dplyr)
#require(plyr)  # added by Tanya for mutate command
require(lattice)  # for densityPlot()
require(ggmap)  # for map
require(mosaic)  # for favstats

shinyServer(
    function(input, output) {
        if (! exists("ds")) {
            ds <- read.csv("dataset_in_wide_format.csv")
            cat("Cat: Loaded up ds from file. \n")
            print("print: Loaded up ds from file.")
            # make row names from address
            rownames(ds) <- paste0(ds[,'streetno'], " ", ds[,'streetname'])
        }
        if (! exists("mymap")) {
            northampton = c(lon=-72.675, lat=42.3250)
            mymap = get_map(location=northampton, zoom=13, color="bw")# web call
        }

        ######## density graph output ################################
        output$densityPlt <- renderPlot({
            ds_clipped <-  ds %>%
               filter(diff2014 >= as.numeric(input$range[1])
                      & diff2014 <= as.numeric(input$range[2]) )
            densityplot(~ diff2014, groups=distgroup, auto.key=TRUE, 
            xlab="Price change 1998 to 2014 (in thousands of 2014 dollars) [diff2014]", 
                   data=ds_clipped)  
        })

        ######## google map output ################################
        output$mapPlt <- renderPlot({
            iwhichData <- match(input$whichInfo, names(ds))  
            ds_clipped <-  ds %>%
                    filter(diff2014 >= as.numeric(input$range[1])
                           & diff2014 <= as.numeric(input$range[2]) )
           if (! exists("mymap")) {
                northampton = c(lon=-72.675, lat=42.3250)
                mymap = get_map(location=northampton, zoom=13, color="bw")# web call
            }
            # try aes_string instead of aes. Very picky syntax for ggplot/shiny.
            #http://stackoverflow.com/questions/19531729/shiny-fill-value-not-passed-to-ggplot-correctly-in-shiny-server-error-object
            #http://docs.ggplot2.org/0.9.3/aes_string.html
            realmap = ggmap(mymap) + 
                geom_point(aes_string(x="longitude", 
                               y="latitude", 
                               colour="distgroup", 
                               size= input$whichInfo), data=ds_clipped ) +
                    ggtitle(paste0('Northampton MA, map of ', input$whichInfo)) + 
                    theme(legend.position="left")
            print(realmap)
        })

        ######## favstats output ################################
        output$table_favstats <- renderTable({
            ds_clipped <-  ds %>%
                    filter(diff2014 >= as.numeric(input$range[1])
                           & diff2014 <= as.numeric(input$range[2]) )
            iwhichData <- match(input$whichInfo, names(ds))  
            
            favstats(ds_clipped[,iwhichData] ~ ds_clipped$distgroup)
        })
        
        ######## Wilcox stats output ################################
        output$text_wilcox <- renderText({
           #if (! exists("ds_clipped")) {
                ds_clipped <-  ds %>%
                    filter(diff2014 >= as.numeric(input$range[1])
                           & diff2014 <= as.numeric(input$range[2]) )
            #}
            iwhichData <- match(input$whichInfo, names(ds))  #Need extra step or no go.
            iCloser <-  ds_clipped$distgroup == "Closer"
            iFarther <- ds_clipped$distgroup == "Farther Away"
            stuff <- wilcox.test(ds_clipped[iCloser,iwhichData], 
                     ds_clipped[iFarther,iwhichData])

            paste0(input$whichInfo, ':', 
                    ' Wlicox rank sum test with continuity correction.', 
                   ' W statistic = ', round(stuff$statistic, 5),
                   ' p-value = ', signif(stuff$p.value, 4))
       })
        
       ######### Documentation text box ###################
#       output$textDoc <- renderText({
        output$htmlDoc <- renderText({
            doc <- readLines("trails_codebook.html", n=-1)  
#            doc <- scan("trails_codebook.txt", character(0), 
#                            sep ='\n', blank.lines.skip=FALSE)
            #doc <- cat(doc, sep="\n")
            doc
      })

    }
)