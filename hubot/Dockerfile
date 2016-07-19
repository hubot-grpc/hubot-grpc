FROM node:latest

# Usual update / upgrade
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
        apt-get install -y redis-server git-core && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install coffee-script, hubot
RUN npm install -g yo generator-hubot coffee-script pegjs mocha

# Working enviroment
RUN useradd -m hubot
USER hubot
WORKDIR /home/hubot

# Install Hubot
RUN yo hubot --name="grpcbot" --defaults

# Install all dependencies as one command to work around limitations on aufs
RUN npm install valid-url protobufjs js-yaml hubot-slack grpc hashmap handlebars co chai hubot-test-helper --save

# Modules
COPY modules modules
# Add tests
COPY test test
USER root
RUN chown -R hubot /home/hubot
# change user back
USER hubot

# create parsers
RUN pegjs modules/parsers/call.pegjs
RUN pegjs --allowed-start-rules Parameters modules/parsers/call.pegjs modules/parsers/params.js


# Add the plugin script
ADD scripts/cloud.coffee scripts/cloud.coffee

# Entrypoint
ENTRYPOINT ["/bin/sh", "-c", "bin/hubot --adapter slack"]
