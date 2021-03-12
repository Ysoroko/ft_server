FROM debian:buster as builder

# to enter the debian:buster as a terminal:
# docker run -it -p 80:80 --name lemp debian:buster /bin/sh
RUN	apt-get update;
RUN	apt-get -y upgrade;
RUN apt-get install nginx mariadb-server mariadb-client -y;
RUN apt-get	install php-cgi php-common php-fpm php-pear php-mbstring -y;
RUN apt-get install php-zip php-net-socket php-gd php-xml-util -y;
RUN apt-get install php-gettext php-mysql php-bcmath unzip -y;
RUN apt-get install wget vim systemd git -y;

# -----------------1. SETUP NGINX-----------------

RUN nginx -s reload;
RUN killall -KILL php-fpm7.3;
RUN /usr/sbin/php-fpm7.3;
# docker run -it -d -v $PWD:/var/www/localhost/htdocs -p 80:80 --name mywp lempenv
# docker build . -t lempenv