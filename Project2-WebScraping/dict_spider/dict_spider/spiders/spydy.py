import scrapy



class SpydySpider(scrapy.Spider):
    name = "spydy"
    
    start_urls = ['http://www.ctlottery.org/Modules/Winners/',
    ]
	
    def parse(self, response):
		for rows in response.xpath('//div[@id="ctl00_MainContent_ContentPanel"]/div[1]/table/tr'):
			item = {

				'date': rows.xpath('./td[1]/text()').extract(),
			    'winner': rows.xpath('./td[2]/span/text()').extract(),
			    'retailer': rows.xpath('./td[3]/a/text()').extract(),
			    'retailer_location': rows.xpath('./td[3]/span/text()').extract(),
			    'game': rows.xpath('./td[4]/span/text()').extract(),
			    'prize': rows.xpath('./td[5]/span/text()').extract(),
		   	}
		   	yield item

		next_page_url = response.css('div.sg_pagination a::attr(href)').extract()[-2]
		
		if next_page_url is not None:        
			next_page_url = response.urljoin(next_page_url)
			yield scrapy.Request(next_page_url, callback=self.parse)


