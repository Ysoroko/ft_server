FROM debian:buster as builder

RUN	apt-get update;
RUN	apt-get -y upgrade;
RUN apt-get install nginx mariadb-server mariadb-client -y;
RUN apt-get	install php-cgi php-common php-fpm php-pear php-mbstring -y;
RUN apt-get install php-zip php-net-socket php-gd php-xml-util -y;
RUN apt-get install php-gettext php-mysql php-bcmath unzip -y;
RUN apt-get install wget vim systemd git -y;

FROM nginx as nginx
COPY localhost /usr/share/nginx/html

FROM php:7.4-cli as php
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp
CMD [ "php", "./your-script.php" ]

FROM phpmyadmin as myadmin

FROM mariadb as mariadb

FROM wordpress as wordpress

