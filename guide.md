### This is the utlimate step-by-step guide to complete ft_server (2021) project for 42 coding schools network.
<br />

## Prerequisites:
#### - 📚 You are familiar with all of the concepts and tools needed for this project: containers, images, ports, MariaDB, Wordpress, phpMyAdmin etc.
#### - 🐳 You have Docker installed on your computer and it is running ([**download link**](https://www.docker.com/get-started))
<br />

## Project parts breakdown:
#### 1) Create a Dockerfile and download a Debian Buster image  
#### 2) Install all of the dependancies needed for the rest of the project
#### 3) Install and configure NGINX
#### 4) Install and configure phpMyAdmin
#### 5) Install and configure Wordpress
#### 6) Generate a SSL certificate and apply it
<br />

## Building, running and cleaning up your containers:
#### Throughout this project you will often need to test your work. The following commands are used *A LOT* and I recommend to create a Makefile with rules that will execute them for you
#### `docker build -t ft_server .` will build our Docker container and name it "ft_server"
#### `docker run -it --rm -p 80:80 -p 443:443 ft_server` After it's built this command will:
  * `run` *run* our container
  * `-it` in the terminal mode (we will be able to execute the commands inside the image from our terminal)
  * `--rm` automatically remove it once it's stopped
  * `-p` link the necessary ports (80 and 443)
  * And finally, name it "ft_server"
#### `docker rmi $(docker images -q)` will remove all the images previously downloaded in Docker
#### `docker rm $(docker ps -qa)` will remove all the built containers
#### `docker system prune` will cleanup the temporary files and the rest of remaining used space
<br />

## 1) Create a Dockerfile and download a Debian Buster image
All you need to do is:
* Create a file called Dockerfile
* Add a line `FROM debian:buster` inside.
* Add lines `RUN apt-get update` and `RUN apt-get upgrade -y`
<br />
Dockerfile is like a Makefile, but instead of executing commands in your terminal it will do it inside Docker images.

The command `FROM` tells Docker to download the image that follows and use the commands we'll add in the next step inside this image.

Here we are using an empty Debian Buster operating system image as asked in the subject. You can imagine that we download an empty Windows or MacOS now and
in the next step we will start installing the dependencies needed for the rest of our project.

Before we do that, we need to update the Debian Buster packages to make sure everything is up to date just as we need.
This is simply done by adding `RUN apt-get update` and `RUN apt-get upgrade -y` to our Dockerfile. 

`RUN` is used in Dockerfile to execute the command inside the image, as if it is entered in the terminal of our Debian OS. If no directory is specified, it is executed at the root of our image.

<br />

```Dockerfile
#------------------ 1. Create a Dockerfile and download Debian Buster image ---------------------
# Download debian:buster from Docker and use it as main image here
FROM debian:buster

# Update Debian Buster packages
RUN apt-get update
RUN apt-get upgrade -y
#------------------------------------------------------------------------------------------------
```
Now if we try to build our docker image and run it, Debian Buster image will be downloaded from Docker and it will be updated.

<br />

## 2) Install all of the dependancies needed to install the rest of the tools
Now that we have our Dockerfile and an empty Debian OS with basic packages, we will install the dependencies and tools needed for further steps in the project.

This is done by adding several `apt-get install` to our Dockerfile. For this project there is a couple of things we need:
```Dockerfile
#----------------------------------- 2. Intall Dependencies --------------------------------------
# Sysvinit-utils for "service" command used to easily restart out nginx after updating
RUN apt-get install sysvinit-utils

# Wget is used to easily download phpMyAdmin / Wordpress
RUN apt-get -y install wget

# Nginx is an open source web server tool we are going to use to connect our Docker container image to our webpage
RUN apt-get -y install nginx

# MariaDB is a tool used to manage databases. It's a community "fork" of MySQL (= improved version of MySQL)
RUN apt-get -y install mariadb-server

# Php packages are needed to read our configuration files and properly connect all of our components together
# In case a php package is missing, we will get an error when launching php related services later
RUN apt-get -y install php-cgi php-common php-fpm php-pear php-mbstring
RUN apt-get -y install php-zip php-net-socket php-gd php-xml-util php-gettext php-mysql php-bcmath
#-------------------------------------------------------------------------------------------------
```
Now if we try to build our docker image and run it, it downloads/updates Debian Buster and also downloads all of the dependencies we need.

