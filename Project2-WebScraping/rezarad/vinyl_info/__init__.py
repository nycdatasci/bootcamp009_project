from ConfigParser import SafeConfigParser
import discogs_client

class vinyl_info(object):

    def __init__(self, name, url):
        self.__name = name
        self.__url = url

    # Create configuration file for API token
    config = SafeConfigParser()
    config.read('config.ini')
    config.add_section('discogs')
    config.set('discogs', 'user_token', 'DSiVpafIZGKrgbyhNmUufrkSfXRhJhfvtTJtWehi')
    config.set('discogs', 'consumer_key', 'LbIcqhcLUMWCxKnYmfoB')
    config.set('discogs', 'consumer_secret', 'eeHDnTaPcvsqFSZVAIRvVPTgxPqpBzPC')

    with open('config.ini', 'w') as f:
        config.write(f)
