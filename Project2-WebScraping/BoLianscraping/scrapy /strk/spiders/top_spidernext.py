from strk.items import rankItem
import scrapy
import re

class TopSpider(scrapy.Spider):
	name = 'top_spidernext'
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
		# >>>>>>> Same problem. Do not manually code the number here. <<<<<<<<<<
		for i in range(1,260):

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
			rankwd = ''.join([i.encode('ascii', 'ignore').strip() for i in rankwd])

	#.encode('ascii','ignore')    # app name
		# name=self.verify(name)


			company=row.xpath('./td[2]/div/a/text()').extract()#.encode('ascii','ignore')
			company = ''.join([i.encode('ascii', 'ignore').strip() for i in company])
			company= re.sub('[. ]', '-', company)
			#company= company.replace('.', '-')

		# company=self.verify(company)  # list to string

			SR_score = row.xpath('./td[3]/text()').extract()#.encode('ascii','ignore')
			SR_score = ''.join([i.encode('ascii', 'ignore').strip() for i in SR_score])

			des =row.xpath('./td[4]/text()').extract()#.encode('ascii','ignore') 	#.encode('ascii','ignore')     ## click into again
			des = ''.join([i.encode('ascii', 'ignore').strip() for i in des])
			# change list to string element, then strip join by ""
			country =row.xpath('./td[5]/a/img/@alt').extract()#.encode('ascii','ignore')     ## click into again
			country = ''.join([i.encode('ascii', 'ignore').strip() for i in country])


			rankbyctr =row.xpath('./td[5]/a/div/text()').extract()
			rankbyctr= ''.join([i.encode('ascii', 'ignore').strip() for i in rankbyctr])

		# type of review is  scrapy.selector.unified.SelectorList

			meta_dict =  {'rankwd':rankwd, 'company': company, 'country': country,'SR_score':SR_score, 'des':des,'rankbyctr':rankbyctr}



			innerurl= 'http://www.startupranking.com/'+company


			yield scrapy.Request(innerurl, callback= self.parse_inner, meta = meta_dict)


	def parse_inner(self,response):

		company = response.meta['company']
		rankwd=response.meta['rankwd']
		SR_score=response.meta['SR_score']
		des=response.meta['des']
		country=response.meta['country']
		rankbyctr=response.meta['rankbyctr']

		name = response.xpath('*//div[@class="su-info"]/h2/a/text()').extract_first().encode('ascii','ignore')
		category = response.xpath('*//div[@class="su-phrase"]/text()').extract_first().encode('ascii','ignore')
		#rank = response.xpath('*//span[@class="srank-rank"]/a/text()').extract_first().encode('ascii','ignore')
		SR_web= response.xpath('*//div[@class="panel su-web"]/p/text()').extract_first().encode('ascii','ignore')
		SR_social= response.xpath('*//div[@class="panel su-social"]/p/text()').extract_first().encode('ascii','ignore')
		tag = response.xpath('*//div[@class="su-tags group"]/ul//li/a/text()').extract()
		tag= [i.encode('ascii', 'ignore') for i in tag]
		alexa=response.xpath('*//ul[@class="social-stats"]/li[2]/span/text()').extract()[0].encode('ascii','ignore')
		moz= response.xpath('*//ul[@class="social-stats"]/li[1]/span/text()').extract()[1].encode('ascii','ignore')
		SR=response.xpath('*//ul[@class="social-stats"]/li[1]/span/text()').extract()[2].encode('ascii','ignore')
		facebook = response.xpath('*//ul[@class="social-stats"]/li[1]/span/text()').extract()[3].encode('ascii','ignore')
		twitter=response.xpath('*//ul[@class="social-stats"]/li[1]/span/text()').extract()[4].encode('ascii','ignore')
		founded=response.xpath('*//p[@class="su-loc"]/text()').extract_first().encode('ascii','ignore').strip()
		#founded= ''.join([i.strip() for i in founded])
		city_state=response.xpath('*//li[@class="su-state"]/a/text()').extract_first().encode('ascii','ignore').strip()


		item= rankItem()
		item['rankwd']= rankwd
		item['company']= company
		item['SR_score']= SR_score
		item['des']= des
		item['country']= country
		item['rankbyctr']= rankbyctr
		item['name']= name
		item['category']= category
		item['SR_web']= SR_web
		item['SR_social']= SR_social
		item['tag']= tag
		item['alexa']= alexa
		item['moz']= moz
		item['SR']= SR
		item['facebook']= facebook
		item['twitter']= twitter
		item['founded']= founded
		item['city_state']= city_state

		yield item  # each review is one item  , get 40 reviews for each app
