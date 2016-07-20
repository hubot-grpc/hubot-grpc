const chai = require('chai');
const expect = chai.expect;

const methods = [
  { name: '.pkg.test.first', parameters: [] },
  { name: '.pkg.test.second', parameters: [
    { type: 'Simple', repeated: false, name: 'first' },
    { type: 'Simple', repeated: false, name: 'second' },
  ], },
  { name: '.pkg.test.third', parameters: [{ type: 'string', repeated: false, name: 'text' }] },
  { name: '.pkg.test.fourth', parameters: [{ type: 'int32', repeated: true, name: 'integers' }] },
  { name: '.pkg.test.fifth', parameters: [{ type: 'Some', repeated: false, name: 'value' }] },
];

describe('Default parameters:', () => {
  const ConfigHelper = require('../config-helper');
  let configHelper;

  it('succeeds to initialize', () => {
    configHelper = new ConfigHelper(__dirname + '/default-params.yml', methods);
    expect(configHelper).not.to.be.a('undefined');
  });

  describe('No defaults specified', () => {
    it('returns the user parameters', () => {
      let params = { text: 'string' };
      expect(configHelper.applyParametersToDefaults(
        configHelper.getDefaultParameters('pkg.test.third'),
        params
      )).to.eql(params);
    });
  });

  describe('Complex object as parameter:', () => {
    it('Reads out the correct parameters', () => {
      expect(configHelper.getDefaultParameters('.pkg.test.second')).to.eql(
        { first: { text: 'first' } }
      );
    });

    it('Correctly merges with user parameters', () => {
      expect(configHelper.applyParametersToDefaults(
        configHelper.getDefaultParameters('.pkg.test.second'),
        { second: { text: 'second' } }
      )).to.eql(
        {
          first: { text: 'first' },
          second: { text: 'second' },
        }
      );
    });

    it('Correctly overrides with user parameters', () => {
      expect(configHelper.applyParametersToDefaults(
        configHelper.getDefaultParameters('.pkg.test.second'),
        {
          first: { text: 'different' },
          second: { text: 'second' },
        }
      )).to.eql(
        {
          first: { text: 'different' },
          second: { text: 'second' },
        }
      );
    });
  });

  describe('Array as parameter:', () => {
    it('Reads out the correct parameters', () => {
      expect(configHelper.getDefaultParameters('.pkg.test.fourth')).to.eql(
        { integers: [1, 2, 3] }
      );
    });

    it('Correctly applies the default parameters', () => {
      expect(configHelper.applyParametersToDefaults(
        configHelper.getDefaultParameters('.pkg.test.fourth'),
        {}
      )).to.eql(
        { integers: [1, 2, 3] }
      );
    });

    it('Correctly overrides with user parameters', () => {
      expect(configHelper.applyParametersToDefaults(
        configHelper.getDefaultParameters('.pkg.test.fourth'),
        {
          integers: [4, 5, 6],
        }
      )).to.eql(
        { integers: [4, 5, 6] }
      );
    });
  });

  describe('Custom Calls:', () => {
    it('Reads out the overwritten parameters', () => {
      let customCall = configHelper.customCalls.find(call => call.alias === 'fourth');
      expect(customCall.defaults).to.eql(
        { integers: [2, 3, 4] }
      );
    });

    it('Reads out the inherited default parameters', () => {
      let customCall = configHelper.customCalls.find(call => call.alias === 'default');
      expect(customCall.defaults).to.eql(
        { integers: [1, 2, 3] }
      );
    });
  });
});
