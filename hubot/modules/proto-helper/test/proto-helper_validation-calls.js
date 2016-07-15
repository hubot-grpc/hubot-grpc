const chai = require('chai');
const expect = chai.expect;

describe('', () => {
  const ProtoHelper = require('../proto-helper');
  const protoHelper = new ProtoHelper(__dirname + '/testing.proto');

  describe('Validating Calls:', () => {

    it('rejects if given name is not a method', () => {
      let closure = () => { protoHelper.validateCall({ fqn: '.pkg.Status', request: {} }); };

      expect(closure).to.throw('".pkg.Status" is no procedure.');
    });

    it('rejects if given name doesnt exist', () => {
      let closure = () => { protoHelper.validateCall({ fqn: '.foo.bar', request: {} }); };

      expect(closure).to.throw('Procedure ".foo.bar" not found.');
    });

    it('rejects if request is not an object', () => {
      let closure = () => { protoHelper.validateCall({ fqn: '.pkg.test.second', request: '{}' }); };

      expect(closure).to.throw('".pkg.Complex" needs to be specified as an object but is a string');
    });

    it('validates if method with correct request message is given', () => {
      let closure = () => { protoHelper.validateCall({ fqn: '.pkg.test.fifth', request: { value: 'D' } }); };

      expect(closure).not.to.throw();
    });
  });
});
