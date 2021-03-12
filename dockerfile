# Use an existing docker image as base
# The image is selected based on all the default programs
# provided which will help us to launch the image

# To enter the debian buster image with shell:
# docker run -it -p 80:80 --name lemp debian:buster /bin/sh
# docker start -it -p 80:80 --name lemp debian:buster /bin/sh
FROM debian:buster

# Expose 'opens up' the specified port of the container
# Without it, the container is isolated and cannot connect to 
# the outside world
EXPOSE 80

# Workdir specifies the working directory (where the commands are executed)
WORKDIR /

# DOWNLOAD AND INSTALL DEPENDENCIES

# Update the Debian Buster OS
RUN	apt-get update;
RUN	apt-get -y upgrade;

# INSTALL ALL
RUN apt-get install nginx mariadb-server mariadb-client -y;
RUN apt-get	php-cgi php-common php-fpm php-pear php-mbstring -y;
RUN apt-get php-zip php-net-socket php-gd php-xml-util -y;
RUN apt-get php-gettext php-mysql php-bcmath unzip -y;
RUN apt-get wget vim systemd git -y;

# -----------------1. SETUP NGINX-----------------

# -p flag doesnt raise a warning if the directory already exists
RUN mkdir -p /var/www/localhost
COPY 
# at this point, we get the "Welcome to nginx on localhost"
# --------------------------------------------------


# -----------------2. Install Maria DB (My Sql)-----------------
# Maria DB (MY Sql) is used to store and manage the data on the server
#RUN apt install -y mariadb-server

# The next line is required to follow through
# with the configuration of the password
#RUN service mysql start;
# The next line is the setup which needs to be only ran once
# RUN mysql_secure_installation
# RUN mariadb
# USER = example_user; PASSWORD = password
# -----------------------------------------------------


# -----------------2. Install PHP-----------------
# PHP is required by NGINX to handle PHP processing and
# act as bridge between PHP interpreter and the web server
# PHP-FPM = PHP fastCGI process manager
# PHP-MYSQL allows PHP to communicate with MySQL-based databases

# RUN nginx -s reload;
# RUN nginx;

# RUN killall -KILL php-fpm7.3;
# RUN service php7.3-fpm start;
# RUN service php7.3-fpm restart;
# RUN mkdir /run/nginx;

# -----------------3. Wordpress-----------------

ADD srcs/default.conf /etc/nginx/conf.d/default.conf
# MANUALLY DONE INSIDE THE IMAGE:
# In order to modify the default nginx configuration file
# we will need a text editor (I chose VIM)
# RUN	apt-get -y install vim;

#COPY srcs/nginx.conf /usr/local/nginx/conf
#COPY ./srcs/index.html /usr/share/nginx/html/index.html
#ADD config/default.conf /etc/nginx/conf.d/default.conf


#CMD ["/bin/sh", "-c",  "exec nginx -g 'daemon off;';"]
CMD ["/bin/sh", "-c", "/usr/sbin/php-fpm7; exec nginx -g 'daemon off;';"]

WORKDIR /var/www/localhost/htdocs



# docker run -it -d -v $PWD:/var/www/localhost/htdocs -p 80:80 --name mywp lempenv
# docker build . -t lempenv



# 1--------
#UPDATE & INSTALL PACKAGES
apt-get update
apt-get upgrade -y
apt-get -y install mariadb-server
apt-get -y install wget
apt -y install php-{mbstring,zip,gd,xml,pear,gettext,cli,fpm,cgi}
apt-get -y install php-mysql
apt-get install -y libnss3-tools
apt-get -y install nginx

#NGINX SETUP
cd
mkdir -p /var/www/localhost
cp /root/nginx-host-conf /etc/nginx/sites-available/localhost
ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

#SLL SETUP
mkdir ~/mkcert && \
  cd ~/mkcert && \
  wget https://github.com/FiloSottile/mkcert/releases/download/v1.1.2/mkcert-v1.1.2-linux-amd64 && \
  mv mkcert-v1.1.2-linux-amd64 mkcert && \
  chmod +x mkcert
./mkcert -install
./mkcert localhost

#DATABASE SETUP
service mysql start
echo "CREATE DATABASE wordpress;" | mysql -u root
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';" | mysql -u root
echo "FLUSH PRIVILEGES;" | mysql -u root
echo "update mysql.user set plugin = 'mysql_native_password' where user='root';" | mysql -u root
cd
mysql wordpress -u root --password=  < wordpress.sql

#WORDPRESS INSTALL
cd
cp wordpress.tar.gz /var/www/localhost/
cd /var/www/localhost/
tar -xf wordpress.tar.gz
rm wordpress.tar.gz

#PHPMYADMIN INSTALL
cd
wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-english.tar.gz
mkdir /var/www/localhost/phpmyadmin
tar xzf phpMyAdmin-4.9.0.1-english.tar.gz --strip-components=1 -C /var/www/localhost/phpmyadmin
cp /root/config.inc.php /var/www/localhost/phpmyadmin/

#ALLOW NGINX USER
chown -R www-data:www-data /var/www/*
chmod -R 755 /var/www/*

#SERVICE STARTER
service mysql restart
/etc/init.d/php7.3-fpm start
service nginx restart



#2---------
FROM debian:buster

COPY srcs/localhost /etc/nginx/sites-available/
COPY srcs/wordpress.zip /var/www/
COPY srcs/wordpress.sql /var/www/
COPY srcs/init.sql /var/www/
COPY srcs/service_start.sh .
CMD bash service_start.sh && tail -f /dev/null
# INSTALL & UPDATE
apt-get update
apt-get install -y wget
apt-get install -y nginx
apt-get install -y mariadb-server
apt-get install -y php
apt-get install -y php-cli php-fpm php-cgi
apt-get install -y php-mysql
apt-get install -y php-mbstring
apt-get install -y openssl
apt-get install -y zip

# WORDPRESS
unzip /var/www/wordpress.zip -d /var/www/

# ZIP DOWNLOADING APACHE 2 ???? xD
apt-get purge -y apache2

# MYSQL
service mysql start
mysql < /var/www/init.sql
mysql wordpress -u root --password=  < /var/www/wordpress.sql

# LINK SITE
ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/
chown -R www-data:www-data /var/www/*
chmod -R 755 /var/www/*

# RUN PHP
/etc/init.d/php7.3-fpm start

# SSL
mkdir ~/mkcert && \
  cd ~/mkcert && \
  wget https://github.com/FiloSottile/mkcert/releases/download/v1.1.2/mkcert-v1.1.2-linux-amd64 && \
  mv mkcert-v1.1.2-linux-amd64 mkcert && \
  chmod +x mkcert
./mkcert -install
./mkcert localhost

# START
service nginx start