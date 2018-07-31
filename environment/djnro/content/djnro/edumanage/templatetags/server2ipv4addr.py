from django import template
import socket

register = template.Library()

@register.filter
def server2ipv4addr(s, server_addr):
    """Convert a hostname to an IPv4 address using existing lookups.
    """

    return server_addr[s]['ipv4'] if server_addr.has_key(s) and server_addr[s].has_key('ipv4') else None

