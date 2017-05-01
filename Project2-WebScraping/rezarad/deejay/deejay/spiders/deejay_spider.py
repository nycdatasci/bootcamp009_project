from deejay_spider.items import DeejayItem
import scrapy

class deejay_spider(scrapy.Spider):
    name = 'deejay'
    allowed_urls = ['https://www.deejay.de/']
    start_urls = ['https://www.deejay.de/m_All/sm_Labels']

def parse(self, response):
    # url = response.xpath('//*[@id="myIframe"]/@src').extract_first()
    page_nums = range(1,291)
    table_urls  = ['https://www.deejay.de/content.php/?param=/m_All/sm_Labels/page_{0}'.format(page) for page in page_nums]

    for url in table_urls
        yield scrapy.Request(url, callback=self.parse_labels)

def parse_labels(self, response):
    labels  = response.xpath('//td[@class="tab31c"]/div/span/a/text()').extract()
    labels = [label.strip() for label in labels]
    countries = response.xpath('//div[@class="relation"]/span/img/@alt').extract()
    last_release = response.xpath('//td[@class="tab32"]/div/span/text()').extract()
    next_release = response.xpath('//td[@class="tab33"]/div/span/text()').extract()
    article = response.xpath('//ul[@class="information"]/li[1]/text()').extract()
    available = response.xpath('//ul[@class="information"]/li[2]/text()').extract()
    vinyl = response.xpath('//ul[@class="information"]/li[3]/text()').extract()
    label_img_url = response.xpath('//td[@class="tab31"]/div/img/@src').extract()
    label_urls = response.xpath('//div[@class="relation"]/span/a/@href').extract()

    label_links = ['https://www.deejay.de/content.php/?param=/'+ url for url in label_urls]

    for url in label_links
        yield scrapy.Request(url, callback=self.parse_releases)

    def parse_releases(self, response):



response.xpath('//div[@class="relation"]/div[@class="style"]/text()').extract()
