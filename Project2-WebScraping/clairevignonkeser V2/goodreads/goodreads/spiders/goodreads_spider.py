from goodreads.items import GoodreadsItem
import scrapy
import re
from scrapy.selector import Selector

class goodreads_spider(scrapy.Spider):
	name = 'goodreads'
	allowed_urls = ['https://www.goodreads.com/']
	start_urls = ['https://www.goodreads.com/genres']

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
		url_list = response.xpath('//a[@class="actionLinkLite"]/@href').extract()
		pageurl = ['https://www.goodreads.com' + l for l in url_list]

		# i = 0
		for url in pageurl:
			yield scrapy.Request(url, callback=self.parse_top)
			# i+=1
			# if i==1:
			# 	break


	def parse_top(self, response):
		main_genre = response.xpath('//div[@class="genreHeader"]/h1/text()').extract_first()
		main_genre = main_genre.strip()

		book_id = response.xpath('//div[@class="coverWrapper"]/a/@href').extract()

		book_links = ['https://www.goodreads.com'+ id_ for id_ in book_id]

		# i=0
		for link in book_links:
			yield scrapy.Request(link, callback=self.parse_each, meta={'main_genre':main_genre})
			# i+=1
			# if i==1:
			# 	break

	def parse_each(self, response):
		MainGenre = response.meta['main_genre']
		MainGenre = self.verify(MainGenre)

		# >>>>>> I think you might want to verify the variable first and then strip. <<<<<<<<<
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

		Genres = response.xpath('//a[@class="actionLinkLite bookPageGenreLink"]/text()').extract()
		Genres = self.verify(Genres)

		# list of all the genres
		allgenres = response.xpath('//div[@class="bigBoxBody"]/div/div/div[@class="left"]').extract()
		AllGenres = []
		# i=0
		for genre in allgenres:
			genre_path = Selector(text = genre).xpath('//a[@class="actionLinkLite bookPageGenreLink"]/text()').extract()
			AllGenres.append(genre_path)
			# i+=1
			# if i==1:
			#   break
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
			#   break
		# concatenating all reviews together and grabbing the first few paragraphs. Note: only looking at top 30 reviews.
		Reviews = reduce(lambda x,y: x+y, Reviews)
		Reviews = ''.join(Reviews).strip()
		Reviews = self.verify(Reviews)

		# i=0
		# >>>>>>> MainGenre is a string. Why iterate through a string? <<<<<<<<
		# >>>>>>> books is never called later so you can do `for _ in MainGenre:` <<<<<<<<
		for books in MainGenre:
			item = GoodreadsItem()
			item['Title'] = Title
			item['MainGenre'] = MainGenre
			item['Author'] = Author
			item['Score'] = Score
			item['NumberOfRating'] = NumberOfRating
			item['NumberOfReviews'] = NumberOfReviews
			item['NumberOfPages'] = NumberOfPages
			item['Genres'] = Genres
			item['Description'] = Description
			item['Year'] = Year
			item['BookCoverURL'] = BookCoverURL
			item['Reviews'] = Reviews
			item['AllGenres'] = AllGenres


			yield item
			# i+=1
			# if i==1:
			# 	break
