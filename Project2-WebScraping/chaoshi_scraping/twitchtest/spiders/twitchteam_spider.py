import scrapy
from twitchtest.items import TwitchTeamItem

class twitchteamSpider(scrapy.Spider):

	name = "twitchteam_spider"
	custom_settings = {
		# custom pipeline for each spider for flexibility
		'ITEM_PIPELINES': {#'twitchtest.pipelines.ValidateItemPipeline': 100,
							'twitchtest.pipelines.WriteTeamItemPipeline': 200}
	}


	allowed_urls = ['https://www.twitchtools.com/']
	#start_urls = ['https://www.twitchtools.com/teams']
	start_urls = ['https://www.twitchtools.com/teams']


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

		
		url1 = 'https://www.twitchtools.com/teams'

		for i in range(1,100): # 72 pages of teams on 4/29/2017, this list keeps growing
		                       # the scraping will stop once it reaches a non existing page

			url = url1 + '?p=' + str(i) + '&sort=members&dir=DESC'

			yield scrapy.Request(url, callback=self.parse_each_page)

	def parse_each_page(self, response):

		teams = response.xpath('//*[@class="boxes"]/div')

		for team in teams:
			subfolder = team.xpath('.//div[@class="thumbnail"]/a/@href').extract_first()
			thumbnail = team.xpath('.//div[@class="thumbnail"]/a/img/@src').extract_first()
			teamname = team.xpath('.//div[@class="user"]/a/text()').extract()
			teamname = ''.join(teamname).strip()
			nmembers = team.xpath('.//div[@class="detail"]/text()').extract()
			nmembers = ''.join(nmembers).strip()

			item = TwitchTeamItem()

			item['teamname']   = teamname
			item['nmembers']   = nmembers
			item['thumbnail']  = thumbnail
			item['subfolder']  = subfolder

			yield item

