from time import time
from datetime import datetime,timedelta
import requests
import hashlib
import hmac
import base64
from urllib.parse import urlparse
import pandas as pd #dataframes, easier to use

#Details
#If either one of the start or end fields are not provided then both fields will be ignored. If a custom time range is not declared then one ending now is selected.
#The granularity field must be one of the following values: {60, 300, 900, 3600, 21600, 86400}. Otherwise, your request will be rejected. These values correspond to 
# #timeslices representing one minute, five minutes, fifteen minutes, one hour, six hours, and one day, respectively.
#If data points are readily available, your response may contain as many as 300 candles and some of those candles may precede your declared start value. 
# #The maximum number of data points for a single request is 300 candles. If your selection of start/end time and granularity will result in more than 300 data points,
# your request will be rejected. If you wish to retrieve fine granularity data over a larger time range, you will need to make multiple requests with new start/end ranges.

#youtube https://www.youtube.com/watch?v=lf92JHVNP0g

#url = "https://api.exchange.coinbase.com/products/BTC-USD/candles?granularity=60&start=1645070640&end=1645069740"
granularity = 60 #60 seconds
timeEnd = datetime.now()
delta = timedelta(minutes=granularity/60)
#max request size is 300 candles
timeStart = timeEnd - (300*delta)
timeStart = timeStart.isoformat()
timeEnd = timeEnd.isoformat() #must be isoformat

url="https://api.exchange.coinbase.com/products/{product_id}/candles"
#https://api-public.sandbox.exchange.coinbase.com/products/BTC-USD/book?level=2
#live is api.exchange.coinbase.com/products/BTC-USD/book?level=1
product_id = "BTC-USD"

requestParam  = {
    "start":timeStart,
    "end":timeEnd,
    "granularity":granularity
}

url = url.format(product_id=product_id)
print("URL: ",url)

headers={
    "Content-Type":"application/json",
    "ACCEPT":"application/json"
}

response = requests.get(url,headers=headers, params=requestParam)

responseJson = response.json()
#print(responseJson)
df = pd.DataFrame(response.json(),columns=["timestamp","low","high","open","close","volume"])

#convert timestamp to a date/time
df["date"] = pd.to_datetime(df["timestamp"], unit='s')
df = df[["date","open","high","low","close","volume"]]
df.set_index("date",inplace=True)

print(df)

#[timestamp, price_low, price_high, price_open, price_close, volume]
#[1645070640, 43379.73, 43405.69, 43400, 43397.5, 15.82406203]