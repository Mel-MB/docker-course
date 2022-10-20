# Start from current (LTS) version of nodeJS, found on dockerHub (https://hub.docker.com/)
FROM node:current-alpine3.16

# specify root directory to execute containers commands
WORKDIR /home/server

# execute cmd as you would do in a local node command prompt (can be repeated as many times as dependancy nedeed)
# => install json-server package for node
RUN npm install -g json-server

# copy file from your image to the container (can be repeated as many times as import nedeed)
COPY db.json /home/server/db.json

# Specify openned port(s)
EXPOSE 3000

# Start with entrypoint json-server with db source and host with ip adress as argument
# Could also work with CMD, but CMD would be erased if `docker run` is provided any arguement later
ENTRYPOINT ["json-server", "db.json", "--host", "0.0.0.0"]
# > json-server db.json