#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
from flask import Flask, render_template, request, session, redirect, url_for,jsonify
# from models import db, User, Place

from forms import SignupForm, LoginForm, AddressForm
from flask.ext.sqlalchemy import SQLAlchemy
from werkzeug import generate_password_hash, check_password_hash
from sqlalchemy import create_engine





app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://flask:wizjysys@flaskest.csjkhjjygutf.us-east-1.rds.amazonaws.com:3306/flaskdb'
app.config['SQLALCHEMY_ECHO'] = True

db = SQLAlchemy(app)


# user_sign up table
class User(db.Model):
  __tablename__ = 'users'
  uid = db.Column(db.Integer, primary_key = True, autoincrement=True)
  firstname = db.Column(db.String(100))
  lastname = db.Column(db.String(100))
  email = db.Column(db.String(120), unique=True)
  pwdhash = db.Column(db.String(54))

  def __init__(self, firstname, lastname, email, password):
    self.firstname = firstname.title()
    self.lastname = lastname.title()
    self.email = email.lower()
    self.set_password(password)
     
  def set_password(self, password):
    self.pwdhash = generate_password_hash(password)

  def check_password(self, password):
    return check_password_hash(self.pwdhash, password)

# positive influencer table 
class pos_influence(db.Model):
  __tablename__='pos_influence'
  rt_status_user_id = db.Column(db.Integer,primary_key=True)
  user_name = db.Column(db.String(100))
  max_follower_count=db.Column(db.Integer)
  max_retweet_count=db.Column(db.Integer)
  max_influence_score = db.Column(db.Float)
  status_text = db.Column(db.String(100))


  def __init__(self,rt_status_user_id,user_name ,max_follower_count,max_retweet_count,max_influence_score,status_text):
    self.rt_status_user_id = rt_status_user_id
    self.user_name = user_name
    self.max_follower_count = max_follower_count
    self.max_retweet_count = max_retweet_count
    self.max_influence_score = max_influence_score
    self.status_text = status_text

# neutral influencer table 
class neu_influence(db.Model):
  __tablename__='neu_influence'
  rt_status_user_id = db.Column(db.Integer,primary_key=True)
  user_name = db.Column(db.String(100))
  max_follower_count=db.Column(db.Integer)
  max_retweet_count=db.Column(db.Integer)
  max_influence_score = db.Column(db.Float)
  status_text = db.Column(db.String(100))


  def __init__(self,rt_status_user_id,user_name ,max_follower_count,max_retweet_count,max_influence_score,status_text):
    self.rt_status_user_id = rt_status_user_id
    self.user_name = user_name
    self.max_follower_count = max_follower_count
    self.max_retweet_count = max_retweet_count
    self.max_influence_score = max_influence_score
    self.status_text = status_text

# negative influencer table

class neg_influence(db.Model):
  __tablename__='neg_influence'
  rt_status_user_id = db.Column(db.Integer,primary_key=True)
  user_name = db.Column(db.String(100))
  max_follower_count=db.Column(db.Integer)
  max_retweet_count=db.Column(db.Integer)
  max_influence_score = db.Column(db.Float)
  status_text = db.Column(db.String(100))


  def __init__(self,rt_status_user_id,user_name ,max_follower_count,max_retweet_count,max_influence_score,status_text):
    self.rt_status_user_id = rt_status_user_id
    self.user_name = user_name
    self.max_follower_count = max_follower_count
    self.max_retweet_count = max_retweet_count
    self.max_influence_score = max_influence_score
    self.status_text = status_text



# positive table for word cloud
class pos_word_cloud(db.Model):
  __tablename__="pos_word_cloud"
  word = db.Column(db.String(100),primary_key=True)
  _2 = db.Column(db.String(100))

  def __init__(self,word,_2):
    self.word = word
    self._2 = _2




app.secret_key = "development-key"


@app.route('/')
def welcome():
    return render_template('welcome.html')

@app.route("/about")
def about():
  return render_template("about.html")

@app.route("/signup", methods=["GET", "POST"])
def signup():
  if 'email' in session:
    return redirect(url_for('about'))

  form = SignupForm()
  if request.method == "POST":
    if form.validate() == False:
      return render_template('signup.html', form=form)
    else:
      newuser = User(form.first_name.data, form.last_name.data, form.email.data, form.password.data)
      print newuser
      db.session.add(newuser)
      db.session.commit()

      session['email'] = newuser.email
      return redirect(url_for('gmap'))

  elif request.method == "GET":
    return render_template('signup.html', form=form)

@app.route("/login", methods=["GET", "POST"])
def login():
  if 'email' in session:
    return redirect(url_for('gmap'))

  form = LoginForm()

  if request.method == "POST":
    if form.validate() == False:
      return render_template("login.html", form=form)
    else:
      email = form.email.data 
      password = form.password.data 

      user = User.query.filter_by(email=email).first()
      if user is not None and user.check_password(password):
        session['email'] = form.email.data 
        return redirect(url_for('gmap'))
      else:
        return redirect(url_for('login'))

  elif request.method == 'GET':
    return render_template('login.html', form=form)

@app.route("/logout")
def logout():
  session.pop('email', None)
  return redirect(url_for('index'))





@app.route('/wordcloud')
def wordcloud():
# The dict we pass into this looks like:
# {'text': 'trump', 'size': 338}

# {'text': 'president', 'size': 39}

# {'text': '@realdonaldtrump', 'size':29}

# {'text': 'donald', 'size':19}
  word = pos_word_cloud.query.all()
  word_freqs = {}
  for i in word:
      key = i.word
      value = i._2
      # print keys,values
      word_freqs[key] = value
      # print word_freqs

  word_freqs_js = []
  for keys, values in word_freqs.items():
      temp = {"text": keys.encode('ascii', 'ignore'), "size": int(values)}
      # print temp
      word_freqs_js.append(temp)
  max_freq = 1094
  return render_template('wordcloud.html', word_freqs=word_freqs_js, max_freq=max_freq)

@app.route("/bars")
def bars():
    labels = ["January","February","March","April","May","June","July","August"]
    values = [10,9,8,7,6,4,7,8]
    return render_template('bars.html', values=values, labels=labels)






@app.route('/gmap',methods=['GET'])
def gmap():
    return render_template('gmap.html',result=json.dumps({"a":[{"o":1},{"o":2}]}, indent = 2))



@app.route('/table')
def table():

  influ_pos = pos_influence.query.all()
  influ_neu = neu_influence.query.all()
  influ_neg = neg_influence.query.all()


  return render_template("table.html", influ_pos= influ_pos, influ_neu=influ_neu ,influ_neg = influ_neg)




@app.route("/chart")
def chart():
    global labels,values
    labels = []
    values = []
    return render_template('chart.html', values=values, labels=labels)


@app.route('/refreshData')
def refresh_graph_data():
    global labels, values
    print("labels now: " + str(labels))
    print("data now: " + str(values))
    return jsonify(sLabel=labels, sData=values)


@app.route('/updateData', methods=['POST'])
def update_data_post():
    global labels, values
    if not request.form or 'data' not in request.form:
        return "error",400
    labels = ast.literal_eval(request.form['label'])
    values = ast.literal_eval(request.form['data'])
    print("labels received: " + str(labels))
    print("data received: " + str(values))
    return "success",201



if __name__ == '__main__':
    app.run(debug = True,threaded=True)
