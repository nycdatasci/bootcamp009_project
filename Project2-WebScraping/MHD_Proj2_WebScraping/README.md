# Mohammad Haseeb Durrani - Project #2 - Web Scraping 
Welcome to my Web Scraping Project Folder

## Folder Contents

- <b>all_data.csv</b> : All of my raw data in one single file.

#### Python Notebook Files:
- <b>Merging CSV Files + Missing Links.ipynb</b> : Since my scraping was done in very small increments of 200 observations per scraping session, I ended up with many CSV files. 
This file contains the code to merge all of these csv files into a my final dataset (all_data.csv).
- <b>Project #2 EDA and Visualization.ipynb</b> : This file contains the code for importing, cleaning, exploratory data analysis and visualization of my data.
#### Sub-folders:
- <b>fiverr_urls</b> : Main folder for my fiverr_urls scrapy project.
  * <b>fiverr_urls</b> : This folder is home to my original spider which I sent to crawl down the first two levels to retrieve all the urls for the 3rd level to scrape.
    * <b>fiverr_urls_5pages.csv</b> : The result of this spider is this file which contains ~ 16400 urls (each representing an observation which needs to be crawled and scraped). 
- <b>fiverr_data</b> : Main folder for my fiverr_data scrapy project. 
  * <b>Files</b> : This folder contains all of my intermediate files generated from each scraping session. 
                   These files were then merged using the code in the Merging CSV Files + Missing Links.ipynb file. 
                   The result of merging these files is all_data.csv. 
  * <b>fiverr_data</b> : This folder is where my superstar fiverr_data_spider is located. This spider crawled through the urls in the fiverr_urls_5pages.csv file, and scraped all of my data 200 observations at a time.
    * <b>missing_urls.csv</b> : Every so often my pages crawled count would not match my items scraped count. 
                               To catch the missing data I would generate this file containing all urls which were crawled but not scraped, and send my spider through them again.
