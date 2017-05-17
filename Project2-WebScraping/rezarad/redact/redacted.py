import whatapi
from ConfigParser import SafeConfigParser

config = SafeConfigParser()
config.read('../config.ini')

username = config.get('redacted', 'username')
password = config.get('redacted', 'password')

apihandle = whatapi.WhatAPI(username = username, password = password,
                                                        , server='https://redacted.ch')

print 
