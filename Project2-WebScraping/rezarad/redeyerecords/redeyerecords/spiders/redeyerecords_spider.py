from redeyerecords.items import RedeyeItem
import scrapy

class redeyerecords_spider(scrapy.Spider):
    name = 'redeyerecords'

    def start_requests(self):
        urls = []
        genres  = ['house','techno-electro']
        sections = ['new-releases','sale-section','super-sale-section','back-catalogue']
        page_nums = range(1,62)

        for genre in genres:
            for section in sections:
                urls  = urls + ["https://www.redeyerecords.co.uk/{0}/{1}/page_{2}".format(genre,section,page) for page in page_nums]

        for url in urls:
            yield scrapy.Request(url, callback=self.parse)

    def parse(self, response):

        artist_releases = response.xpath('//div[@class="relArtist plArtist"]/text()').extract()
        tracks = response.xpath('//div[@class="relTrack plTrack"]/text()').extract()
        label = response.xpath('//div[@class="relLabel"]/a/text()').extract()
        front_cover = response.xpath('//div[@class="relLabel"]/a/text()').extract()
        catalog_num = response.xpath('//div[@class="relCat"]/text()').extract()
        price = response.xpath('//div[@class="relInfo relInfoMgn relInfoPrice"]/text()').extract()
        available = response.xpath('//div[starts-with(@id, "atb")]//*/text()').extract()

        item = RedeyeItem()
        for i, el in enumerate(artist_releases):
            item['artist'] = artist_releases[i]
            item['release'] =  artist_releases[i]
            item['tracks'] = tracks[i]
            item['label'] = label[i]
            item['front_cover'] = front_cover[i]
            item['catalog_num'] = catalog_num[i]
            item['price'] = price[i]
            item['available'] = available[i]
            yield item
