price = c()
size = c()
date = c()
locamount = c()
currency = c()

i = 1

while (i != 0) {
  url = paste0(paste0("https://stockx.com/api/products/91191b39-ab68-4241-98bf-dc9d0bb087c4/activity?state=480&currency=USD&limit=10&page=", i), "&sort=createdAt&order=DESC")
  list = content(GET(url))$ProductActivity
  if (length(list) == 0) break
  else {
    for (j in 1:length(list)) {
      price = c(price, list[[j]]$amount)
      size = c(size, list[[j]]$shoeSize)
      date = c(date, list[[j]]$createdAt)
      locamount = c(locamount, list[[j]]$localAmount)
      currency = c(currency, list[[j]]$localCurrency)  
    }
  }
  i = i + 1
}

temp = data.frame(Date = date,
                  Size = size,
                  Price = price,
                  Local_Amount = locamount,
                  Currency = currency)

write.csv(temp, "Nike Air Jordan 4 Royalty.csv")