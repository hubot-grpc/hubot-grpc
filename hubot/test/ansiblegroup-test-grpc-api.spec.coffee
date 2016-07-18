Helper = require('hubot-test-helper')
helper = new Helper('../scripts/cloud.coffee')

co     = require('co')
expect = require('chai').expect

defaultDelayTime = 1000

delay = (time) ->
  return new Promise (fulfill) ->
    setTimeout fulfill, time

describe 'ansiblegroup-test-grpc-api', ->
  beforeEach ->
    @room = helper.createRoom(httpd: false)


  #################
  # Non Streaming #
  #################
  context 'emptyResponse(Empty)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.emptyResponse'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns an empty object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.emptyResponse']
        ['hubot', "{}"]
      ]

  context 'simpleResponse(Empty)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.simpleResponse'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.simpleResponse']
        ['hubot', "text: test text"]
      ]

  context 'complexResponse(Empty)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.complexResponse'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.complexResponse']
        ['hubot', "first:\n  text: first\nsecond:\n  text: second"]
      ]

  context 'simpleRequest(Simple)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.simpleRequest text:"bla"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns an empty object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.simpleRequest text:"bla"']
        ['hubot', "{}"]
      ]

  context 'complexRequest(Complex)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.complexRequest first:{text:"Bla"} second: { text: "second"}'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns an empty object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.complexRequest first:{text:"Bla"} second: { text: "second"}']
        ['hubot', "{}"]
      ]

  context 'simpleRequestComplexResponse(Simple)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.simpleRequestComplexResponse text : "simple"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.simpleRequestComplexResponse text : "simple"']
        ['hubot', "first:\n  text: simple\nsecond:\n  text: simple"]
      ]

  #################
  #   Streaming   #
  #################
  context 'streamingRequest(stream Simple)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.streamingRequest text : "simple"'
        yield @room.user.say 'user', '@hubot stream 1'
        yield @room.user.say 'user', 'hubot stream 1 text : "last"'
        yield @room.user.say 'user', 'hubot endstream 1'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct responses', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.streamingRequest text : "simple"']
        ['hubot', "You just started a stream to the server with id 1"]
        ['user', '@hubot stream 1']
        ['user', 'hubot stream 1 text : "last"']
        ['user', 'hubot endstream 1']
        ['hubot', "Stream 1 is closed now."]
        ['hubot', "text: last"]
      ]

  context 'streamingResponse(Empty)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.streamingResponse'
        # Wait for hubot to respond
        yield delay(1000 + defaultDelayTime)

    it 'has the correct number of messages', ->
      expect(@room.messages).to.have.length(11)


    it 'streams the correct responses', ->
      # Streamed responses can vary in order -> check for existance only
      for i in [0..9]
        expect(
          @room.messages.find(
            (item) ->
              item[0] == 'hubot' && item[1] == "text: test text #{i}"
          )
        ).to.not.be.undefined

  context 'bidirectionalStreaming(stream Simple)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.bidirectionalStreaming text : "first"'
        yield delay(50)
        yield @room.user.say 'user', 'hubot stream 1 text: "second"'
        yield delay(50)
        yield @room.user.say 'user', 'hubot stream 1 text: "third"'
        yield delay(50)
        yield @room.user.say 'user', 'hubot endstream 1'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'streams the requests back', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.bidirectionalStreaming text : "first"']
        ['hubot', "You just started a stream to the server with id 1"]
        ['hubot', "text: first"]

        ['user', 'hubot stream 1 text: "second"']
        ['hubot', "text: second"]

        ['user', 'hubot stream 1 text: "third"']
        ['hubot', "text: third"]

        ['user', 'hubot endstream 1']
        ['hubot', "Stream 1 is closed now."]
      ]

  #################
  #     Enums     #
  #################
  context 'enumRequest(Status)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.enumRequest value:"B"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.enumRequest value:"B"']
        ['hubot', 'text: \'{"value":"B"}\'']
      ]

  context 'enumResponse(Empty)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.enumResponse'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.enumResponse']
        ['hubot', 'value: C']
      ]

  #################
  # Oneof Request #
  #################
  context 'oneOfRequest(Info)', ->

    it 'returns the correct object for a text request', ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.oneOfRequest text:"test"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)
      .then =>
        expect(@room.messages).to.eql [
          ['user', '@hubot call iaas.fapra.testing.test.oneOfRequest text:"test"']
          ['hubot', "text: '{\"content\":\"text\",\"text\":\"test\",\"object\":null}'"]
        ]

    it 'returns the correct object for Simple request', ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.oneOfRequest object:{text: "test"}'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)
      .then =>
        expect(@room.messages).to.eql [
          ['user', '@hubot call iaas.fapra.testing.test.oneOfRequest object:{text: "test"}']
          ['hubot', "text: '{\"content\":\"object\",\"text\":\"\",\"object\":{\"text\":\"test\"}}'"]
        ]

    xit 'rejects request with both oneof parameters', ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.oneOfRequest text:"test" object:{text: "test"}'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)
      .then =>
        expect(@room.messages).to.eql [
          ['user', '@hubot call iaas.fapra.testing.test.oneOfRequest text:"test" object:{text: "test"}']
          ['hubot', "text: '{\"content\":\"object\",\"text\":\"test\",\"object\":{\"text\":\"test\"}}'"]
        ]

    it 'returns correct response if nothing is passed', ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.oneOfRequest'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)
      .then =>
        expect(@room.messages).to.eql [
          ['user', '@hubot call iaas.fapra.testing.test.oneOfRequest']
          ['hubot', "text: '{\"content\":null,\"text\":\"\",\"object\":null}'"]
        ]

  context 'oneOfResponse(Empty)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.oneOfResponse'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'worked for this particular test run (non-deterministic)', ->
      hubotsResponse = @room.messages[1]
      isOneOf = (hubotsResponse[1] == 'content: text\ntext: some info text\nobject: null' || hubotsResponse[1] == 'content: object\ntext: \'\'\nobject:\n  text: some info text inside an object')
      expect(hubotsResponse[0]).to.equal('hubot')
      expect(isOneOf).to.be.true

  context 'arrayRequest(Array)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.arrayRequest items: ["A", "B", "C"]'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.arrayRequest items: ["A", "B", "C"]']
        ['hubot', 'text: \'{"items":["A","B","C"]}\'']
      ]

  context 'arrayResponse(Empty)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.arrayResponse'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.arrayResponse']
        ['hubot', 'items:\n  - item1\n  - item2\n  - item3']
      ]

  context 'mapRequest(SimpleMap)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.mapRequest items: {key: {text: "value"}, second: {text: "somevalue"}}'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.mapRequest items: {key: {text: "value"}, second: {text: "somevalue"}}']
        ['hubot', "text: '{\"items\":{\"key\":{\"text\":\"value\"},\"second\":{\"text\":\"somevalue\"}}}'"]
      ]

  context 'mapResponse(Empty)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.mapResponse'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.mapResponse']
        ['hubot', "items:\n  first:\n    text: item1\n  second:\n    text: item2\n  third:\n    text: item3"]
      ]

  context 'scalarValuesRequest(AllScalarValues)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.scalarValuesRequest ' +
          'doubleValue: 156.12 floatValue: 1681.51 int32Value: 484 int64Value: 456 ' +
          'uint32Value: 899 uint64Value: 775 sint32Value: 455 sint64Value: 796 fixed32Value: 646 ' +
          'fixed64Value: 899 sfixed32Value: 811 sfixed64Value: 912 boolValue: true stringValue: "test" ' +
          'bytesValue: b"This is a byte array"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.scalarValuesRequest ' +
          'doubleValue: 156.12 floatValue: 1681.51 int32Value: 484 int64Value: 456 ' +
          'uint32Value: 899 uint64Value: 775 sint32Value: 455 sint64Value: 796 fixed32Value: 646 ' +
          'fixed64Value: 899 sfixed32Value: 811 sfixed64Value: 912 boolValue: true stringValue: "test" ' +
          'bytesValue: b"This is a byte array"']
        ['hubot', "text: >-\n  {\"doubleValue\":156.12,\"floatValue\":1681.510009765625,\"int32Value\":484,\"int64Value\":\"456\"," +
          "\"uint32Value\":899,\"uint64Value\":\"775\",\"sint32Value\":455,\"sint64Value\":\"796\",\"fixed32Value\":646," +
          "\"fixed64Value\":\"899\",\"sfixed32Value\":811,\"sfixed64Value\":\"912\",\"boolValue\":true,\"stringValue\":\"test\"," +
          "\"bytesValue\":{\"type\":\"Buffer\",\"data\":[84,104,105,115,32,105,115,32,97,32,98,121,116,101,32,97,114,114,97,121]}}"]
      ]

  context 'scalarValuesRequest(AllScalarValues) for an url as bytesValue', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.scalarValuesRequest ' +
            'doubleValue: 156.12 floatValue: 1681.51 int32Value: 484 int64Value: 456 ' +
            'uint32Value: 899 uint64Value: 775 sint32Value: 455 sint64Value: 796 fixed32Value: 646 ' +
            'fixed64Value: 899 sfixed32Value: 811 sfixed64Value: 912 boolValue: true stringValue: "test" ' +
            'bytesValue: url"http://xkcd.com/610/info.0.json"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.scalarValuesRequest ' +
          'doubleValue: 156.12 floatValue: 1681.51 int32Value: 484 int64Value: 456 ' +
          'uint32Value: 899 uint64Value: 775 sint32Value: 455 sint64Value: 796 fixed32Value: 646 ' +
          'fixed64Value: 899 sfixed32Value: 811 sfixed64Value: 912 boolValue: true stringValue: "test" ' +
          'bytesValue: url"http://xkcd.com/610/info.0.json"']
        ['hubot', "text: >-\n  {\"doubleValue\":156.12,\"floatValue\":1681.510009765625,\"int32Value\":484,\"int64Value\":\"456\"," +
          "\"uint32Value\":899,\"uint64Value\":\"775\",\"sint32Value\":455,\"sint64Value\":\"796\",\"fixed32Value\":646," +
          "\"fixed64Value\":\"899\",\"sfixed32Value\":811,\"sfixed64Value\":\"912\",\"boolValue\":true,\"stringValue\":\"test\"," +
          "\"bytesValue\":{\"type\":\"Buffer\",\"data\":[123,34,109,111,110,116,104,34,58,32,34,55,34,44,32,34,110,117,109,34,58,32,54,49," +
          "48,44,32,34,108,105,110,107,34,58,32,34,34,44,32,34,121,101,97,114,34,58,32,34,50,48,48,57,34,44,32,34,110,101,119,115,34,58,32," +
          "34,34,44,32,34,115,97,102,101,95,116,105,116,108,101,34,58,32,34,83,104,101,101,112,108,101,34,44,32,34,116,114,97,110,115,99,114," +
          "105,112,116,34,58,32,34,40,40,65,32,116,104,111,117,103,104,116,32,98,117,98,98,108,101,32,105,115,32,115,104,97,114,101,100,32,98," +
          "101,116,119,101,101,110,32,116,104,101,32,102,105,118,101,32,111,99,99,117,112,97,110,116,115,32,111,102,32,97,32,115,117,98,119,97," +
          "121,32,99,97,114,46,41,41,92,110,65,108,108,58,32,76,111,111,107,32,97,116,32,116,104,101,115,101,32,112,101,111,112,108,101,46,32,71," +
          "108,97,115,115,121,45,101,121,101,100,32,97,117,116,111,109,97,116,111,110,115,32,103,111,105,110,103,32,97,98,111,117,116,32,116,104," +
          "101,105,114,32,100,97,105,108,121,32,108,105,118,101,115,44,32,110,101,118,101,114,32,115,116,111,112,112,105,110,103,32,116,111,32,108," +
          "111,111,107,32,97,114,111,117,110,100,32,97,110,100,32,92,110,116,104,105,110,107,33,92,110,32,32,73,39,109,32,116,104,101,32,111,110,108," +
          "121,32,99,111,110,115,99,105,111,117,115,32,104,117,109,97,110,32,105,110,32,97,32,119,111,114,108,100,32,111,102,32,115,104,101,101,112," +
          "46,92,110,92,110,123,123,84,105,116,108,101,32,116,101,120,116,58,32,72,101,121,44,32,119,104,97,116,32,97,114,101,32,116,104,101,32,111," +
          "100,100,115,32,45,45,32,102,105,118,101,32,65,121,110,32,82,97,110,100,32,102,97,110,115,32,111,110,32,116,104,101,32,115,97,109,101,32,116," +
          "114,97,105,110,33,32,32,77,117,115,116,32,98,101,32,103,111,105,110,103,32,116,111,32,97,32,99,111,110,118,101,110,116,105,111,110,46,125,125," +
          "34,44,32,34,97,108,116,34,58,32,34,72,101,121,44,32,119,104,97,116,32,97,114,101,32,116,104,101,32,111,100,100,115,32,45,45,32,102,105,118," +
          "101,32,65,121,110,32,82,97,110,100,32,102,97,110,115,32,111,110,32,116,104,101,32,115,97,109,101,32,116,114,97,105,110,33,32,32,77,117,115," +
          "116,32,98,101,32,103,111,105,110,103,32,116,111,32,97,32,99,111,110,118,101,110,116,105,111,110,46,34,44,32,34,105,109,103,34,58,32,34,104," +
          "116,116,112,58,92,47,92,47,105,109,103,115,46,120,107,99,100,46,99,111,109,92,47,99,111,109,105,99,115,92,47,115,104,101,101,112,108,101,46," +
          "112,110,103,34,44,32,34,116,105,116,108,101,34,58,32,34,83,104,101,101,112,108,101,34,44,32,34,100,97,121,34,58,32,34,49,53,34,125]}}"]
      ]

  context 'scalarValuesResponse(Empty)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.scalarValuesResponse'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.scalarValuesResponse']
        ['hubot', "doubleValue: 2147483648.5\nfloatValue: 123.45600128173828\nint32Value: 123\nint64Value: '9223372036854775807'\n" +
          "uint32Value: 123\nuint64Value: '9223372036854775807'\nsint32Value: 123\nsint64Value: '9223372036854775807'\nfixed32Value: 123\n" +
          "fixed64Value: '9223372036854775807'\nsfixed32Value: 123\nsfixed64Value: '9223372036854775807'\nboolValue: true\nstringValue: some text\n" +
          "bytesValue: !<tag:yaml.org,2002:binary> thesearebyte"]
      ]

  context 'importedRequest(External)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.importedRequest foo: "some text"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.importedRequest foo: "some text"']
        ['hubot', "text: '{\"foo\":\"some text\"}'"]
      ]

  context 'importedResponse(Empty)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.importedResponse'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.importedResponse']
        ['hubot', "foo: bar"]
      ]

  context 'absolutelyReferencedRequest(iaas.fapra.Simple)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.absolutelyReferencedRequest title: "super title" content: "great content"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.absolutelyReferencedRequest title: "super title" content: "great content"']
        ['hubot', "text: '{\"title\":\"super title\",\"content\":\"great content\"}'"]
      ]

  context 'absolutelyReferencedResponse(Empty)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.absolutelyReferencedResponse'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.absolutelyReferencedResponse']
        ['hubot', "title: foo\ncontent: bar"]
      ]

  context 'dotPrefixedReferencedRequest(.iaas.fapra.Simple)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.dotPrefixedReferencedRequest title: "super title" content: "great content"'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.dotPrefixedReferencedRequest title: "super title" content: "great content"']
        ['hubot', "text: '{\"title\":\"super title\",\"content\":\"great content\"}'"]
      ]

  context 'dotPrefixedReferencedResponse(Empty)', ->
    beforeEach ->
      co =>
        yield @room.user.say 'user', '@hubot call iaas.fapra.testing.test.dotPrefixedReferencedResponse'
        # Wait for hubot to respond
        yield delay(defaultDelayTime)

    it 'returns the correct object', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot call iaas.fapra.testing.test.dotPrefixedReferencedResponse']
        ['hubot', "title: foo\ncontent: bar"]
      ]