## 3) Configure NGINX
In the previous part of the project we have downloaded nginx using `RUN apt-get -y install nginx`.

Now, we will configure it to connect our container to our webpage.

In order to do so, NGINX will need a configuration file where we will tell it what is our webpage name, what ports he needs to "listen" to and what other tools we will use.

Normally on our computer we would simply create a file and write inside, but since we need to do it inside the container, we prepare the configuration file in advance and
then copy it inside our container when we need it.
In our project folder, let's create a "srcs" folder as required by subject and create an empty file named "localhost" inside.

localhost is the webpage we will be using to acces our web server in this project.

Add the following lines to our "localhost" file:
```php
server {
     # tells to listen to port 80
     listen 80;
     # same but for IPV6
     listen [::]:80;
     # tells the name(s) of our website
     server_name localhost www.localhost;
     # will redirect us to https://$host$request_uri;
     # when we try to reach the website name in our browser
     return 301 https://$host$request_uri;
 }
 server {
    # tells to listen to port 443
    listen 443 ssl;
    # same but for IPV6
    listen [::]:443 ssl;
    # tells the name(s) of our website
    server_name localhost www.localhost;

    # Enables SSL protocol
    ssl on;
    # Tells where to look for SSL certificate
    ssl_certificate /etc/ssl/nginx-selfsigned.crt;
    # Tells where to look for SSL key
    ssl_certificate_key /etc/ssl/nginx-selfsigned.key;

    # Tells where to look for all the files related to our website
    root /var/www/localhost;
    # Enables autoindex to redirect us to the choice between wordpress and phpMyAdmin
    autoindex on;
    # Tells the possible names of the index file
    index index.html index.htm index.nginx-debian.html index.php;
    # Tells to check for existence of files before moving on
	location / {
		try_files $uri $uri/ =404;
	}
    # Specifies the php configuration
	location ~ \.php$ {
		include snippets/fastcgi-php.conf;
		fastcgi_pass unix:/run/php/php7.3-fpm.sock;
	}
 }
 ```
 At this point we have added inside everything we need for the entire project, but some parts aren't functionnal yet and will be added further in this guide.
 
 Now that our configuration is ready, we will need to add some lines to our Dockerfile to copy it inside the container and set it up:
 ```Dockerfile
#----------------------------------- 3. CONFIGURE NGINX  --------------------------------------
# NGINX will need a folder where it will search everything related to our website
RUN mkdir /var/www/localhost

# We change the ownership of the folder we just created so any user can acces it
RUN chown -R $USER:$USER /var/www/localhost

# COPY copies files from the given directory on our computer to given directory inside our container.
# If a file already exists in the specified directory, we will overwrite it
# We place it inside /etc/nginx/sites-available as required per NGINX documentation
COPY srcs/localhost /etc/nginx/sites-available

# We also need to create a link between the 2 following folder to "enable" our website
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled

# For the next steps, we will be working inside /var/www/localhost directory
# To avoid writing /var/www/localhost before every command, we can change current working directory
# WORKDIR command in dockerfile changes the directory where next commands will be executed
WORKDIR /var/www/localhost/
#----------------------------------------------------------------------------------------------
```
Now if we try to build our docker image and run it, it downloads/updates Debian Buster, all of the dependencies we need
and also copies our NGINX configuration file inside the container. We still have no way of reaching our website and checking that everything works, this will be added in the last step.
<br />

