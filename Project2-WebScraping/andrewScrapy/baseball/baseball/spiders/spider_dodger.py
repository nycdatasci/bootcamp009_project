import scrapy
import time
from baseball.items import BaseballItem


class SpiderDodger(scrapy.Spider):
	name = "spider_dodger"
	allowed_urls = ['http://www.baseball-reference.com/']
	start_urls = ['http://www.baseball-reference.com/awards/hof.shtml']


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
		'''
		Let's get list of links to crawl first
		'''
		# links = response.xpath('//td[@class="left "]/a/@href').extract()

		# for link in links:
			# new_url = 'http://www.baseball-reference.com' + link
			# print new_url
			# yield scrapy.Request(new_url, callback = self.parse_player)
			# yield scrapy.Request(new_url)
		new_url = "http://www.baseball-reference.com/players/p/piazzmi01.shtml"
		yield scrapy.Request(new_url, callback = self.parse_player)




	def parse_player(self, response):
		'''
		scrape the player pages
		'''

		if response.xpath('//*[@id="meta"]/div[2]/h1/text()') == []:
			name = ""
		else:
			name = response.xpath('//*[@id="meta"]/div[2]/h1/text()').extract_first()
		name = self.verify(name)
		
		if response.xpath('//*[@id="meta"]/div[2]/p[1]/text()') == []:
			position = ""
		else:
			position = response.xpath('//*[@id="meta"]/div[2]/p[1]/text()').extract()[1].strip()
		position = self.verify(position)	
		
		rows = response.xpath('//*[@id="content"]//table/tbody/tr')		
		for i in range(1, len(rows)):
			
			year = rows[i].xpath('./th//text()').extract_first()
			# if rows[i].xpath('./th/text()') == []:
			# 	year = ""
			# else:
			# 	year = rows[i].xpath('./th/text()').extract_first()
			# age = rows[i].xpath('//*[@id="batting_standard.1996"]/td[1]//text()').extract_first()
			
			team = rows[i].xpath('./td[2]//text()').extract_first()
			# if type(team) != int:
			#	 team = ''

			games = rows[i].xpath('./td[4]//text()').extract_first()
			# if rows[i].xpath('./td[4]/text()') == []:
			# 	games = rows[i].xpath('./td[4]/strong/em/text()').extract_first()
			# else:
			# 	games = rows[i].xpath('./td[4]/text()').extract_first()
			
			pa = rows[i].xpath('./td[5]//text()').extract_first()
			# if rows[i].xpath('./td[5]/text()') == []:
			# 	pa = rows[i].xpath('./td[5]/strong/em/text()').extract_first()
			# else:
			# 	pa = rows[i].xpath('./td[5]/text()').extract_first()
			
			ab = rows[i].xpath('./td[6]//text()').extract_first()
			# if rows[i].xpath('./td[6]/text()') == []:
			# 	ab = rows[i].xpath('./td[6]/strong/em/text()').extract_first()
			# else:
			# 	ab = rows[i].xpath('./td[6]/text()').extract_first()
			
			runs = rows[i].xpath('./td[7]//text()').extract_first()
			# if rows[i].xpath('./td[7]/text()') == []:
			# 	runs = rows[i].xpath('./td[7]/strong/em/text()').extract_first()
			# else:
			# 	runs = rows[i].xpath('./td[7]/text()').extract_first()
			
			hits = rows[i].xpath('./td[8]//text()').extract_first()
			# if rows[i].xpath('./td[8]/text()') == []:
			# 	hits = rows[i].xpath('./td[8]/strong/em/text()').extract_first()
			# else:
			# 	hits = rows[i].xpath('./td[8]/text()').extract_first()
			
			hr = rows[i].xpath('./td[11]//text()').extract_first()
			# if rows[i].xpath('./td[11]/text()') == []:
			# 	hr = rows[i].xpath('./td[11]/strong/em/text()').extract_first()
			# else:
			# 	hr = rows[i].xpath('./td[11]/text()').extract_first()
			
			rbi = rows[i].xpath('./td[12]//text()').extract_first()
			# if rows[i].xpath('./td[12]/text()') == []:
			# 	rbi = rows[i].xpath('./td[12]/strong/em/text()').extract_first()
			# else:
			# 	rbi = rows[i].xpath('./td[12]/text()').extract_first()
			
			sb = rows[i].xpath('./td[13]//text()').extract_first()
			# if rows[i].xpath('./td[13]/text()') == []:
			# 	sb = rows[i].xpath('./td[13]/strong/em/text()').extract_first()
			# else:
			# 	sb = rows[i].xpath('./td[13]/text()').extract_first()
			
			cs = rows[i].xpath('./td[14]//text()').extract_first()
			# if rows[i].xpath('./td[14]/text()') == []:
			# 	cs = rows[i].xpath('./td[14]/strong/em/text()').extract_first()
			# else:
			# 	cs = rows[i].xpath('./td[14]/text()').extract_first()				
			
			bb = rows[i].xpath('./td[15]//text()').extract_first()
			# if rows[i].xpath('./td[15]/text()') == []:
			# 	bb = rows[i].xpath('./td[15]/strong/em/text()').extract_first()
			# else:
			# 	bb = rows[i].xpath('./td[15]/text()').extract_first()
			
			so = rows[i].xpath('./td[16]//text()').extract_first()
			# if rows[i].xpath('./td[16]/text()') == []:
			# 	so = rows[i].xpath('./td[16]/strong/em/text()').extract_first()
			# else:
			# 	so = rows[i].xpath('./td[16]/text()').extract_first()
			
			ba = rows[i].xpath('./td[17]//text()').extract_first()
			# if rows[i].xpath('./td[17]/text()') == []:
			# 	ba = rows[i].xpath('./td[17]/strong/em/text()').extract_first()
			# else:
			# 	ba = rows[i].xpath('./td[17]/text()').extract_first()
			
			obp = rows[i].xpath('./td[18]//text()').extract_first()
			# if rows[i].xpath('./td[18]/text()') == []:
			# 	obp = rows[i].xpath('./td[18]/strong/em/text()').extract_first()
			# else:
			# 	obp = rows[i].xpath('./td[18]/text()').extract_first()
			
			slg = rows[i].xpath('./td[19]//text()').extract_first()
			# if rows[i].xpath('./td[19]/text()') == []:
			# 	slg = rows[i].xpath('./td[19]/strong/em/text()').extract_first()
			# else:
			# 	slg = rows[i].xpath('./td[19]/text()').extract_first()
			
			ops = rows[i].xpath('./td[20]//text()').extract_first()
			# if rows[i].xpath('./td[20]/text()') == []:
			# 	ops = rows[i].xpath('./td[20]/strong/em/text()').extract_first()
			# else:
			# 	ops = rows[i].xpath('./td[20]/text()').extract_first()

			ops_plus = rows[i].xpath('./td[21]//text()').extract()	
			# if not rows[i].xpath('./td[21]/text()').extract_first():
			# 	if not rows[i].xpath('./td[21]/strong/text()').extract_first():
			# 		ops_plus = rows[i].xpath('./td[21]/strong/em/text()').extract_first()
			# 	if not rows[i].xpath('./td[21]/strong/em/text()').extract_first():
			# 		ops_plus = rows[i].xpath('./td[21]/strong/text()').extract_first()
			# else:
			# 	ops_plus = rows[i].xpath('./td[21]/text()').extract_first()

			tb = rows[i].xpath('./td[22]//text()').extract_first()
			# if rows[i].xpath('./td[22]/text()') == []:
			# 	tb = rows[i].xpath('./td[22]/strong/em/text()').extract_first()
			# else:
			# 	tb = rows[i].xpath('./td[22]/text()').extract_first()


			
			ibb = rows[i].xpath('./td[27]//text()').extract_first()
			# if rows[i].xpath('./td[27]/text()') == []:
			# 	ibb = rows[i].xpath('./td[27]/strong/em/text()').extract_first()
			# else:
			# 	ibb = rows[i].xpath('./td[27]/text()').extract_first()

		# create another variable like rows for the player value -- batting table. we only want to extract WAR.
		# pv_rows = 
		# for i in range(1, len(pvrows)):
		# 	war = blahblahblah

			
			# verify
			year = self.verify(year)
			# age = self.verify(year)
			team = self.verify(team)
			games = self.verify(games)
			pa = self.verify(pa)
			ab = self.verify(ab)
			runs = self.verify(runs)
			hits = self.verify(hits)
			hr = self.verify(hr)
			rbi = self.verify(rbi)
			sb = self.verify(sb)
			cs = self.verify(cs)
			bb = self.verify(bb)
			so = self.verify(so)
			ba = self.verify(ba)
			obp = self.verify(obp)
			slg = self.verify(slg)
			ops = self.verify(ops)
			ops_plus = self.verify(ops_plus)
			tb = self.verify(tb)
			ibb = self.verify(ibb)
			
			item = BaseballItem()
			item['name'] = name
			item['year'] = year
			# item['age'] = age
			item['team'] = team
			item['position'] = position
			item['games'] = games
			item['pa'] = pa
			item['ab'] = ab
			item['runs'] = runs
			item['hits'] = hits
			item['hr'] = hr
			item['rbi'] = rbi
			item['sb'] = sb
			item['cs'] = cs
			item['bb'] = bb
			item['so'] = so
			item['ba'] = ba
			item['obp'] = obp
			item['slg'] = slg
			item['ops'] = ops
			item['ops_plus'] = ops_plus
			item['tb'] = tb
			item['ibb'] = ibb
			
			yield item




