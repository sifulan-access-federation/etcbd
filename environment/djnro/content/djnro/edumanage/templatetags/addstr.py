
# credits: http://www.e-howtogeek.com/59981/how-to-concatenate-strings-in-django-templates

from django import template
from django.template.defaultfilters import stringfilter

register = template.Library()

@register.filter
@stringfilter
def addstr(arg1, arg2):
    """concatenate arg1 & arg2"""
    return str(arg1) + str(arg2)

