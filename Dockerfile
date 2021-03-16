FROM debian:buster

# Update the debian:buster OS sofrware packages
RUN apt-get update
RUN apt-get upgrade -y

#----------------------------------- INSTALL EVERYTHING ---------------------------------------
RUN apt-get install sysvinit-utils
RUN apt-get -y install wget

RUN apt-get -y install nginx
RUN apt-get -y install mariadb-server
RUN apt-get -y install php7.3 php-mysql php-fpm php-pdo php-gd php-cli php-mbstring php-xml
#----------------------------------------------------------------------------------------------



#----------------------------------- CONFIGURE NGINX TO USE PHP ---------------------------------------
RUN mkdir /var/www/localhost
RUN chown -R $USER:$USER /var/www/localhost
COPY srcs/localhost /etc/nginx/sites-available
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled
#----------------------------------------------------------------------------------------------


WORKDIR /var/www/localhost/

#----------------------------------- PHP MY ADMIN ---------------------------------------
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-english.tar.gz
RUN tar -xf phpMyAdmin-5.1.0-english.tar.gz && rm -rf phpMyAdmin-5.1.0-english.tar.gz
RUN mv phpMyAdmin-5.1.0-english phpmyadmin

COPY ./srcs/config.inc.php phpmyadmin
#----------------------------------------------------------------------------------------------

#----------------------------------- WORDPRESS ------------------------------------------
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xvzf latest.tar.gz && rm -rf latest.tar.gz 
COPY ./srcs/wp-config.php /var/www/localhost/wordpress
#----------------------------------------------------------------------------------------------

RUN openssl req -x509 -nodes -days 365 -subj "/C=BE/ST=Belgium/L=Brussels/O=na/OU=s19/CN=ysoroko" -newkey rsa:2048 -keyout /etc/ssl/nginx-selfsigned.key -out /etc/ssl/nginx-selfsigned.crt;

RUN chown -R www-data:www-data *
RUN chmod -R 755 /var/www/*

COPY ./srcs/start.sh ./
CMD bash start.sh;

#######################-START-########################
# docker build -t ft_server .
# docker run -it --rm -p 80:80 -p 443:443 ft_server

##################-CLEAN UP-########################
# docker system prune
# docker rmi $(docker images -q)
# docker rm $(docker ps -qa)