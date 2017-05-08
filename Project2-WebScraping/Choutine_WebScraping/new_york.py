from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import csv

options = webdriver.ChromeOptions()
# to maximize the window 
options.add_argument("--start-maximized")
driver = webdriver.Chrome("C:/Users/qiube/Documents/Data Science Academy/WebScraping/project/coursehorse_sele/chromedriver.exe",
                          chrome_options=options)

# scrape starting from page 1
page_num=1
class_links_list=[]

# set the ending page No. 200
while page_num<=200:
    
    try:
        main_url="https://coursehorse.com/nyc/classes?page="
        driver.get(main_url+str(page_num))
        print("page num is"+str(page_num))
        # increment page number
        page_num+=1
        
        # close pop up window 
        try:
            time.sleep(2)
            # click on exit of pop up window 
            driver.find_element_by_xpath('//*[@id="welcome-overlay-window"]/a').click()
            time.sleep(2)
            
        except Exception as e:
            print("no pop up")
            pass;

        # append each class link to class_list
        # each page has 16 class links
        for class_list in range(1,16):
            
            classPath = ('//*[@id="filter-results"]/div/div[{0}]/div[2]/div/div[1]/div[1]/h4[@class="title"]/a').format(class_list)
            class_links=driver.find_element_by_xpath(classPath).get_attribute("href")
            class_links_list.append(class_links)
            print(class_list)
            print(str(len(class_links_list)))
                                   
            
    except Exception as e:
        print (e)
        driver.close()
        break

# save class link list as txt. file    
with open("class_link_new_york.txt", "w") as output:
    output.write(str(class_links_list))              
          
# open up a csv file to write data on
csv_file = open('new_york.csv', 'w', encoding="utf-8",newline='')
writer = csv.writer(csv_file)

# define each column 
writer.writerow(['class_name', 'school', 'price', 'location', 'city','category','sub_cat1','sub_cat2','datetime',\
'class_level','class_size','description','num_saved','image','rating','rating_content'])

# go through each class link and scrape its page 
for class_link in class_links_list: 
    try:
        driver.get(class_link)
        # close pop up window if it shows up
        try:
            time.sleep(2)
            driver.find_element_by_xpath('//*[@id="welcome-overlay-window"]/a').click()
            time.sleep(2)
            
        except Exception as e:
            print("no pop up")
            pass;
        
        # create a data dictionary to store all columns 
        data_dict={}
        print("scapying class start")    
        try:
            class_name=driver.find_element_by_xpath('//div[@class="course-body eleven wide column"]/div/h1').text
            print(class_name)
            
        except Exception as e:
            print("no class name")
            class_name="NA"               
            pass;
        
        try:
            school=driver.find_element_by_xpath('//*[@id="course-page-container"]/div/div/div[2]/div[2]/div[1]/p/a').text
            print(school)
        except Exception as e:
            print("no school name")
            school="NA"               
            pass;                                                           
        
        try:
            price=driver.find_element_by_class_name('original-price').text
        except Exception as e:
            print("no price")
            price="NA"               
            pass;   
            
        try:                          
            location=driver.find_element_by_xpath('//span[@class="js-class-location-text"]').text
        except Exception as e:
            print("no location")
            location="NA"               
            pass;   
            
        # assign the city column 
        city="New York"
                    
        try:    
            category=driver.find_element_by_xpath('//*[@id="course-page-container"]/div/div/div[1]/div/span[2]/a').text    
        except Exception as e:
            print("no category")
            category="NA"               
            pass;   
        
        
        try:    
            sub_cat1=driver.find_element_by_xpath('//*[@id="course-page-container"]/div/div/div[1]/div/span[3]/a').text    
        except Exception as e:
            print("no sub_cat1")
            sub_cat1="NA"               
            pass;   
        
        try:    
            sub_cat2=driver.find_element_by_xpath('//*[@id="course-page-container"]/div/div/div[1]/div/span[4]/a').text    
        except Exception as e:
            print("no sub_cat2")
            sub_cat2="NA"               
            pass;   
               
        try:
            date_path=driver.find_element_by_xpath('//div[@class="js-class-date class-date ui twelve wide column"]').text
            datetime=date_path.split("\n",2)[0]
        except Exception as e:
            print("no datetime")
            datetime="NA"               
            pass;  
            
        try:                  
            class_level=driver.find_element_by_xpath('//div[@class="description"]/span').text
        except Exception as e:
            print("no class_level")
            class_level="NA"               
            pass;                                              
                                                    
        try:                                            
            class_size=driver.find_element_by_xpath('//*[@id="course-info-tabs"]/div/div[2]/div[1]/div[2]/div/div/span').text
        except Exception as e:
            print("no class_size")
            class_size="NA"               
            pass;
            
        try:    
            decription=driver.find_element_by_xpath('//*[@id="course-info-tabs"]/div/div[2]/div[2]').text
        except Exception as e:
            print("no decription")
            decription="NA"               
            pass;

                                   
        try:
            num_saved=driver.find_element_by_xpath('//div[@class="course-booking ui five wide center aligned column"]/p').text    
        except Exception as e:
            print("no num saved")
            num_saved=0               
            pass;
        
        try:                                       
            image=driver.find_element_by_xpath('//*[@id="course-page-container"]/div/div/div[2]/div[1]/div/div[2]/img[@src]').get_attribute('src')
        except Exception as e:
            print("no image")
            image=0               
            pass;
                       
        try: 
            rating_path = driver.find_elements_by_xpath('//div[@id="reviews-block"]//span[@class="ui star rating disabled"]')
            stars = rating_path[0].find_elements_by_xpath('.//i[@class="icon active"]')
            rating=len(stars)
        except Exception as e:
            print("no rating")
            rating=0               
            pass;
        
        # track all the review to a review list                 
        reviews=driver.find_elements_by_css_selector("div.review-row.ui.row")
        
        review_list=[]
        for review in reviews:
            
            content = review.find_element_by_xpath('.//div[2]/p').text
            try:
                # remove unrelated first line of the content 
                content = content.split("\n",2)[1]
            except Exception as e:
                print("no rating split")               
                pass;
                
            review_list.append(content)
                                  

        data_dict['class_name'] = class_name
        data_dict['school'] = school
        data_dict['price'] = price
        data_dict['location'] = location
        data_dict['city'] = city
        data_dict['category'] = category
        data_dict['sub_cat1'] = sub_cat1
        data_dict['sub_cat2'] = sub_cat2
        data_dict['datetime'] = datetime
        data_dict['class_level'] = class_level
        data_dict['class_size'] = class_size
        data_dict['decription'] = decription
        data_dict['num_saved'] = num_saved
        data_dict['image'] = image
        data_dict['rating'] = rating
        data_dict["rating_content"]=review_list

        writer.writerow(data_dict.values())
        print("end of a class")
        driver.back()
        time.sleep(4)
        
        print("row number is"+str(len(data_dict)))
    
    except Exception as e:
        
        print (e)
        csv_file.close()
        driver.close()
        break


