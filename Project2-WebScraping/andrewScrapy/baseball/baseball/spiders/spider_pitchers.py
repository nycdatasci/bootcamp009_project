import scrapy
import time
import re
from baseball.items import PitchersItem

# >>>>>>> Similar problems in this spider, refer to the comments in the other one. <<<<<<<<<
class SpiderDodger(scrapy.Spider):
	name = "spider_pitchers"
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
		links = response.xpath('//td[@class="left "]/a/@href').extract()

		for link in links:
			new_url = 'http://www.baseball-reference.com' + link
			print new_url
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
			# Wins
			wins = str(rows[i].xpath('./td[4]//text()').extract_first())
			# Losses
			losses = str(rows[i].xpath('./td[5]//text()').extract_first())
			# Earned Run Average
			era = str(rows[i].xpath('./td[7]//text()').extract_first())
			# Games played
			games = str(rows[i].xpath('./td[8]//text()').extract_first())
			# Complete games
			cg = str(rows[i].xpath('./td[11]//text()').extract_first())
			# Complete Game Shutouts
			sho = str(rows[i].xpath('./td[12]//text()').extract_first())
			# saves
			saves = str(rows[i].xpath('./td[13]//text()').extract_first())
			# Innings pitched
			ip = str(rows[i].xpath('./td[14]//text()').extract_first())
			# Hits allowed
			h = str(rows[i].xpath('./td[15]//text()').extract_first())
			# Runs allowed
			r = str(rows[i].xpath('./td[16]//text()').extract_first())
			# Earned runs allows
			er = str(rows[i].xpath('./td[17]//text()').extract_first())
			# Homeruns Allowed
			hr = str(rows[i].xpath('./td[18]//text()').extract_first())
			# Walks
			bb = str(rows[i].xpath('./td[19]//text()').extract_first())
			# Intentional Walks
			ibb = str(rows[i].xpath('./td[20]//text()').extract_first())
			# Strikeouts
			k = str(rows[i].xpath('./td[21]//text()').extract_first())
			# Hit by pitch
			hbp = str(rows[i].xpath('./td[22]//text()').extract_first())
			# Balks
			bk = str(rows[i].xpath('./td[23]//text()').extract_first())
			# Wild Pitches
			wp = str(rows[i].xpath('./td[24]//text()').extract_first())
			# Batters faced
			bf = str(rows[i].xpath('./td[25]//text()').extract_first())
			# ERA+ (adjusted per ballback)
			era_plus = str(rows[i].xpath('./td[26]//text()').extract_first())
			# Fielding independent pitching
			fip = str(rows[i].xpath('./td[27]//text()').extract_first())
			# Walks and hits per innings pitched
			whip = str(rows[i].xpath('./td[28]//text()').extract_first())
			# Hits per 9 innings
			h9 = str(rows[i].xpath('./td[29]//text()').extract_first())
			# Homerun per 9 innings
			hr9 = str(rows[i].xpath('./td[30]//text()').extract_first())
			# Walks per 9 innings
			bb9 = str(rows[i].xpath('./td[31]//text()').extract_first())
			# Strikeout per 9 innings
			k9 = str(rows[i].xpath('./td[32]//text()').extract_first())


			# verify
			year = self.verify(year)
			team = self.verify(team)
			wins = self.verify(wins)
			losses = self.verify(losses)
			era = self.verify(era)
			games = self.verify(games)
			cg = self.verify(cg)
			sho = self.verify(sho)
			saves = self.verify(saves)
			ip = self.verify(ip)
			h = self.verify(h)
			r = self.verify(r)
			er = self.verify(er)
			hr = self.verify(hr)
			bb = self.verify(bb)
			ibb = self.verify(ibb)
			k = self.verify(k)
			hbp = self.verify(hbp)
			bk = self.verify(bk)
			wp = self.verify(wp)
			bf = self.verify(bf)
			era_plus = self.verify(era_plus)
			fip = self.verify(fip)
			whip = self.verify(whip)
			h9 = self.verify(h9)
			hr9 = self.verify(hr9)
			bb9 = self.verify(bb9)
			k9 = self.verify(whip)


			item = PitchersItem()
			item['name'] = name
			item['position'] = position
			item['year'] = year
			item['team'] = team
			item['wins'] = wins
			item['losses'] = losses
			item['era'] = era
			item['games'] = games
			item['cg'] = cg
			item['sho'] = sho
			item['saves'] = saves
			item['ip'] = ip
			item['h'] = h
			item['r'] = r
			item['er'] = er
			item['hr'] = hr
			item['bb'] = bb
			item['ibb'] = ibb
			item['k'] = k
			item['hbp'] = hbp
			item['bk'] = bk
			item['wp'] = wp
			item['bf'] = bf
			item['era_plus'] = era_plus
			item['fip'] = fip
			item['whip'] = whip
			item['h9'] = h9
			item['hr9'] = hr9
			item['bb9'] = bb9
			item['k9'] = k9


			yield item
