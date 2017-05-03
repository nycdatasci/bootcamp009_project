with open("nyc_data_science_academy/bootcamp009_project/Project2-WebScraping/rezarad/redeyerecords/redeyerecords/middlewares.py") as fp:
    for i, line in enumerate(fp):
        if "\xe2" in line:
            print i, repr(line)
