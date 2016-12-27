# Achmea Bank - parser
# Objective: read information from website using JSON
productRateAB <- function(urlBank, nodeDur=0, scaleRate =1) {

  # Lees JSON data in
  rateProduct1 <- data.frame(fromJSON(urlBank))
  
    # Vind row met meest recente datum
  if(nodeDur == 0){
    #RPR
    #Order rpr rates in line with date
    rateProduct1 <- rateProduct1[order(rateProduct1$rpr.interestRates.publishDate,decreasing=TRUE),]
    
    #Define row (always 1 after ordering)
    nodeRow <- 1
    
    #Define col
    nodeCol <- match("rpr.interestRates.interestRate",names(rateProduct1))

  }else{
    # RVR
    #Order rvr rates in line with date
    rateProduct1 <-rateProduct1[order(rateProduct1$rvr.interestRates.publishDate,decreasing=TRUE),]
    
    #Run through  rvr.interestRates.durationYears and in case of NA create Years
    for (row in 1:nrow(rateProduct1)) { 
      
      # Column with durations
      colD <- match("rvr.interestRates.durationYears",names(rateProduct1))
      # column with months
      colM <- match("rvr.interestRates.durationMonths",names(rateProduct1))
      
      if(is.na(rateProduct1[row,colD])) {
        # Convert value to years
        rateProduct1[row,colD] <- rateProduct1[row,colM]/12
      }
      
      # Define row - match first row with the rate
      nodeRow <- match(nodeDur,rateProduct1[,colD])
      
      #Define col
      nodeCol <- match("rvr.interestRates.nominalInterestRate",names(rateProduct1))
    }
    
  }
  
  # Haal de rente uit dataframe
  rateProduct1 <- rateProduct1[nodeRow,nodeCol]
  
  rateProduct1 <- gsub("[^0-9,.]","",rateProduct1)
  rateProduct1 <- as.numeric(gsub("[,]",".",rateProduct1))/scaleRate
  
  # Transform naar effective rate per year en rond af (conform)
  # see https://www.centraalbeheer.nl/Style%20Library/cb_style_2014/script/js/cb.js
  rateProduct1 = exp(rateProduct1) - 1;
  rateProduct1 = round(rateProduct1*10000) / 10000;  
  
  return(rateProduct1)
}