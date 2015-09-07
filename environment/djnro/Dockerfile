FROM python:2.7

#libpg-dev needed for psycopg2 compildation
RUN apt-get -qq -y install libpq-dev

RUN mkdir /djnro
WORKDIR /djnro

#pull in the djnro code, install it's dependencies
RUN git clone https://github.com/grnet/djnro.git ./
ADD requirements-additional.txt ./
ADD uwsgi.ini ./
RUN pip install -r requirements-additional.txt -r requirements.txt
CMD uwsgi /djnro/uwsgi.ini
