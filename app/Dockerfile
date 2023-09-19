FROM tiangolo/uwsgi-nginx-flask:python3.8-alpine-2023-09-18
RUN apk --update add bash nano
ENV STATIC_URL /static
ENV STATIC_PATH /var/www/app/static
COPY ./requirements.txt /var/www/requirements.txt
COPY ./ /app
RUN pip install -r /var/www/requirements.txt
EXPOSE 80/tcp
