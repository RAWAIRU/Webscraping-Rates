# OHRA - parser
# Objective: read information from website
productRateOHRA <- function(urlBank,htmlNode,nodePos=0, scaleRate =1) {

  html <- urlBank #%>% GET(user_agent('R')) %>% content('text')
  
  # if multiple nodes are selected
  rateProduct1 <- html %>%
      read_html() %>%
      html_nodes(htmlNode)
    
  rateProduct1 <- html_text(rateProduct1[nodePos])
  
  rateProduct1 <- gsub("[^0-9,.]","",rateProduct1)
  rateProduct1 <- as.numeric(gsub("[,]",".",rateProduct1))/scaleRate
  
  return(rateProduct1)
}