import time
import random
import csv
from selenium import webdriver
# from selenium.webdriver.common.keys import Keys
# from selenium.webdriver.common.by import By
# from selenium.webdriver.support.ui import WebDriverWait
# from selenium.webdriver.support import expected_conditions as EC


# choose a web driver
driver = webdriver.Chrome()

# load into the sorted chart table
driver.get("https://www.decks.de/decks-sess/workfloor/lists/list.php?wo=ten&nowstyle=zz")
# create a csv file with data headers
csv_file = open('decks.csv', 'wb')
writer = csv.writer(csv_file)
writer.writerow(['artist', 'release', 'track', 'label_cat', 'genre', 'price', 'release_date', 'available'])


page_num = 1
while True:
    try:
        print "Scraping Page Number " + str(page_num)
        page_num = page_num + 1

        releases = driver.find_element_by_xpath('//span[@class = "txt_titel"]').text
        for release in releases:
            release_info = {}
            artist = driver.find_element_by_xpath('//a[@class = "txt_artist"]').text
            track = driver.find_element_by_xpath('//span[@class = "soundtxt"]/a').text
            label_cat = driver.find_element_by_xpath('//span[@class = "labeltxt"]').text
            genre = driver.find_element_by_xpath('//a[@class = "txt_styles"]').text
            price = driver.find_element_by_xpath('//div[@class = "preisschild"]//').text
            release_date = driver.find_element_by_xpath('//span[@class = "txt_date"][1]').text
            available = driver.find_element_by_xpath('//td/div/img[1]/@src')

            release_info['artist'] = artist
            release_info['release'] = release
            release_info['track'] = track
            release_info['label_cat'] = label_cat
            release_info['genre'] = genre
            release_info['price'] = price
            release_info['release_date'] = release_date
            release_info['available'] = available
            writer.writerow(release_info.values())

        # Locate the next button on the page
        nextbutton = driver.find_element_by_xpath('//a[@class="next"]')
        nextbutton.click()
        time.sleep(random.random()*12)
    except Exception as e:
        print e
        csv_file.close()
        driver.close()
        break
