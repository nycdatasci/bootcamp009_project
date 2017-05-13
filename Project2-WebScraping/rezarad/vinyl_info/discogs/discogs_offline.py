# connect to database and create table
import sqlite3
import gzip

conn = sqlite3.connect(":memory:")
conn.execute('''create table my_table (value1 integer, value2 integer, xml text)''')

with gzip.open('discogs_20170501_releases.xml.gz', 'rb') as f:
    file_content = f.read()




# read text from file
f = file('discogs/discogs_20170501_releases.xml.gz')
xml_string_from_file = f.read()

# insert text into database
cur = conn.cursor()
cur.execute('''insert into my_table (value1, value2, xml) values (?, ?, ?)''', (23, 42, xml_string_from_file))
cur.commit()

# read from database into variable
cur.execute('''select * from my_table''')
xml_string_from_db = cur.fetchone()[2]
