from scrapy.exceptions import DropItem
from scrapy.exporters import CsvItemExporter
import sqlite3
from os import path
from datetime import datetime
sqlite_file = '/Users/WesAull/GoogleDrive/NYCDSA/bootcamp009_project/Project2-WebScraping/WesAull/IBD.db'

class WriteItemSQLitePipeline(object):
    def __init__(self):
        self.setupDBCon()
        self.createTables()

    def setupDBCon(self):
        self.conn = sqlite3.connect(sqlite_file)
        self.cur = self.conn.cursor()

    def createTables(self):
        self.createGoogleTable()
        self.createGoogleCorTable()

    def createGoogleTable(self):
        self.cur.execute("CREATE TABLE IF NOT EXISTS Google (search_term text, date text, search_activity real)")

    def createGoogleCorTable(self):
        self.cur.execute("CREATE TABLE IF NOT EXISTS GoogleCor (search_term text,corr_term text,pearson real)")

    def process_item(self, item, spider):
        self.storeInDb(item)        
        return item

    def storeInDb(self,item):

        for i in item['hist_search_activity']:
            x = (item['search_term'], i['date'], i['value'])
            self.cur.execute("INSERT INTO Google(search_term, date, search_activity) VALUES(?,?,?)", x)
            self.conn.commit()
        print 'Activity Stored in Database'
        print '---------------------------'


        corr = zip(item['corr_terms'],item['corr_terms_cor'])
        for i,j in corr:
            y = (item['search_term'], i, j)
            self.cur.execute("INSERT INTO GoogleCor(search_term, corr_term, pearson) VALUES(?,?,?)", y)
            self.conn.commit()
        print 'Correlation Stored in Database'
        print '------------------------------'

    def closeDB(self):
        self.conn.close()

    def __del__(self):
        self.closeDB()



