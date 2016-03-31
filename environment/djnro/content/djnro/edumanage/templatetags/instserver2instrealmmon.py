from django import template

register = template.Library()

@register.filter
def instserver2instrealmmon(s):
    """Get a list of InstRealmMon instances relevant for an InstServer

    """
    irms = []
    for ir in s.instrealm_set.all():
       irms += ir.instrealmmon_set.all()

    return irms

