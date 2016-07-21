# hubot-grpc

[![Build Status](https://travis-ci.org/hubot-grpc/hubot-grpc.svg?branch=master)](https://travis-ci.org/hubot-grpc/hubot-grpc)

```hubot-grpc``` is a plugin for the [Hubot](https://hubot.github.com/) chatbot which allows to generically call grpc services directly from chat applications like Slack.

It features:
  - A generic way to map grpc services into the chat format (This is part of [API bricks](https://github.com/apibricks) where also different mappings to e.g. RESTful services are available)
  - A YAML configuration format for enhancing the user experience when interacting with the service
  - Containerized execution using docker

## Usage

### Getting started

It is suggested to use docker to run the bot with this script.
While there is no container image on docker hub yet, you can use the [Dockerfile](hubot/Dockerfile) to build the image. This however currently only supports Slack as a chat platform.

Just navigate into the hubot folder and run something like ```docker build -t hubot .```.
After this you should be able to start a container using the image with ```docker run hubot```.

For it to be useful however you should have a grpc service running somewhere (ideally also in a container, see [API bricks specification](https://github.com/apibricks/apibricks-spec)), which needs to be accessible from the hubot container.

Information on how the bot can connect to the grpc service can be passed on via environment variables.

### Environment Variables

The following Variables are available for configuration

- HUBOT_SLACK_TOKEN - The slack integration token for connecting to the chat
- API_HOST - The hostname to reach your grpc-service
- API_PORT - The port on which the grpc-service is running
- API_PROTO_PATH - A custom path of where to find the proto file that describes the grpc-service (defaults to ```/api/main.proto```)
- API_CONFIG_PATH - A custom path of where to find the config.yml file (defaults to ```/api/config.yml```)

### Example Docker-Compose file

There are some examples of docker-compose files in the [compose](/compose) folder for running integration tests against some services. For a quick start you can use a file similar to the following one (place it in the repository root as ```docker-compose.yml```) and add your slack integration token. ```docker-compose up --build``` should build hubot and start the containers.

```
version: '2'
services:
  testing:
    image: apibricks/ansiblegroup-test-grpc-api
  hubottesting:
    build:
      context: hubot
    environment:
      - HUBOT_SLACK_TOKEN=your-token
      - API_HOST=server
      - API_PORT=50051
    links:
      - testing:server
    volumes_from:
      - testing
```

### How to talk to hubot

### Additional configuration through config.yml file



## Limitations
