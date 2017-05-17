from IMDB.items import ImdbItem
import scrapy

url = "http://www.imdb.com/list/ls057823854?start=%d&view=detail&sort=listorian:asc"

class IMDB_spider(scrapy.Spider):
    name = 'IMDB_spider'
    allowed_urls = ['http://www.imdb.com/']
    start_urls = [url % i for i in range(1,9901,100)]

    def verify(self, content):
        if isinstance(content, list):
            if len(content) > 0:
                content = content[0]
                # convert unicode to str
                return content.encode('ascii', 'ignore')
            else:
                return ""
        else:
            # convert unicode to str
            return content.encode('ascii', 'ignore')

    def parse(self, response):
        rows = response.xpath('//div[@class = "list detail"]//div[@class = "info"]')
        for i in rows:
            name = i.xpath('./b/a/text()').extract_first()
            name_2 = i.xpath('./b/a/@href').extract_first()
            url="http://www.imdb.com/"+ name_2
            yield scrapy.Request(url, callback=self.parse_each, meta={"name":name})

# response.xpath('//div[@class = "pagination"]/a/@href')
    def parse_each(self,response):
        name = response.meta["name"]
        year = response.xpath('//div[@class = "title_wrapper"]//a/text()').extract_first()
        rate = response.xpath('//div[@class = "ratingValue"]//@title').extract_first()
        date_c = response.xpath('//div[@class = "subtext"]//@content').extract()
        length = response.xpath('//div[@class = "subtext"]//@datetime').extract()
        Director = response.xpath('//div[@class = "credit_summary_item"]//span[@class = "itemprop"]/text()').extract_first()
        actors = response.xpath('//div[@class = "credit_summary_item"]//span[@itemprop="actors"]//span[@class = "itemprop"]/text()').extract()
        genre = response.xpath('//div[@class="subtext"]//span[@class="itemprop"]/text()').extract()
        budget = response.xpath('//*[@id="titleDetails"]/div[7]/h4/following-sibling::text()').extract()
        open_week = response.xpath('//*[@id="titleDetails"]/div[8]/h4/following-sibling::text()').extract()
        gross = response.xpath('//*[@id="titleDetails"]/div[9]/h4/following-sibling::text()').extract()
        item = ImdbItem()
        item["name"]=name
        item["year"]=year
        item["rate"]=rate
        item["date_c"]=date_c
        item["length"]=length
        item["Director"] = Director
        item["actors"] = actors
        item["genre"] = genre
        # item["budget"] = budget
        # item["open_week"] = open_week
        # item["gross"] = gross

        dic = {'Budget': 'budget', 'Opening Weekend':'open_week', 'Gross':'gross'}

        attribute = response.xpath('//h3[@class="subheading"]/following-sibling::div[@class="txt-block"]/h4')
        for i in attribute:
            key = i.xpath('./text()').extract_first()[:-1]
            if key in dic.keys():
                value = i.xpath('./following::text()').extract_first()
                item[dic[key]] = value
        yield item

'''     
            url_list = response.xpath('//div[@class="cluster-heading"]/h2/a/@href').extract()
        pageurl = ['https://play.google.com/' + l for l in url_list]

        for url in pageurl:
            yield scrapy.Request(url, callback=self.parse_top)


    def parse_top(self, response):
        top_list = response.xpath('//div[@class="cluster-heading"]/h2/text()').extract_first()
        app_id = response.xpath('//div[@class="card no-rationale square-cover apps small"]/@data-docid').extract()

        app_links = ['https://play.google.com/store/apps/details?id='+ id_ for id_ in app_id]

        for link in app_links:
            yield scrapy.Request(link, callback=self.parse_each, meta={'top_list':top_list})

    def parse_each(self, response):
        top_list = response.meta['top_list']
        name = response.xpath('//div[@class="id-app-title"]/text()').extract_first()
        company = response.xpath('//a[@class="document-subtitle primary"]/span/text()').extract_first()
        category = response.xpath('//a[@class="document-subtitle category"]/span/text()').extract_first()



        reviews = response.xpath('//div[@class="single-review"]')


        for review in reviews:
            content = review.xpath('./div[@class="review-body with-review-wrapper"]/text()').extract()
            content = ''.join(content).strip()
            rating = review.xpath('.//div[@class="tiny-star star-rating-non-editable-container"]/@aria-label').extract_first()

            item = GooglePlayItem()
            item['top_list'] = top_list
            item['name'] = name
            item['company'] = company
            item['content'] = content
            item['rating'] = rating

            yield item
'''