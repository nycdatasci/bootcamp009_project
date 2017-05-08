import scrapy
import pandas as pd
from twitchtest.items import TwitchChannelInfoItem

# channel subfolder paths have been scraped from the twitchtest_spider, and saved in a csv file
# here we read in the csv file, assemble the full urls, and loop over them

# >>>>>>>> This class is a little bit redundant. I believe you can do it with list comprehension. <<<<<<<<<
class TwitchChannelInfoUrlsPrep():
    def __init__(self):
        pass

    def prep_urls(self):
        with open("twitchtools_channels.csv", "r") as f:
            channels = pd.read_csv(f)
        urls = 'https://www.twitchtools.com' + channels['subfolder']      # pandas.core.series.Series
        # urls = list('https://www.twitchtools.com' + channels['subfolder']) # list
        return urls


class twitchchannelinfoSpider(scrapy.Spider):
	name = "twitchchannelinfo_spider"

	custom_settings = {
		# custom pipeline for each spider for flexibility
		'ITEM_PIPELINES': {#'twitchtest.pipelines.ValidateItemPipeline': 100,
							'twitchtest.pipelines.WriteChannelInfoItemPipeline': 200}
	}

	allowed_urls = ['https://www.twitchtools.com/']
	#start_urls = ['https://www.twitchtools.com/channels']
	start_urls = TwitchChannelInfoUrlsPrep().prep_urls()


	def verify(self, content):
		if isinstance(content, list):
			 if len(content) > 0:
				 content = content[0]
				 # convert unicode to str
				 return content.encode('ascii','ignore')
			 else:
				 return ""
		else:
			# convert unicode to str
			return content.encode('ascii','ignore')


	def parse(self, response):
        # >>>>>>>>> Nice format :) <<<<<<<<<
		# extract upper info box (guaranteed to have info for every channel)
		display_name         = response.xpath('//*[@id="main"]//ul/li[1]/span/text()').extract_first()
		account_unique_id    = response.xpath('//*[@id="main"]//ul/li[2]/span/text()').extract_first()
		channel_followers    = response.xpath('//*[@id="main"]//ul/li[3]/span/text()').extract_first()
		channel_views        = response.xpath('//*[@id="main"]//ul/li[4]/span/text()').extract_first()

		mature_flag          = response.xpath('//*[@id="main"]//ul/li[5]/span/text()').extract_first()
		mature_flag          = ''.join(mature_flag).strip()

		twitch_partner_flag  = response.xpath('//*[@id="main"]//ul/li[6]/span/text()').extract_first()
		twitch_partner_flag  = ''.join(twitch_partner_flag).strip()

		last_game            = response.xpath('//*[@id="main"]//ul/li[7]/span/text()').extract_first()

		account_created_date = response.xpath('//*[@id="main"]//ul/li[8]/span/text()').extract_first()
		account_created_date = ''.join(account_created_date).strip()

		account_updated_date = response.xpath('//*[@id="main"]//ul/li[9]/span/text()').extract_first()
		account_updated_date = ''.join(account_updated_date).strip()

		twitch_url           = response.xpath('//*[@id="main"]//ul/li[10]/span/text()').extract_first()

		# extract team info (direction: channel-to-multiple-teams), could be empty

		teams_joined_ls  = response.xpath('//*[@id="main"]//div[@class="boxes"]//div[@class="user"]/a/text()').extract()
		if len(teams_joined_ls) > 0:
			teams_joined_ls  = [''.join(t).strip() for t in teams_joined_ls]
			teams_joined_str = ';'.join(teams_joined_ls)
		else:
			teams_joined_str = 'did not join any team'


		# # verify
		# display_name         = self.verify(display_name)
		# account_unique_id    = self.verify(account_unique_id)
		# channel_followers    = self.verify(channel_followers)
		# channel_views        = self.verify(channel_views)
		# mature_flag          = self.verify(mature_flag)
		# twitch_partner_flag  = self.verify(twitch_partner_flag)
		# last_game            = self.verify(last_game)
		# account_created_date = self.verify(account_created_date)
		# account_updated_date = self.verify(account_updated_date)
		# twitch_url           = self.verify(twitch_url)


		# prep for export

		item = TwitchChannelInfoItem()

		item['display_name']         = display_name
		item['account_unique_id']    = account_unique_id
		item['channel_followers']    = channel_followers
		item['channel_views']        = channel_views
		item['mature_flag']          = mature_flag
		item['twitch_partner_flag']  = twitch_partner_flag
		item['last_game']            = last_game
		item['account_created_date'] = account_created_date
		item['account_updated_date'] = account_updated_date
		item['twitch_url']           = twitch_url
		item['page_url']             = response.request.url


		item['teams_joined'] = teams_joined_str # placeholder


		yield item
