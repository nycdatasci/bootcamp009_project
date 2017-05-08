from bestreads.items import BestreadsItem
import scrapy
import re
from scrapy.selector import Selector

class bestreads_spider(scrapy.Spider):
	name = 'bestreads'
	allowed_urls = ['https://www.goodreads.com/']

	# 'best books ever' list includes more than 48,000 books - will focus on top 500 for analysis
	rootURL = 'https://www.goodreads.com/list/show/1.Best_Books_Ever?page='
	start_urls = [rootURL + str(i) for i in range(1,5)]

	# # for debug
	# start_urls = ['https://www.goodreads.com/list/show/1.Best_Books_Ever?page=1',
	# 			  'https://www.goodreads.com/list/show/1.Best_Books_Ever?page=2']

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
		books = response.xpath('//*[@id="all_votes"]/table/tr').extract()
		# i=0
		for book in books:
			ranking = Selector(text=book).xpath('//td[@class="number"]/text()').extract()[0]
			ranking = self.verify(ranking)

			totalscore = Selector(text=book).xpath('//span[@class="smallText uitext"]/a/text()').extract()[0]
			totalscore = re.search('.*:\s(\d*,*\d*,*\d*)', totalscore).group(1)
			totalscore = self.verify(totalscore)

			url = Selector(text=book).xpath('//a[@class="bookTitle"]/@href').extract()
			pageurl = 'https://www.goodreads.com' + url[0]

			item = BestreadsItem()
			item['Ranking'] = ranking
			item['TotalScore'] = totalscore

			request = scrapy.Request(pageurl, callback=self.parse_each)
			request.meta['item'] = item
			yield request
			# i+=1
			# if i==1:
			# 	break


	def parse_each(self, response):
		item = response.meta['item']

		Title = response.xpath('//div[@class="last col"]/h1/text()').extract_first()
		Title = Title.strip()
		Title = self.verify(Title)
		
		Author = response.xpath('//div[@class="last col"]/div/span/a/span/text()').extract_first()
		Author = self.verify(Author)

		Score = response.xpath('//span[@class="average"]/text()').extract_first()
		Score = self.verify(Score)

		NumberOfRating = response.xpath('//a[@class="actionLinkLite votes"]/span/@title').extract_first()
		NumberOfRating = self.verify(NumberOfRating)

		NumberOfReviews = response.xpath('//a[@class="actionLinkLite"]/span/span/@title').extract_first()
		NumberOfReviews = self.verify(NumberOfReviews)

		NumberOfPages = response.xpath('//span[@itemprop="numberOfPages"]/text()').extract_first()
		NumberOfPages = re.search('(\d*)\s*pages', NumberOfPages).group(1)
		NumberOfPages = self.verify(NumberOfPages)

		# looking only at the main genre (i.e. genre under which most of users classified the book)
		MainGenre = response.xpath('//a[@class="actionLinkLite bookPageGenreLink"]/text()').extract()
		MainGenre = self.verify(MainGenre)

		# list of all the genres
		allgenres = response.xpath('//div[@class="bigBoxBody"]/div/div/div[@class="left"]').extract()
		AllGenres = []
		# i=0
		for genre in allgenres:
			genre_path = Selector(text = genre).xpath('//a[@class="actionLinkLite bookPageGenreLink"]/text()').extract()
			AllGenres.append(genre_path)
			# i+=1
			# if i==1:
			# 	break
		AllGenres = reduce(lambda x,y: x+y, AllGenres)
		AllGenres = ','.join(AllGenres).strip()
		AllGenres = self.verify(AllGenres)

		Description = response.xpath('//div[@class="readable stacked"]/span/text()').extract_first()
		Description = ''.join(Description).strip()
		Description = self.verify(Description)

		Year = response.xpath('//div[@class="uitext stacked darkGreyText"]/div/text()').extract()
		Year = ''.join(Year)
		try:
			Year = re.search('.*(\d{4}).*', Year ).group(1)
		except:
			Year = ''
		finally:
			Year = self.verify(Year)

		BookCover = response.xpath('//div[@class="bookCoverContainer"]/div/a/@href').extract()
		BookCoverURL = ['https://www.goodreads.com'+ id_ for id_ in BookCover]
		BookCoverURL = self.verify(BookCoverURL)

		# long reviews have a different path than short reviews. Need to account for that
		reviews = response.xpath('//*[@id="bookReviews"]/div[@class="friendReviews elementListBrown"]').extract()
		Reviews = []
		# i=0
		for review in reviews:
			review_path = Selector(text = review).xpath('//span[@class="readable"]/span[@style="display:none"]/text()').extract()
			if review_path == []:
				review_path = Selector(text = review).xpath('//span[@class="readable"]/span/text()').extract()
				Reviews.append(review_path)
			else:
				Reviews.append(review_path)
			# i+=1
			# if i==1:
			# 	break
		# concatenating all reviews together and grabbing the first few paragraphs. Note: only looking at top 30 reviews.
		Reviews = reduce(lambda x,y: x+y, Reviews)
		Reviews = ''.join(Reviews).strip()
		Reviews = self.verify(Reviews)

		# # concatenating all reviews together and grabbing the first few paragraphs. Note: only looking at top 30 reviews.
		# Reviews = response.xpath('//div[@class="reviewText stacked"]/span/span[1]/text()').extract()
		# Reviews = ''.join(Reviews).strip()
		# Reviews = self.verify(Reviews)

		item['Title'] = Title
		item['Author'] = Author
		item['Score'] = Score
		item['NumberOfRating'] = NumberOfRating
		item['NumberOfReviews'] = NumberOfReviews
		item['NumberOfPages'] = NumberOfPages
		item['MainGenre'] = MainGenre
		item['AllGenres'] = AllGenres
		item['Description'] = Description
		item['Year'] = Year
		item['BookCoverURL'] = BookCoverURL
		item['Reviews'] = Reviews

		yield item