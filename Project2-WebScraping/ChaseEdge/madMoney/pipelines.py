# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

from scrapy.exceptions import DropItem
from scrapy.exporters import CsvItemExporter
from scrapy.xlib.pydispatch import dispatcher
from scrapy import log, signals


class ValidateItemPipeline(object):

    def process_item(self, item, spider):
        if not any(item.values()):
            raise DropItem("Missing values!")
        else:
            return item

def item_type(item):
    return type(item).__name__.replace('Item','').lower()

class WriteItemPipeline(object):

    # Pulling in different multiple Items and placing them in separate files
    SaveTypes = ['pick', 'profile', 'problem', 'foolpick', 'foolprofile','stock']

    def __init__(self):
        dispatcher.connect(self.spider_opened, signal=signals.spider_opened)
        dispatcher.connect(self.spider_closed, signal=signals.spider_closed)

    def spider_opened(self, spider):
        # make seperate files for each item
        self.files = dict([ (name, open(name+'s.csv','wb')) for name in self.SaveTypes ])
        self.exporters = dict([ (name,CsvItemExporter(self.files[name])) for name in self.SaveTypes])
        [e.start_exporting() for e in self.exporters.values()]

    def spider_closed(self, spider):
        [e.finish_exporting() for e in self.exporters.values()]
        [f.close() for f in self.files.values()]

    def process_item(self, item, spider):
        t = item_type(item)
        if t in set(self.SaveTypes):
            self.exporters[t].export_item(item)
        return item
