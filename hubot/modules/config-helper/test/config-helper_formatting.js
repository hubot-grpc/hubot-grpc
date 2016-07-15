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

const context = {
  response: { first: 'bla', second: ['test', 'array'] },
  user: { name: 'Max', id: '1234' },
};

describe('Getting formatting information:', () => {
  const ConfigHelper = require('../config-helper');
  let configHelper;

  it('succeeds to initialize', () => {
    configHelper = new ConfigHelper(__dirname + '/custom-formatting.yml', methods);
    expect(configHelper).not.to.be.a('undefined');
  });

  describe('Default Templates:', () => {
    let formattings;
    beforeEach(() => {
      formattings = configHelper.getResponseTemplates('.pkg.test.second');
    });
    it('returns one response templates for the second method', () => {
      expect(formattings).to.be.an('array').of.length(1);
    });

    it('outputs the given response as yaml', () => {
      let output = formattings[0](context);
      expect(output).to.equal('first: bla\nsecond:\n  - test\n  - array');
    });
  });

  describe('Custom Templates:', () => {
    let formattings;
    beforeEach(() => {
      formattings = configHelper.getResponseTemplates('.pkg.test.first');
    });

    it('returns two response templates for the first method', () => {
      expect(formattings).to.be.an('array').of.length(2);
    });

    it('formats as expected for the first template', () => {
      let output = formattings[0](context);
      expect(output).to.equal('bla\n  - test\n  - array');
    });

    it('formats as expected for the second template', () => {
      let output = formattings[1](context);
      expect(output).to.equal('Hallo Max: bla');
    });
  });
});
