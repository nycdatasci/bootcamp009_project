# Website we want to scrape is: https://www.verizonwireless.com/smartphones/samsung-galaxy-s7/
# The documentatio of selenium is here: http://selenium-python.readthedocs.io/index.html

# Please follow the instructions below to setup the environment of selenium
# Step #1
# Windows users: download the chromedriver from here: https://chromedriver.storage.googleapis.com/index.html?path=2.27/
# Mac users: Install homebrew: http://brew.sh/
#            Then run 'brew install chromedriver' on the terminal
#
# Step #2
# Windows users: open Anaconda prompt and run 'conda install -c conda-forge selenium=3.0.2'
# Mac users: open Terminal and run 'pip install selenium'

from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support import expected_conditions as EC
import time
import csv
import pandas as pd

# Windows users need to specify the path to chrome driver you just downloaded.
# driver = webdriver.Chrome('path\to\where\you\download\the\chromedriver')

###############################################
#############    Trying Selenium  #############
###############################################    
ticker='AAPL' 
df = pd.read_csv('Dow.csv', index_col=False, header=0)
df = pd.read_csv('SP500.csv', index_col=False, header=0)
df = pd.read_csv('Ticker.csv', index_col=False, header=0)

ticker_list = df['Ticker']
# print ticker_list   
ticker_list[:3]
ticker_list = ['AAPL']

csv_file = open('estimates_2.csv', 'ab')
writer = csv.writer(csv_file)
# writer.writerow(['Ticker', 'Estimates'])

for ticker in ticker_list:
    try:
        driver = webdriver.Chrome('C:\Users\chaiho\Documents\NYC Data Science Academy\Selenium\chromedriver')
        # driver = webdriver.PhantomJS('C:\Users\chaiho\Documents\NYC Data Science Academy\Selenium\chromedriver')

        driver.get("http://apps.cnbc.com/view.asp?country=US&uid=stocks/earnings&symbol="+ticker)

        # driver.find_elements_by_tag_name('polygon')[0].click() 
        # time.sleep(5)

        # Actions action = new Actions(driver);
        # WebElement mainMenu = driver.findElement(By.linkText("MainMenu"));
        # action.moveToElement(mainMenu).moveToElement(driver.findElement(By.xpath("submenuxpath"))).click().build().perform();




        # Trying many times
        # Trying to hover over bar graph
        # area_list = driver.find_elements_by_tag_name("map")
        area_list=[]
        # i=0
        # while len(area_list)==0:
            # print "iteration:"+str(i)
            # area_list = driver.find_elements_by_xpath('//*[@id="chartMap"]/map/area')
            # i= i+1
            # print "#"*50

        # button = driver.find_element_by_xpath('//*[@id="chartMap"]/map/area[1]')
        # button = driver.find_element_by_id("chartMap")
        # button.click()

        # element = wd.find_element_by_link_text(self.locator)
        print "Attempting to Hover...."
        
        element = driver.find_element_by_xpath('//*[@id="chartMap"]/map/area[1]')
        
        print element
        # element = driver.find_element_by_xpath('//*[@id="chartMap"]/map/area[1]')
        # print element
        
        # element_list = driver.find_element_by_tag_name('map')
        # print element_list
        # element = driver.find_element_by_id('chartMap')
        # print element
        # area_list = element.get_tag('area')
        # print area_list
        hov = ActionChains(driver).move_to_element(element)
        hov.perform()
        
        print "#"*50
        

        # Getting Legend Data
        result = ''
        i = 0
        while len(result)==0:
            if i==100:
                break
            print "Try:"+str(i)
            table = driver.find_element_by_xpath('//td[@id="legend"]')
            table_html = table.get_attribute('td')
            result = table.text
            print "Legend:\n"+result
            i = i+1

            print "#"*50


        writer.writerow([ticker,result])
        # driver.close()
    except:
        # driver.close()
        continue