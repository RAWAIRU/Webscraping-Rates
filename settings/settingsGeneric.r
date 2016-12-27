# Load parsing library
library(rvest)
library(tictoc)
library(jsonlite)
library(httr)
library(tm)

# Data storage (load parsing functions and set settings)
source('functions/storeRates.R')
source('functions/storeMonitor.R')
outputFolder      <- "output/"
outputFolder_pdf  <- "output/downloadedFiles/"
outputFolder_arc  <- "output/archiveRates/"
outputFolder_mon  <- "output/archiveMonitor/"
outputFile_mon    <- "Monitor"
fileTypeDB        <- "txt"
initiateMon       <- TRUE
# Generic settings
D             <- format(Sys.Date(), "%Y-%m-%d") 
Dyest         <- format(Sys.Date()-1, "%Y-%m-%d") 
# Columns
dbnumCols     <- 6
dbcolumnName1 <- "Date"
dbcolumnName2 <- "Bank"
dbcolumnName3 <- "Product"
dbcolumnName4 <- "Rate"
dbcolumnName5 <- "URL"
dbcolumnName6 <- "Duration"

