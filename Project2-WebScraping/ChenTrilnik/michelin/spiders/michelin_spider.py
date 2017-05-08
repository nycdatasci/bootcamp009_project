import scrapy
from scrapy import Spider
from michelin.items import MichelinItem
from scrapy.http import Request

#URL = 'https://www.viamichelin.com/web/Restaurants/Restaurants-New_York-_-New_York-United_States'

class MichelinItem1(scrapy.Spider):
	name = 'michelin_spider'
	allowed_urls = ['https://www.viamichelin.com']
	#start_urls=['https://www.viamichelin.com/web/Restaurants/Restaurants-Rome-_-Roma-Italy?page=' + str(i+1) for i in range(4)]
	#https://www.viamichelin.com/web/Restaurants?address=London&addressId=31NDFhcWsxMGNOVEV1TlRBd01qUT1jTFRBdU1USTNNRFk9
	#start_urls=['https://www.viamichelin.com/web/Restaurants/Restaurants-Paris-75000-Ville_de_Paris-France?page=' + str(i+1) for i in range(27)]
	#start_urls=['https://www.viamichelin.com/web/Restaurants/Restaurants-Chicago-_-Illinois-United_States?page=' + str(i+1) for i in range(13)]
	#start_urls = ['https://www.viamichelin.com/web/Restaurants/Restaurants-New_York-_-New_York-United_States?page=' + str(i+1) for i in range(35)]
	# start_urls = ['https://www.viamichelin.com/web/Restaurants/Restaurants-New_York-_-New_York-United_States']
	start_urls= ['https://www.viamichelin.com/web/Restaurants?geoboundaries=-74.4964131,-142.734375:81.4662609,141.328125&page=' + str(i+1) for i in range(796)]
	#start_urls =['https://www.viamichelin.com/web/Restaurants/Restaurants-London-_-Greater_London-United_Kingdom?strLocid=31NDFhcWsxMGNOVEV1TlRBd01qUT1jTFRBdU1USTNNRFk9&page=' + str(i+1) for i in range(23)]

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

				#find the data on each of the restaurants

	def parse_restaurants(self,response):
		r_name = response.xpath('//div[@class="datasheet-item datasheet-name"]/text()').extract_first(default = "none")
		r_name = r_name.strip()
		r_name = self.verify(r_name)
		Address = response.xpath('//div[@class="datasheet-item"]/text()').extract_first(default = "none")
		cuisine	= response.xpath('//div[@class="datasheet-cooking-type"]/text()').extract_first(default = "none")
		Price = response.xpath('//div[@class="datasheet-price"]/em/text()').extract() 
		Michelin_star = response.xpath('//div[@class="datasheet-quotation-item clearfx"]/div[2]/strong/text()').extract_first(default = "none")
		Michelin_star_review = response.xpath('//div[@class="datasheet-quotation-item clearfx"]/div[2]/text()').extract_first(default = "none")   
		Standard = response.xpath('//div[@class="datasheet-quotation"]/div[2]/div[2]/strong/text()').extract_first(default = "none")
		Review = response.xpath('//div[@class="datasheet-description"]/blockquote/text()').extract_first(default = "none")
		Review  = Review.strip()
		Review = self.verify(Review)
		location = response.xpath('//body/div[@class="poi_view restaurant_view"]')[0].root.get('data-fetch_summary')
		location = self.verify(location)
		item1 = MichelinItem()
		print type(item1)
		print "=" * 40
		item1['Retaurant_name'] = r_name
		item1['Address'] = Address
		item1['Cuisine'] = cuisine
		item1['Price'] = Price
		item1['Michelin_star'] = Michelin_star
		item1['Michelin_star_review'] = Michelin_star_review
		item1['Standard'] = Standard
		item1['Review'] = Review
		item1['location'] = location
   		#Review  = ' '.join(Review).strip()
		#Review = self.verify(Review)
		yield item1


	# Finds the links to each of the restaurants details
	def parse(self,response):

		restaurants_links = response.xpath('//div[@class="poi-item-info"]/div[1]/a/@href').extract()  
		for link in restaurants_links:
			new_url= 'https://www.viamichelin.com' + link
			yield scrapy.Request(new_url, callback= self.parse_restaurants)
	
	

	
		
