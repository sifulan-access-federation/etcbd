FROM python:2.7

#libpg-dev needed for psycopg2 compildation
RUN apt-get -qq -y install libpq-dev

RUN mkdir /djnro
WORKDIR /djnro

#pull in the djnro code, install it's dependencies
RUN git clone https://github.com/REANNZ/djnro.git ./
COPY requirements-additional.txt ./
RUN pip install -r requirements-additional.txt -r requirements.txt
COPY uwsgi.ini ./
COPY local_settings.py djnro/
EXPOSE 3031
CMD exec uwsgi /djnro/uwsgi.ini
