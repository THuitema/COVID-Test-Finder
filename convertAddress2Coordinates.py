import requests
import urllib.parse

# TODO: open address file, create list of them, run through list and do what's below, write coordinates to new file

'''
address = 'Oakton High School Fairfax Virginia'
url = 'https://nominatim.openstreetmap.org/search/' + urllib.parse.quote(address) +'?format=json'

response = requests.get(url).json()

if response: # checks if coordinates are found
    print(response[0]["lat"]) # yeah
    print(response[0]["lon"])
else:
    print('Nothing found')
    
'''
List = open("addresses.txt").readlines()
coordinates = open("coordinates.txt", 'w')
length = len(List)

for i in range(length):
    address = List[i]
    # gets coordinates
    url = 'https://nominatim.openstreetmap.org/search/' + urllib.parse.quote(address) + '?format=json'
    response = requests.get(url).json()
    if response: # checks if coordinates are found
        print(response)
        # writing coordinates to file
        print(response[0]["lat"] )
        coordinates.write(response[0]['lat'] + '\n')
        print(response[0]["lon"])
        coordinates.write(response[0]['lon'] + '\n')

    else:
        print('Nothing found')
'''
you could put an if statement checking if there is anything in the response variable
bc if it couldn't find the address in the map im guessing it would return nothing

'''