from deejay.items import DeejayReleaseItem
import scrapy
import pandas as pd


class DeejayReleasesSpider(scrapy.Spider):
    name = 'deejay_releases_spider'
    # import label urls
    deejay_csv = pd.read_csv('deejay.csv')
    start_urls = ['https://www.deejay.de/content.php?filterChange=1&param=/{0}/page_1/media_vinyl'.format(label) for label in deejay_csv['label_urls']]

    def verify(self, content):
        if isinstance(content, list):
            if len(content) > 0:
                content = content[0]
                return content.encode('utf-8', 'ignore')
            else:
                return ""
        else:
            return content.encode('utf-8', 'ignore')

    def parse(self, response):

        release = response.xpath('//h3[@class = "title"]/a/text()').extract()
        artist = response.xpath('//div/h2[@class = "artist"]//*//a/text()').extract()
        catalog_num = response.xpath('//div[@class = "label"]/*[1]/text()').extract()
        label = response.xpath('//div[@class = "label"]/*[3]/text()').extract()
        release_date = response.xpath('//div[@class = "date"]/text()').extract()
        price = response.xpath('//div[@class = "kaufen"]/*/text()').extract()
        available = response.xpath('//div[@class = "order"]/div[1]/@class').extract()

        for i, rel in enumerate(release):
            print i

            item = DeejayReleaseItem()
            item['release'] = release[i]
            item['artist'] = artist[i]
            item['catalog_num'] = catalog_num[i]
            item['label'] = label[i]
            item['release_date'] = release_date[i]
            item['price'] = price[i]
            item['available'] = available[i]
            yield item
