from django.conf.urls import patterns, include, url
import edumanage.viewsextra

urlpatterns = patterns(
    '',
    url(r'^icingaconf/?', edumanage.viewsextra.icingaconf, name="icingaconf"),
    url(r'^', include('djnro.urls')),
)
