from ConfigParser import SafeConfigParser

config = SafeConfigParser()
config.read('config.ini')
config.add_section('discogs')
config.set('discogs', 'user_token', 'DSiVpafIZGKrgbyhNmUufrkSfXRhJhfvtTJtWehi')
config.set('discogs', 'consumer_key', 'LbIcqhcLUMWCxKnYmfoB')
config.set('discogs', 'consumer_secret', 'eeHDnTaPcvsqFSZVAIRvVPTgxPqpBzPC')

with open('config.ini', 'w') as f:
    config.write(f)
