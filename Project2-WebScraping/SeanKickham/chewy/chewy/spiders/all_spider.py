import scrapy
from chewy.items import ChewyItem


class DogFoodSpider(scrapy.Spider):
    name = "chewyall"
    allowed_urls = ['https://www.chewy.com/']
    # >>>>>>>>> Is there anyway to save the list to a local file and load it back? <<<<<<<
    start_urls = ['https://www.chewy.com/b/vitamins-supplements-417', 'https://www.chewy.com/s?rh=c%3A288%2Cc%3A374&page=1', 'https://www.chewy.com/s?rh=c%3A288%2Cc%3A335&page=1', 'https://www.chewy.com/s?rh=c%3A325%2Cc%3A391&page=1', 'https://www.chewy.com/s?rh=c%3A288%2Cc%3A332&page=1', 'https://www.chewy.com/s?rh=c%3A325%2Cc%3A387&page=1', 'https://www.chewy.com/s?rh=c%3A885%2Cc%3A886&page=1', 'https://www.chewy.com/s?rh=c%3A941%2Cc%3A942&page=1', 'https://www.chewy.com/s?rh=c%3A977%2Cc%3A978&page=1', 'https://www.chewy.com/s?rh=c%3A1025%2Cc%3A1026&page=1','https://www.chewy.com/s?rh=c%3A325%2Cc%3A326&page=1', 'https://www.chewy.com/s?rh=c%3A288%2Cc%3A315&page=1', 'https://www.chewy.com/b/perches-toys-967', 'https://www.chewy.com/s?rh=c%3A977%2Cc%3A1005&page=1','https://www.chewy.com/b/dental-healthcare-372','https://www.chewy.com/b/vitamins-supplements-374','https://www.chewy.com/b/cleaning-potty-351','https://www.chewy.com/b/crates-pens-gates-364','https://www.chewy.com/b/beds-mats-365','https://www.chewy.com/b/carriers-travel-371','https://www.chewy.com/b/bowls-feeders-338','https://www.chewy.com/b/grooming-355','https://www.chewy.com/b/flea-tick-381','https://www.chewy.com/b/leashes-collars-344','https://www.chewy.com/b/training-behavior-1449','https://www.chewy.com/b/apparel-accessories-1470','https://www.chewy.com/b/gifts-books-1758','https://www.chewy.com/b/technology-1897','https://www.chewy.com/b/litter-accessories-410','https://www.chewy.com/b/dental-healthcare-415','https://www.chewy.com/b/vitamins-supplements-417','https://www.chewy.com/b/flea-tick-404','https://www.chewy.com/b/training-cleaning-428','https://www.chewy.com/b/crates-pens-gates-424','https://www.chewy.com/b/beds-mats-425','https://www.chewy.com/b/trees-condos-scratchers-456','https://www.chewy.com/b/carriers-travel-454','https://www.chewy.com/b/grooming-432','https://www.chewy.com/b/bowls-feeders-394','https://www.chewy.com/b/leashes-collars-400','https://www.chewy.com/b/gifts-books-1924',
'https://www.chewy.com/s?rh=c%3A885&page=1', 'https://www.chewy.com/s?rh=c%3A941&page=1', 'https://www.chewy.com/s?rh=c%3A977&page=1', 'https://www.chewy.com/s?rh=c%3A1025&page=1', 'https://www.chewy.com/s?rh=c%3A1663&page=1']


    def verify(self, content):     #content is whatever you extracted
        if content is None:
            return ""
        elif isinstance(content, list):     #when would it give a list???? When you do extract instead of extract_first
             if len(content) > 0:
                 content = content[0]     #first element
                 # convert unicode to str
                 return content.encode('ascii','ignore')
             else:        #empty string
                 return ""
        else:
            # convert unicode to str
            return content.encode('ascii','ignore')



    def parse(self, response):    # parse for init page in start_urls

        page = response.xpath('//p[@class="results-count"]/text()').extract_first().split(' ')[0].split('(')[1]
        page = int(page)
        page = (page + 35)/36
        page = str(page)
        category = response.xpath('//div[@class="results-header__title"]//h1/text()').extract_first().strip()
        url_list = response.xpath('//article[@class="product-holder  cw-card cw-card-hover"]//a/@href').extract()
        page_url = ['https://www.chewy.com' + l for l in url_list]


        for url in page_url:
            yield scrapy.Request(url, callback=self.parse_top, meta={'category' : category, 'page':page})
        next_page = str(response.xpath('//a[@class="btn btn-white btn-next"]/@href').extract_first())
        next_page = 'https://www.chewy.com/' + next_page
        yield scrapy.Request(next_page, callback=self.parse)



    def parse_top(self, response):
        category = response.meta['category']
        page = response.meta['page']

        # product info from top
        product_name = response.xpath('//div[@id="brand"]/a/text()').extract_first().strip()
        product_description = response.xpath('//div[@id="product-title"]/h1/text()').extract_first().strip()
        cost = str(response.xpath('//div[@id="pricing"]//p[@class ="price"]/span/text()').extract_first()).strip()
        old_cost = str(response.xpath('//*[@id="pricing"]//li[@class = "list-price"]/p[2]/text()').extract_first()).strip()
        size = str(response.xpath('//*[@id="variation-Size"]/div/span/text()').extract_first()).strip()
        rating = str(response.xpath('//*[@id="ugc-section"]//span[@itemprop = "ratingValue"]/text()').extract_first()).strip()
        no_reviews = str(response.xpath('//*[@id="ugc-section"]//span[@itemprop = "reviewCount"]/a/text()').extract_first()).strip().split(' ')[0]
        percent_rec = response.xpath('//*[@id="ugc-section"]//span[@class="progress-radial__text--percent"]/text()').extract_first()


        # verify
        # >>>>>>> The functionality of the verify function is to convert a unicode to string.<<<<<<
        # >>>>>>> So actually you don't need the previous part. <<<<<<<
        category = self.verify(category)
        page = self.verify(page)
        product_name = self.verify(product_name)
        product_description = self.verify(product_description)
        cost = self.verify(cost)
        old_cost = self.verify(old_cost)
        size = self.verify(size)
        rating = self.verify(rating)
        no_reviews = self.verify(no_reviews)
        percent_rec = self.verify(percent_rec)

        # description list at bottom of page
        k = response.xpath('//*[@id="attributes"]/ul/li/div/text()').extract()
        k = [item.strip() for item in k]
        k = [x.encode('ascii', 'ignore').decode('ascii') for x in k]
        k = [str(x) for x in k]
        # >>>>>> The following two can be combined using regular expression. <<<<<<<
        k = [x.lower().replace(' ', '_') for x in k]
        k = [x.lower().replace('&', 'and') for x in k]
        ll = zip(k[::2], k[1::2])
        ll = dict(ll)


        # yield item
        item = ChewyItem()
        item['product_name'] = product_name
        item['product_description'] = product_description
        item['cost'] = cost
        item['old_cost'] = old_cost
        item['rating'] = rating
        item['no_reviews'] = no_reviews
        item['size'] = size
        item['percent_rec'] = percent_rec
        item['category'] = category
        item['page'] = page

        for i, j in ll.items():
            item[i] = j

        yield item
