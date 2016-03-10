from django.conf.urls import patterns, include, url

urlpatterns = patterns(
    '',
    url(r'^icingaconf/?', 'edumanage.viewsextra.icingaconf', name="icingaconf"),
    url(r'^', include('djnro.urls')),
)
