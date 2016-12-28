#########################
# ControlCenter - overarching function to scrape websites
# - Objective: per referenced website, obtain rates
# - structure: (1) loop over banks, (2) retrieve rates per bank and store rates, 
# (3) Monitor outcome per bank in separate monitoring file, (4) email update

# Define setting - Generic
# - note: in settingsGeneric also a shortlist of banks is provided
source('settings/settingsGeneric.R')

# (1) Loop over banks
for (bankNum in 1:numBanks) {
  
  # Start timer per bank
  tic()
  
  # Print initation of process - bank no.
  print("Rate extraction initiated for next bank...")
  print(paste("=> Bank No.:", bankNum))
  
  # (2) Retrieve rates for each bank
  # Initiate tryCatch error handling function
  checkMonitor <- tryCatch(
    {
      # Capture settings - Bank Specific
      #source(paste("functions/productRate",listBanksPRFiles[bankNum],".R", sep=""))
      source(paste("settings/settings",listBanksSetFiles[bankNum],".R", sep=""))
      
      # Print initation of process - bank name
      print(paste("=> Bank Name:", bank))
      
      # Access data from URL for products and define data frame across products
      dfRates       <- data.frame(matrix(NA, nrow=numberofProducts, ncol=dbnumCols))
      
      
      
      # Interate over products - Bank specific
      for (productNum in 1:numberofProducts) {
        
        # Temp vars
        tempD     <- D
        tempBank  <- bank
        tempName  <- eval(parse(text=paste("productName", productNum, sep="")))
        tempUrl   <- eval(parse(text=paste("productUrl", productNum, sep="")))
        tempDur   <- eval(parse(text=paste("productDur", productNum, sep="")))
        temphtmlNode    <- eval(parse(text=paste("productNode", productNum, sep="")))
        tempNodPos      <- eval(parse(text=paste("productNode", productNum, "b", sep="")))
        
        # For each column define the value
        dfRates[productNum,1] <-  tempD
        dfRates[productNum,2] <-  tempBank
        dfRates[productNum,3] <-  tempName
        dfRates[productNum,4] <-  productRateScraping(typeScrape, tempUrl,tempDur,
                                                      scaleFactor, temphtmlNode, tempNodPos,
                                                      outputFolder_pdf)
        dfRates[productNum,5] <-  tempUrl
        dfRates[productNum,6] <-  tempDur
      }
      
      # Define databases - Bank specific
      dbArchive     <- paste(outputFolder_arc, bankDBname,"-",D, ".", fileTypeDB , sep="")
      dbRates       <- paste(outputFolder, bankDBname, ".", fileTypeDB, sep="")
      
      # Store databases - Bank specific
      # - returns ("SUCCES") if succesful
      # - note: initiateDB is bank specific (and in settings file)
      storeRates(initateDB, columnNames, dfRates, dbRates, dbArchive) 
      
    },
    error = function(cond)
    {
      # error handler picks up where error was generated
      message(paste("ERROR:  ",cond))
      return("FAILED")
      
    },
    warning = function(cond) {
      # warning handler picks up where warning was generated
      message(paste("WARNING:  ",cond))
      return("WARNING")
    },
    finally ={ 
      # NOTE: Here goes everything that should be executed at the end, regardless of success or error.
    }
  )  # END tryCatch
  
  # Stop Timer and do not print Time
  timeElapsed <- toc(quiet = TRUE)
  
  # Print succes or failure of attempt
  print(paste("=> Extraction status:", checkMonitor))
  
  # (3) Monitor outcome per bank in monitoring file encpompassing status of all banks
  # Monitoring function - store if analysis was succesful
  dbMonitor       <- paste(outputFolder_mon, outputFile_mon, ".", fileTypeDB , sep="")
  dbMonitorArc    <- paste(outputFolder_mon, outputFile_mon,"-",D, ".", fileTypeDB , sep="")
  outMon          <- c(D,bank,checkMonitor, format(Sys.time(), "%Y-%m-%d %H:%M:%S"), timeElapsed$toc[["elapsed"]] - timeElapsed$tic[["elapsed"]])
  storeMonitor(initiateMon,dbMonCol, outMon, dbMonitor,dbMonitorArc)
  
} # END loop over banks

# Clear environment
rm(list = ls())
