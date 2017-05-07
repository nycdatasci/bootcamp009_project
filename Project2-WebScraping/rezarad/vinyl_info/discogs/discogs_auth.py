from ConfigParser import SafeConfigParser
import discogs_client

class Discogs_Auth(object):

    def authorizeAPI(self):
        config = SafeConfigParser()
        config.read('config.ini')

        user_token = config.get('discogs', 'user_token')

        # getfloat() raises an exception if the value is not a float
        a_float = config.getfloat('discogs', 'a_float')
        # getint() and getboolean() also do this for their respective types
        an_int = config.getint('discogs', 'an_int')

        # Authorize access to discogs database
        user_agent = "MusicTrendsVisualization/0.1"
        discogsclient = discogs_client.Client(user_agent, user_token = user_token)

        def getData(self):
            years = ["2014", "2015", "2016", "2017"]

            for year in years:
                result = discogsclient.search(genre='Electronic', year=year, format='Vinyl')
                yield len(result)


#
#
#
#
#
# # for release in result:
# #     print release.labels[0]
# #     print release.format
#
#
#
#
# # hostom = discogsclient.label('HOSTOM')
# #
# #
# # print hostom
