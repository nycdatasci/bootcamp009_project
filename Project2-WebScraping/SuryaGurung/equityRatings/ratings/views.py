# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.shortcuts import render

# Create your views here.

def about(request):
    
    context_dict = {}
    
    
    
    return render(request, 'ratings/about.html', context_dict)



def index(request):
    context_dict = {}
    
    
    return render(request, 'ratings/index.html', context_dict)

def summary(request, ticker):
    context_dict = {}
    context_dict['ticker'] = ticker

    return render(request, 'ratings/summary.html', context_dict)