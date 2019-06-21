from django import template
import socket

register = template.Library()

@register.filter
def server2ipv4addr(s, server_addr):
    """Convert a hostname to an IPv4 address using existing lookups.
    """

    return server_addr[s]['ipv4'] if s in server_addr and 'ipv4' in server_addr[s] else None

