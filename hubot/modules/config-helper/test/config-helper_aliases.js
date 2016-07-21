const chai = require('chai');
const expect = chai.expect;

const methods = [
  { name: '.pkg.test.first', parameters: [] },
  { name: '.pkg.test.second', parameters: [
    { type: 'Simple', repeated: false, name: 'first' },
    { type: 'Simple', repeated: false, name: 'second' },
  ], },
  { name: '.pkg.test.third', parameters: [{ type: 'string', repeated: false, name: 'text' }] },
  { name: '.pkg.test.forth', parameters: [{ type: 'int32', repeated: true, name: 'integers' }] },
  { name: '.pkg.test.fifth', parameters: [{ type: 'Some', repeated: false, name: 'value' }] },
];

describe('Getting alias information:', () => {
  const ConfigHelper = require('../config-helper');
  let configHelper;

  it('succeeds to initialize', () => {
    configHelper = new ConfigHelper(__dirname + '/custom-commands.yml', methods);
    expect(configHelper).not.to.be.a('undefined');
  });

  describe('Aliases:', () => {

    let customCalls;

    it('does not throw when getting the aliases', () => {
      let closure = () => { customCalls = configHelper.getCustomCalls(); };

      expect(closure).not.to.throw();
    });

    it('returns three aliases', () => {
      expect(customCalls).to.be.an('array').of.length(3);
    });

    it('gives the correct first alias', () => {
      expect(customCalls[0]).to.have.property('name', 'first');
    });

    it('has the right method description', () => {
      expect(customCalls[0]).to.have.property('methodFqn', '.pkg.test.first');
      expect(customCalls[0]).to.have.property('methodSplit');
      expect(customCalls[0].methodSplit).to.eql(['pkg', 'test', 'first']);
    });

    it('matches the expected string for the first alias', () => {
      let match = customCalls[0].regexp.exec('first some:{param:false}');
      expect(match[1].trim()).to.equal('some:{param:false}');
    });

    it('matches the expected string for the second alias', () => {
      let match = customCalls[1].regexp.exec('do second some:{param:[false]}');
      expect(match[1].trim()).to.equal('some:{param:[false]}');
    });
  });

});
