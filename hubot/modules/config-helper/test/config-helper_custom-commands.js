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

describe('Customized Commands:', () => {
  const ConfigHelper = require('../config-helper');
  let configHelper;

  it('succeeds to initialize', () => {
    configHelper = new ConfigHelper(__dirname + '/custom-commands.yml', methods);
    expect(configHelper).not.to.be.a('undefined');
  });

  describe('Commands:', () => {

    let commands;

    it('does not throw when getting the commands', () => {
      let closure = () => { commands = configHelper.getCommands(); };

      expect(closure).not.to.throw();
    });

    it('returns four commands', () => {
      expect(commands).to.be.an('array').of.length(4);
    });

    it('gives the correct first command', () => {
      expect(commands[0]).to.equal('call .pkg.test.third <text:string> - Calls third and returns nothing');
    });

    it('gives the correct second command', () => {
      expect(commands[1]).to.equal('first  - Help message for the first alias');
    });

    it('gives the correct third command', () => {
      expect(commands[2]).to.equal('do second <first:Simple> <second:Simple>');
    });

    it('gives the correct forth command', () => {
      expect(commands[3]).to.equal('third <text:string> - Calls third and returns nothing');
    });
  });

  describe('Default Call Permission:', () => {
    it('allows to call "third" with default syntax', () => {
      expect(configHelper.isDefaultCallAllowed('.pkg.test.third')).to.equal(true);
    });
    it('rejects all other methods with default syntax', () => {
      expect(configHelper.isDefaultCallAllowed('.pkg.test.first')).to.equal(false);
      expect(configHelper.isDefaultCallAllowed('.pkg.test.second')).to.equal(false);
      expect(configHelper.isDefaultCallAllowed('.pkg.test.forth')).to.equal(false);
      expect(configHelper.isDefaultCallAllowed('.pkg.test.fifth')).to.equal(false);
    });
  });

});
