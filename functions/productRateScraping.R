# Product rate parser (generic) - product specific
# Objective: read information from website using JSON
# Variables:
# - typeUrl - denotes the type of website - important for scrap approach
#           - options are "HTTP", "HTTPGET" "JSONAB", "PDFDL", "HTTPKNAB", "HTTPLPB"
# - urlBank - website that needs to be scraped
# - nodeDur - duration of the product that is scraped
# - scaleRate - scale factor to be applied to the rate that is scraped
# - htmlNode - the syntax used in scraping
# - attrNode - optional value to indicate which element needs to selected from scraped text
# - outputPDF - in case of PDFDL file for PDF needs to be stored
productRateScraping <- function(typeScrape ="default", urlBank, nodeDur=0,
                                scaleRate =1, htmlNode, attrNode=0,
                                outputPDF = "") {

  # Select option for scraping methodology
  rateProduct <- 
    switch(typeScrape,
     # Load generic HTTP request
     HTTP = {
       # Load URL
       html <- urlBank %>% GET(user_agent('R')) %>% httr::content('text')
       
       # Read html text and scrape nodes
       if(attrNode >0) {
         # If specific nodes is selected
         rateProduct1 <- html %>%
            read_html() %>%
            html_nodes(htmlNode)
         # Get the rate from the preferred node
         rateProduct <- html_text(rateProduct1[attrNode])
         
       }else{
         # if no specific node is selected
         rateProduct1 <- html %>%
           read_html() %>%
           html_node(htmlNode) 
         # Get the rate from the preferred node
         rateProduct <- html_text(rateProduct1)
       }
       
       # Clean the rate
       rateProduct <- gsub("[^0-9,.]","",rateProduct)
       rateProduct <- as.numeric(gsub("[,]",".",rateProduct))/scaleRate
       
     }, #END HTTP
     
     # Load generic HTTP request (LPB specific)
     HTTPLPB = {
       # Load URL
       html <- urlBank #%>% GET(user_agent('R')) %>% httr:content('text')
       
       # Read html text and scrape nodes
       # Get the rate from the preferred attribute node
       rateProduct <- html %>%
         read_html() %>%
         html_node(htmlNode) %>%
         html_attr(attrNode)
       
       # Clean the rate
       rateProduct <- gsub("[^0-9,.]","",rateProduct)
       rateProduct <- as.numeric(gsub("[,]",".",rateProduct))/scaleRate
       
     }, #END HTTP
     
     # Load generic HTTP request (KNAB Bank specific)
     HTTPKNAB = {
       # Load URL
       html <- urlBank %>% GET(user_agent('R')) %>% httr::content('text')
       
       # Read html text and scrape nodes
       rateProduct1 <- html %>%
         read_html() %>%
         html_nodes(htmlNode) %>%
         html_text()
       # Read html text and scrape nodes 2 - 
       # For special product Node 2 is created to add to the rate product
       if (attrNode != '') {
         rateProduct2 <- html %>%
           read_html() %>%
           html_node(attrNode) %>%
           html_text()
       } else {
          rateProduct2 <- 0
       }
       
       # Clean the rates (product 1)
       rateProduct1 <- gsub("[^0-9,.]","",rateProduct1)
       rateProduct1 <- as.numeric(gsub("[,]",".",rateProduct1))/scaleRate
       # Clean the rates (product 2)
       rateProduct2 <- gsub("[^0-9,.]","",rateProduct2)
       rateProduct2 <- as.numeric(gsub("[,]",".",rateProduct2))/scaleRate
       
       rateProduct <- rateProduct1 + rateProduct2
       
     }, #END HTTPKNAB
     
     # Load PDF data (Delta LLoyd Bank specific)
     PDFDL = {
       # Root domain of url Bank
       url_bank_base <- paste(parse_url(urlBank)$scheme,'://', parse_url(urlBank)$hostname, sep='')
       
       # Identifier of link towardss PDF
       url_pdf_id    <- htmlNode
       
       # (1) Identify link of file (using rvest)
       html    <- urlBank #%>% GET(user_agent('R')) %>% content('text')
       pg      <- read_html(url_bank)
       links   <- html_attr(html_nodes(pg, "a"), "href")
       rowLink <- pmatch(url_pdf_id, links)
       download.weblink    <- paste(url_bank_base, links[rowLink],sep="")
       
       # (2) Store file in appropriate folder (if not available yet)
       download.filename   <- basename(download.weblink)
       download.store      <- paste(outputFolder_pdf,download.filename, sep="")
       # check if file already exists - otherwise download
       if(!file.exists(download.store)){
         download.file(download.weblink, download.store, method = 'auto', quiet = F, mode = "wb",
                       cacheOK = TRUE, extra = getOption("download.file.extra"))
         
         print(paste("Following file has been downloaded:", download.weblink))
       }
       
       # (3) Parse the PDF file
       pdf <- tm::readPDF(control = list(text = "-layout"))
       # writes the pdf contents into plain text
       dat <- pdf(elem = list(uri = download.store),language = "nl", id = "id1")
       # Remove content that may jeopordise data table
       doc <- dat$content
       doc <- gsub("Internet Spaarrekening",'', doc)
       doc <- gsub("0,- tot  25.000,-",'', doc)
       doc <- gsub("25.000,- of meer",'', doc)
       doc <- gsub("Deposito's Internet",'', doc)
       doc <- gsub("Spaarrekening",'', doc)
       doc <- gsub("- een jaar",'', doc)
       doc <- gsub("- drie jaar",'', doc)
       doc <- gsub("- vijf jaar",'', doc)
       # Replaces commas by points and spaces by commas
       doc <- gsub(',', '.', doc)
       doc <- gsub(' +', ',', doc)
       # Reads the plain text doc into a data frame (and remove column 1)
       dfPDF <- read.csv(textConnection(doc), header=FALSE)
       dfPDF <- dfPDF[-1]
       # Identify row which initiates the interest rates search in the table
       rowStart = which(dfPDF== "RenRteente", arr.ind=TRUE)[1]
       
       # (4) Extract rate
       rateProduct <- dfPDF[rowStart+attrNode,1]
       # Clean the rate
       rateProduct <- gsub("[^0-9,.]","",rateProduct)
       rateProduct <- as.numeric(gsub("[,]",".",rateProduct))/scaleRate
       
     }, #END PDFDL
     
       # Load JSON data (Achmea Bank specific)
     JSONAB = {
       
       # Create dataframe from JSON file
       rateProduct1 <- data.frame(fromJSON(urlBank))
       
       # Find row with most recent date
       if(nodeDur == 0){
         #RPR - Order rpr rates in line with date
         rateProduct1 <- rateProduct1[order(rateProduct1$rpr.interestRates.publishDate,decreasing=TRUE),]
         #Define row (always 1 after ordering)
         nodeRow <- 1
         #Define col
         nodeCol <- match("rpr.interestRates.interestRate",names(rateProduct1))
         
       }else{
         #RVR - Order rvr rates in line with date
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
       
       # Get the rate from the data frame
       rateProduct <- rateProduct1[nodeRow,nodeCol]
       # Clean the rate
       rateProduct <- gsub("[^0-9,.]","",rateProduct)
       rateProduct <- as.numeric(gsub("[,]",".",rateProduct))/scaleRate
       
       # Transform naar effective rate per year en rond af
       # see https://www.centraalbeheer.nl/Style%20Library/cb_style_2014/script/js/cb.js
       rateProduct = exp(rateProduct) - 1;
       rateProduct = round(rateProduct*10000) / 10000;  
       
     }, #END JSONAB
     
     # DEFAULT - signal error
     stop("No available scraping method selected")
     )
  
  # Return the rate as part of the function
  return(rateProduct)
}