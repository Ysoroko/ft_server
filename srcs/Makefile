# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ysoroko <ysoroko@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/03/16 11:34:07 by ysoroko           #+#    #+#              #
#    Updated: 2021/03/17 12:16:52 by ysoroko          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# -t allows to specify the name of the created container
build:
	cd ../; docker build -t ft_server .

# -it Allows me to enter the containers terminal (in a "pretty" format)
# -rm Removes the container when we exit from it
# -p Links the ports (necessary on MacOS)
# port 80: port HTTP
# port 443: port HTTPS
run:
	cd ../; docker run -it --rm -p 80:80 -p 443:443 ft_server

all: build
	run

# Commented out commands don't work properly with Makefile
clean:
	cd ../; docker system prune
	# docker rmi $(docker images -q)
	# docker rm $(docker ps -qa)