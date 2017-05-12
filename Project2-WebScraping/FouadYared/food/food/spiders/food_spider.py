from food.items import FoodItem
import scrapy
class food_spider(scrapy.Spider):
    name = 'food'
    allowed_urls = ['http://www.ewg.org/']
    start_urls = ['http://www.ewg.org/foodscores']

    def verify(self, content):
        if isinstance(content, list):
            #checks to see if content is a list
            if len(content) > 0:
                content = content[0]
                # convert unicode to str
                return content.encode('ascii', 'ignore')
            else:
                return ""
        elif (content is None):
            # convert unicode to str
            return "test"
        else:
            return content.encode('ascii', 'ignore')

    def parse(self, response):
        baby_food_url = response.xpath('//div[@id="dropdown_menu"]/ul/li/a/@href').extract()[0]
        candy_food_url = response.xpath('//div[@id="dropdown_menu"]/ul/li/a/@href').extract()[4]
        eggs_url = response.xpath('//div[@id="dropdown_menu"]/ul/li/a/@href').extract()[11]
        tofu_meatAlt_url = response.xpath('//div[@id="dropdown_menu"]/ul/li/a/@href').extract()[22]

        # not all the urls are in the same place.
        # this joins the four urls that are separate categories with all the others
        subcategories_url = response.xpath('//div[@id="dropdown_menu"]/ul/li/ul/li/a/@href').extract()
        list1 = [baby_food_url, candy_food_url, eggs_url, tofu_meatAlt_url]
        url_list = list1 + subcategories_url

        import itertools
        pageurl = ['http://www.ewg.org' + l for l in url_list]

        for item_url in pageurl:
            for i in range(1, 100):
                try:
                    url_to_parse = item_url + '&page={}&per_page=12&type=products'.format(i)
                    yield scrapy.Request(url_to_parse, callback=self.parse_top)
                except:
                    print("Doesn't work...")
                    break

    def parse_top(self, response):
        food_categories_text = response.xpath('//div[@id="dropdown_menu"]/ul/li/a/text()').extract()

        food_id = response.xpath('//div[@class="ind_result_text fleft"]/a/@href').extract()

        food_links = ['http://www.ewg.org' + id for id in food_id]

        for link in food_links:
            yield scrapy.Request(link, callback=self.parse_each, meta={'food_categories_text':food_categories_text})

    def parse_each(self, response):
        # variable set 1/3
        food_categories_text = response.meta['food_categories_text']
        food_categories_text = self.verify(food_categories_text)

        # url_to_parse = response.meta['url_to_parse']
        # url_to_parse = self.verify(url_to_parse)

        food_rating = response.xpath('//div[@class="updated_score fleft"]/img/@src').extract_first()
        food_rating = self.verify(food_rating)

        food_name = response.xpath('//h1[@class="truncate_title_specific_product_page"]/text()').extract_first()
        food_name = self.verify(food_name)

        food_category_text = response.xpath('//div[@class="product_header product_header_updated dont_hide_on_mobile loaction_views_food_products_show"]/div/a[2]/text()').extract_first()
        food_category_text = self.verify(food_category_text)

        food_subcategory_text = response.xpath('//div[@class="product_header product_header_updated dont_hide_on_mobile loaction_views_food_products_show"]/div/a[3]/text()').extract_first()
        food_subcategory_text = self.verify(food_subcategory_text)

        # variable set 2/3
        all_comments = str(response.xpath('//div[@class="gages_col_individual zeropadding bottom_space"][1]/p/text()[1]').extract())
        all_comments = self.verify(all_comments)

        pos_neg_comment = str(response.xpath('//div[@class="gages_col_individual zeropadding bottom_space"][1]/p/img/@alt').extract())
        pos_neg_comment = self.verify(pos_neg_comment)

        ingredients = response.xpath('//div[@class="gages_col_individual zeropadding bottom_space"][3]/p/text()[1]').extract()
        ingredients = self.verify(ingredients)

        certified_organic = response.xpath('//div[@class="gages_col_individual zeropadding bottom_space"][2]/p/text()[1]').extract_first()
        certified_organic = self.verify(certified_organic)

        allergens = str(response.xpath('//div[@class="gages_col_individual zeropadding bottom_space"][2]/p/text()[1]').extract_first())
        allergens = self.verify(allergens)

        serving_amount = response.xpath('//thead[@class="performance-facts__header performance-facts__header2"]/tr/th/span/text()').extract_first()
        serving_amount = self.verify(serving_amount)

        serving_unit = response.xpath('//thead[@class="performance-facts__header performance-facts__header2"]/tr/th/text()[2]').extract_first()
        serving_unit = self.verify(serving_unit)

        calories = response.xpath('//th[@class="cal2 "]/div/text()').extract_first()
        calories = self.verify(calories)

        # variable set 3/3
        nutri_fat_perc = response.xpath('//table[@class="nutrient_table"]//span[@class="update_on_ss_change"]/text()').extract_first()
        nutri_fat_perc = self.verify(nutri_fat_perc)

        nutri_fat_num = response.xpath('//table[@class="nutrient_table"]//span[@class="update_on_ss_change"]/text()').extract()[1]
        nutri_fat_num = self.verify(nutri_fat_num)

        nutri_carbs_perc = response.xpath('//table[@class="nutrient_table"]//span[@class="update_on_ss_change"]/text()').extract()[2]
        nutri_carbs_perc = self.verify(nutri_carbs_perc)

        nutri_carbs_num = response.xpath('//table[@class="nutrient_table"]//span[@class="update_on_ss_change"]/text()').extract()[3]
        nutri_carbs_num = self.verify(nutri_carbs_num)

        nutri_sugar_num = response.xpath('//table[@class="nutrient_table"]//span[@class="update_on_ss_change"]/text()').extract()[4]
        nutri_sugar_num = self.verify(nutri_sugar_num)

        nutri_protein_perc = response.xpath('//table[@class="nutrient_table"]//span[@class="update_on_ss_change"]/text()').extract()[5]
        nutri_protein_perc = self.verify(nutri_protein_perc)

        nutri_protein_num = response.xpath('//table[@class="nutrient_table"]//span[@class="update_on_ss_change"]/text()').extract()[6]
        nutri_protein_num = self.verify(nutri_protein_num)

        nutri_perc_nutriName = str(response.xpath('//table[@class="nutrient_table"]//span[1]/text()').extract())
        nutri_perc_nutriName = self.verify(nutri_perc_nutriName)

        nutri_addedSugars = str(response.xpath('//tr[@class="thick-end"]//td[@class]/text()').extract())
        nutri_addedSugars = self.verify(nutri_addedSugars)

        rows = response.xpath('//table[@class="nutrient_table"]//tr')

        dic = {}

        for row in rows[1:]:
            key = row.xpath("./td[2]/span/text()").extract_first()
            value = row.xpath("./td[1]/span/text()").extract_first()
            try:
                key = key.strip()
                dic[key] = value
            except:
                continue

        item = FoodItem()
        item['food_categories_text'] = food_categories_text
        item['food_rating'] = food_rating
        item['food_name'] = food_name
        item['food_category_text'] = food_category_text
        item['food_subcategory_text'] = food_subcategory_text
        item['all_comments'] = all_comments
        item['pos_neg_comment'] = pos_neg_comment
        item['ingredients'] = ingredients
        item['certified_organic'] = certified_organic
        item['allergens'] = allergens
        item['serving_amount'] = serving_amount
        item['serving_unit'] = serving_unit
        item['calories'] = calories
        item['nutri_fat_perc'] = nutri_fat_perc
        item['nutri_fat_num'] = nutri_fat_num
        item['nutri_carbs_perc'] = nutri_carbs_perc
        item['nutri_carbs_num'] = nutri_carbs_num
        item['nutri_sugar_num'] = nutri_sugar_num
        item['nutri_protein_perc'] = nutri_protein_perc
        item['nutri_protein_num'] = nutri_protein_num
        item['nutri_perc_nutriName'] = nutri_perc_nutriName
        item['nutri_addedSugars'] = nutri_addedSugars

        item['Total_Fat'] = dic.get('Total Fat', '')
        item['Total_Carbs'] = dic.get('Total Carbs', '')
        item['Sugars'] = dic.get('Sugars', '')
        item['Protein'] = dic.get('Protein', '')
        item['Saturated_Fat'] = dic.get('Saturated Fat', '')
        item['Cholesterol'] = dic.get('Cholesterol', '')
        item['Sodium'] = dic.get('Sodium', '')
        item['Added_Sugar_Ingredients'] = dic.get('Added Sugar Ingredients', '')
        item['Dietary_Fiber'] = dic.get('Dietary Fiber', '')
        item['Vitamin_A'] = dic.get('Vitamin A', '')
        item['Vitamin_C'] = dic.get('Vitamin C', '')
        item['Calcium'] = dic.get('Calcium', '')
        item['Iron'] = dic.get('Iron', '')
        item['Potassium'] = dic.get('Potassium', '')

        yield item