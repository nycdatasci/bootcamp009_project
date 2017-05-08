from steam_all.items import SteamAllItem
import scrapy
import re


URL = "http://store.steampowered.com/search/?filter=topsellers&page=%d"


class steamall_spider(scrapy.Spider):
    name = 'steam_all'
    allowed_urls = ['http://store.steampowered.com/']
    start_urls = [URL % (i+1) for i in range(318)]

    # def __init__(self):
    #     self.page_number = 1

    def verify(self, content):
        if isinstance(content, list):
            if len(content) > 0:
                content = content[0]
                return content.encode('ascii', 'ignore')
            else:
                return ""
        else:
            return content.encode('ascii', 'ignore')

    def parse(self, response):
        url_list = response.xpath('//div[@id="search_result_container"]/div[2]/a/@href').extract()
        titles = response.xpath('//a/div[@class="responsive_search_name_combined"]/div[@class="col search_name ellipsis"]/span[@class="title"]/text()').extract()

        for i in range(0,len(url_list)):
            url = url_list[i]
            list_title = titles[i]
            app_id = re.findall("http://store.steampowered.com/\w+/(\d+)/.+",url)[0]
            yield scrapy.Request(url, cookies={'birthtime':'0','mature_content':'1','path': '/','domain': 'store.steampowered.com'},
                                 callback=self.parse_each, meta={'url':url,'list_title':list_title, 'app_id':app_id})

    def parse_each(self, response):
        list_title = response.meta['list_title']
        app_id = response.meta['app_id']
        url = response.meta['url']
        title = response.xpath('//div[@class = "apphub_AppName"]/text()').extract_first(default='not-found')
        title = self.verify(title)
        links = response.xpath('//div[@class = "blockbg"]/a').extract()
        no_links = len(links)
        main_link = response.xpath('//div[@class = "blockbg"]/a/@href').extract()[2]
        desc = response.xpath('//div[@class = "game_description_snippet"]/text()').extract_first(default='not-found')
        desc = self.verify(desc)
        genre = response.xpath('//div[@class="details_block"]/b[2]/following-sibling::a/text()').extract()
        publish = response.xpath('//div[@class="details_block"]/b[3]/following-sibling::a/text()').extract()
        if no_links > 3:
            mother_node = response.xpath('//div[@class = "blockbg"]/a[3]/text()').extract_first(default='not_found')
        else:
            mother_node = response.xpath('//div[@class = "blockbg"]/a/span/text()').extract_first(default='not_found')
        mother_node = self.verify(mother_node)
        # >>>>>>>> type is not a good variable name in Python since it is a function at the same time. <<<<<<<<<<
        if no_links > 3:
            type = response.xpath('//div[@class = "blockbg"]/a[4]/text()').extract_first(default='not_found')
        else:
            type = "None"
        user_rating = response.xpath('//div[@itemprop="aggregateRating"]//span[@class = "game_review_summary positive"]/text()').extract_first(default='not-found')
        no_user = response.xpath('//div[@itemprop="aggregateRating"]//span[@class = "nonresponsive_hidden responsive_reviewdesc"]/text()').extract_first(default='not-found')
        Rdate = response.xpath('//span[@class = "date"]/text()').extract_first(default='not-found')
        keywords = response.xpath("//*[@id='game_highlights']/div[1]/div/div[4]/div/div[2]/a[@class='app_tag']/text()").extract()
        game_spcs = response.xpath('//*[@id="category_block"]/div[@class = "game_area_details_specs"]//a[@class="name"]/text()').extract()
        critics_review = response.xpath('//div[@class = "score high"]/text()').extract_first(default='not-found')
        item = SteamAllItem()
        item['genre'] = genre
        item['publish'] = publish
        item['list_title'] = list_title
        item['app_id'] = app_id
        item['type'] = type
        item['title'] = title
        item['mother_node'] = mother_node
        item['url'] = url
        item['main_link'] = main_link
        item['no_links'] = no_links
        item['desc'] = desc
        item['user_rating'] = user_rating
        item['no_user'] = no_user
        item['Rdate'] = Rdate
        item['keywords'] = keywords
        item['game_spcs'] = game_spcs
        item['critics_review'] = critics_review
        yield item
        # self.page_number += 1
        # yield Request(URL % self.page_number,
        #               cookies = {'birthtime':'0','mature_content':'1','path': '/','domain': 'store.steampowered.com'})
