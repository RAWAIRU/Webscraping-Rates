# Leasplan Bank - parser
# Objective: read information from LPB website
productRateLPB <- function(urlBank,htmlNode,attributeBank, scaleRate =1) {

  rateProduct1 <- urlBank %>%
    read_html() %>%
    html_node(htmlNode) %>%
    html_attr(attributeBank)
  rateProduct1 <- gsub("[^0-9,.]","",rateProduct1)
  rateProduct1 <- as.numeric(gsub("[,]",".",rateProduct1))/scaleRate
  
  return(rateProduct1)
}