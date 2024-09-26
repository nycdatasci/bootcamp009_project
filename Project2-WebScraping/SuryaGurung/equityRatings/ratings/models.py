# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models

# Create your models here.

class StockRatings(models.Model):
    ticker = models.CharField(max_length = 10, primary_key = True)
    company = models.CharField(max_length = 50, default = '')
    ratingDate = models.DateField(max_length = 20, default = '')
    rating = models.CharField(max_length = 20, default = '')
    ratingClass = models.CharField(max_length = 20, default = '')
    brokerageFirm = models.CharField(max_length = 50, default = '')
    
    def __str__(self): # for python 2, use __unicode__ too
        return self.ticker + ': ' + self.company
