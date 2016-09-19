#!/usr/bin/env python

import os
import sys
import smtplib
import email.mime.text


def send_notification_email(to, subject, body):
    """
    Send a plain text email.

    :param to: the list of recipients of the email
    :type to: list
    :param subject: the subject line of the email
    :type subject: str
    :param body: the body text of the email
    :type body: str

    ENV variables:
    EMAIL_HOST=smtp.example.org
    EMAIL_PORT=25
    EMAIL_USER=
    EMAIL_PASSWORD=
    EMAIL_USE_TLS=
    EMAIL_FROM=donotreply@example.org
    """

    sender = os.getenv('EMAIL_FROM','donotreply@example.org')
    msg = email.mime.text.MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = ', '.join(to)

    print("sending email to {} with subject {}".format(to, subject))

    try:
        server = smtplib.SMTP(os.getenv('EMAIL_HOST', 'smtp.example.org'), os.getenv('EMAIL_PORT', 25) )
        #server.set_debuglevel(1)
        if os.getenv('EMAIL_USE_TLS', 'False').upper() == 'TRUE':
            server.starttls()
        if os.getenv('EMAIL_USER') or os.getenv('EMAIL_PASSWORD'):
            server.login(os.getenv('EMAIL_USER'), os.getenv('EMAIL_PASSWORD') )
        server.sendmail(sender, to, msg.as_string())
        #python 3 notation
        #server.send_message(msg)
        server.close()
    except smtplib.SMTPException as error:
        print("smtp error sending to recipients: {}, subject: {}, error: {}".format(to, subject, error))
        try:
            server.close()
        except:
            pass


subject = ""
to = ""
body = ""
base_index = 1

if (len(sys.argv)<=1) or ( (sys.argv[1] == "-s") and (len(sys.argv) <=3) ):
    print "Not enough arguments!"
    print "Usage: %s [-s <subject>] recipients...." % sys.argv[0]
    exit(2)

if sys.argv[1] == "-s":
   subject = sys.argv[2]
   base_index +=2

to = sys.argv[base_index:]

for line in sys.stdin:
    body = body+line

send_notification_email(to, subject, body)

