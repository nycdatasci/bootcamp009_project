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
writer.writerow(['release', 'artist', 'track', 'label_cat', 'genre', 'release_date', 'available', 'price'])

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
            release_info = {}
            # >>>>> Same problem here. Wrap them in a function. <<<<<
            if len(row.find_elements_by_xpath('.//span[@class = "txt_titel"]')) != 0:
                release = row.find_element_by_xpath('.//span[@class = "txt_titel"]').text
            else:
                release = ''
            print release
            if len(row.find_elements_by_xpath('.//a[@class = "txt_artist"]')) != 0:
                artist = row.find_element_by_xpath('.//a[@class = "txt_artist"]').text
            else:
                artist = ''
            if len(row.find_elements_by_xpath('.//span[@class = "soundtxt"]/a')) != 0:
                track = row.find_element_by_xpath('.//span[@class = "soundtxt"]/a').text
            else:
                track = ''
            label_cat = row.find_element_by_xpath('.//span[@class = "labeltxt"]').text
            if len(row.find_elements_by_xpath('.//a[@class = "txt_styles"]')) != 0:
                genre = row.find_element_by_xpath('.//a[@class = "txt_styles"]').text
            else:
                genre = ''
            if len(row.find_elements_by_xpath('.//div[@class = "preisschild"]//*')) != 0:
                price = row.find_element_by_xpath('.//div[@class = "preisschild"]//*').text
            else:
                price = ''
            if len(row.find_elements_by_xpath('.//span[@class = "txt_date"][1]')) != 0:
                release_date = row.find_element_by_xpath('.//span[@class = "txt_date"][1]').text
            else:
                release_date = ''
            if len(row.find_elements_by_xpath('.//td/form/div/img[1]')) != 0:
                available = row.find_element_by_xpath('.//td/form/div/img[1]').get_attribute("src")
            else:
                available = ''

            release_info['release'] = release.encode("utf-8")
            release_info['artist'] = artist.encode("utf-8")
            release_info['track'] = track.encode("utf-8")
            release_info['label_cat'] = label_cat.encode("utf-8")
            release_info['genre'] = genre.encode("utf-8")
            release_info['release_date'] = release_date.encode("utf-8")
            release_info['available'] = available.encode("utf-8")
            release_info['price'] = price.encode("utf-8")
            writer.writerow(release_info.values())

        # Locate the next button on the page
        nextbutton = driver.find_element_by_xpath('//a[@class="next"]')
        nextbutton.click()
        time.sleep(random.random())

    except Exception as e:
        print e
        driver.close()
        csv_file.close()
        break
