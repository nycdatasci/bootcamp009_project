


from strk.items import rank1Item
import scrapy

class TopSpider(scrapy.Spider):
	name = 'top_spider245'
	allowed_urls = ['http://www.startupranking.com/']
	start_urls = ['http://www.startupranking.com/top/']



	# def verify(self, content):        # to ask
	# 	if isinstance(content, list):
	# 		 if len(content) > 0:
	# 			 content = content[0]
	# 			 # convert unicode to str
	# 			 return content.encode('ascii','ignore')
	# 		 else:
	# 			 return ""
	# 	else:
	# 		# convert unicode to str   if it is unicode directly
	# 		return content.encode('ascii','ignore')      

	def parse(self,response):       # first function has to parse, after that , any names are ok
		
		# links = response.xpath('//div[@class="cluster-heading"]/h2/a/@href').extract()
		# links = response.xpath('//a[@class = "title-link id-track-click"]/@href').extract()
		# links= response.xpath('//a[@class="title-link id-track-click/@href')

		for i in range(1,246):

			link = "http://www.startupranking.com/top/0/" + str(i)  # must str, not 'i' most of the link follow the same pattern

			yield scrapy.Request(link, callback= self.parse_table)  # call back  list

	

# 	def parse_list(self,response):

# 		app_list = response.xpath('//div[@class="cluster-heading"]/h2/text()').extract_first()   # one more a than them
# 		app_links = response.xpath('//a[@class ="card-click-target"]/@href').extract()     #each app link, no first

# 		for link in app_links:
# 			app_url = 'https://play.google.com' + link 


# 			yield scrapy.Request(app_url, callback= self.parse_app, meta ={'app_list':app_list})     # dictionary 


# # click into each app

	def parse_table(self,response):

		rows=response.xpath('*//tbody[@class="ranks"]/tr')

		for row in rows:
		
		# app_list=response.meta['app_list']
		# app_list=self.verify(app_list)

			rankwd=row.xpath('./td[1]/text()').extract_first()
	#.encode('ascii','ignore')    # app name
		# name=self.verify(name)


			company=row.xpath('./td[2]/div/a/text()').extract()#.encode('ascii','ignore')  
		# company=self.verify(company)

			SR_score = row.xpath('./td[3]/text()').extract()#.encode('ascii','ignore')  

			des =row.xpath('./td[4]/text()').extract()#.encode('ascii','ignore') 	#.encode('ascii','ignore')     ## click into again
			des = ''.join([i.encode('ascii', 'ignore').strip() for i in des])
			# change list to string element, then strip join by ""
			country =row.xpath('./td[5]/a/img/@alt').extract()#.encode('ascii','ignore')     ## click into again
			rankbyctr =row.xpath('./td[5]/a/div/text()').extract()
		# type of review is  scrapy.selector.unified.SelectorList     



		

		# for review in reviews:

		# 	content= review.xpath('./div[@class="review-body with-review-wrapper"]/text()').extract()

		# 	content=''.join(content).strip()   #to ask
		# 	#verify content
		# 	# content= self.verify(content)

		# 	rating =review.xpath('.//div[@class="tiny-star star-rating-non-editable-container"]/@aria-label').extract_first()

			item= rank1Item()
			item['rankwd']= rankwd
			item['company']= company
			item['SR_score']= SR_score
			item['des']= des
			item['country']= country
			item['rankbyctr']= rankbyctr 

			yield item  # each review is one item  , get 40 reviews for each app


		
