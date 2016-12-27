# KNAB Bank - parser
# Objective: read information from website
productRateKNAB <- function(urlBank,htmlNode, htmlNode2='', scaleRate =1) {

  html <- urlBank %>% GET(user_agent('R')) %>% httr::content('text')
  
  rateProduct1 <- html %>%
    read_html() %>%
    html_node(htmlNode) %>%
    html_text()
  rateProduct1 <- gsub("[^0-9,.]","",rateProduct1)
  rateProduct1 <- as.numeric(gsub("[,]",".",rateProduct1))/scaleRate
  
  # For special product Node 2 is created to add to the rate product
  if (htmlNode2 != '') {
    rateProduct2 <- html %>%
      read_html() %>%
      html_node(htmlNode2) %>%
      html_text()
    rateProduct2 <- gsub("[^0-9,.]","",rateProduct2)
    rateProduct2 <- as.numeric(gsub("[,]",".",rateProduct2))/scaleRate
    
    rateProduct1 <- rateProduct1 + rateProduct2
  }
  
  return(rateProduct1)
}