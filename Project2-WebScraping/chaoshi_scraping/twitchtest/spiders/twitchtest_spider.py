import scrapy
from twitchtest.items import TwitchtestItem

class twitchtestSpider(scrapy.Spider):

	name = "twitchtest_spider"
	custom_settings = {
		# custom pipeline for each spider for flexibility
		'ITEM_PIPELINES': {#'twitchtest.pipelines.ValidateItemPipeline': 100,
							'twitchtest.pipelines.WriteItemPipeline': 200}
	}


	allowed_urls = ['https://www.twitchtools.com/']
	#start_urls = ['https://www.twitchtools.com/channels']
	start_urls = ['https://www.twitchtools.com/channels']


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

		
		url1 = 'https://www.twitchtools.com/channels'

		for i in range(1,500): # 481 pages of channels on 4/28/2017, this list keeps growing
		                       # the scraping will stop once it reaches a non existing page

			url = url1 + '?p=' + str(i) + '&sort=followers&dir=DESC'

			yield scrapy.Request(url, callback=self.parse_each_page)

	def parse_each_page(self, response):

		channels = response.xpath('//*[@class="boxes"]/div')

		for channel in channels:
			subfolder = channel.xpath('.//div[@class="thumbnail"]/a/@href').extract_first()
			thumbnail = channel.xpath('.//div[@class="thumbnail"]/a/img/@src').extract_first()
			username = channel.xpath('.//div[@class="user"]/a/text()').extract()
			username = ''.join(username).strip()
			nfollowers = channel.xpath('.//div[@class="detail"]/text()').extract()
			nfollowers = ''.join(nfollowers).strip()

			item = TwitchtestItem()

			item['username']   = username
			item['nfollowers'] = nfollowers
			item['thumbnail']  = thumbnail
			item['subfolder']  = subfolder

			yield item

