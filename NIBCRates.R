#########################
# NIBC
# - Objective: Haal rente op en sla op in CSV file

# Define setting - Generic
source('settings/settingsGeneric.R')

#Start Timer
tic()

# Initiate tryCatch error handling function
checkMonitor <- tryCatch(
  {
  #Define variables - Bank Specific
  source('functions/productRateNIBC.R')
  source('settings/settingsNIBC.R')
  
  # Access data from URL for products and define data frame across products
  columnNames   <- c(dbcolumnName1,dbcolumnName2,dbcolumnName3,dbcolumnName4,dbcolumnName5,dbcolumnName6)
  dfRates       <- data.frame(matrix(NA, nrow=numberofProducts, ncol=dbnumCols))
  
  for (productNum in 1:numberofProducts) {
    
    #temp vars
    tempName  <- eval(parse(text=paste("productName", productNum, sep="")))
    tempUrl   <- eval(parse(text=paste("productUrl", productNum, sep="")))
    tempDur   <- eval(parse(text=paste("productDur", productNum, sep="")))
    tempNod   <- eval(parse(text=paste("productNode", productNum, sep="")))
    tempNod2   <- eval(parse(text=paste("productNode", productNum, "b", sep="")))
    
    # For each column define the value
    dfRates[productNum,1] <-  D
    dfRates[productNum,2] <-  bank
    dfRates[productNum,3] <-  tempName
    dfRates[productNum,4] <-  productRateNIBC(tempUrl,tempNod,tempNod2,scaleFactor)
    dfRates[productNum,5] <-  tempUrl
    dfRates[productNum,6] <-  tempDur
  }

  # Store database
  dbArchive     <- paste(outputFolder_arc, bankDBname,"-",D, ".", fileTypeDB , sep="")
  dbRates       <- paste(outputFolder, bankDBname, ".", fileTypeDB, sep="")
  
  #returns ("SUCCES") if succesful
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

# Stop Timer and print Time
timeElapsed <- toc()

# Monitoring function - store if analysis was succesful
dbMonitor       <- paste(outputFolder_mon, outputFile_mon, ".", fileTypeDB , sep="")
dbMonitorArc    <- paste(outputFolder_mon, outputFile_mon,"-",D, ".", fileTypeDB , sep="")
dbMonCol        <- c("Date", "Bank", "Rates stored?","Timestamp", "Time elapsed")
outMon          <- c(D,bank,checkMonitor, format(Sys.time(), "%Y-%m-%d %H:%M:%S"), timeElapsed$toc[["elapsed"]] - timeElapsed$tic[["elapsed"]])
storeMonitor(initiateMon,dbMonCol, outMon, dbMonitor,dbMonitorArc)

# Clear environment
rm(list = ls())
