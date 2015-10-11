
# Create databases in the Postgres Image

# Load the local deployment environment variables
# (and filtre the syntax to quote the values first)
eval $( cat localdev_djnro.env | sed 's/=\(.*\)/="\1"/' )

# Run a command in the Postgres database to create the role and database
# Equivalant to:
#   create role djnrodev with login encrypted password 'djnrodev';
#   create database djnrodev with owner djnrodev;

docker exec -u postgres postgres psql --command="create role $DB_USER with login encrypted password '$DB_PASSWORD' ;"
docker exec -u postgres postgres psql --command="create database $DB_NAME with owner $DB_USER;"

# Initialize database on the Django side - and create super user
docker exec -i djnro ./manage.py syncdb <<-EOF
	yes
	admin
	$ADMIN_EMAIL
	$ADMIN_PASSWORD
	$ADMIN_PASSWORD
EOF

docker exec djnro ./manage.py migrate

# load django fixtures - initial data
docker exec djnro ./manage.py loaddata initial_data/fixtures_manual.xml

# run fetch-kml one-off:
docker exec djnro ./manage.py fetch_kml

# create initial realm
docker exec -i djnro ./manage.py shell <<-EOF
	from edumanage.models import Realm
	Realm(country="$REALM_COUNTRY_CODE").save()
EOF

