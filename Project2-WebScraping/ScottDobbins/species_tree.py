# @author Scott Dobbins
# @version 0.0
# @date 2017-05-03 16:30

### import packages ###

# selenium
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# other python packages
import re
import csv

# my helper package
import wait_helper


#from time import sleep

### constants ###
debug_mode_on = True
# wait_mean = 2
# wait_sd = 1


### set up web driver ###
driver = webdriver.Chrome()
URL = "http://www.catalogueoflife.org/annual-checklist/2017/browse/tree/"
driver.get(URL)


### set up csv files for writing ###

# species information file (scraped from CatalogueOfLife directly)
species_csv = open('species.csv', 'wb')
species_writer = csv.writer(species_csv)

species_writer.writerow(['ID',
						  'Kingdom', 'kingdom_found', 'kingdom_est',
						  'Phylum', 'phylum_found',
						  'Class', 'class_found',
						  'Order', 'order_found',
						  'Family', 'family_found',
						  'Genus', 'genus_found',
						  'Species', 'species_URL'])

#expando_button_src = "/annual-checklist/2017/scripts/library/dojo/dojo/resources/blank.gif"

### start crawl through one category ###

kingdom_count = 0
phylum_count = 0
class_count = 0
order_count = 0
family_count = 0
genus_count = 0
species_count = 0

index_max = 1

current_level = 0
current_names = []
current_numbers = [0] * 8
current_counts = [0] * 8

level_dict = {0: 'root', 1: 'kingdom', 2: 'phylum', 3: 'class', 4: 'order', 5: 'family', 6: 'genus', 7: 'species'}

# main_panel = driver.find_element_by_xpath('/body')
# print(main_panel)

# print("found main_panel")

#sleep(10)

# wait_buttons = WebDriverWait(driver, 10)
# buttons_wait = wait_buttons.until(EC.presence_of_all_elements_located((By.XPATH, '//img[@src="/annual-checklist/2017/scripts/library/dojo/dojo/resources/blank.gif"]')))

ridiculousness = driver.find_elements_by_xpath('/body/div')
print(len(ridiculousness))

stuff = driver.find_elements_by_xpath('/*')
print(len(stuff))
print(stuff[0].get_attribute('class'))

stuff2 = stuff[0].find_elements_by_xpath('/*')
print(len(stuff2))
print(stuff2[0].get_attribute('class'))

all_first_divs = stuff[0].find_elements_by_xpath('/div')
all_second_divs = stuff[0].find_elements_by_xpath('//div')
all_things = stuff[0].find_elements_by_xpath('//*')

print(len(all_first_divs))
print(len(all_second_divs))
print(len(all_things))

for item in all_second_divs:
	print(item.get_attribute('id'))

#
# checkbox_panel = main_panel.find_element_by_xpath('div[@id="tree-checkboxes"]')
# statistics_checkbox = checkbox_panel.find_element_by_xpath('/input[@id="showStatisticsCheckbox"]')
# statistics_checkbox.click()
# print("clicked stats checkbox")
#
#
# next_items = main_panel.find_elements_by_xpath('/span')
# print(len(next_items))
# for item in next_items:
# 	print(item.get_attribute('class'))
# print("finished printing attributes")

# tree_container = main_panel.find_element_by_xpath('/div[@class="dijitTreeContainer"]')
# print("found tree_container")
# tree_root = tree_container.find_element_by_xpath('/div[@class="dijitTreeNode dijitTreeIsRoot"]')
# print("found tree_root")
# kingdom_container = tree_root.find_element_by_xpath('/div[@class="dijitTreeContainer"]')
# print("found kingdom_container")

wait_buttons = WebDriverWait(driver, 10)
buttons_wait = wait_buttons.until(EC.presence_of_all_elements_located((By.XPATH, '//img[@src="/annual-checklist/2017/scripts/library/dojo/dojo/resources/blank.gif"]')))

kingdoms = kingdom_container.find_elements_by_xpath('/div[@class="dijitTreeNode dijitTreeIsRoot"]')

kingdom_info = kingdoms[1].find_element_by_xpath('/div[@class="dijitTreeRow"]/span[@class="dijitTreeContent"]/span[@class="dijitTreeLabel"]/span[@class="treeStatistics"]').text
kingdom_info = re.search('[0-9]+', kingdom_info)
kingdom_found = kingdom_info.group(1)
kingdom_count = kingdom_info.group(2)
kingdom_percent = kingdom_info.group(3)
print(kingdom_info)

next_button = kingdoms[1].find_element_by_xpath('/div[@class="dijitTreeRow"]/img[@class="dijitTreeExpando dijitTreeExpandoClosed"]')
next_button.click()

species_csv.close()
# driver.close()
