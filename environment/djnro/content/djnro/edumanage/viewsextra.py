import re
from sets import Set

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
    InstitutionDetails,
    InstitutionContactPool,
    InstRealm,
    Contact,
)
from edumanage.decoratorsextra import require_ssl, logged_in_or_basicauth, has_perm_or_basicauth


def all_monitoring_contacts():
    """"Return all contacts used in monitoring.  This now means all contacts associated with institutions that are either:
        * Associated with InstRealms that have a monitored realm (InstRealmMon) instance.
        * Have a server associated with the institution
    """

    contacts = Set()
    for irm in InstRealmMon.objects.all():
      try:
        for c in irm.realm.instid.institutiondetails.contact.all():
          contacts.add(c)
      except InstitutionDetails.DoesNotExist:
          # If the Institution has no InstitutionDetails, we cannot find any
          # contacts - and in that case, OK to ignore here
          pass

    for server in InstServer.objects.all():
      for inst in server.instid.all():
        try:
          for c in inst.institutiondetails.contact.all():
            contacts.add(c)
        except InstitutionDetails.DoesNotExist:
            # If the Institution has no InstitutionDetails, it is not associated
            # with any contacts - and in that case, OK to ignore here
            pass

    return contacts

@require_ssl
@has_perm_or_basicauth('edumanage.change_monlocalauthnparam',realm='eduroam management tools')
def icingaconf(request):

    resp_body = render_to_string('exports/icinga2.conf',
                    {
                     'allinstrealmmons': InstRealmMon.objects.all(),
                     'nroservers': settings.NRO_SERVERS,
                     'instservers': InstServer.objects.all(),
                     'confparams': settings.ICINGA_CONF_PARAMS,
                     'allcontacts': all_monitoring_contacts(),
                    }
                )
    resp_body = re.sub("\n\n\n*","\n\n",
            re.sub(" *$","", resp_body, flags=re.MULTILINE),
            flags=re.MULTILINE)

    resp_content_type = "text/plain"

    return HttpResponse(resp_body,
                        content_type=resp_content_type)


