from deejay_spider.items import DeejayItem
import scrapy

class redeye_spider(scrapy.Spider):
    name = 'redeye'
    allowed_urls = ['https://www.redeyerecords.co.uk/']
    start_urls = ['https://www.redeyerecords.co.uk/']
    table_urls = []

    def parse(self, response):
        genres  = ['house','techno-electro']
        sections = ['new-releases','sale-section','super-sale-section','back-catalogue']
        page_nums = range(1,61)

        for genre in genres:
            for section in sections:
                table_urls  = table_urls + ["https://www.redeyerecords.co.uk/{0}/{1}/page_{2}".format(genre,section,page) for page in page_nums]

        for url in table_urls
            yield scrapy.Request(url, callback=self.parse_releases)

    def parse_releases(self, response):
        artist = response.xpath('//div[@class="relArtist plArtist"]/text()').extract()
        tracks = response.xpath('//div[@class="relTrack plTrack"]/text()').extract()
        label = response.xpath('//div[@class="relLabel"]/a/text()').extract()
        front_cover = response.xpath('//div[@class="relLabel"]/a/text()').extract()
        catalog_num = response.xpath('//div[@class="relCat"]/text()').extract()
        price = response.xpath('//div[@class="relInfo relInfoMgn relInfoPrice"]/text()').extract()
        available = response.xpath('//div[starts-with(@id, "atb")]//*/text()').extract()
