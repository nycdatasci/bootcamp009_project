from scrapy.exceptions import DropItem
import sqlite3
from os import path
from sqlalchemy import *
from datetime import datetime
engine = create_engine("sqlite:////Users/WesAull/GoogleDrive/NYCDSA/bootcamp009_project/Project2-WebScraping/WesAull/IBD.db")
metadata = MetaData()
search = Table('search', metadata,
    Column('search_term', String(25), primary_key=True),
    Column('search_activity', Float, nullable = False),
    Column('date', Date, nullable = False)
    )

correlation = Table('correlation', metadata,
    Column('search_term', String(25), ForeignKey("search.search_term"), primary_key = True),
    Column('corr_term', String(25), nullable = False),
    Column('corr', Float, nullable = False)
    )

metadata.create_all(engine)

class ValidateItemPipeline(object):

    def process_item(self, item, spider):
        if not all(item.values()):
            raise DropItem("Missing values!")
        else:
            return item

class WriteItemSQLitePipeline(object):
    def __init__(self):
        self.setupDBCon()

    def setupDBCon(self):
        self.conn = engine.connect()

    def process_item(self, item, spider):
        self.storeInDb(item)        
        return item

    def storeInDb(self,item):
        for i in item['hist_search_activity']:
            engine.execute(search.insert(), search_term=item['search_term'], date=datetime.strptime(i['date'],'%Y-%m-%d').date(), search_activity=i['value'])
        
        corr = zip(item['corr_terms'],item['corr_terms_cor'])
        for i,j in corr:
            engine.execute(correlation.insert(), search_term=item['search_term'], corr_term=i, corr=j)
        print '------------------------'
        print 'Data Stored in Database'
        print '------------------------'
        self.conn.commit()

    def closeDB(self):
        self.conn.close()

    def __del__(self):
        self.closeDB()
