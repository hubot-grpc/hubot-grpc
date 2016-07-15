Helper = require('hubot-test-helper')
helper = new Helper('../scripts/cloud.coffee')

co     = require('co')
expect = require('chai').expect

defaultDelayTime = 1000

delay = (time) ->
  return new Promise (fulfill) ->
    setTimeout fulfill, time

describe 'puppetgroup-test-grpc-api', ->
  beforeEach ->
    @room = helper.createRoom(httpd: false)

  context 'stringTest(StringRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call cloudlab.TestOpsProto.Test.stringTest name: "Hans" place: "München"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call cloudlab.TestOpsProto.Test.stringTest name: "Hans" place: "München"']
        ['hubot', 'output: Hi Hansfrom München']
      ]

  context 'integerTest(IntegerRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call cloudlab.TestOpsProto.Test.integerTest firstNumber: 5 secondNumber: 7'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call cloudlab.TestOpsProto.Test.integerTest firstNumber: 5 secondNumber: 7']
        ['hubot', "output: 'Sum is: 12'"]
      ]

  context 'floatTest(FloatRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call cloudlab.TestOpsProto.Test.floatTest firstNumber: 0.5 secondNumber: 0.7'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call cloudlab.TestOpsProto.Test.floatTest firstNumber: 0.5 secondNumber: 0.7']
        ['hubot', "output: 'Sum is: 1.2'"]
      ]

  context 'doubleTest(DoubleRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call cloudlab.TestOpsProto.Test.doubleTest firstNumber: 0.5 secondNumber: 0.7'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call cloudlab.TestOpsProto.Test.doubleTest firstNumber: 0.5 secondNumber: 0.7']
        ['hubot', "output: 'Sum is: 1.2'"]
      ]

  context 'boolTest(EvenOddRequest) - even', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call cloudlab.TestOpsProto.Test.boolTest number: 2'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call cloudlab.TestOpsProto.Test.boolTest number: 2']
        ['hubot', "output: true"]
      ]

  context 'boolTest(EvenOddRequest) - odd', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call cloudlab.TestOpsProto.Test.boolTest number: 3'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call cloudlab.TestOpsProto.Test.boolTest number: 3']
        ['hubot', "output: false"]
      ]

  context 'enumTest(EnumRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call cloudlab.TestOpsProto.Test.enumTest status: "DELIVERED"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call cloudlab.TestOpsProto.Test.enumTest status: "DELIVERED"']
        ['hubot', "output: 'Status is: DELIVERED'"]
      ]

  context 'repeatedTest(Array)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call cloudlab.TestOpsProto.Test.repeatedTest items: ["first", "second", "another"]'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call cloudlab.TestOpsProto.Test.repeatedTest items: ["first", "second", "another"]']
        ['hubot', "output: 'Items are: [first, second, another]'"]
      ]

  xcontext 'mapTest(MapRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call cloudlab.TestOpsProto.Test.mapTest map:{key:"value", second: "pair"}'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call cloudlab.TestOpsProto.Test.mapTest map:{key:"value", second: "pair"}']
        ['hubot', "output: 'Items are: [first, second, another]'"]
      ]

  context 'ClientStream(stream StringRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call cloudlab.TestOpsProto.Test.ClientStream name: "Jan" place: "Stuttgart"'
        yield @room.user.say 'user', 'hubot stream 1 name: "Jens" place: "Berlin"'
        yield @room.user.say 'user', 'hubot endstream 1'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call cloudlab.TestOpsProto.Test.ClientStream name: "Jan" place: "Stuttgart"']
        ['hubot', 'You just started a stream to the server with id 1']
        ['user', 'hubot stream 1 name: "Jens" place: "Berlin"']
        ['user', 'hubot endstream 1']
        ['hubot', 'Stream 1 is closed now.']
        ['hubot', "output: Hi Jan. You're from Stuttgart"]
      ]

  context 'ServerStream(StringRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call cloudlab.TestOpsProto.Test.ServerStream name: "Jan" place: "Stuttgart"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call cloudlab.TestOpsProto.Test.ServerStream name: "Jan" place: "Stuttgart"']
        ["hubot", "name: Jan\nplace: ''"]
        ["hubot", "name: ''\nplace: Stuttgart"]
      ]

  context 'BidirectionalStream(stream StringRequest)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call cloudlab.TestOpsProto.Test.BidirectionalStream name: "Jan" place: "Stuttgart"'
        yield @room.user.say 'user', 'hubot stream 1 name: "Jens" place: "Berlin"'
        yield @room.user.say 'user', 'hubot endstream 1'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call cloudlab.TestOpsProto.Test.BidirectionalStream name: "Jan" place: "Stuttgart"']
        ['hubot', 'You just started a stream to the server with id 1']
        ['user', 'hubot stream 1 name: "Jens" place: "Berlin"']
        ['user', 'hubot endstream 1']
        ['hubot', 'Stream 1 is closed now.']
        ['hubot', "name: Jan\nplace: ''"]
        ['hubot', "name: ''\nplace: Stuttgart"]
      ]
