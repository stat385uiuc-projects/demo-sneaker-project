
#' Scrape Sneaker Pricing
#' 
#' Retrieves sneaker pricing from stockx.com
#' 
#' @param name   The name of a sneaker.
#' @return A `list` with pricing and picture information.
#'  
#' @importFrom RSelenium rsDriver
#' @export
scrape_sneaker_info = function(name) {
  rD = rsDriver()
  remDr = rD$client
  search_website("https://stockx.com", name, remDr)
  direct(remDr)
  list = get_info(remDr)
  rD$server$stop()
  return(list)
}

#' Search the Sneaker Website for Sneaker Data
#' 
#' Triggers a search on the website for sneaker data
#' 
#' @param web   The website address
#' @param shoe  The name of the shoe
#' @param remDr An `RSelenium` remote driver
#' @export
#' @import httr
search_website = function(web, shoe, remDr) {
  remDr$navigate(web)
  wenElem = remDr$findElement(using = "id", "home-search")
  wenElem$sendKeysToElement(list(shoe))
  Sys.sleep(3)
}

#' Locate Sneaker Item
#' 
#' Clicks to visit the sneaker item page
#' 
#' @inheritParams search_website
#' @export
direct = function(remDr) {
  target = remDr$findElement(using = "class", "list-item-content")
  target$clickElement() 
  Sys.sleep(3)
}

#' Retrieve Sneaker Price Table
#' 
#' Obtains Sneaker Pricing Information
#' 
#' @inheritParams search_website
#' @return A `data.frame` with the sneaker pricing information
#' @importFrom XML htmlParse readHTMLTable
#' @export
get_table = function(remDr) {
  table = remDr$findElement(using = "class", "latest-sales-container")
  doc = htmlParse(table$getPageSource()[[1]])
  data.frame(readHTMLTable(doc))
}

#' Retrieve Sneaker Picture
#' 
#' Downloads the desired sneaker picture from Website.
#' 
#' @inheritParams search_website
#' @importFrom xml2 read_html
#' @importFrom rvest html_node html_attr
#' @importFrom utils download.file
#' @export
get_picture = function(remDr) {
  pic = remDr$findElement(using = "class", "product-media")
  html = pic$getPageSource()[[1]]
  container = read_html(html)
  selector = "div:nth-child(1) > img"
  img_url = container %>%
    html_node(selector) %>%
    html_attr("src")
  download.file(img_url, "shoe.png", mode = "wb")
  return("shoe.png")
}

#' Retrieves Sneaker Information
#' 
#' Downloads the desired sneaker prices and picture from Website.
#' 
#' @inheritParams search_website
#' @export
get_info = function(remDr) {
  table = get_table(remDr)
  image = get_picture(remDr)
  return(list(table = table, 
              image = image))
}