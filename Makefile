# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ysoroko <ysoroko@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/03/16 11:34:07 by ysoroko           #+#    #+#              #
#    Updated: 2021/03/16 12:14:53 by ysoroko          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

build:
	docker build -t ft_server .

run:
	docker run -it --rm -p 80:80 -p 443:443 ft_server

all: build
	run

clean:
	docker system prune
	# docker rmi $(docker images -q)
	# docker rm $(docker ps -qa)