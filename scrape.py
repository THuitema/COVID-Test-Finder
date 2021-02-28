import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
PATH = '/Users/thuitema/PycharmProjects/VaccineLocator/chromedriver'
url = 'https://www.vdh.virginia.gov/coronavirus/covid-19-testing/covid-19-testing-sites/'

driver = webdriver.Chrome(PATH)
driver.get(url)

search = driver.find_element_by_id('wpsl-search-input')
search.send_keys('22033')
search.send_keys(Keys.RETURN)
time.sleep(20)
# try:
#     main = WebDriverWait(driver, 10).until(
#         EC.presence_of_element_located((By.CLASS_NAME, "wpsl-store-location"))
#     )
# except:
#     driver.quit()

main = driver.find_element_by_id('wpsl-stores')

output = open('sloppyinfo2.txt', 'w')
output.write(str(main.text))
print(main.text)
