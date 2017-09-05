library(shiny)
library(shinyFiles)
options(shiny.maxRequestSize=10000*1024^2) 

shinyUI(fluidPage(
  #  Application title
  headerPanel("Trendy"),
  
  # Sidebar with sliders that demonstrate various available options
  fluidRow(width = 12, height = 100,
               # file
              column(4,
               fileInput("filename", label = "Data file input (support .csv, .txt, .tab)"),
               
               # time vector
               fileInput("TimeVector", label = "Time vector \n file name (e.g. support .csv, .txt, .tab)"),
               
              
                 # Normalization
                 radioButtons("Norm_buttons",
                              label = "Do you need to normalize the data?",
                              choices = list("Yes" = 1,
                                             "No" = 2),
                              selected = 2),

                # Scale
                 radioButtons("Scale_InData",
                           label = "Center and scale the data?",
                           choices = list("Yes" = 1,
                                          "No" = 2),
                           selected = 2),
                          
             radioButtons("Plot_Data",
                       label = "Output scatterplots with Trendy fit (sorted by adjusted R^2)?",
                       choices = list("Yes" = 1,
                                      "No" = 2),
                       selected = 1)
                       ),            
              column(4,
                  numericInput("meanCut",
                              label = "Only consider genes with mean greater than",
                              value = 10),
                 # MaxK
                 numericInput("maxK",
                              label = "Maximum number of breakpoints",
                              value = 5),
                 # MinNum
                 numericInput("minNum",
                              label = "Minimum number of data points in each segment",
                              value = 3),         
                     
                 # pvalcut
                 numericInput("pvalCut",
                              label = "P-value to determine direction of segment (up, down, or same)",
                              value = .2),
               

                 # out name
                 textInput("outName", 
                           label = "Name of output files", 
                           value = "trendy_results")
                      
                
               ),
               
               column(4,
                      # output dir
                      tags$div(tags$b("Please select a folder for output :")),
                      
                      shinyDirButton('Outdir', label ='Select Output Folder', title = 'Please select a folder'),
                      tags$br(),
                      tags$br()
                      ),
               br(),
               br(),
               actionButton("Submit","Submit for processing")
  ),
  
  # Show a table summarizing the values entered
  mainPanel(
    h4(textOutput("print0"))
  )
))