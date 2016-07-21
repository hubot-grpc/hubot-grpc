# Description:
#   This script provides the functionality to use a rpc service defined by a proto3-file via hubot
#
# Dependencies:
#
# Commands:
#   hubot stream <id> (<parameter>:<value>)* - sends a stream of the specified parameter(s)
#   hubot endstream <id> - closes a stream
#
# Author:
#   <github username of the original script author>

yaml          = require 'js-yaml'
callParser    = require '../modules/parsers/call'
paramParser   = require '../modules/parsers/params'
Caller        = require '../modules/caller/caller'
ProtoHelper   = require '../modules/proto-helper/proto-helper'
ConfigHelper  = require '../modules/config-helper/config-helper'

protopath     = '/api/main.proto'
configpath    = '/api/config.yml'
host          = process.env.API_HOST + ':' + process.env.API_PORT

caller        = new Caller       protopath, host
protoHelper   = new ProtoHelper  protopath
configHelper  = new ConfigHelper configpath, protoHelper.getAllMethods()

makeCall = (response, normalizedCall, defaultParameters) ->
  # Check if the user is allowed to call this method
  if(!configHelper.isUserAllowed(normalizedCall.fqn, response.message.user.name))
    response.send "You are not allowed to do this"
    return

  # merge params with default params from config
  normalizedCall.parameters = configHelper.applyParametersToDefaults(defaultParameters, normalizedCall.parameters)
  try
    protoHelper.validateCall({
      fqn: normalizedCall.fqn,
      request: normalizedCall.parameters
    })
    try
      # Randomly choose on of the available response templates from the confighelper
      responseTemplate = response.random configHelper.getResponseTemplates(normalizedCall.fqn)
      stream = caller.call(normalizedCall,
        # render the response using the template
        (res) -> response.send responseTemplate({response: res, user: response.message.user})
      , (err) -> response.send yaml.safeDump err.message
      )
      if stream.clientStream
        response.send "You just started a stream to the server with id #{stream.id}"
    catch err
      response.send(err.message)
  catch err
    response.send err.message

installCustomCallHandler = (robot, customCall) ->
  robot.respond customCall.regexp, (response) ->
    try
      # try to parse everything contained in the last matching group
      # last matching group, because user could specify an alias containing ()
      # || "" because matching group is null if no parameter is given
      params = paramParser.parse(response.match[response.match.length - 1] || "")
      normalizedCall = {
        method: customCall.methodSplit,
        fqn: customCall.methodFqn,
        parameters: params,
      }
      console.log(customCall)
      makeCall response, normalizedCall, customCall.defaults
    catch err
      console.log err
      #response.send "Cannot parse your call (line: #{err.location.start.line}, column: #{err.location.start.column}): #{err.message}"


# Configures the plugin
module.exports = (robot) ->

  # Add help commands
  for command in configHelper.getCommands()
    robot.commands.push "*#{robot.name} #{command}*"

  # Add listeners for custom aliases
  for customCall in configHelper.getCustomCalls()
    installCustomCallHandler(robot, customCall)


  # Adds a custom listener for dynamically calling grpc services
  robot.respond /call\s+(\S[\s\S]*)/i, (response) ->
    try
      # try to parse everything contained in the matching group
      parsed = callParser.parse(response.match[1])
      makeCall response, parsed, configHelper.getDefaultParameters(parsed.fqn)
    catch err
      response.send "Cannot parse your call (line: #{err.location.start.line}, column: #{err.location.start.column}): #{err.message}"

  # Add a listener for sending data to request streams
  robot.respond /stream\s+(\d+)\s+(\S[\s\S]*)/i, (response) ->
    parsed = undefined
    paramMatch = response.match[response.match.length - 1]
    idMatch = parseInt(response.match[response.match.length - 2])
    try
      parsed = paramParser.parse(paramMatch)
    catch error
      response.send JSON.stringify error
    if parsed
      try
        # TODO Validate the message (currently not known at this point)
        caller.stream(idMatch, parsed)
      catch error
        response.send error.message

  robot.respond /endstream\s+(\d+)\s*/i, (response) ->
    idMatch = parseInt(response.match[1])
    caller.endStream idMatch
    response.send "Stream #{idMatch} is closed now."
