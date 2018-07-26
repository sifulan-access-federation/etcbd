# -*- coding: utf-8 -*- vim:encoding=utf-8:
# vim: tabstop=4:shiftwidth=4:softtabstop=4:expandtab
import warnings
import re

from django.conf import settings
from optparse import make_option
from django.core.management.base import BaseCommand
from edumanage.models import InstServer, InstRealmMon, Contact
from edumanage.viewsextra import all_monitoring_contacts
from django.template.loader import render_to_string

class Command(BaseCommand):
    help = "Export monitoring configuration"

    def add_arguments(self, parser):
        parser.add_argument(
            '--output',
            dest='output',
            default="yaml",
            help="Output type: json, yaml"
        )

    def handle(self, *args, **options):
        self.stdout.write(
            re.sub("\n\n\n*","\n\n",
              re.sub(" *$","",
                render_to_string('exports/icinga2.conf',
                    {
                     'allinstrealmmons': InstRealmMon.objects.all(),
                     'nroservers': settings.NRO_SERVERS,
                     'instservers': InstServer.objects.all(),
                     'confparams': settings.ICINGA_CONF_PARAMS,
                     'allcontacts': all_monitoring_contacts(),
                    }
                ), flags=re.MULTILINE
              ), flags=re.MULTILINE)
            )

