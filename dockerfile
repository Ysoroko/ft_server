# Use an existing docker image as base
# The image is selected based on all the default programs
# provided which will help us to launch the image
FROM debian:buster

EXPOSE 80

# DOWNLOAD AND INSTALL DEPENDENCIES

# Update the Debian Buster OS
RUN	apt-get update;
RUN	apt-get -y upgrade;


# -----------------1. DEPLOY NGINX-----------------
RUN	apt-get -y install nginx;

# run nginx is needed to actually launch the nginx 
# (which was until then only installed)
RUN nginx
# at this point, we get the "Welcome to nginx on localhost"
# --------------------------------------------------


# -----------------2. Install Maria DB (My Sql)-----------------
# Maria DB (MY Sql) is used to store and manage the data on the server
RUN apt install -y mariadb-server

# The next line is required to follow through
# with the configuration of the password
RUN service mysql start;
# RUN mariadb
# The next line is the setup which needs to be only ran once
# RUN mysql_secure_installation
# USER = example_user; PASSWORD = password
# -----------------------------------------------------


# -----------------2. Install PHP-----------------
# PHP is required by NGINX to handle PHP processing and
# act as bridge between PHP interpreter and the web server
# PHP-FPM = PHP fastCGI process manager
# PHP-MYSQL allows PHP to communicate with MySQL-based databases
RUN apt-get -y install php-fpm php-mysql;



RUN nginx -s reload;


RUN killall -KILL php-fpm7.3;
RUN service php7.3-fpm start;

# MANUALLY DONE INSIDE THE IMAGE:
# In order to modify the default nginx configuration file
# we will need a text editor (I chose VIM)
# RUN	apt-get -y install vim;

RUN	apt-get -y install php-mysql;
RUN	mkdir /run/nginx;

#COPY srcs/nginx.conf /usr/local/nginx/conf
#COPY ./srcs/index.html /usr/share/nginx/html/index.html
#ADD config/default.conf /etc/nginx/conf.d/default.conf


#CMD ["/bin/sh", "-c",  "exec nginx -g 'daemon off;';"]

WORKDIR /var/www/localhost/htdocs



#$ docker run -it --rm -d -p 8080:80 --name web webserver
