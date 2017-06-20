#!/usr/bin/python
# -*- coding: utf-8 -*-

import MySQLdb as mdb
import pandas as pd

# read file. maybe make a function for this?
df = pd.read_csv("./predict_output.csv")

def parse_predictions(dataframe):
    '''
    Extract the business id's from the output of the predictions so that
    we can look them up on MySQL DB.
    '''
    biz_list = []
    biz_id = dataframe.iloc[:,0]
    for id in biz_id:
        biz_list.append(id)
    tuple_ = tuple(biz_list)
    return tuple_


def query_mysql(toop):
    '''
    Use the tuple as the list of business ids you want to query.
    '''
    # con = mdb.connect('localhost', #localhost
    # 	'user', # user
    # 	'pw', # pw
    # 	'prod'); # db
    # UNCOMMENT THE ABOVE AND INCLUDE MYSQL CONNECTION INFO

    with con: 

        cur = con.cursor()
        cur.execute(
            """
            SELECT 
            A.*,
            B.final_rating 
            FROM clean_businesses as A left join all_finalscores as B on A.business_id=B.business_id
            WHERE A.business_id in %s
            ORDER BY B.final_rating DESC
            """ % (toop,)) 

        # fetch rows
        rows = cur.fetchall()

        # store column names
        desc = cur.description

        for i in range(0,len(desc)):
            print desc[i][0],

        for row in rows:
            print row


# Test the above.
biz_tuple = parse_predictions(df)
#print biz_tuple
query_mysql(biz_tuple)

# 1. Read in data (business_id's?) from model prediction
# 2. Fix the output so they aren't tuples.
# 3. Improve the god awful lines 23-26.