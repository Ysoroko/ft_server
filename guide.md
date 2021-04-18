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

This is adding several `apt-get install` to our Dockerfile. For this project there are several things we need:
```Dockerfile
#----------------------------------- 2. Intall Dependencies --------------------------------------
# Sysvinit-utils for "service" command used to easaily restart out nginx after updating
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
RUN php-zip php-net-socket php-gd php-xml-util php-gettext php-mysql php-bcmath
#-------------------------------------------------------------------------------------------------
```
Now if we try to build our docker image and run it, it downloads/updates Debian Buster and also downloads all of the dependencies we need.

## 3) Configure NGINX
In the previous part of the project we have downloaded nginx using `RUN apt-get -y install nginx`.

Now, we will configure it to connect our container to our webpage.

In order to do so, NGINX will need a configuration file where we will tell it what is our webpage name, what ports he needs to "listen" to and what other tools we will use.

Normally on our computer we would simply create a file and write inside, but since we need to do it inside the container, we prepare the configuration file in advance and
then copy it inside our container when we need it.
In our project folder, let's create a "src" folder as required by subject and create an empty file named "localhost" inside.

localhost is the webpage we will be using to acces our web server in this project.

Add the following php code to our "localhost" file:
```php
server {
     //tell nginx to listen to the port 80
     listen 80;
     //same but apparently it's required for IPV6
     listen [::]:80;
     //tell nginx the possible names of our website he'll be redirecting us to
     server_name localhost www.localhost;
     //whenever we try to reach "localhost" or "www.localhost" it will actually redirect us to https://$host$request_uri
     return 301 https://$host$request_uri;
 }
 server {
    //Same thing but for 443 port
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name localhost www.localhost;

    //The following part is used for SSL required in the subject and doesn't do much at the moment but it will be used later
    ssl on;
    ssl_certificate /etc/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/nginx-selfsigned.key;
  
    //The root directive specifies the root directory that will be used to search for a file
    root /var/www/localhost;
    
    //Autoindex is what will redirect us to the choice between phpMyAdmin and Wordpress. For the moment, it doesn't do much
    autoindex on;
    //The index directive defines the index configuration file’s name (the default value is index.html)
    index index.html index.htm index.nginx-debian.html index.php;
    
    //According to NGINX documentation this will chek for the existence of the files before using them
	location / {
		try_files $uri $uri/ =404;
	}
 //This is needed for php configuration and use in NGINX
	location ~ \.php$ {
		include snippets/fastcgi-php.conf;
		fastcgi_pass unix:/run/php/php7.3-fpm.sock;
	}
 }
 ```
 
 Now that we have our configuration file ready, we will need to add some lines to our Dockerfile to copy it inside the container and set it up:
 ```Dockerfile
#----------------------------------- 3. CONFIGURE NGINX  --------------------------------------
# NGINX will need a folder where it will search everything related to our website
RUN mkdir /var/www/localhost

# We change the ownership of the folder we just created so any user can acces it
RUN chown -R $USER:$USER /var/www/localhost

# COPY copies files from our computer inside our container.
# We place it inside /etc/nginx/sites-available as required per NGINX documentation
COPY srcs/localhost /etc/nginx/sites-available

# We also need to create a link between the 2 following folder to "enable" our website
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled
#----------------------------------------------------------------------------------------------
```