from time import time
import requests
import hashlib
import hmac
import base64
from urllib.parse import urlparse
from requests.api import get

#A bare minimum example on connecting to coinbase's sandbox and making an authenticated API call
#authenticated calls requires hashing the message as a signature
#Main sandbox website https://public.sandbox.pro.coinbase.com/


url="https://api-public.sandbox.exchange.coinbase.com/accounts"

#normally would store the secret and key in a config file
api_key = "f2e982dcb3161718a77c69ac13c3b5db"
api_secret = "KAy6VJB2ANdSZ8x41dplRgQQBDXJkjv1wvtGSuKIPXVohCOSbe8p0kvT3+AS5phazgu6WdxVOyIAoz6I3MddZQ=="
print("URL: ",url)


p=input("Enter password:")

#https://www.programiz.com/python-programming/time
#This time is correct
#Checked against this website https://www.epochconverter.com/
timeSinceEpoch= str(int(time())) #seconds since Unix Epoch
method = "GET"
oURL = urlparse(url)
requestPath = oURL.path
message = timeSinceEpoch + method + requestPath + ''

print("Message: ",message)
hmac_key = base64.b64decode(api_secret)
signature = hmac.new(key=hmac_key,msg=message.encode('utf-8'),digestmod=hashlib.sha256)
#signature can not just be a hex digest, it has to be base 64 encoded!!!
signature_b64 = base64.b64encode(signature.digest()).decode('utf-8')

print("Signature: ", signature_b64)

headers={
    "Content-Type":"application/json",
    #"User-Agent":"CoinbasePython",
    "ACCEPT":"application/json",
    "CB-ACCESS-SIGN":signature_b64,
    "CB-ACCESS-TIMESTAMP":timeSinceEpoch,
    "CB-ACCESS-KEY":api_key,
    "CB-ACCESS-PASSPHRASE":p
    }

print(headers)
response = requests.get(url,headers=headers)
print(response)
print(response.text)