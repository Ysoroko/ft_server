# ft_server
#### A server created and launched locally with Docker, integrated phpMyAdmin, Wordpress, MariaDB and SSL

#### Using dockerfile with a single container, this project allows us to launch the server on any computer with Docker, without worrying about the dependencies and compatibility issues

--------------------------------------------------------------------------------------------------------------------------------------

#### ✅ [My complete tutorial to validate this project](https://github.com/Ysoroko/ft_server_tutorial)

--------------------------------------------------------------------------------------------------------------------------------------

Here below you can see the results in the web browser:
### Wordpress
![](srcs/images/wordpress.png)

### PhpMyAdmin
![](srcs/images/phpMyAdmin.png)

### Auto-Index
![](srcs/images/index.png)

--------------------------------------------------------------------------------------------------------------------------------------

### Test it yourself:
1) ❗ Requires Docker installed and running
2) Clone this repository anywhere you want, on any OS with Docker running.
3) Run `make build` in your terminal to build the container
4) Run `make run` to launch the container
5) Navigate to [**localhost**](https://localhost) in your browser to see the result

--------------------------------------------------------------------------------------------------------------------------------------

# Useful links that helped me with this project:
- [**Udemy course as a useful introduction to Docker**](https://www.udemy.com/course/docker-and-kubernetes-the-complete-guide/)
- [**How to install LEMP stack on Debian 10**](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mariadb-php-lemp-stack-on-debian-10)
- [**Wordpress and phpMyAdmin setup with Docker on Alpine**](https://codingwithmanny.medium.com/custom-wordpress-docker-setup-8851e98e6b8)
- [**Generating a self signed SSL key**](https://linuxize.com/post/creating-a-self-signed-ssl-certificate/)
- [**Incomplete project guide by a 42 student (part 1)**](https://forhjy.medium.com/how-to-install-lemp-wordpress-on-debian-buster-by-using-dockerfile-1-75ddf3ede861)
- [**Incomplete project guide by a 42 student (part 2)**](https://forhjy.medium.com/42-ft-server-how-to-install-lemp-wordpress-on-debian-buster-by-using-dockerfile-2-4042adb2ab2c)