## 4) Install and configure phpMyAdmin
In step 2 we have installed mariadb-server. Now we will configure it and set up phpMyAdmin to use it.
[**Here (step 2)**](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mariadb-php-lemp-stack-on-debian-10) you can see how to install, launch and setup mariadb databases by running several commands inside Debian Buster terminal. For our project we need to tell our container to execute these commands automatically, without us typing them ourselves. This can be achieved by creating a ".sh" file that we will launch when running our container. In our "srcs" folder, let's create a "start.sh" file and try to configure mariadb and create a database we can later use for Wordpress by adding the following commands inside:
```Shell
# Start up NGINX
service nginx start;

# Start up MySQL
service mysql start;

# Start up PHP
service php7.3-fpm start;

#------------------------ Create & configure Wordpress database ----------------------------------------
# 1. Create a database named wordpress
echo "CREATE DATABASE wordpress;" | mysql -u root --skip-password;

# 2. Create a root account which can access all tables in wordpress
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;" | mysql -u root --skip-password;

# 3. Apply the previous changes (otherwise it waits until we restart the server)
echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password;

# 4. Disregards the password, check the UNIX socker instead
# Since we setup no password, it wouldn't let us connect to phpMyAdmin otherwise
echo "update mysql.user set plugin='' where user='root';" | mysql -u root --skip-password;

# Restart the nginx to apply the changes
service nginx restart;

# Restart php to apply the changes
service php7.3-fpm restart;
```
Now that all of the commands we need to execute are ready and waiting in "start.sh" file, let's place it in our
container and tell our Dockerfile to execute it.
```Dockerfile
#----------------------------------- 4. PHP MY ADMIN ---------------------------------------
# Move start.sh from our computer inside the container
COPY ./srcs/start.sh ./

# Every other command in Dockerfile is executed while "building" our container
# CMD tells Docker the default command to execute when we are "running" our container
CMD bash start.sh;
```
Now that we are managing databases with MariaDB and we have created a database, let's download and configure phpMyAdmin to test it! 

First, just as for NGINX, phpMyAdmin will need a configuration file to set up some basic behaviour.
Let's create a "config.inc.php" file in our "srcs" folder and add the following lines inside:
```PHP
<?php
/**
 * phpMyAdmin sample configuration, you can use it as base for
 * manual configuration. For easier setup you can use setup/
 *
 * All directives are explained in documentation in the doc/ folder
 * or at <https://docs.phpmyadmin.net/>.
 */

declare(strict_types=1);

/**
 * This is needed for cookie based authentication to encrypt password in
 * cookie. Needs to be 32 chars long.
 */
$cfg['blowfish_secret'] = 'abcdefghijklmnopqrstuvwxyz0123456789'; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */

/**
 * Servers configuration
 */
$i = 0;

/**
 * First server
 */
$i++;
/* Authentication type */
$cfg['Servers'][$i]['auth_type'] = 'cookie';
/* Server parameters */
$cfg['Servers'][$i]['host'] = 'localhost';
$cfg['Servers'][$i]['compress'] = false;
/* This is needed to login to phpMyAdmin without the use of the password */
$cfg['Servers'][$i]['AllowNoPassword'] = true;

/**
 * Directories for saving/loading files from server
 */
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';
```

Now that we have our phpMyAdmin configuration file ready, let's download phpMyAdmin and set everything up!
Add the following lines to our Dockerfile:
```Dockerfile
# Download phpMyAdmin by using "wget" which we installed in step 2
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-english.tar.gz

# Extract the downloaded compressed files and remove the ".tar" file we no longer need
RUN tar -xf phpMyAdmin-5.1.0-english.tar.gz && rm -rf phpMyAdmin-5.1.0-english.tar.gz

# Move the extracted files in the "phpmyadmin" folder
RUN mv phpMyAdmin-5.1.0-english phpmyadmin

# Copy the "config.inc.php" file we created to the same "phpmyadmin" folder
COPY ./srcs/config.inc.php phpmyadmin
#----------------------------------------------------------------------------------------------
```

Now if we try to build our docker image and run it, it downloads/updates Debian Buster, all of the dependencies we need
and also copies our NGINX configuration file inside the container. It also downloads and installs phpMyAdmin, creates a database and a profile which will be able to access it and copies phpMyAdmin configuration file inside our container.

