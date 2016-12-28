# storeRates
# Objective: store rate information in database
storeRates <- function(initateDB = FALSE, columnNames = c(), dataframeRates = NULL, dbRates = '', dbArchive = '') {
  
  # Initiate database
  if (initiateDB){
    # Option 1: Create new file  
    dataframeRates <- rbind(columnNames, dataframeRates)
    write.table(dataframeRates, file = dbRates, na="NA", quote= F,col.names = F,row.names = F,sep=",")
    print(paste("=> Rate Db initiated:", dbRates))
    
  }else{
    # Option 2: Write to existing file encompassing following steps:
    # - define column names
    # - Read the current file
    # - Create identical names for matching purposes
    # - # rbind both data.frames
    # - get only the non duplicate rows from the new data.frame
    # - Store file with the non duplicate rows
    # - Archive file with the non duplicate rows
    dfRead                    <- read.csv(file = dbRates, stringsAsFactors=FALSE, sep=",") 
    colnames(dataframeRates)  <- colnames(dfRead)
    allD                      <- rbind(dfRead, dataframeRates) 
    allUnique                 <- unique(allD)
    
    write.table(allUnique, file = dbRates, row.names=F,col.names=T,na="NA",append=F, quote= F, sep=",")
    write.table(dfRead, file = dbArchive, row.names=F,col.names=T,na="NA",append=F, quote= F, sep=",")
    print(paste("=> Rate Db updated:", dbRates))
    print(paste("=> Rate Db archived:", dbArchive))
  }
  
  return('SUCCES')
  
  
}