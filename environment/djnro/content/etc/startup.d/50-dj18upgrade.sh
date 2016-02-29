#!/bin/bash

# perform an in-place upgrade to Django 1.8 IFF:
# (1)  This instance is running Django 1.8
# (2)  The DB we connect has NOT been used with Django 1.8 yet - first time upgrade

IS_DJ18=
DB_HAS_DJANGO_MIGRATIONS=
DB_HAS_SOUTH_MIGRATIONS=

if ./manage.py version | grep '^1\.8' > /dev/null ; then IS_DJ18='Y' ; fi

if ./manage.py inspectdb |grep '^class DjangoMigrations' > /dev/null ; then DB_HAS_DJANGO_MIGRATIONS='Y' ; fi
if ./manage.py inspectdb |grep '^class SouthMigrationHistory' > /dev/null ; then DB_HAS_SOUTH_MIGRATIONS='Y' ; fi

if [ -z "$IS_DJ18" ] ; then
    echo "Not running Django 1.8, not upgrading"
elif [ -n "$DB_HAS_DJANGO_MIGRATIONS" ] ; then
    echo "Database has already been upgraded, not upgrading"
elif [ -z "$DB_HAS_SOUTH_MIGRATIONS" ] ; then
    echo "This is not a Django 1.4 database with South migrations, not upgrading"
else
    echo "We are running Django 1.8 and the database has not been upgraded yet, upgrading..."
    # Change UserModel from built-in auth.User to custom accounts.User
    # (And change corresponding content-types)
    echo "Migrating user model content type"
    ./manage.py shell <<-EOF
	from django.contrib.contenttypes.models import ContentType
	ct=ContentType.objects.get(model='user')
	ct.app_label=u'accounts'
	ct.save()
	exit()
	EOF
    # Tell Django migrations framework that our database structures are already in place
    # But replay all migrations that Django internal structures have undergone between Django 1.4 and 1.8
    # And this applies also to the User model that is now presented under (our) accounts package.
    echo "Migrating to Django migrations"
    ./manage.py migrate --fake-initial contenttypes
    ./manage.py migrate --fake-initial auth
    ./manage.py migrate --fake-initial --fake edumanage
    ./manage.py migrate --fake-initial --fake accounts 0002_initial
    ./manage.py migrate --fake-initial

    # Fix up database:
    # Add missiung UNIQUE CONSTRAINT to SocialAuth.Nonce
    echo "Fixing up SocialAuth.Nonce"
    ./manage.py shell <<-EOF
	from django.db import connections
	cursor = connections['default'].cursor()
	cursor.execute('ALTER TABLE social_auth_nonce ADD CONSTRAINT "social_auth_nonce_server_url_36601f978463b4_uniq" UNIQUE (server_url, timestamp, salt);')
	exit()
	EOF
    # Add missing Foreign Key (missed in PostgreSQL manual migrations workaround) to Edumanage.Instrealmmon
    echo "Fixing up Edumanage.Instrealmmon"
    ./manage.py shell <<-EOF
	from django.db import connections
	cursor = connections['default'].cursor()
	cursor.execute('ALTER TABLE edumanage_instrealmmon ADD CONSTRAINT "edumanage_i_realm_id_24cc89d4be4145e5_fk_edumanage_instrealm_id" FOREIGN KEY (realm_id) REFERENCES edumanage_instrealm(id) DEFERRABLE INITIALLY DEFERRED;')
	exit()
	EOF

    echo "Migration successfully completed - enjoy Django 1.8"
fi

