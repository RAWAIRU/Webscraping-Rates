# Delta Lloyd Bank - parser
# Objective: read information from website
# Delta Lloyd Bank - parser
# Objective: read information from website
productRateDeltaLloydBank <- function(urlBank,htmlNode,nodePos=0, scaleRate =1, outputFolder_pdf ='') {
  
  # Rooot domain of url Bank
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
  
  #Extract rate
  rateProduct1 <- dfPDF[rowStart+nodePos,1]
  
  rateProduct1 <- gsub("[^0-9,.]","",rateProduct1)
  rateProduct1 <- as.numeric(gsub("[,]",".",rateProduct1))/scaleRate
  
  # (4) Return the rate
  return(rateProduct1)
}