import scrapy
import pandas as pd
from twitchtest.items import TwitchTeamInfoItem

# team subfolder paths have been scraped from the twitchteam_spider, and saved in a csv file
# here we read in the csv file, assemble the full urls, and loop over them

class TwitchTeamInfoUrlsPrep():
    def __init__(self):
        pass

    def prep_urls(self):
        with open("twitchtools_teams.csv", "r") as f:
            teams = pd.read_csv(f)
        urls = 'https://www.twitchtools.com' + teams['subfolder']      # pandas.core.series.Series
        # urls = list('https://www.twitchtools.com' + teams['subfolder']) # list
        return urls


class twitchteaminfoSpider(scrapy.Spider):
	name = "twitchteaminfo_spider"

	custom_settings = {
		# custom pipeline for each spider for flexibility
		'ITEM_PIPELINES': {#'twitchtest.pipelines.ValidateItemPipeline': 100,
							'twitchtest.pipelines.WriteTeamInfoItemPipeline': 200}
	}

	allowed_urls = ['https://www.twitchtools.com/']
	#start_urls = ['https://www.twitchtools.com/teams']
	start_urls = TwitchTeamInfoUrlsPrep().prep_urls()


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

		# extract upper info box (guaranteed to have info for every channel)
		team_name         = response.xpath('//*[@id="main"]//ul/li[1]/span/text()').extract_first()
		team_unique_id    = response.xpath('//*[@id="main"]//ul/li[2]/span/text()').extract_first()

		team_created_date = response.xpath('//*[@id="main"]//ul/li[3]/span/text()').extract_first()
		team_created_date = ''.join(team_created_date).strip()

		team_updated_date = response.xpath('//*[@id="main"]//ul/li[4]/span/text()').extract_first()
		team_updated_date = ''.join(team_updated_date).strip()

		twitch_url        = response.xpath('//*[@id="main"]//ul/li[5]/span/text()').extract_first()

		# extract team info (direction: channel-to-multiple-teams), could be empty

		team_members_ls      = response.xpath('//*[@id="main"]//div[@class="boxes"]//div[@class="user"]/a/text()').extract()
		
		# nfollowers_member_ls = response.xpath('//*[@id="main"]//div[@class="boxes"]//div[@class="detail"]/text()').extract()
		# subfolder_ls         = response.xpath('//*[@id="main"]//div[@class="boxes"]//div[@class="user"]/a/@href').extract()

		team_members_ls = [''.join(t).strip() for t in team_members_ls]
		team_members_ls = ';'.join(team_members_ls)

		# nfollowers_member_ls = [''.join(t).strip() for t in nfollowers_member_ls]


		# # verify
		# display_name         = self.verify(display_name)
		# account_unique_id    = self.verify(account_unique_id)
		# channel_followers    = self.verify(channel_followers)
		# channel_views        = self.verify(channel_views)
		# mature_flag          = self.verify(mature_flag)
		# twitch_partner_flag  = self.verify(twitch_partner_flag)
		# last_game            = self.verify(last_game)
		# team_created_date = self.verify(team_created_date)
		# team_updated_date = self.verify(team_updated_date)
		# twitch_url           = self.verify(twitch_url)


		# prep for export

		item = TwitchTeamInfoItem()

		item['team_name']         = team_name
		item['team_unique_id']    = team_unique_id

		item['team_created_date'] = team_created_date
		item['team_updated_date'] = team_updated_date

		item['twitch_url'] = twitch_url
		item['page_url']   = response.request.url

		# these are lists
		item['team_members_ls']      = team_members_ls # placeholder
		# item['nfollowers_member_ls'] = nfollowers_member_ls
		# item['subfolder_ls']         = subfolder_ls


		yield item


