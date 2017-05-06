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
writer.writerow(['release', 'artist', 'label_cat', 'price', 'release_date', 'available'])

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
        release_info = {}
        rows = driver.find_elements_by_xpath('//body/table')
        releases = driver.find_elements_by_xpath('//span[@class = "txt_titel"]')
        artists = driver.find_elements_by_xpath('//a[@class = "txt_artist"]')
        # tracks = driver.find_elements_by_xpath('//span[@class = "soundtxt"]/a')
        label_cats = driver.find_elements_by_xpath('//span[@class = "labeltxt"]')
        # genres = driver.find_elements_by_xpath('//a[@class = "txt_styles"]')
        prices = driver.find_elements_by_xpath('//div[@class = "preisschild"]//*')
        release_dates = driver.find_elements_by_xpath('//span[@class = "txt_date"][1]')
        availables = driver.find_elements_by_xpath('//td/form/div/img[1]')

        for i, el in enumerate(rows):
            print releases[i].text
            release_info['release'] = releases[i].text
            release_info['artist'] = artists[i].text
            # release_info['track'] = tracks[i].text
            release_info['label_cat'] = label_cats[i].text
            # release_info['genre'] = genres[i].text
            if i % 2 == 0:
                release_info['price'] = prices[i].text + prices[i + 1].text
            release_info['release_date'] = release_dates[i].text
            release_info['available'] = availables[i].get_attribute("src")
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
