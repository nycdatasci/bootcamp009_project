from scrapy import Spider
from coinmarket.items import CoinmarketItem


class BudgetSpider(Spider):
	name = "coinmarket_spider"
	allowed_urls = ['https://coinmarketcap.com']
	start_urls = ['https://coinmarketcap.com/all/views/all/']

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
		rows = response.xpath('//*[@id="currencies-all"]/tbody/tr')

		for row in rows:
			Name = row.xpath('./td[2]/a/text()').extract() 
			Name = self.verify(Name)
			Symbol = row.xpath('./td[3]/text()').extract()
			Symbol = self.verify(Symbol)
			Market_cap = row.xpath('./td[4]/@data-usd').extract()
			Market_cap = self.verify(Market_cap)
			Price = row.xpath('./td[5]/a/@data-usd').extract()
			Price = self.verify(Price)
			Circulating_supply = row.xpath('./td[6]/a/@data-supply').extract()
			Circulating_supply = self.verify(Circulating_supply)
			Volume_24h = row.xpath('./td[7]/a/@data-usd').extract()
			Volume_24h = self.verify(Volume_24h)
			Percent_change_24h = row.xpath('./td[9]/@data-usd').extract()
			Percent_change_24h = self.verify(Percent_change_24h)
			Percent_change_7d = row.xpath('./td[10]/@data-usd').extract()
			Percent_change_7d = self.verify(Percent_change_7d)

			item = CoinmarketItem()
			item['Name'] = Name
			item['Symbol'] = Symbol
			item['Market_cap'] = Market_cap
			item['Price'] = Price
			item['Circulating_supply'] = Circulating_supply
			item['Volume_24h'] = Volume_24h
			item['Percent_change_24h'] = Percent_change_24h
			item['Percent_change_7d'] = Percent_change_7d

			yield item
