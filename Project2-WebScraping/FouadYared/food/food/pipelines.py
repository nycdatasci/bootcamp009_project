from scrapy.exporters import CsvItemExporter

class FoodPipeline(object):
    def process_item(self, item, spider):
        return item

class WriteItemPipeline(object):

    def __init__(self):
        self.filename = 'foodOne.csv'

    def open_spider(self, spider):
        self.csvfile = open(self.filename, 'wb')
        self.exporter = CsvItemExporter(self.csvfile)
        self.exporter.start_exporting()

    def close_spider(self, spider):
        self.exporter.finish_exporting()
        self.csvfile.close()

    def process_item(self, item, spider):
        self.exporter.export_item(item)
        return item