options(shiny.maxRequestSize=500*1024^2) 
library(Trendy)
library(EBSeq)
library(parallel)
library(segmented)
library(shiny)
library(shinyFiles)


shinyServer(function(input, output, session) {
  volumes <- c('home'="~")
  shinyDirChoose(input, 'Outdir', roots=volumes, session=session, restrictions=system.file(package='base'))
  output$Dir <- renderPrint({parseDirPath(volumes, input$Outdir)})
  
  wcinfo = sessionInfo(package="Trendy")
  wcinfo_print = wcinfo$otherPkgs
  
  In <- reactive({
    
  
    outdir <- paste0("~", do.call("file.path", input$Outdir[[1]]), "/")

   
    
    withProgress(message = 'Progress:', value = 0, {
      
       incProgress(0.2, detail = "Uploading files...")
       the.file <- input$filename
       if (is.null(the.file)) { stop("Please upload data") }
     
       Sep=strsplit(the.file$name,split=".", fixed=TRUE)[[1]]
    	  if(Sep[length(Sep)] == "csv") {
          a1 = read.table(input$filename$datapath, stringsAsFactors = FALSE,
                          header = TRUE, row.names = 1, comment.char = "", sep=",")
        }                        
        if(Sep[length(Sep)] != "csv") {
            try((a1 = read.table(input$filename$datapath, stringsAsFactors = FALSE,
                  header = TRUE, row.names = 1, comment.char = "", sep="\t")), silent=TRUE)
      	    if(methods::is(a1, "try-error")) {
      		    print("Initial data import failed, file format may be incorrect. Check that gene names are in the first 
               row and that you have column names in your file.") 
            }
        }
      
     
      
        Data = data.matrix(a1)
        time.file <- NULL
        time.file <- input$TimeVector$name
        if (is.null(time.file)) {
            tVectIn = seq_len(ncol(Data))}

        if (!is.null(time.file)) {
            Time.Sep = strsplit(time.file, split = ".", fixed=TRUE)[[1]]
            if (Time.Sep[length(Time.Sep)] == "csv") {
                TimeIn = read.table(input$TimeVector$datapath, stringsAsFactors = FALSE,
                                    header = FALSE, sep=",")
            }
            if (Time.Sep[length(Time.Sep)] != "csv") {
                TimeIn = read.table(input$TimeVector$datapath, stringsAsFactors = FALSE,
                                header = FALSE, sep="\t")
            }
            tVectIn = TimeIn[[1]]
            names(tVectIn) <- colnames(Data)
            if (length(tVectIn) != ncol(Data)) {
              stop("Length of the time vector is not the same as the number of samples!") }

        }

       incProgress(0.1, detail = "Upload successful!")
       
       
        List <- list(
              InFile=the.file,
              TimeFile=time.file,
              NormTF = ifelse(input$Norm_buttons == "1", TRUE, FALSE), 
        	    ScaleTF = ifelse(input$Scale_InData == "1", TRUE, FALSE), 
              MeanCut = input$meanCut,
              MaxK = input$maxK,
              MinNumInSeg = input$minNum,
              PvalCut = input$pvalCut,
              outputName = paste0(outdir, input$outName),
              PlotData = ifelse(input$Plot_Data == "1", TRUE, FALSE),
              Info = paste0(outdir, input$outName, "_run_parameters.txt"),
              OutDir = outdir
            )
       incProgress(0.2, detail = "Formatting data for Trendy...")  
    
       
        if (List$NormTF) {
            Sizes <- EBSeq::MedianNorm(Data)
            if (is.na(Sizes[1])) {
              Sizes <- MedianNorm(Data, alternative=TRUE)
              message("Alternative normalization method is applied.")
            }
            Data <- GetNormalizedMat(Data, Sizes)
        }
        if (List$ScaleTF) {
            Data <- Data[which(rowMeans(Data) >= List$MeanCut), ]
            Data <- t(apply(Data, MARGIN = 1, FUN = function(X) (X - min(X))/diff(range(X))))
            List$MeanCut <- -Inf
        }
        
        incProgress(0.4, detail = "Running Trendy...")

        setwd(outdir)
        seg.all <- results(trendy(Data, tVectIn = tVectIn, saveObject = TRUE,
                        fileName = List$outputName,
						meanCut = List$MeanCut, 
						maxK = List$MaxK, 
                        minNumInSeg = List$MinNumInSeg, 
						pvalCut = List$PvalCut, 
                        ))
    
       
        getAll <- topTrendy(seg.all, adjR2Cut = -Inf)

        getRsq <- getAll$AdjustedR2
        GenesToPlot <- names(sort(getRsq, decreasing=TRUE))
        
        toOut <- formatResults(getAll, featureNames = GenesToPlot)

     if (List$PlotData) {
        incProgress(0.1, detail = "Making scatterplots...")
        pdf(paste0(List$outputName,"_scatter.pdf"), height=15, width=10)
        par(mfrow=c(3,2), mar=c(5,5,2,1))
        XX <- plotFeature(Data, tVectIn = tVectIn, 
                      featureNames=GenesToPlot, showFit=TRUE,
                      trendyOutData = seg.all)
        dev.off()              
      }

      write.table(toOut, file=paste0(List$outputName, "_summaryTrendy.csv"), quote=F, sep=",", row.names=FALSE)
        })
    ## Sessioninfo & input parameters
    sink(List$Info)
    print(paste0("Package version: ", wcinfo_print$Trendy$Version))
    print("Input parameters:")
    print(paste0("Input File: ", List$InFile[1]))
    print(paste0("Time File: ", List$TimeFile[1]))
    print(paste0("Whether to normalize? ", List$NormTF))
    print(paste0("Whether to scale? ", List$ScaleTF))
    print(paste0("Mean cutoff: ", List$MeanCut))
    print(paste0("Maximum possible breakpoints considered: ", List$MaxK))
    print(paste0("Minimum number of data per segment: ", List$MinNumInSeg))
    print(paste0("P-value for significance of segment trend (up or down): ", List$PvalCut))
    sink()
    
    
    List=c(List)	
})   
  
  Act <- eventReactive(input$Submit,{
    In()})
  # Show the values using an HTML table
  output$print0 <- renderText({
    tmp <- Act()
    print("Done!")
  })
  


})