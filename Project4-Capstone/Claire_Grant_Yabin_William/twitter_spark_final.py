from __future__ import print_function
import sys
import re
from operator import add 
import pandas as pd
from pyspark.sql.types import StructField, StructType, StringType
from pyspark.sql import Row
from pyspark.sql.types import *
from pyspark.sql import SQLContext
import json
import boto
import boto3
from boto.s3.key import Key
import boto.s3.connection
from pyspark.sql import SparkSession
from pyspark import SparkContext, SparkConf
from pyspark.ml.feature import MinMaxScaler
from pyspark.ml.linalg import Vectors, VectorUDT
from pyspark.sql.functions import *

stopwords = ["a", "about", "above", "above", "across", "after", "afterwards", "again", "against", "all", "almost", "alone", "along", "already", "also","although","always","am","among", "amongst", "amoungst", "amount",  "an", "and", "another", "any","anyhow","anyone","anything","anyway", "anywhere", "are", "around", "as",  "at", "back","be","became", "because","become","becomes", "becoming", "been", "before", "beforehand", "behind", "being", "below", "beside", "besides", "between", "beyond", "bill", "both", "bottom","but", "by", "call", "can", "cannot", "cant", "co", "con", "could", "couldnt", "cry", "de", "describe", "detail", "do", "done", "down", "due", "during", "each", "eg", "eight", "either", "eleven","else", "elsewhere", "empty", "enough", "etc", "even", "ever", "every", "everyone", "everything", "everywhere", "except", "few", "fifteen", "fify", "fill", "find", "fire", "first", "five", "for", "former", "formerly", "forty", "found", "four", "from", "front", "full", "further", "get", "give", "go", "had", "has", "hasnt", "have", "he", "hence", "her", "here", "hereafter", "hereby", "herein", "hereupon", "hers", "herself", "him", "himself", "his", "how", "however", "hundred", "ie", "if", "in", "inc", "indeed", "interest", "into", "is", "it", "its", "itself", "keep", "last", "latter", "latterly", "least", "less", "ltd", "made", "many", "may", "me", "meanwhile", "might", "mill", "mine", "more", "moreover", "most", "mostly", "move", "much", "must", "my", "myself", "name", "namely", "neither", "never", "nevertheless", "next", "nine", "no", "nobody", "none", "noone", "nor", "not", "nothing", "now", "nowhere", "of", "off", "often", "on", "once", "one", "only", "onto", "or", "other", "others", "otherwise", "our", "ours", "ourselves", "out", "over", "own","part", "per", "perhaps", "please", "put", "rather", "re", "same", "see", "seem", "seemed", "seeming", "seems", "serious", "several", "she", "should", "show", "side", "since", "sincere", "six", "sixty", "so", "some", "somehow", "someone", "something", "sometime", "sometimes", "somewhere", "still", "such", "system", "take", "ten", "than", "that", "the", "their", "them", "themselves", "then", "thence", "there", "thereafter", "thereby", "therefore", "therein", "thereupon", "these", "they", "thickv", "thin", "third", "this", "those", "though", "three", "through", "throughout", "thru", "thus", "to", "together", "too", "top", "toward", "towards", "twelve", "twenty", "two", "un", "under", "until", "up", "upon", "us", "very", "via", "was", "we", "well", "were", "what", "whatever", "when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "whereupon", "wherever", "whether", "which", "while", "whither", "who", "whoever", "whole", "whom", "whose", "why", "will", "with", "within", "without", "would", "yet", "you", "your", "yours", "yourself", "yourselves", "the",'i','&amp;','-','']

def sent_class(value1):
  if value1 >-0.4 and value1 <0.4: return 'Neutral'
  elif value1 <= -0.4: return 'Negative'
  elif value1 >= 0.4 : return 'Positive'

def split_line(s): return s.split()

def stopword(i):
  if i in stopwords:
    return ''
  else:
    return i

def main(): 
    conf = SparkConf().setAppName("first")
    sc = SparkContext(conf=conf)
    sc._jsc.hadoopConfiguration().set("fs.s3n.awsAccessKeyId",'xxx')
    sc._jsc.hadoopConfiguration().set("fs.s3n.awsSecretAccessKey",'xxx')
    config_dict = {"fs.s3n.awsAccessKeyId":"xxx",
               "fs.s3n.awsSecretAccessKey":"xxx"}
    bucket = "project4capstones3"
    prefix = "/2017/06/*/*/project*"
    filename = "s3n://{}/{}".format(bucket, prefix)

    rdd = sc.hadoopFile(filename,
                    'org.apache.hadoop.mapred.TextInputFormat',
                    'org.apache.hadoop.io.Text',
                    'org.apache.hadoop.io.LongWritable',
                    conf=config_dict)
    spark = SparkSession.builder.appName("PythonWordCount").config("spark.files.overwrite","true").getOrCreate()

    df = spark.read.json(rdd.map(lambda x: x[1]))
   #  df_writer = pyspark.sql.DataFrameWriter(df)
#     df_writer.saveAsTable('test_table', mode='overwrite')
    data_rm_na = df.filter(df["status_id"]!='None')
    features_of_interest = ["rt_status_user_followers_count", 'rt_status_user_friends_count',\
                        'rt_status_user_statuses_count',\
                        'rt_status_retweet_count',\
                        'rt_status_user_listed_count',
                        'rt_status_user_name',\
                        'rt_status_user_profile_image',\
                        'rt_status_num_user_mentions',\
                        'rt_status_user_id',\
                        'searched_names',\
                        'rt_status_sentMag',\
                        'rt_status_sentScore',\
                        'rt_status_text',\
                        'rt_status_favorite_count']
    df_reduce= data_rm_na.select(features_of_interest)
    df_reduce = df_reduce.withColumn("rt_status_user_followers_count", df_reduce["rt_status_user_followers_count"].cast(IntegerType()))
    df_reduce = df_reduce.withColumn("rt_status_user_friends_count", df_reduce["rt_status_user_friends_count"].cast(IntegerType()))
    df_reduce = df_reduce.withColumn("rt_status_user_statuses_count", df_reduce["rt_status_user_statuses_count"].cast(IntegerType()))
    df_reduce = df_reduce.withColumn("rt_status_retweet_count", df_reduce["rt_status_retweet_count"].cast(IntegerType()))
    df_reduce = df_reduce.withColumn("rt_status_user_listed_count", df_reduce["rt_status_user_listed_count"].cast(IntegerType()))
    df_reduce = df_reduce.withColumn("rt_status_favorite_count", df_reduce["rt_status_favorite_count"].cast(IntegerType()))
    df_reduce = df_reduce.withColumn("rt_status_num_user_mentions", df_reduce["rt_status_num_user_mentions"].cast(IntegerType()))
    # followers_count rescale
    max_user_followers_count = df_reduce.select('rt_status_user_followers_count').rdd.flatMap(list).max()
    df_reduce = df_reduce.withColumn('rescale_rt_status_user_followers_count',df_reduce.rt_status_user_followers_count/max_user_followers_count)
    #listed_count rescale
    max_listed_count = df_reduce.select('rt_status_user_listed_count').rdd.flatMap(list).max()
    df_reduce = df_reduce.withColumn('rescale_rt_status_user_listed_count',df_reduce.rt_status_user_listed_count/max_listed_count)
    #number_of_tweets rescale
    max_user_statuses_count  = df_reduce.select('rt_status_user_statuses_count').rdd.flatMap(list).max()
    df_reduce = df_reduce.withColumn('rescale_rt_status_user_statuses_count',df_reduce.rt_status_user_statuses_count/max_user_statuses_count)
    # retweets_received rescale
    max_retweets_received  = df_reduce.select('rt_status_retweet_count').rdd.flatMap(list).max()
    df_reduce = df_reduce.withColumn('rescale_rt_status_retweet_count',df_reduce.rt_status_retweet_count/max_retweets_received)
    # retweets_received rescale
    max_favorite_count  = df_reduce.select('rt_status_favorite_count').rdd.flatMap(list).max()
    df_reduce = df_reduce.withColumn('rescale_rt_status_favorite_count',df_reduce.rt_status_favorite_count/max_favorite_count)
    df_reduce=df_reduce.withColumn('Influencer_Score', (df_reduce.rescale_rt_status_retweet_count *10.0 + df_reduce.rescale_rt_status_favorite_count * 9.0 + df_reduce.rescale_rt_status_user_followers_count * 6.0 + df_reduce.rescale_rt_status_user_statuses_count * 5.0 + df_reduce.rescale_rt_status_user_listed_count* 4.0)/34.0*10.0)
    df_reduce = df_reduce.withColumn("rt_status_user_id", df_reduce["rt_status_user_id"].cast(FloatType()))

    df_final=df_reduce.groupBy('rt_status_user_id').agg(
        round(max('Influencer_Score'),2).alias('max_influence_score'),
        max('rt_status_retweet_count').alias('max_retweet_count'),
        max('rt_status_user_followers_count').alias('max_follower_count'),
        max('rt_status_user_friends_count').alias('max_friends_count'),
        round(avg('rt_status_sentScore'),2).alias('avg_sentiment'),
        round(avg('rt_status_sentMag'),2).alias('avg_sentMag'),
        first('rt_status_text').alias('status_text'),
        first('rt_status_user_name').alias('user_name'),
        first('rt_status_user_profile_image').alias('profile_image'),
        first('searched_names').alias('search_name'),
        ).sort('max_influence_score',ascending=False)
    print(40*"=")
    df_reduce_udf = udf(sent_class, StringType())
    df_final = df_final.withColumn('sent_class', df_reduce_udf('avg_sentiment')) 
    df_final.createOrReplaceTempView("df_final")
    neg_influence=spark.sql("SELECT * FROM df_final WHERE df_final.sent_class='Negative' LIMIT 5")
    pos_influence=spark.sql("SELECT * FROM df_final WHERE df_final.sent_class='Positive' LIMIT 5")
    neu_influence=spark.sql("SELECT * FROM df_final WHERE df_final.sent_class='Neutral' LIMIT 5")
    # Saving the negative influencer table to RDS
    url_ = "jdbc:mysql://flaskest.csjkhjjygutf.us-east-1.rds.amazonaws.com:3306/flaskdb"
    table_neg_ = "neg_influence"
    table_pos_ = "neu_influence"
    table_neu_ = "pos_influence"
    table_word_neg_  = "neg_word_cloud"
    table_word_pos_ = "pos_word_cloud"
    table_word_neu_ = "neu_word_cloud"

    mode_ = "overwrite"

    neg_influence.write.format("jdbc").option("url", url_)\
    .option("dbtable", table_neg_)\
    .option("driver", "com.mysql.jdbc.Driver")\
    .option("user", "flask")\
    .option("password", "wizjysys")\
    .mode(mode_)\
    .save()

    pos_influence.write.format("jdbc").option("url", url_)\
    .option("dbtable", table_pos_)\
    .option("driver", "com.mysql.jdbc.Driver")\
    .option("user", "flask")\
    .option("password", "wizjysys")\
    .mode(mode_)\
    .save()

    neu_influence.write.format("jdbc").option("url", url_)\
    .option("dbtable", table_neu_)\
    .option("driver", "com.mysql.jdbc.Driver")\
    .option("user", "flask")\
    .option("password", "wizjysys")\
    .mode(mode_)\
    .save()

    neg_text=spark.sql("SELECT df_final.status_text FROM df_final WHERE df_final.sent_class='Negative'")
    pos_text=spark.sql("SELECT df_final.status_text FROM df_final WHERE df_final.sent_class='Positive'")
    neu_text=spark.sql("SELECT df_final.status_text FROM df_final WHERE df_final.sent_class='Neutral'")
    df_words_udf = udf(stopword, StringType())
    neg_wordsDF=neg_text.rdd.map(lambda x: x[0])
    neg_words_rdd = neg_wordsDF.flatMap(split_line)
    neg_wordcount = neg_words_rdd.map(lambda word: (word.lower(), 1))
    neg_wc = neg_wordcount.reduceByKey(lambda a, b: a+b)
    neg_wc_df=neg_wc.toDF()
    neg_wc_df = neg_wc_df.withColumn('_2',neg_wc_df['_2'].cast(IntegerType()))
    neg_wc_df_stop= neg_wc_df.withColumn('word',df_words_udf('_1'))
    neg_word_cloud=neg_wc_df_stop.filter(neg_wc_df_stop.word != '').sort('_2',ascending=False).select('word','_2')
    print(40 * "-")

    pos_wordsDF=pos_text.rdd.map(lambda x: x[0])
    pos_words_rdd = pos_wordsDF.flatMap(split_line)
    pos_wordcount = pos_words_rdd.map(lambda word: (word.lower(), 1))
    pos_wc = pos_wordcount.reduceByKey(lambda a, b: a+b)
    pos_wc_df=pos_wc.toDF()
    pos_wc_df = pos_wc_df.withColumn('_2',pos_wc_df['_2'].cast(IntegerType()))
    pos_wc_df_stop= pos_wc_df.withColumn('word',df_words_udf('_1'))
    pos_word_cloud=pos_wc_df_stop.filter(pos_wc_df_stop.word != '').sort('_2',ascending=False).select('word','_2')

    neu_wordsDF=neu_text.rdd.map(lambda x: x[0])
    neu_words_rdd = neu_wordsDF.flatMap(split_line)
    neu_wordcount = neu_words_rdd.map(lambda word: (word.lower(), 1))
    neu_wc = neu_wordcount.reduceByKey(lambda a, b: a+b)
    neu_wc_df=neu_wc.toDF()
    neu_wc_df = neu_wc_df.withColumn('_2',neu_wc_df['_2'].cast(IntegerType()))
    neu_wc_df_stop= neu_wc_df.withColumn('word',df_words_udf('_1'))
    neu_word_cloud=neu_wc_df_stop.filter(neu_wc_df_stop.word != '').sort('_2',ascending=False).select('word','_2')

    neg_word_cloud.createOrReplaceTempView("temp_neg")
    pos_word_cloud.createOrReplaceTempView("temp_pos")
    neu_word_cloud.createOrReplaceTempView("temp_neu")

    neg_word_cloud=spark.sql("SELECT * FROM temp_neg LIMIT 200")
    pos_word_cloud=spark.sql("SELECT * FROM temp_pos LIMIT 200")
    neu_word_cloud=spark.sql("SELECT * FROM temp_neu LIMIT 200")

    neg_word_cloud.write.format("jdbc").option("url", url_)\
    .option("dbtable", table_word_neg_)\
    .option("driver", "com.mysql.jdbc.Driver")\
    .option("user", "flask")\
    .option("password", "wizjysys")\
    .mode(mode_)\
    .save()

    pos_word_cloud.write.format("jdbc").option("url", url_)\
    .option("dbtable", table_word_pos_)\
    .option("driver", "com.mysql.jdbc.Driver")\
    .option("user", "flask")\
    .option("password", "wizjysys")\
    .mode(mode_)\
    .save()

    neu_word_cloud.write.format("jdbc").option("url", url_)\
    .option("dbtable", table_word_neu_)\
    .option("driver", "com.mysql.jdbc.Driver")\
    .option("user", "flask")\
    .option("password", "wizjysys")\
    .mode(mode_)\
    .save()
#     "user" : "flask",
#     "password" : "wizjysys",
#     "driver" : "com.mysql.jdbc.Driver"
#     }
#     print(40 *'=')
#     print("Save the updated data to a new table with JDBC")
#     df = spark.read.json("/Users/yogadude/spark-2.1.1-bin-hadoop2.7/examples/src/main/resources/people.json")
#     df.show()
#     df.write \
#     .format("jdbc") \
#     .option("url", url_) \
#     .option("dbtable", "table_name_test") \
#     .option("driver", "com.mysql.jdbc.Driver") \
#     .option("user", "flask") \
#     .option("password", "wizjysys") \
#     .save()
    #df.write.jdbc(table=table_,url=url_,properties=dbProperties,mode=mode_)


if __name__ == "__main__":
    main()