from django.conf.urls import include, url
import edumanage.viewsextra

urlpatterns = [
    url(r'^icingaconf/?', edumanage.viewsextra.icingaconf, name="icingaconf"),
    url(r'^radsecproxyconf/?', edumanage.viewsextra.radsecproxyconf, name="radsecproxyconf"),
    url(r'^', include('djnro.urls')),
]
