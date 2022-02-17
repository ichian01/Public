from time import time
import requests
import hashlib
import hmac
import base64
from urllib.parse import urlparse

#Use websockets to connect to coinbase to get order book
#periodically store order book into memory
#try writing orderbook into file
#try writing orderbook into sql server
#use config file

url="https://api-public.sandbox.exchange.coinbase.com/products/{product_id}/book?level={level}"
#https://api-public.sandbox.exchange.coinbase.com/products/BTC-USD/book?level=2
#live is api.exchange.coinbase.com/products/BTC-USD/book?level=1
product_id = "BTC-USD"
level = 2 #order book level, 1 is best, 2 has aggregated depth, 3 is UID per order
url = url.format(product_id=product_id,level=level)
print("URL: ",url)

method = "GET"

headers={
    "Content-Type":"application/json",
    "ACCEPT":"application/json"
}

response = requests.get(url,headers=headers)

responseJson = response.json()
print(responseJson)
print(responseJson["bids"])