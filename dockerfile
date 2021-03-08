# Use an existing docker image as base
# The image is selected based on all the default programs
# provided which will help us to launch the image
FROM alpine as builder
# as builder specifies the stage

# Changes the working directory 
WORKDIR /usr/app

# Allows us to import a file before RUN to avoid rerunning 
# the commands every time we modify the file here
COPY ./package.json ./

# Download and install a dependency
# Apache package manage is preinstalled on alpine image
RUN apk add --update redis
RUN apk add --update gcc

# Copy moves files from our local machine to the container
# Syntax: COPY [PATH TO FILES] [PATH TO CONTAINER WORKSPACE]
COPY ./ ./
# copies all from the current directory to the current
# working directory inside the container

RUN npm run build 

# Tell the image what to do when it starts as a container
CMD ["redis-server"]
#unneccessary if followed by another stage (FROM)

FROM nginx
COPY --from=builder /usr/app/build /usr/share/nginx/html