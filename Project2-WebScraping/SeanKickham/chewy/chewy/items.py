# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class ChewyItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    
    # main product info
	product_name = scrapy.Field()
	product_description = scrapy.Field()
	cost = scrapy.Field()
	old_cost = scrapy.Field()
	rating = scrapy.Field()
	no_reviews = scrapy.Field()
	item_number = scrapy.Field()
	weight = scrapy.Field()
	page = scrapy.Field()
	category = scrapy.Field()
	percent_rec = scrapy.Field()

	# possible description list info
	breed_size = scrapy.Field()
	food_form = scrapy.Field()
	lifestage = scrapy.Field()
	brand = scrapy.Field()
	made_in = scrapy.Field()
	special_diet = scrapy.Field()
	food_texture = scrapy.Field()
	size = scrapy.Field()
	supplement_form = scrapy.Field()
	fish_type = scrapy.Field()
	reptile_type = scrapy.Field()
	small_pet_type = scrapy.Field()
	bird_type = scrapy.Field()
	dimensions = scrapy.Field()
	toy_feature = scrapy.Field()
	material = scrapy.Field()
	bed_type = scrapy.Field()
	litter_box_type = scrapy.Field()
	bowl_feature = scrapy.Field()
	litter_and_bedding_type = scrapy.Field()
	leash_and_collar_feature = scrapy.Field()


