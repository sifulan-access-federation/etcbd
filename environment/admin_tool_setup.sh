
# Create databases in the Postgres Image

# Get the database parameters
. localdev_djnro.env

# Run a command in the Postgres database to create the role and database
# Equivalant to:
#   create role djnrodev with login encrypted password 'djnrodev';
#   create database djnrodev with owner djnrodev;

docker exec -u postgres postgres psql --command="create role $DB_USER with login encrypted password '$DB_PASSWORD' ;"
docker exec -u postgres postgres psql --command="create database $DB_NAME with owner $DB_USER;"

