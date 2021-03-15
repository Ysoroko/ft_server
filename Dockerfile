FROM debian:buster

# Update the debian:buster OS sofrware packages
RUN apt-get update;
RUN apt-get upgrade -y;

# Wget is used for wordpress .tar download
RUN apt-get -y install wget;
# Vim is only necessary for manual tweaks inside the debian image
RUN apt-get -y install vim; 

RUN apt-get -y install nginx;
# COPY srcs/default /etc/nginx/sites-available

RUN apt-get install sysvinit-utils;
RUN apt-get -y install mariadb-server;

RUN apt-get -y install php7.3 php-mysql php-fpm;
RUN apt-get -y install php-pdo php-gd php-cli php-mbstring;

# Install phpMyAdmin
WORKDIR /var/www/html/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz
RUN tar -xf phpMyAdmin-5.0.1-english.tar.gz && rm -rf phpMyAdmin-5.0.1-english.tar.gz
RUN mv phpMyAdmin-5.0.1-english phpmyadmin

COPY srcs/config.inc.php phpmyadmin

# INSTALL WORDPRESS
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xvzf latest.tar.gz && rm -rf latest.tar.gz

COPY ./srcs/wp-config.php /var/www/html
COPY ./srcs/wordpress.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/

# RUN openssl req -x509 -nodes -days 365 -subj "/C=KR/ST=Korea/L=Seoul/O=innoaca/OU=42seoul/CN=forhjy" -newkey rsa:2048 -keyout /etc/ssl/nginx-selfsigned.key -out /etc/ssl/nginx-selfsigned.crt;

# Chown = change the ownership of the wordpress directory
RUN chown -R www-data:www-data *
RUN chmod -R 755 /var/www/*
COPY ./srcs/start.sh ./

CMD bash start.sh

# docker build -t ft_server .
# docker run -it --rm -p 80:80 ft_server