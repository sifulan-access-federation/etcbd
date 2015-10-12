FROM python:2.7

#libpg-dev needed for psycopg2 compildation
RUN apt-get -qq -y install libpq-dev

RUN mkdir /djnro
WORKDIR /djnro

#pull in the djnro code, install it's dependencies
RUN git clone https://github.com/grnet/djnro.git ./
COPY requirements-additional.txt ./
RUN pip install -r requirements-additional.txt -r requirements.txt
COPY uwsgi.ini ./
COPY local_settings.py djnro/
COPY 0022_auto__chg_field_institutiondetails_number_id__del_field_instrealmmon_i.py edumanage/migrations/
EXPOSE 3031
CMD exec uwsgi /djnro/uwsgi.ini
