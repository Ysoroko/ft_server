#----------------------------------- 1. DEBIAN BUSTER ---------------------------------------
FROM debian:buster

# Update Debian Buster
RUN apt-get update
RUN apt-get upgrade -y
#----------------------------------------------------------------------------------------------

#----------------------------------- 2. INSTALL PACKAGES ---------------------------------------
# Sysvinit-utils for "service" command used in start.sh
RUN apt-get install sysvinit-utils
# Wget for downloading phpMyAdmin / Wordpress
RUN apt-get -y install wget

RUN apt-get -y install nginx
RUN apt-get -y install mariadb-server
RUN apt-get -y install php7.3 php-mysql php-fpm php-pdo php-gd php-cli php-mbstring php-xml
#----------------------------------------------------------------------------------------------

#----------------------------------- 3. CONFIGURE NGINX TO USE PHP ---------------------------------------
RUN mkdir /var/www/localhost
RUN chown -R $USER:$USER /var/www/localhost
COPY srcs/localhost /etc/nginx/sites-available
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled
#----------------------------------------------------------------------------------------------

# Change the directory where the next command lines are executed
WORKDIR /var/www/localhost/

#----------------------------------- 4. PHP MY ADMIN ---------------------------------------
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-english.tar.gz
RUN tar -xf phpMyAdmin-5.1.0-english.tar.gz && rm -rf phpMyAdmin-5.1.0-english.tar.gz
RUN mv phpMyAdmin-5.1.0-english phpmyadmin

COPY ./srcs/config.inc.php phpmyadmin
#----------------------------------------------------------------------------------------------


#----------------------------------- 5. WORDPRESS ------------------------------------------
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xvzf latest.tar.gz && rm -rf latest.tar.gz 
COPY ./srcs/wp-config.php /var/www/localhost/wordpress
#----------------------------------------------------------------------------------------------


#----------------------------------- 6. GENERATE SSL KEY CERTIFICATE ------------------------------------------
# GENERATE SSL KEY CERTIFICATE
# x509 specifies a self signed certificate
# -nodes specifies that the private key wont be encrypted
# -days specifies the validity (in days) of the certificate
# -subj allows us to use the following string (and not create a separate file for it)
# -newkey creates a new certificate request and a new private key 
# -rsa 2018 is the standard key size (in bits)
# -keyout specifies where to save the key
# -out specifies the file name
RUN openssl req -x509 -nodes -days 30 -subj "/C=BE/ST=Belgium/L=Brussels/O=42 Network/OU=s19/CN=ysoroko" -newkey rsa:2048 -keyout /etc/ssl/nginx-selfsigned.key -out /etc/ssl/nginx-selfsigned.crt;
#----------------------------------------------------------------------------------------------

RUN chown -R www-data:www-data *
RUN chmod -R 755 /var/www/*

COPY ./srcs/start.sh ./
CMD bash start.sh;


#----------------------------------------------------------------------------------------------
#######################-START-########################
# docker build -t ft_server .
# docker run -it --rm -p 80:80 -p 443:443 ft_server

##################-CLEAN UP-########################
# docker system prune
# docker rmi $(docker images -q)
# docker rm $(docker ps -qa)
#----------------------------------------------------------------------------------------------