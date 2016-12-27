# SNS Bank - parser
# Objective: read information from website
productRateSNS <- function(urlBank,htmlNode,nodePos=0, scaleRate =1) {

  html <- urlBank #%>% GET(user_agent('R')) %>% content('text')
  
  if(nodePos > 0){
    
    # if multiple nodes are selected
    rateProduct1 <- html %>%
      read_html() %>%
      html_nodes(htmlNode)
    
    rateProduct1 <- html_text(rateProduct1[nodePos])
    
  }else{
    # if one node is selected
    rateProduct1 <- html %>%
      read_html() %>%
      html_node(htmlNode) %>%
      html_text()
  }
  
  rateProduct1 <- gsub("[^0-9,.]","",rateProduct1)
  rateProduct1 <- as.numeric(gsub("[,]",".",rateProduct1))/scaleRate
  
  return(rateProduct1)
}