from redeyerecords.items import RedeyeItem
import scrapy
import re

# >>>>>>>>> You can have multiple spider files in the same project. <<<<<<<<<
# >>>>>>>>> No need to create a brand new project for each spider. <<<<<<<<<<
class redeyerecords_spider(scrapy.Spider):
    name = 'redeyerecords'
    start_urls = []
    genres  = ['house-disco','techno-electro']
    sections = ['new-releases','sale-section','super-sale-section','back-catalogue']
    page_nums = range(1,62)

    for genre in genres:
        for section in sections:
            start_urls  = start_urls + ["https://www.redeyerecords.co.uk/{0}/{1}/page-{2}".format(genre,section,page) for page in page_nums]

    def parse(self, response):

        artist_releases = response.xpath('//div[@class="relArtist plArtist"]/text()').extract()
        tracks = response.xpath('//div[@class="relTrack plTrack"]/text()').extract()
        label = response.xpath('//div[@class="relLabel"]/a/text()').extract()
        front_cover = response.xpath('//img[@class="relArt plArt"]/@src').extract()
        catalog_num = response.xpath('//div[@class="relCat"]/text()').extract()
        price = response.xpath('//div[@class="relInfo relInfoMgn relInfoPrice"]/text()').extract()
        available = response.xpath('//div[starts-with(@id, "atb")]/text() | //div[starts-with(@id, "atb")]/a/text()').extract()
        link = response.xpath('//div[@class="relInfo relInfoMgn"][1]/a/@href').extract()


        for i, el in enumerate(artist_releases):
            print i

            item = RedeyeItem()
            item['artist'] = re.split(" - ", artist_releases[i],)
            item['release'] =  re.split(" - ", artist_releases[i])
            item['tracks'] = tracks[i]
            item['label'] = label[i]
            item['front_cover'] = front_cover[i]
            item['catalog_num'] = catalog_num[i]
            item['price'] = price[i]
            item['available'] = available[i]
            item['link'] = link[i]

            yield item
