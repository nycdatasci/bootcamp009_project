import gzip
with gzip.open("discogs_20170501_releases.xml.gz", 'rb') as f:
    file_content = f.read()
