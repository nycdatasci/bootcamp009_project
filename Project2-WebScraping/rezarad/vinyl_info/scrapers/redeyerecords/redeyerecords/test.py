with open("nyc_data_science_academy/bootcamp009_project/Project2-WebScraping/rezarad/redeyerecords/redeyerecords/middlewares.py") as fp:
    for i, line in enumerate(fp):
        if "\xe2" in line:
            print i, repr(line)


name = 'redeyerecords'
start_urls = ['https://www.redeyerecords.co.uk/']
table_urls = []
genres  = ['house', 'techno-electro']
sections = ['new-releases','sale-section','super-sale-section','back-catalogue']
page_nums = range(1,62)

for genre in genres:
    for section in sections:
        table_urls  = table_urls + ["https://www.redeyerecords.co.uk/{0}/{1}/page_{2}".format(genre,section,page) for page in page_nums]

for url in table_urls:
    print url


page_nums = range(1,292)
urls  = ["https://www.deejay.de/content.php/?param=/m_All/sm_Labels/page_" + str( page) for page in page_nums]
map(lambda s: s.decode('utf8').encode('ascii', errors='ignore'),urls)
map(lambda s: s.replace('\\', ""),urls)
print urls

import re

print re.search("add","addToBasket") != None

# print re .split(" - ","Nebraska - F&r 003")[0]
