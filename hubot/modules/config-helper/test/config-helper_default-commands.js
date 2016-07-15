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

describe('Default Commands:', () => {
  const ConfigHelper = require('../config-helper');
  let configHelper;

  it('succeeds to initialize (with incorrect config path => no config)', () => {
    configHelper = new ConfigHelper('bullshit', methods);
    expect(configHelper).not.to.be.a('undefined');
  });

  describe('Commands:', () => {

    let commands;

    it('does not throw when getting the commands', () => {
      let closure = () => { commands = configHelper.getCommands(); };

      expect(closure).not.to.throw();
    });

    it('returns five commands', () => {
      expect(commands).to.be.an('array').of.length(5);
    });

    it('gives the correct first command', () => {
      expect(commands[0]).to.equal('call .pkg.test.first');
    });

    it('gives the correct second command', () => {
      expect(commands[1]).to.equal('call .pkg.test.second <first:Simple> <second:Simple>');
    });

    it('gives the correct third command', () => {
      expect(commands[2]).to.equal('call .pkg.test.third <text:string>');
    });

    it('gives the correct forth command', () => {
      expect(commands[3]).to.equal('call .pkg.test.forth <integers:int32[]>');
    });

    it('gives the correct fifth command', () => {
      expect(commands[4]).to.equal('call .pkg.test.fifth <value:Some>');
    });
  });
});
