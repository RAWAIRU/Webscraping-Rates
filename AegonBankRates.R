#########################
# Aegon Bank
# - Objective: Haal rente op en sla op in CSV file

# Define setting - Generic
source('settings/settingsGeneric.R')

#Start Timer
tic()

#Define variables - Bank Specific
source('functions/productRateAegonBank.R')
source('settings/settingsAegonBank.R')

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
  dfRates[productNum,4] <-  productRateAegonBank(tempUrl,tempNod,tempNod2,scaleFactor)
  dfRates[productNum,5] <-  tempUrl
  dfRates[productNum,6] <-  tempDur
}


# Store database
dbArchive     <- paste(outputFolder_arc, bankDBname,"-",D, ".", fileTypeDB , sep="")
dbRates       <- paste(outputFolder, bankDBname, ".", fileTypeDB, sep="")
checkStatus   <- storeRates(initateDB, columnNames, dfRates, dbRates, dbArchive) 

# Stop Timer and print Time
toc()

# Clear environment
rm(list = ls())
