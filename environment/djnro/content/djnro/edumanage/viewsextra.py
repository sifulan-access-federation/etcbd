import re

from django.shortcuts import render_to_response, redirect, render
from django.http import (
    HttpResponse,
    HttpResponseRedirect,
    HttpResponseNotFound,
    HttpResponseBadRequest
)
from django.template import RequestContext
from django.core.urlresolvers import reverse
from django.contrib.auth.decorators import login_required
from django.views.decorators.cache import never_cache
from django.contrib.auth import logout
from django.template.loader import render_to_string
from django.conf import settings
from django.utils.translation import ugettext as _

from edumanage.models import (
    InstRealmMon,
    Realm,
    InstServer,
    MonLocalAuthnParam,
    Institution,
    InstitutionContactPool,
    InstRealm,
    Contact,
)
from edumanage.decoratorsextra import require_ssl, logged_in_or_basicauth, has_perm_or_basicauth


@require_ssl
@has_perm_or_basicauth('edumanage.change_monlocalauthnparam',realm='eduroam management tools')
def icingaconf(request):
    nro_servers = (
        { 'name': "nro1",
          'host': "nro1.host",
          'port': "1812",
          'secret': "s3cr3t",
          'status_server': True,
        },
        { 'name': "nro2",
          'host': "nro2.host",
          'port': "1812",
          'secret': "s3cr3t",
          'status_server': True,
        },
        )

    resp_body = render_to_string('exports/icinga2_nro.conf',
                    {
                     'instrealmmons': InstRealmMon.objects.all(),
                     'nroservers': nro_servers
                    }
                )
    resp_body = re.sub("\n\n\n*","\n\n",
            re.sub(" *$","", resp_body, flags=re.MULTILINE),
            flags=re.MULTILINE)

    resp_content_type = "text/plain"

    return HttpResponse(resp_body,
                        content_type=resp_content_type)


