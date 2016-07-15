Helper = require('hubot-test-helper')
helper = new Helper('../scripts/cloud.coffee')

co     = require('co')
expect = require('chai').expect

defaultDelayTime = 1000

delay = (time) ->
  return new Promise (fulfill) ->
    setTimeout fulfill, time

describe 'chefgroup-test-grpc-api', ->
  beforeEach ->
    @room = helper.createRoom(httpd: false)


  context 'BidirectionalStream(stream GreetingRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call TesterService.BidirectionalStream name:"Markus"'
        yield delay(defaultDelayTime)
        yield @room.user.say 'user', 'hubot stream 1 name:"Jan"'
        yield delay(defaultDelayTime)
        yield @room.user.say 'user', 'hubot stream 1 name:"Kai"'
        yield delay(defaultDelayTime)
        yield @room.user.say 'user', 'hubot endstream 1'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call TesterService.BidirectionalStream name:"Markus"']
        ['hubot', 'You just started a stream to the server with id 1']
        ["hubot", "greeting: Hello Markus"]
        ["user", 'hubot stream 1 name:"Jan"']
        ["hubot", "greeting: Hello Jan"]
        ["user", 'hubot stream 1 name:"Kai"']
        ["hubot", "greeting: Hello Kai"]
        ["user", 'hubot endstream 1']
        ['hubot', 'Stream 1 is closed now.']
      ]

  context 'NoStream(CalculationRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call .TesterService.NoStream values_to_use:[1,2,3,4,5,6,7,8,9,10] type:"ADDITION" info:{info: "info"}'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call .TesterService.NoStream values_to_use:[1,2,3,4,5,6,7,8,9,10] type:"ADDITION" info:{info: "info"}']
        ['hubot', "map:\n  ADDITION: '55'"]
      ]

  context 'RequestStream(stream AddUserRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call .TesterService.RequestStream firstname:"Michael" lastname:"Müller"'
        yield delay(defaultDelayTime)
        yield @room.user.say 'user', 'hubot stream 1 firstname:"Foo" lastname:"Bar"'
        yield delay(defaultDelayTime)
        yield @room.user.say 'user', 'hubot endstream 1'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call .TesterService.RequestStream firstname:"Michael" lastname:"Müller"']
        ['hubot', 'You just started a stream to the server with id 1']
        ['user', 'hubot stream 1 firstname:"Foo" lastname:"Bar"']
        ['user', 'hubot endstream 1']
        ['hubot', 'Stream 1 is closed now.']
        ['hubot', 'qty: 2']
      ]

  context 'ResponseStream(ListUsersRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call .TesterService.ResponseStream limit:4'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call .TesterService.ResponseStream limit:4']
        ['hubot', "user:\n  firstname: Michael\n  lastname: Müller"]
        ['hubot', "user:\n  firstname: Foo\n  lastname: Bar"]
      ]
