#This python script interprets all scraped product pages and saves in a consistent format
#The raggedness of the data made it very difficult to generalize, a template spec list was required

import os
import pandas as pd
from bs4 import BeautifulSoup, NavigableString, Comment
import re
import collections

template_output_specs = [('color',''), #All
                         ('manufacturer',''), #All
                         ('part #',''), #All
                         ('type',''), #Most
                         ('model',''), #All
                         ('motherboard compatibility',''), #Case
                         ('data width',''), #CPU
                         ('socket',''), #CPU
                         ('operating frequency',''), #CPU
                         ('max turbo frequency',''), #CPU
                         ('cores',''), #CPU
                         ('l1 cache',''), #CPU
                         ('l2 cache',''), #CPU
                         ('l3 cache',''), #CPU
                         ('lithography',''), #CPU
                         ('thermal design power',''), #CPU
                         ('includes cpu cooler',''), #CPU
                         ('hyper-threading',''), #CPU
                         ('maximum supported memory',''), #CPU, MOBO
                         ('integrated graphics',''), #CPU
                         ('internal 2.5" bays',''), #Case
                         ('internal 3.5" bays',''), #Case
                         ('external 5.25" bays',''), #Case
                         ('external 3.5" bays',''), #Case
                         ('includes power supply',''), #Case
                         ('front panel usb 3.0 ports',''), #Case
                         ('maximum video card length',''), #Case
                         ('capacity',''), #Storage
                         ('interface',''), #Storage
                         ('form factor',''), #Storage
                         ('buffer cache',''), #Storage
                         ('price/gb',''), #Storage
                         ('height',''), #Cooler
                         ('radiator size',''),
                         ('noise level',''), #Cooler
                         ('supported sockets',''), #Cooler
                         ('fan rpm',''),
                         ('liquid cooled',''), #Cooler
                         ('fanless',''), #Cooler, PSU, GPU
                         ('wattage',''), #PSU
                         ('modular',''), #PSU
                         ('efficiency',''), #PSU
                         ('efficiency certification',''), #PSU
                         ('output',''), #PSU
                         ('pci-express 6+2-pin connectors',''), #PSU
                         ('fans',''), #PSU
                         ('chipset',''), #GPU
                         ('video ram',''), #GPU
                         ('interface',''), #GPU
                         ('sli support',''), #GPU
                         ('memory size',''),
                         ('memory type',''), #GPU, MOBO
                         ('crossfire support',''), #GPU
                         ('core clock',''),
                         ('boost clock',''),
                         ('dvi-d dual-link',''),
                         ('dvi-i dual-link',''),
                         ('hdmi',''),
                         ('mini-hdmi',''),
                         ('displayport',''),
                         ('mini-displayport',''),
                         ('expansion slot width',''),
                         ('length',''),
                         ('tdp',''),
                         ('supports g-sync',''), #GPU
                         ('cpu socket',''), #MOBO
                         ('memory slots',''),
                         ('raid support',''),
                         ('sata 6 gb/s',''),
                         ('sata express',''),
                         ('onboard ethernet',''),
                         ('onboard usb 3.0 header(s)',''),
                         ('u.2',''),
                         ('onboard video',''), #MOBO
                         ('speed',''), #MEM
                         ('size',''),
                         ('cas latency',''),
                         ('voltage',''),
                         ('heat spreader',''),
                         ('ecc',''),
                         ('registered',''), #MEM
                         ('prod_name',''),
                         ('prod_price', ''),
                         ('cache',''),
                         ('nand flash type',''),
                         ('radiator size',''),
                         ('noise level',''), #Cooler
                         ('supported sockets',''), #Cooler
                         ('fan rpm',''),
                         ('liquid cooled',''), #Cooler
                         ('l2 cache 2',''),
                         ('l3 cache',''),
                         ('front panel usb 3.0 ports',''),
                         ('dimensions','')
    ]

first_line = '{}, prod_type, rating_val, rating_n'.format(', '.join(str(x) for x in collections.OrderedDict(template_output_specs).keys()))

os.chdir('./scraped_html')
for i in range(1,2297):
    file_name = 'html_output-{}.txt'.format(i)
    print file_name
    spec_names = []
    spec_vals = []
    b = BeautifulSoup(open(file_name), 'html.parser')

    output_specs = template_output_specs[:]
    output_specs = collections.OrderedDict(output_specs)

    prod_type = b.find("h4", attrs={"class":"kind"}).text.encode('ascii', 'ignore')
    rating_val = b.find("span", attrs={"itemprop":"ratingValue"}).text.encode('ascii', 'ignore')
    rating_n = b.find("span", attrs={"itemprop":"ratingCount"}).text.encode('ascii', 'ignore')
    spec_finder = b.find("div", attrs={"class":"specs block"}).findAll("h4")

    spec_text = []
    for spec_name in spec_finder:
        spec_text.append(spec_name.text.encode('ascii','ignore').strip().lower())

    for output_spec in output_specs:
        if output_spec in spec_text:
            for spec_name in spec_finder:
                if spec_name.text.encode('ascii', 'ignore').lower() == output_spec:
                    temp = spec_name.next_sibling.strip().encode('ascii', 'ignore')
                    temp = re.sub(', ','-', temp)
                    output_specs[output_spec] = temp

    spec_names_str = ', '.join(str(x) for x in output_specs.keys())

    
    spec_vals_str = ', '.join(str(x) for x in output_specs.values())
    spec_vals_str = '{}, {}, {}, {}'.format(spec_vals_str, prod_type, rating_val, rating_n)

    with open('output-final.csv', 'a') as out_file:
        if i == 1:
            out_file.write('{}\n'.format(first_line))
        out_file.write('%s\n' % spec_vals_str)
    out_file.close()
    




