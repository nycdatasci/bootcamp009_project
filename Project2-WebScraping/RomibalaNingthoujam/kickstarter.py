from selenium import webdriver
import time
#import csv
import unicodecsv
# >>>>>>>> I nevered used unicodecsv before but you can always manually convert unicode to ascii. <<<<<<<<<
browser = webdriver.Chrome()
#browser = webdriver.Firefox()

csv_file = open('kickstarter.csv', 'wb')
writer = unicodecsv.writer(csv_file)
writer.writerow(['category', 'url', 'subcategory', 'project_name', 'creator', 'location', 'goal', 'pledged', 'backers', 'funding_start_date', 'funding_end_date'])
colnames = ['category', 'url', 'subcategory', 'project_name', 'creator', 'location', 'goal', 'pledged', 'backers', 'funding_start_date', 'funding_end_date']
category_dict = {'Dance': '6', 'Design' : '7', 'Fashion' : '9', 'Film & Video' : '11', 'Food' : '10', 'Games' : '12',
 'Journalism' : '13', 'Music' : '14', 'Photography' : '15', 'Publishing' : '18', 'Theater' : '17'}
for category, value in category_dict.items():
	url = 'https://www.kickstarter.com/discover/advanced?state=successful&woe_id=23424977&sort=magic&category_id='+value
	browser.get(url)
	time.sleep(2)

	# number = browser.find_element_by_xpath('//b[@class="count green"]').text #encode('ascii', 'ignore')
	# number = int(''.join(number.split()[0].split(',')))
	# number = (number/20)
	# number = min(number, 200)
	# for page in range(1,  number + 1):

	# To scrape 100 top projects in each category; each page lists 20 projects (20 * 5 pages = 100)
	for page in range(1, 6):
		new_url = url + '&page=' + str(page)
		browser.get(new_url)
		projects = browser.find_elements_by_xpath('//div[@class="row"]/li//div[@class="project-profile-title text-truncate-xs"]/a')
		projects = [i.get_attribute('href') for i in projects]
		for project in projects:
			browser.get(project)
			# Scrape all the attributes you want
			item = {}

			project_name = browser.find_element_by_xpath('.//div[@class="NS_project_profile__title"]').text #encode('ascii', 'ignore')
			creator = browser.find_element_by_xpath('.//div[@class="creator-name"]/div[@class="mobile-hide"]').text #encode('ascii', 'ignore')
			subcategory = browser.find_element_by_xpath('.//div[@class="NS_projects__category_location ratio-16-9"]/a[@class="grey-dark mr3 nowrap type-12"][2]').text #encode('ascii', 'ignore')
			location = browser.find_element_by_xpath('.//div[@class="NS_projects__category_location ratio-16-9"]/a[@class="grey-dark mr3 nowrap type-12"][1]').text #encode('ascii', 'ignore')
			goal = browser.find_element_by_xpath('.//div[@class="type-12 medium navy-500"]/span[@class="money"]').text
			pledged = browser.find_element_by_xpath('.//h3[@class="mb0"]/span[@class="money"]').text
			backers = browser.find_element_by_xpath('.//div[@class="mb0"]/h3[@class="mb0"]').text
			funding_start_date = browser.find_element_by_xpath('.//div[@class="NS_campaigns__funding_period"]//time[@class="js-adjust-time"][1]').text
			funding_end_date = browser.find_element_by_xpath('.//div[@class="NS_campaigns__funding_period"]//time[@class="js-adjust-time"][2]').text


			item['project_name'] = project_name
			item['creator'] = creator
			item['category'] = category
			item['subcategory'] = subcategory
			item['url'] = browser.current_url
			item['location'] = location
			item['goal'] = goal
			item['pledged'] = pledged
			item['backers'] = backers
			item['funding_start_date'] = funding_start_date
			item['funding_end_date'] = funding_end_date

            # >>>>>>>> What is the purpose of the following line of code? <<<<<<<
            # >>>>>>>> Would item.values() do the same thing? <<<<<<<<<<<
			result = map(lambda x: item[x], colnames)
			writer.writerow(result)

			#writer.writerow(item.values())
			#print item.values()
			time.sleep(2)

browser.close()
