FROM python:3.4

#libpg-dev needed for psycopg2 compildation
RUN apt-get -qq -y install libpq-dev

ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
CMD uwsgi /code/uwsgi.ini
