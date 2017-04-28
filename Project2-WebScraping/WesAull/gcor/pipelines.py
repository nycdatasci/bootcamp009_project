# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

from scrapy.exceptions import DropItem
from scrapy.pipelines.files import FilesPipeline

# class FilesPipeline(object):
#     def process_item(self, item, spider):
#         return item

# 	def process_item(self, item, spider):
#     	path = self.get_path(item['url'])
#     	with open(path, "wb") as f:
#         	f.write(item['body'])  
#     	del item['body']
#     	item['path'] = path
#     	# let item be processed by other pipelines. ie. db store
#     	return item
