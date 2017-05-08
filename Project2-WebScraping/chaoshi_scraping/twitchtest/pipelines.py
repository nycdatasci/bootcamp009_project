# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html


from scrapy.exceptions import DropItem
from scrapy.exporters import CsvItemExporter
from scrapy.exporters import JsonItemExporter

class ValidateItemPipeline(object):

    def process_item(self, item, spider):
        if not all(item.values()):
            raise DropItem("Missing values!")
        else:
            return item


class WriteItemPipeline(object):

    def __init__(self):
        self.filename = 'twitchtools_channels.csv'      # this line needs to change when running different spiders

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


class WriteChannelInfoItemPipeline(object):

    def __init__(self):
        self.filename = 'twitchtools_channelsinfo.csv'

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


class WriteTeamItemPipeline(object):

    def __init__(self):
        self.filename = 'twitchtools_teams.csv'      # this line needs to change when running different spiders

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

# class WriteTeamInfoItemPipeline(object):

# #######################################################
# ############### consider json or mangoDB ##############
# #######################################################

#     def __init__(self):
#         self.filename = 'twitchtools_teamsinfo.json'    # this line needs to change when running different spiders

#     def open_spider(self, spider):
#         self.jsonfile = open(self.filename, 'wb')
#         self.exporter = JsonItemExporter(self.jsonfile)
#         self.exporter.start_exporting()

#     def close_spider(self, spider):
#         self.exporter.finish_exporting()
#         self.jsonfile.close()

#     def process_item(self, item, spider):
#         self.exporter.export_item(item)
#         return item




class WriteTeamInfoItemPipeline(object):

#######################################################
############### consider json or mangoDB ##############
#######################################################

    def __init__(self):
        self.filename = 'twitchtools_teamsinfo.csv'    # this line needs to change when running different spiders

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
