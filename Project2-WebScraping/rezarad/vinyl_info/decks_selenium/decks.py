import time
import random
import csv
from selenium import webdriver
# from selenium.webdriver.common.keys import Keys
# from selenium.webdriver.common.by import By
# from selenium.webdriver.support.ui import WebDriverWait
# from selenium.webdriver.support import expected_conditions as EC

# create a csv file with data headers
csv_file = open('decks.csv', 'wb')
writer = csv.writer(csv_file)
writer.writerow(['release', 'artist', 'track', 'label_cat', 'genre', 'price', 'release_date', 'available'])

# choose a web driver
driver = webdriver.Chrome()
driver.get("https://www.decks.de/decks-sess/workfloor/lists/list.php?wo=ten&nowstyle=zz")
time.sleep(random.random() * 4)

driver.switch_to.frame(driver.find_element_by_name("workflooframe"))
# wait = WebDriverWait(driver,  10)


page_num = 1
while True:
    try:
        print "Scraping Page Number " + str(page_num)
        page_num = page_num + 1

        rows = driver.find_elements_by_xpath('//body/table')
        for row in rows:
            print row

            release_info = {}

            releases = row.find_element_by_xpath('.//span[@class = "txt_titel"]').text
            artists = row.find_element_by_xpath('.//a[@class = "txt_artist"]').text
            tracks = row.find_element_by_xpath('.//span[@class = "soundtxt"]/a').text
            label_cats = row.find_element_by_xpath('.//span[@class = "labeltxt"]').text
            genres = row.find_element_by_xpath('.//a[@class = "txt_styles"]').text
            prices = row.find_element_by_xpath('.//div[@class = "preisschild"]//*').text
            release_dates = row.find_element_by_xpath('.//span[@class = "txt_date"][1]').text
            availables = row.find_element_by_xpath('.//td/form/div/img[1]').get_attribute("src")

            release_info['release'] = releases
            release_info['artist'] = artists
            release_info['track'] = tracks
            release_info['label_cat'] = label_cats
            release_info['genre'] = genres
            release_info['release_date'] = release_dates
            release_info['available'] = availables
            writer.writerow(release_info.values())

        # Locate the next button on the page
        nextbutton = driver.find_element_by_xpath('//a[@class="next"]')
        nextbutton.click()
        time.sleep(random.random() * 6)

    except Exception as e:
        print e
        driver.close()
        csv_file.close()
        break
