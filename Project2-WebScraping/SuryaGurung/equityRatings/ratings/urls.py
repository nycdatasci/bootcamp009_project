from django.conf.urls import url
from ratings import views

urlpatterns = [ url(r'^$', views.index, name = 'home'), 
                url(r'^about/$', views.about, name = 'about'),
                url(r'^summary/(?P<ticker>[\^\w]+)/$', views.summary, name = 'summary'),
             
            ]
            