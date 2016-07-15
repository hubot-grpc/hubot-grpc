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

describe('Getting restriction information:', () => {
  const ConfigHelper = require('../config-helper');
  let configHelper;

  it('succeeds to initialize', () => {
    configHelper = new ConfigHelper(__dirname + '/custom-restrictions.yml', methods);
    expect(configHelper).not.to.be.a('undefined');
  });

  describe('Getting permission for first method:', () => {
    it('Rejects for user "any"', () => {
      expect(configHelper.isUserAllowed('.pkg.test.first', 'any'))
        .to.be.false;
    });

    it('Gives permission for user "max"', () => {
      expect(configHelper.isUserAllowed('.pkg.test.first', 'max'))
        .to.be.true;
    });
  });

  describe('Getting permission for second method:', () => {
    it('Gives permission for any user', () => {
      expect(configHelper.isUserAllowed('.pkg.test.second', 'any'))
        .to.be.true;
    });
  });
});
