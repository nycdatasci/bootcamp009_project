import numpy as np
import pandas as pd
from scrapinghub import HubstorageClient


def get_scraped_data(dir,project_id, scrapinghub_key, spider):
    # establish a connection with scrapyhub and get a items generator
    hc = HubstorageClient(auth=scrapinghub_key)
    print project_id
    empty, totalItems, keptItems = 0, 0, 0
    for job in hc.get_project(project_id).jobq.list(spider=spider):
        for item in hc.get_job(job['key']).items.list():
	    print item		
            totalItems += 1
            item = pd.Series(item)
            if item['title'] != '' and item['article'] != '' and \
                            item['title'] != ' ' and item['article'] != ' ':
                item['spider'] = spider
                item = item.drop('category')
                item = item.replace(["page1", "page2", "page3", "scrape_time", "", "basic"],
                                    [np.nan, np.nan, np.nan, np.nan, np.nan, "reutersbasic"])
                item = item.replace({'<.*?>': '', '\[.*?\]': '', '\(.*?\)': ''}, regex=True)

                #add article hash code as the id of the article
                item['id'] = hash(item['article'])

                #write item(as records) to a json file
                file = dir + str(item['id']) + '.json'
#		f = open(file,'w')
                item.to_json(file)

                keptItems += 1

            else:
                empty += 1

    print '#' * 50
    print 'Fetched: ', totalItems, ' from spider: ', item['spider']
    print keptItems, ' were written to the folder'
    print '-' * 50, '\n\n'

project_id = '*****' #name of the project in scrapinghub
scrapinghub_key = '*********' #scrapinghub api key
spiders = ['cbs', 'cnn', 'abc', 'fox', 'nypost'] #list of spider names
dir = r'C:/Users/Pradeep Krishnan/Desktop/NewsFlows/data/'

if __name__ == '__main__':
    for spider in spiders:
        get_scraped_data(dir, project_id, scrapinghub_key, spider)