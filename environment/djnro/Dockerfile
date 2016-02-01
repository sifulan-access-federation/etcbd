FROM python:2.7

#libpg-dev needed for psycopg2 compilation
#this pkg is included in python:2.7, but make the statement explicit anyway
RUN apt-get update -q && apt-get -qq -y install libpq-dev

# temporary: install utils
RUN apt-get -q -y install --no-install-recommends lsof vim less file

RUN mkdir /djnro
WORKDIR /djnro

#pull in the djnro code, install it's dependencies
RUN git clone https://github.com/REANNZ/djnro.git ./
COPY requirements-additional.txt ./
RUN pip install -r requirements-additional.txt -r requirements.txt
COPY envwrap.sh run-kml-refresh.sh uwsgi.ini ./
COPY local_settings.py djnro/
EXPOSE 3031
CMD exec ./envwrap.sh uwsgi /djnro/uwsgi.ini
