from django import template
from django.template.defaultfilters import stringfilter

register = template.Library()

@register.filter
@stringfilter
def icingaescape(txt):
    """Escape string to be safe in Icinga configuration

       The escaping required is (in this order):

       $   $$
       \   \\
       "   \"
    """
    return txt.replace("$","$$").replace("\\","\\\\").replace("\"", "\\\"")

