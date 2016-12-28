# storeMonitor
# Objective: store whether retrieval of rates was succesfull in database (for monitoringpurposes)
storeMonitor <- function(initiateDB = FALSE, columnNames = c(), dataframeValues = NULL, dbName = '', dbArchive = '') {
  
  
  # Initiate database
  if (initiateDB){
    
    # Option 1: Create new file  
    dataframeValues <- rbind(columnNames, dataframeValues)
    write.table(dataframeValues, file = dbName, na="NA", quote= F,col.names = F,row.names = F,sep=",")
    print(paste("Database has been stored under location:", dbName))
    
  }else{
    # Option 2: Write to existing file encompassing following steps:
    # - define column names
    # - Read the current file
    # - Create identical names for matching purposes
    # - # rbind both data.frames
    # - get only the non duplicate rows from the new data.frame
    # - Store file with the non duplicate rows
    # - Archive file with the non duplicate rows
    dfRead                    <- read.csv(file = dbName, stringsAsFactors=FALSE, sep=",") 
    #colnames(dataframeValues) <- colnames(dfRead)
    allD                      <- rbind(dfRead, dataframeValues) 
    allUnique                 <- unique(allD)
    
    write.table(allUnique, file = dbName, row.names=F,col.names=T,na="NA",append=F, quote= F, sep=",")
    write.table(dfRead, file = dbArchive, row.names=F,col.names=T,na="NA",append=F, quote= F, sep=",")
    print(paste("Database has been updated under location:", dbName))
    print(paste("Former database has been archived under location:", dbArchive))
  }
  
  return('Monitoring Database stored')
  
  
}