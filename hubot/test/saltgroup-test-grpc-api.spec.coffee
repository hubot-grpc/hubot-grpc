Helper = require('hubot-test-helper')
helper = new Helper('../scripts/cloud.coffee')

co     = require('co')
expect = require('chai').expect

defaultDelayTime = 1000

delay = (time) ->
  return new Promise (fulfill) ->
    setTimeout fulfill, time

describe 'saltgroup-test-grpc-api', ->
  beforeEach ->
    @room = helper.createRoom(httpd: false)


  context 'processDouble(MessageDouble)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processDouble val:1.234'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
        expect(@room.messages[1][1]).to.include('val: 100.111')

  context 'processFloat(MessageFloat)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processFloat val:1.234'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages[1][1]).to.include('val: 200.222')

  context 'processInt32(MessageInt32)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processInt32 val:32'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processInt32 val:32']
        ['hubot', 'val: 100']
      ]

  context 'processInt64(MessageInt64)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processInt64 val:64'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processInt64 val:64']
        # strange but int64 is mapped to a string it seems -> maybe number isnt long enough?
        ['hubot', "val: '200'"]
      ]

  context 'processUint32(MessageUint32)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processUint32 val:320'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processUint32 val:320']
        ['hubot', 'val: 300']
      ]

  context 'processUint64(MessageUint64)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processUint64 val:640'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processUint64 val:640']
        ['hubot', "val: '400'"]
      ]

  context 'processSint32(MessageSint32)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processSint32 val:3200'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processSint32 val:3200']
        ['hubot', 'val: 500']
      ]

  context 'processSint64(MessageSint64)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processSint64 val:6400'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processSint64 val:6400']
        ['hubot', "val: '600'"]
      ]

  context 'processFixed32(MessageFixed32)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processFixed32 val:32000'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processFixed32 val:32000']
        ['hubot', 'val: 700']
      ]

  context 'processFixed64(MessageFixed64)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processFixed64 val:64000'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processFixed64 val:64000']
        ['hubot', "val: '800'"]
      ]

  context 'processSfixed32(MessageSfixed32)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processSfixed32 val:34'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processSfixed32 val:34']
        ['hubot', 'val: 900']
      ]

  context 'processSfixed64(MessageSfixed64)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processSfixed64 val:35'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processSfixed64 val:35']
        ['hubot', "val: '1000'"]
      ]

  context 'processBool(MessageBool)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processBool val:false'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processBool val:false']
        ['hubot', 'val: true']
      ]

  context 'processString(MessageByte)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processString val:"Some long string"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processString val:"Some long string"']
        ['hubot', 'val: OUTPUT']
      ]

  xcontext 'processBytes(MessageString)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processBytes val:b"Is this a valid byte buffer?"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processBytes val:b"Is this a valid byte buffer?"']
        ['hubot', 'val: UTF16 ENCODED STRING']
      ]

  context 'processEnum(MessageEnum)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processEnum enum:"VALUE_REQUEST"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processEnum enum:"VALUE_REQUEST"']
        ['hubot', 'enum: VALUE_RESPONSE']
      ]

  context 'processObject(MessageObject)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processObject object:{val: "string"}'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processObject object:{val: "string"}']
        ['hubot', 'object:\n  val: RESPONSE']
      ]

  context 'processRepeated(MessageRepeated)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processRepeated repeatedMessageObject:[{object:{val: "string"}}, {object: {val: "second"}}]'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processRepeated repeatedMessageObject:[{object:{val: "string"}}, {object: {val: "second"}}]']
        ['hubot', "repeatedMessageObject:\n  - object:\n      val: RESPONSE OBJECT A\n  - object:\n      val: RESPONSE OBJECT B"]
      ]

  context 'processStreamedInput(stream MessageObject)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processStreamedInput object:{val: "string"}'
        yield @room.user.say 'user', 'hubot stream 1 object:{val: "bla"}'
        yield @room.user.say 'user', 'hubot endstream 1'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processStreamedInput object:{val: "string"}']
        ['hubot', 'You just started a stream to the server with id 1']
        ['user', 'hubot stream 1 object:{val: "bla"}']
        ['user', 'hubot endstream 1']
        ['hubot', 'Stream 1 is closed now.']
        ['hubot', "object:\n  val: OBJECT MODIFIED"]
      ]

  context 'processStreamedOutput(MessageObject)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processStreamedOutput object:{val: "string"}'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processStreamedOutput object:{val: "string"}']
        ['hubot', "object:\n  val: OBJECT 1 MODIFIED"]
        ['hubot', "object:\n  val: OBJECT 2 MODIFIED"]
        ['hubot', "object:\n  val: OBJECT 3 MODIFIED"]
      ]

  context 'processStreamedInputOutput(stream MessageObject)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processStreamedInputOutput object:{val: "string"}'
        yield @room.user.say 'user', 'hubot stream 1 object:{val: "bla"}'
        yield @room.user.say 'user', 'hubot endstream 1'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processStreamedInputOutput object:{val: "string"}']
        ['hubot', 'You just started a stream to the server with id 1']
        ['user', 'hubot stream 1 object:{val: "bla"}']
        ['user', 'hubot endstream 1']
        ['hubot', 'Stream 1 is closed now.']
        ['hubot', "object:\n  val: OBJECT 1 MODIFIED"]
        ['hubot', "object:\n  val: OBJECT 2 MODIFIED"]
        ['hubot', "object:\n  val: OBJECT 3 MODIFIED"]
      ]

  context 'processNested(MessageNested)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processNested val: {innerVal: "inner"}'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processNested val: {innerVal: "inner"}']
        ['hubot', 'val:\n  innerVal: RESPONSE']
      ]

  context 'processNestedExternal(MessageNestedExternal)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', 'hubot call fapra.teamsaltstack.testapi.TestService.processNestedExternal val: {innerVal: "inner"}'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'correctly works', ->
      expect(@room.messages).to.eql [
        ['user', 'hubot call fapra.teamsaltstack.testapi.TestService.processNestedExternal val: {innerVal: "inner"}']
        ['hubot', 'val:\n  innerVal: RESPONSE']
      ]
