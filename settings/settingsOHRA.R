#Settings
initiateDB    <- FALSE
bank          <- "OHRA"
bankDBname    <- "OHRA"
numberofProducts <- 5
scaleFactor   <- 100
#Product names
productName1      <- "OHRA Internet Spaarrekening"
productName2      <- "OHRA Deposito"
productName3      <- "OHRA Deposito"
productName4      <- "OHRA Deposito"
productName5      <- "OHRA Deposito"
#Product durations
productDur1      <- "0"
productDur2      <- "1"
productDur3      <- "3"
productDur4      <- "5"
productDur5      <- "10"

#Product links
typeScrape <- "HTTP"
url_bank  <- "http://www.ohra.nl/sparen/rente-rentegarantie.jsp"
url_bank2 <- ""
productUrl1   <- url_bank
productUrl2   <- url_bank
productUrl3   <- url_bank
productUrl4   <- url_bank
productUrl5   <- url_bank
#Product node
productNode1  <- 'table[class="datatable responsive"] td:nth-child(4n-2)'
productNode2  <- 'table[class="datatable responsive"] td:nth-child(4n-2)'
productNode3  <- 'table[class="datatable responsive"] td:nth-child(4n-2)'
productNode4  <- 'table[class="datatable responsive"] td:nth-child(4n-2)'
productNode5  <- 'table[class="datatable responsive"] td:nth-child(4n-2)'
productNode1b  <- 2
productNode2b  <- 4
productNode3b  <- 5
productNode4b  <- 6
productNode5b  <- 7








