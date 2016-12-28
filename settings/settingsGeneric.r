# Load libraries
library(rvest)
library(tictoc)
library(jsonlite)
library(httr)
library(tm)

# Shortlist banks
numBanks <- 11
listBanks <- c("Achmea Bank - Centraal Beheer Achmea", "Aegon Bank", "Argenta", 
               "Delta Lloyd Bank", "KNAB", "LPB", 
                "NIBC", "NN Bank", "OHRA",
                "SNS", "YapiKredi")
listBanksSetFiles <- c("AB", "AegonBank", "Argenta", 
                      "DeltaLloydBank", "KNAB", "LPB", 
                      "NIBC", "NNBank", "OHRA",
                      "SNS", "YapiKredi")
listBanksPRFiles <- c("AB", "AegonBank", "Argenta", 
                       "DeltaLloydBank", "KNAB", "LPB", 
                       "NIBC", "NNBank", "OHRA",
                       "SNS", "YapiKredi")

# Data storage (load parsing functions and set variables)
source('functions/productRateScraping.R')
source('functions/storeRates.R')
source('functions/storeMonitor.R')
outputFolder      <- "output/"
outputFolder_pdf  <- "output/downloadedFiles/"
outputFolder_arc  <- "output/archiveRates/"
outputFolder_mon  <- "output/archiveMonitor/"
outputFile_mon    <- "Monitor"
fileTypeDB        <- "txt"
initiateMon       <- FALSE
# Date settings
D             <- format(Sys.Date(), "%Y-%m-%d") 
Dyest         <- format(Sys.Date()-1, "%Y-%m-%d") 
# Columns of rate files per bank
dbnumCols     <- 6
dbcolumnName1 <- "Date"
dbcolumnName2 <- "Bank"
dbcolumnName3 <- "Product"
dbcolumnName4 <- "Rate"
dbcolumnName5 <- "URL"
dbcolumnName6 <- "Duration"
columnNames   <- c(dbcolumnName1,dbcolumnName2,dbcolumnName3,dbcolumnName4,dbcolumnName5,dbcolumnName6)
# Columns of Monitoring file
dbnumCols     <- 5
dbMoncolumnName1 <- "Date"
dbMoncolumnName2 <- "Bank"
dbMoncolumnName3 <- "Rates stored?"
dbMoncolumnName4 <- "Timestamp"
dbMoncolumnName5 <- "Time elapsed"
dbMonCol        <- c(dbMoncolumnName1, dbMoncolumnName2, dbMoncolumnName3, dbMoncolumnName4, dbMoncolumnName5)
