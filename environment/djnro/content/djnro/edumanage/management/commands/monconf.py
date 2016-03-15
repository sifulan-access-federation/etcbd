# -*- coding: utf-8 -*- vim:encoding=utf-8:
# vim: tabstop=4:shiftwidth=4:softtabstop=4:expandtab
import warnings
import re

from django.conf import settings
from optparse import make_option
from django.core.management.base import BaseCommand
from edumanage.models import InstServer, InstRealmMon
from django.template.loader import render_to_string

class Command(BaseCommand):
    option_list = BaseCommand.option_list + (
        make_option(
            '--output',
            dest='output',
            default="yaml",
            help="Output type: json, yaml"
        ),
    )
    args = ''
    help = "Export monitoring configuration"
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
    def handle(self, *args, **options):
        self.stdout.write(
            re.sub("\n\n\n*","\n\n",
              re.sub(" *$","",
                render_to_string('exports/icinga2_nro.conf',
                    {
                     'instrealmmons': InstRealmMon.objects.all(),
                     'nroservers': settings.NRO_SERVERS
                    }
                ), flags=re.MULTILINE
              ), flags=re.MULTILINE)
            )

