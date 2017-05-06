from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import csv

driver = webdriver.Chrome()

csv_file = open('queerty_recomm.csv', 'wb')
writer = csv.writer(csv_file)
writer.writerow(['category', 'author', 'title', 'num_comments','tags','article_url','time', 'recs_urls'])

#my_list = ['life','entertainment','politics','goods']
my_list = ['goods']
def verify(content):
	if isinstance(content, list):
		if len(content) > 0:
			content = content[0]
			return content.encode('ascii','ignore')
		else:
			return ""
	else:
		return content.encode('ascii','ignore')

for category in my_list:
	category_url = 'https://www.queerty.com/' + category
	driver.get(category_url)
	max_number = int(driver.find_elements_by_xpath('//a[@class ="page-numbers"]')[-1].text)
	print max_number
	
#	urls  =  ['https://www.queerty.com/' + category + '/page/'+ str(i+1) for i in range(3,4)]	
	urls = ['https://www.queerty.com/' + category + '/page/'+ str(i+1) for i in range(1,max_number)]
	for url in urls: # Looping through the pages
		print "-" * 40 
		print url
 		driver.get(url)
 		links_list = driver.find_elements_by_xpath('//article[@class="card card-large  archive-card "]/a')
 		links = [link.get_attribute('href') for link in links_list] # list of the urls
 		for link in links: # Loop through the urls
#  			article_url =  link.get_attribute("href")
 			driver.get(link)
 			article_dict = {}
 			try: 
 				title = driver.find_element_by_xpath('//h1[@class="entry-title"]').text
 			except:
 				continue
 			try:  
 				author = driver.find_element_by_xpath('//span[@class="byline"]/a').text
 			except: 
 				author = ""
 			try:
 				time_ = driver.find_element_by_xpath('//time[@class="posted-on"]').get_attribute("datetime")
 			except:
 				time_ = ""
 			try: 
 				num_comments =  driver.find_element_by_xpath('//span[@class="comments-number"]').text
 			except:
 				num_comments = ""
 				
 			print '*' * 40 
 			print title
 			list_of_rec = driver.find_elements_by_xpath('//div[@class="trc_rbox_div trc_rbox_border_elm"]//a')
 			recs = '|'.join([rec.get_attribute("href") for rec in list_of_rec])
 			tag_list = driver.find_elements_by_xpath('//span[@class="tags-links"]//a')
 			tags = '|'.join([verify(tag.text) for tag in tag_list])
 			title = verify(title)
 			article_dict['title'] = title
 			article_dict['category'] = category
 			article_dict['article_url'] = link
 			article_dict['time'] = time_
 			article_dict['num_comments'] = num_comments
 			article_dict['recs'] =  recs
 			article_dict['tags'] = tags
 			article_dict['author'] = author
 			
 			writer.writerow(article_dict.values())
 			
 		time.sleep(2)
 			
driver.close()
 			
# 		
