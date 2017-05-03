import scrapy
#from scrapy import Spider
from scrapy.selector import Selector
from Weather.items import WeatherItem

class WeatherSpider(scrapy.Spider):
	name = 'weather_spider'
	allowed_urls = ['https://www.wunderground.com/']
	#start_urls = ['https://www.wunderground.com/history/?MR=1']
	start_urls = ['https://www.wunderground.com/history/airport/KBOS/2016/5/2/DailyHistory.html?']
	next_day_url = ''	
	#we'll load a list of all the variables we want to load
	def verify(self, content):
		#print "test"
		if isinstance(content, list):
			print "test verify\n"
			if len(content) > 0:
				content = content[0]
				 # convert unicode to str
				return content.encode('ascii','ignore')
			else:
				return ""
		else:
			# convert unicode to str
			return content.encode('ascii','ignore')
	#def parse(self,response):



	#	next_day = response.xpath('//div[@class="next-link"]/a/@href').extract_first()
	#	for x in range(0,5):
	#		next_day_url = "https://www.wunderground.com"  + next_day
	#		nextResponse = scrapy.Request(next_day_url, callback=self.parse_day)
	#		#print nextResponse.text
	#		#next_day = nextResponse.xpath('//div[@class="next-link"]/a/@href').extract_first()
	#		next_day = nextResponse.xpath('//div[@class="next-link"]/a/@href').extract_first()
	#		print next_day
	#		print next_day_url
	#		#url = response.request.url			
			#print url
	#		yield scrapy.Request(next_day_url, callback=self.parse_day)
	i=0
	def parse(self, response):
		if self.i < 365:
		#this gives us all the rows of our table
			Date = response.xpath("//h2[@class='history-date']/text()").extract_first()
		#print Date
			rows = response.xpath('//div[@id="observations_details"]/table/tbody/tr')
			next_day = response.xpath('//div[@class="next-link"]/a/@href').extract_first()			
			next_day_url = "https://www.wunderground.com"  + next_day

			for row in rows:
			#this gives us all the elements of the row, many of them are empty
				raw_data = row.xpath('.//text()').extract()
			#all_data = row.xpath('.//text()').extract()
			#the rows are of variable length because sometimes windchill and gustspeed are present
			#sometimes windspeed takes two values (speed and 'mph') and sometimes it is just 'calm'
				junkStrings = ['\n\t\t','\n  ',u'\xa0mph','\n',u'\n\t\xa0\n',u'\xa0\xb0F',u'\xa0mi']
				parsed_Data = filter(lambda a: a not in junkStrings, raw_data)
				time = parsed_Data[0]
				temperature = parsed_Data[1]
				windChill = parsed_Data[2]
				dewPoint = parsed_Data[3]
				humidity = parsed_Data[4]
				pressure = parsed_Data[5]
				visibility = parsed_Data[7]
				windDir = parsed_Data[8]
				windSpeed = parsed_Data[9]
				gustSpeed =parsed_Data[10]
				precipitation = parsed_Data[11]
				#condition = parsed_Data[12]


				#offset = 0
				#time = raw_data[1]	
				#temperature = raw_data[4]
				#if wind chill has just - 
				#if (raw_data[9] ==  u'\n\t\t'):
				#	offset += 3
				#	windChill = temperature
				#else:
				#	windChill = raw_data[9]
				#dewPoint = raw_data[14-offset]
				#humidity = raw_data[18-offset]
				#pressure = raw_data[21-offset]
				#visibility = raw_data[26-offset]
				#if wind dir = calm
				#if (raw_data[30-offset] == 'Calm'):
				#	offset +=4
				#windDir = raw_data[30-offset]
				#not sure if there ever are no values in the wind speed table
				#if (raw_data[30-offset] == 'Calm'):
				#	offset +=2
				#windSpeed = raw_data[33-offset]
				#if (raw_data[33-offset] == 'Calm'):
				#	offset +=2
				##if gust speed = -
				#if (raw_data[38-offset] == u'\n\t\t'):
				#	offset +=3
				#	gustSpeed = '0'
				#else:
				#	gustSpeed = raw_data[38-offset]
				#precipitation = raw_data[43-offset]
				#print precipitation
				#print "\n"
				#we can go further with analysis after we find preciptation patterns
				#if (all_data[])
				item = WeatherItem()
				time = self.verify(time)
				Date = self.verify(Date)
				temperature = self.verify(temperature)
				windChill = self.verify(windChill)
				dewPoint = self.verify(dewPoint)
				humidity = self.verify(humidity)		
				pressure = self.verify(pressure)
				visibility = self.verify(visibility)
				windDir = self.verify(windDir)
				windSpeed = self.verify(windSpeed)
				gustSpeed = self.verify(gustSpeed)
				precipitation = self.verify(precipitation)
				item['time'] = time	
				item['windChill'] = windChill
				item['temperature'] = temperature
				item['dewPoint'] = 	dewPoint
				item['humidity'] = humidity
				item['pressure'] = pressure
				item['visibility'] = visibility
				item['windDir'] = windDir
				item['windSpeed'] =  windSpeed
				item['gustSpeed'] = gustSpeed
				item['precipitation'] = precipitation
				item['Date'] = Date
				yield item
			self.i += 1
			yield scrapy.Request(next_day_url,callback=self.parse)
			