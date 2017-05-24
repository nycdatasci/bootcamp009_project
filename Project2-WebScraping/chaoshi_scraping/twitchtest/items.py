# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class TwitchtestItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    username   = scrapy.Field()
    nfollowers = scrapy.Field()
    thumbnail  = scrapy.Field()
    subfolder  = scrapy.Field()



class TwitchChannelInfoItem(scrapy.Item):
	# define the fields for your item here like:
	# name = scrapy.Field()
	display_name         = scrapy.Field()
	account_unique_id    = scrapy.Field()
	channel_followers    = scrapy.Field()
	channel_views        = scrapy.Field()
	mature_flag          = scrapy.Field()
	twitch_partner_flag  = scrapy.Field()
	last_game            = scrapy.Field()
	account_created_date = scrapy.Field()
	account_updated_date = scrapy.Field()
	twitch_url           = scrapy.Field()
	page_url             = scrapy.Field()

	teams_joined         = scrapy.Field() 
	# this might be empty if the channel does NOT belong to any team
	# 1 channel can join multiple teams, so this field need to either
	# 1) have a flex structure, like a list
	# or
	# 2) get channel names, ' '.join(list)     # <- space separated


class TwitchTeamItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    teamname   = scrapy.Field()
    nmembers = scrapy.Field()
    thumbnail  = scrapy.Field()
    subfolder  = scrapy.Field()



class TwitchTeamInfoItem(scrapy.Item):
	# define the fields for your item here like:
	# name = scrapy.Field()
	team_name         = scrapy.Field()
	team_unique_id    = scrapy.Field()

	team_created_date = scrapy.Field()
	team_updated_date = scrapy.Field()

	twitch_url        = scrapy.Field()
	page_url          = scrapy.Field()

	team_members_ls      = scrapy.Field() 
	nfollowers_member_ls = scrapy.Field()
	subfolder_ls         = scrapy.Field()
	# teams have very different number of members
	# unstructured data type is more appropriate
	# json? mangoDB?



