const chai = require('chai');
const expect = chai.expect;

describe('', () => {
  const ProtoHelper = require('../proto-helper');
  const protoHelper = new ProtoHelper(__dirname + '/testing.proto');

  describe('Validating Messages:', () => {

    it('validates an empty message for every message type (proto3 -> all optional)', () => {
      let closure1 = () => { protoHelper.validateMessage('.pkg.Empty', {}); };

      expect(closure1).not.to.throw();

      let closure2 = () => { protoHelper.validateMessage('.pkg.Test', {}); };

      expect(closure2).not.to.throw();

      let closure3 = () => { protoHelper.validateMessage('.pkg.Complex', {}); };

      expect(closure3).not.to.throw();

      let closure4 = () => { protoHelper.validateMessage('.pkg.Complex.Simple', {}); };

      expect(closure4).not.to.throw();

      let closure5 = () => { protoHelper.validateMessage('.pkg.Status', {}); };

      expect(closure5).not.to.throw();

      let closure6 = () => { protoHelper.validateMessage('.pkg.SimpleMap', {}); };

      expect(closure6).not.to.throw();
    });

    it('rejects if no object is given as value', () => {
      let closure = () => { protoHelper.validateMessage('.pkg.Empty', 'no object'); };

      expect(closure).to.throw('".pkg.Empty" needs to be specified as an object but is a string');
    });

    it('rejects if an array is given as value', () => {
      let closure = () => { protoHelper.validateMessage('.pkg.Empty', [{ test: 'string' }]); };

      expect(closure).to.throw('".pkg.Empty" needs to be specified as an object but is an array');
    });

    it('rejects a not specified field', () => {
      let closure = () => { protoHelper.validateMessage('.pkg.Empty', { test: 'string' }); };

      expect(closure).to.throw('"test" is not a defined field of .pkg.Empty');
    });

    it('rejects if given a not existing message type', () => {
      let closure = () => { protoHelper.validateMessage('.pkg.Empty.NotExisting', { test: 'string' }); };

      expect(closure).to.throw('No Definition found for the message: .pkg.Empty.NotExisting');
    });

    describe('Handling Enums:', () => {
      it('validates a correct string as an enum', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Status', { value: 'A' }); };

        expect(closure).not.to.throw();
      });
      it('rejects a wrong string as an enum', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Status', { value: 'E' }); };

        return expect(closure).to.throw('Field "value" (enumtype: .pkg.Status.Some) has possible values ["A", "B", "C", "D"] but "E" provided');
      });
      it('rejects a number as an enum', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Status', { value: 1 }); };

        return expect(closure).to.throw('Field "value" (enumtype: .pkg.Status.Some) has possible values ["A", "B", "C", "D"] but "1" provided');
      });
    });

    describe('Handling repeated Integers:', () => {
      it('validates a single integer', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Test', { integers: 1 }); };

        expect(closure).not.to.throw();
      });
      it('validates an array of integers', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Test', { integers: [1, 3, 3, 7] }); };

        expect(closure).not.to.throw();
      });
      it('rejects an array of strings', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Test', { integers: ['1', '3', '3', '7'] }); };

        expect(closure).to.throw('Provided field "integers" of ".pkg.Test" must be of type int32 but found string');
      });
      it('rejects a nested message string', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Test', { integers: { prop: '2' } }); };

        expect(closure).to.throw('Provided field "integers" of ".pkg.Test" must be of type int32 but found object');
      });
    });

    describe('Handling Strings:', () => {
      it('validates a string', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Complex.Simple', { text: 'string' }); };

        expect(closure).not.to.throw();
      });
      xit('rejects an array of strings', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Complex.Simple', { text: ['string'] }); };

        expect(closure).to.throw('Provided field "text" of ".pkg.Complex.Simple" must be of type string but found array');
      });
      it('rejects an integer', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Complex.Simple', { text: 1 }); };

        expect(closure).to.throw('Provided field "text" of ".pkg.Complex.Simple" must be of type string but found number');
      });
      it('rejects an nested object', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Complex.Simple', { text: { foo: 'bar' } }); };

        expect(closure).to.throw('Provided field "text" of ".pkg.Complex.Simple" must be of type string but found object');
      });
    });

    describe('Handling nested messages', () => {
      it('validates a nested message', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Complex', { first: { text: 'text' }, second: {} }); };

        expect(closure).not.to.throw();
      });
      it('rejects an integer', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Complex', { first: 'text', second: {} }); };

        expect(closure).to.throw('Field "first" (type: .pkg.Complex.Simple) needs to be specified as an object but is a string');
      });
      it('rejects an array', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.Complex', { first: ['text'], second: {} }); };

        expect(closure).to.throw('Field "first" (type: .pkg.Complex.Simple) needs to be specified as an object but is an array');
      });
    });

    describe('Handling Maps', () => {
      it('validates a fully specified map object', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.SimpleMap', { items: { first: { text: 'text' }, second: { text: 'text' } } }); };

        expect(closure).not.to.throw();
      });
      it('validates a correct map object', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.SimpleMap', { items: { first: { text: 'text' }, second: {} } }); };

        expect(closure).not.to.throw();
      });
      it('rejects an error in the value', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.SimpleMap', { items: { first: 'string' } }); };

        expect(closure).to.throw('Field "items" (type: .pkg.Complex.Simple) needs to be specified as an object but is a string');
      });
      it('rejects an error nested in the value message', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.SimpleMap', { items: { first: { text: true } } }); };

        expect(closure).to.throw('Provided field "text" of ".pkg.Complex.Simple" must be of type string but found boolean.');
      });
      // currently only string keys are possible to specify (as javascript object)
      xit('rejects an error in the key', () => {
        let closure = () => { protoHelper.validateMessage('.pkg.SimpleMap', { items: { first: { text: true } } }); };

        expect(closure).to.throw('Provided field "text" of ".pkg.Complex.Simple" must be of type string but found boolean.');
      });

    });
  });
});
