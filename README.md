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

Furthermore you need to put the proto file under ```/api/main.proto``` using a docker volume or modifying the dockerfile.

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

#### The generic way

With the following syntax you can call any grpc method without any further configuration.

- ```botname call package.service.method parameters```

#### Specifying Parameters

If the request message type would be *Object* defined as follows:

```
message Simple {
  string text = 1;
}

message Object {
  string param1 = 1;
  Simple param2 = 2;
}
```

the request would look like this:

```
botname call some.method param1: "plain string" param2: { text: "lorem ipsum"}
```

So basically all fields of the request message become top level parameters, which in turn can be specified in a JSON-like syntax.
Fieldnames are however not enclosed in ```"```.

All fields are optional as this is the case in proto3 messages.

#### Calling by applications

You can define additional aliases for creating shorter commands.
These can be called with ```botname your_alias parameters```, where the parameters are passed the same way as above.

### Additional configuration through config.yml file

Because the default call syntax can become quite tedious to write in a chat, there are several possibilities to enhance the usability through an optional config file.

This config file is using the Yaml file format and offers the following features:

- Defining shorthand aliases for methods (also multiple aliases are possible per method)
- Specifying default parameters that are passed on if the user does not override them (different defaults can be specified for different aliases of the same method)
- Disabling the default call syntax (and thus if no alias is defined, disabling the whole method)
- Restricting method calls to certain users
- Providing custom handlebars templates for defining how hubot responds
- Defining custom help messages that are displayed in the *help* commands (also possible on the level of aliases)

An example config file for a [XKCD API](https://github.com/hubot-grpc/xkcd-grabber):

```
allow_default_calls: true

procedure_options:
  - procedure: .xkcd.XkcdGrabber.getLatestUrl
    allow_default_call: false
    help: "Default call help"
    custom_calls:
      - alias: latest
        help: "get the latest xkcd comic"
  - procedure: .xkcd.XkcdGrabber.getPreviousUrl
    defaults:
      offset: 2
    custom_calls:
      - alias: "go three back"
        defaults:
          offset: 3
      - alias: "two back"
  - procedure: .xkcd.XkcdGrabber.getNextUrl
    help: "Calls third and returns nothing"
    custom_calls:
      - alias: "next"
  - procedure: .xkcd.XkcdGrabber.getRandomUrl
    allowed_users:
      - alice
      - bob
```


## Limitations

- Maps only support string keys
- there is no elegant solution to set the script up without using the container
  - there is no npm package for the plugin
- There is no way to see the status of long running requests (or cancel them)
- The docker container only supports Slack out of the box
- Error handling is bad
  - some catches throw errors themselves and thus give weird error messages
- The connection to the grpc service is currently only made insecurly
- Byte data is not nice in chats
- Url types and byte buffers cannot be specified as default parameters in the config file 


## Wishlist

- More modular design
  - Maybe using events in hubot and splitting core functionality and the interfacing with the user up.
  - Allowing to use plugins for example for pasting byte data onto a file pasting service.
- Published images/packages on docker hub and npm
- Integration tests for all advanced features
- Running the integration tests in travis-ci
