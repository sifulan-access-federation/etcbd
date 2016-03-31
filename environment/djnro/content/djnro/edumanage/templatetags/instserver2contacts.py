from django import template
from sets import Set

register = template.Library()

@register.filter
def instserver2contacts(s):
    """Get a set of Contact instances relevant for an InstServer - i.e., list
       of contacts used in all institutions associated with this server.

    """
    contacts = Set()

    for inst in s.instid.all():
      try:
        for c in inst.institutiondetails.contact.all():
          contacts.add(c)
      except InstitutionDetails.DoesNotExist:
          # If the Institution has no InstitutionDetails, it is not associated
          # with any contacts - and in that case, OK to ignore here
          pass

    return contacts

