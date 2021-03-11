# Use an existing docker image as base
# The image is selected based on all the default programs
# provided which will help us to launch the image

# To enter the debian buster image with shell:
# docker run -it -p 80:80 --name lemp debian:buster /bin/sh
# docker start -it -p 80:80 --name lemp debian:buster /bin/sh
FROM debian:buster

EXPOSE 80

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

# -----------------1. DEPLOY NGINX-----------------

# run nginx is needed to actually launch the nginx 
# (which was until then only installed)
# This is actually done in CMD line
# RUN nginx
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
