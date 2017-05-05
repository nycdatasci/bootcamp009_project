import discogs_client

## Authorize access to discogs database
user_agent  = "MusicTrendsVisualization/0.1"
discogsclient  =  discogs_client.Client(user_agent, user_token= "JSlyFrOCGjJdDepKlrRlGVhLqEUiHDRsgHGyMYYW")

years = ["2014", "2015", "2016", "2017"]

for year in years:
    result  = discogsclient.search(genre='Electronic', year=year, format='Vinyl')
    print len(result)



# for release in result:
#     print release.labels[0]
#     print release.format




# hostom = discogsclient.label('HOSTOM')
#
#
# print hostom
