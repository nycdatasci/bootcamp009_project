from scrapy.exceptions import DropItem
import sqlite3
from os import path
sqlite_file = '/Users/WesAull/GoogleDrive/NYCDSA/bootcamp009_project/Project2-WebScraping/WesAull/IBD.db'

class ValidateItemPipeline(object):

    def process_item(self, item, spider):
        if not all(item.values()):
            raise DropItem("Missing values!")
        else:
            return item

class WriteItemSQLitePipeline(object):
    def __init__(self):
        self.setupDBCon()
        self.createTables()

    def setupDBCon(self):
        self.conn = sqlite3.connect(sqlite_file)
        self.cur = self.conn.cursor()

    def createTables(self):
        self.dropIBDTable()
        self.createIBDTable()

    def createIBDTable(self):
        self.cur.execute("CREATE TABLE IF NOT EXISTS IBD(id INTEGER PRIMARY KEY NOT NULL, \
            name TEXT, \
            path TEXT, \
            source TEXT \
            )")

    def dropIBDTable(self):
        self.cur.execute("DROP TABLE IF EXISTS IBD")

    def process_item(self, item, spider):
        self.storeInDb(item)        
        return item

    def storeInDb(self,item):
        self.cur.execute("INSERT INTO IBD(\
            name, \
            path, \
            source \
            ) \
            VALUES( ?, ?, ?)", \
            ( \
                item.get('Name',''),
                item.get('Path',''),
                item.get('Source','')
            ))
        print '------------------------'
        print 'Data Stored in Database'
        print '------------------------'
        self.conn.commit()

    def closeDB(self):
        self.conn.close()

    def __del__(self):
        self.closeDB()
