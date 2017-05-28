import scrapy
import time
from baseball.items import HittersItem


class SpiderDodger(scrapy.Spider):
	name = "spider_batters"
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
		# >>>>>>>> Good comments. <<<<<<<<<<
		'''
		Let's get list of links to crawl first
		'''
		links = response.xpath('//td[@class="left "]/a/@href').extract()

		for link in links:
			new_url = 'http://www.baseball-reference.com' + link
			yield scrapy.Request(new_url, callback = self.parse_player)




	def parse_player(self, response):
		'''
		scrape the player pages
		'''
		# Find the positions, and pass any that are equal to pitchers
		if response.xpath('//*[@id="meta"]/div[2]/p[1]/text()').extract() == []:
			position = ""
		else:
			position = str(response.xpath('//*[@id="meta"]/div[2]/p[1]/text()').extract()[1].strip())

		position = self.verify(position)

		# Player name
		if not response.xpath('//*[@id="meta"]/div[2]/h1/text()').extract_first():
			name = response.xpath('//*[@id="meta"]/div/h1/text()').extract_first()
		else:
			name = response.xpath('//*[@id="meta"]/div[2]/h1/text()').extract_first()

		name = self.verify(name)

		# Defensive Position


		rows = response.xpath('//*[@id="content"]//table/tbody/tr')
		for row in rows:
			# Year
			year = str(rows[i].xpath('./th//text()').extract_first())
			# Team
			team = str(rows[i].xpath('./td[2]//text()').extract_first())
			# Games
			games = str(rows[i].xpath('./td[4]//text()').extract_first())
			# Plate Appearances
			pa = str(rows[i].xpath('./td[5]//text()').extract_first())
			# At Bats
			ab = str(rows[i].xpath('./td[6]//text()').extract_first())
			# Runs
			runs = str(rows[i].xpath('./td[7]//text()').extract_first())
			# Hits
			hits = str(rows[i].xpath('./td[8]//text()').extract_first())
			# Home runs
			hr = str(rows[i].xpath('./td[11]//text()').extract_first())
			# Runs batted in
			rbi = str(rows[i].xpath('./td[12]//text()').extract_first())
			# Stolen bases
			sb = str(rows[i].xpath('./td[13]//text()').extract_first())
			# Caught Stealing
			cs = str(rows[i].xpath('./td[14]//text()').extract_first())
			# Walks
			bb = str(rows[i].xpath('./td[15]//text()').extract_first())
			# Strike outs
			so = str(rows[i].xpath('./td[16]//text()').extract_first())
			# Batting Average
			ba = str(rows[i].xpath('./td[17]//text()').extract_first())
			# On Base Percentage
			obp = str(rows[i].xpath('./td[18]//text()').extract_first())
			# Slugging
			slg = str(rows[i].xpath('./td[19]//text()').extract_first())
			# OPS = OBP + SLG
			ops = str(rows[i].xpath('./td[20]//text()').extract_first())
			# OPS plus (weighted per ballpark)
			ops_plus = str(rows[i].xpath('./td[21]//text()').extract_first())
			# Total Bases
			tb = str(rows[i].xpath('./td[22]//text()').extract_first())
			# Intentional Walks
			ibb = str(rows[i].xpath('./td[27]//text()').extract_first())


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


			item = HittersItem()
			item['name'] = name
			item['year'] = year
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
