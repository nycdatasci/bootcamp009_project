
import scrapy
from yahoofinance.items import YahooFinanceItem


class yahoofinance_spider(scrapy.Spider):
    name = 'yahoofinance'
    allowed_urls = ['https://finance.yahoo.com/']
    start_urls = ['https://finance.yahoo.com/quote/TSLA/options?p=TSLA']

    def verify(self, content):
        if isinstance(content, list):
             if len(content) > 0:
                 content = content[0]
                 # convert unicode to str
                 return content.encode('ascii','ignore')
             else:
                 return ""
        else:
            return content.encode('ascii','ignore')

    def parse(self, response):
        optiontype = 'call'
        rows = response.xpath('//table[@class="calls table-bordered W(100%) Pos(r) Bd(0) Pt(0) list-options"]//tr')

        # >>>>>>> It is better to iterate through the rows list like `for row in rows` instead of using index. <<<<<<<<
        # >>>>>>> Then you can use relative path and not to worry about the index anymore. <<<<<<<<<<<<
        for i in range(1, len(rows)):

            strike =       rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[1]/div[2]/table/tbody/tr[' + str(i) + ']/td[1]//text()').extract_first()
            contractname = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[1]/div[2]/table/tbody/tr['+ str(i) + ']/td[2]//text()').extract_first()
            lastprice = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[1]/div[2]/table/tbody/tr[' + str(i) + ']/td[3]//text()').extract_first()
            bid = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[1]/div[2]/table/tbody/tr[' + str(i) + ']/td[4]//text()').extract_first()
            ask = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[1]/div[2]/table/tbody/tr[' + str(i) + ']/td[5]//text()').extract_first()
            change = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[1]/div[2]/table/tbody/tr[' + str(i) + ']/td[6]//text()').extract_first()
            changeperc = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[1]/div[2]/table/tbody/tr[' + str(i)+ ']/td[7]//text()').extract_first()
            volumn = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[1]/div[2]/table/tbody/tr[' + str(i) + ']/td[8]//text()').extract_first()
            openinterest = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[1]/div[2]/table/tbody/tr[' + str(i) + ']/td[9]//text()').extract_first()
            impliedvolatility = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[1]/div[2]/table/tbody/tr[' + str(i) + ']/td[10]//text()').extract_first()


            item = YahooFinanceItem()
            item['optiontype'] = optiontype
            item['strike'] = self.verify(strike)
            item['contractname'] = self.verify(contractname)
            item['lastprice'] = self.verify(lastprice)
            item['bid'] = self.verify(bid)
            item['ask'] = self.verify(ask)
            item['change'] = self.verify(change)
            item['changeperc'] = self.verify(changeperc)
            item['volumn'] = self.verify(volumn)
            item['openinterest'] = self.verify(openinterest)
            item['impliedvolatility'] = self.verify(impliedvolatility)


            yield item

        optiontype = 'put'
        rows = response.xpath('//table[@class="puts table-bordered W(100%) Pos(r) list-options"]//tr')

        # >>>>>>>>>>> Why repeat the same code again? <<<<<<<<<<
        for i in range(1, len(rows)):


            strike =       rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[2]/div[2]/table/tbody/tr[' + str(i) + ']/td[1]//text()').extract_first()
            contractname = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[2]/div[2]/table/tbody/tr[' + str(i) + ']/td[2]//text()').extract_first()
            lastprice = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[2]/div[2]/table/tbody/tr[' + str(i) + ']/td[3]//text()').extract_first()
            bid = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[2]/div[2]/table/tbody/tr[' + str(i) + ']/td[4]//text()').extract_first()
            ask = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[2]/div[2]/table/tbody/tr[' + str(i) + ']/td[5]//text()').extract_first()
            change = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[2]/div[2]/table/tbody/tr[' + str(i) + ']/td[6]//text()').extract_first()
            changeperc = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[2]/div[2]/table/tbody/tr[' + str(i) + ']/td[7]//text()').extract_first()
            volumn = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[2]/div[2]/table/tbody/tr[' + str(i) + ']/td[8]//text()').extract_first()
            openinterest = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[2]/div[2]/table/tbody/tr[' + str(i) + ']/td[9]//text()').extract_first()
            impliedvolatility = rows[i].xpath('//*[@id="quote-leaf-comp"]/section/section[2]/div[2]/table/tbody/tr[' + str(i) + ']/td[10]//text()').extract_first()


            item = YahooFinanceItem()
            item['optiontype'] = optiontype
            item['strike'] = self.verify(strike)
            item['contractname'] = self.verify(contractname)
            item['lastprice'] = self.verify(lastprice)
            item['bid'] = self.verify(bid)
            item['ask'] = self.verify(ask)
            item['change'] = self.verify(change)
            item['changeperc'] = self.verify(changeperc)
            item['volumn'] = self.verify(volumn)
            item['openinterest'] = self.verify(openinterest)
            item['impliedvolatility'] = self.verify(impliedvolatility)


            yield item
