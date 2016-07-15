const chai = require('chai');
const expect = chai.expect;

describe('Proto Helper:', () => {
  const ProtoHelper = require('../proto-helper');

  it('correctly loads the protofile given the builder', () => {
    const protoHelper = new ProtoHelper(
      require('protobufjs').protoFromFile(__dirname + '/testing.proto')
    );
    expect(protoHelper.builder).not.to.be.null;
  });

  const protoHelper = new ProtoHelper(__dirname + '/testing.proto');

  it('correctly loads the protofile given the path', () => {
    expect(protoHelper.builder).not.to.be.null;
  });

  describe('Describing methods:', () => {
    let methods = protoHelper.getAllMethods();
    it('describes the methods as an array of correct length', () => {
      expect(methods).to.be.an('array');
      expect(methods).to.have.length(5);
    });

    it('describes the first method correctly', () => {
      let first = methods[0];
      expect(first).to.eql({
        name: '.pkg.test.first',
        parameters: [],
      });
    });

    it('describes the second method correctly', () => {
      let second = methods[1];
      expect(second).to.eql({
        name: '.pkg.test.second',
        parameters: [
          {
            name: 'first',
            repeated: false,
            type: 'Simple',
          },
          {
            name: 'second',
            repeated: false,
            type: 'Simple',
          },
        ],
      });
    });

    it('describes the third method correctly', () => {
      let third = methods[2];
      expect(third).to.eql({
        name: '.pkg.test.third',
        parameters: [
          {
            name: 'text',
            repeated: false,
            type: 'string',
          },
        ],
      });
    });

    it('describes the forth method correctly', () => {
      let forth = methods[3];
      expect(forth).to.eql({
        name: '.pkg.test.forth',
        parameters: [
          {
            name: 'integers',
            repeated: true,
            type: 'int32',
          },
        ],
      });
    });

    it('describes the fifth method correctly', () => {
      let fifth = methods[4];
      expect(fifth).to.eql({
        name: '.pkg.test.fifth',
        parameters: [
          {
            name: 'value',
            repeated: false,
            type: 'Some',
          },
        ],
      });
    });
  });
});
