const chai = require('chai');
const expect = chai.expect;
const chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);
const nock = require('nock');

describe('UrlToParamsResolver: ', () => {
  const UrlParamsResolver = require('../url-params-resolver');
  const url = require('url');

  describe('resolveUrlParamsToBuffer', () => {

    describe('when a single url param is passed', () => {

      beforeEach(() => {
        nock('http://www.example.com')
          .get('/pic1.jpg')
          .reply(200, 'pic1 content');
      });

      it('resolves the content of the url', () => {
        return UrlParamsResolver.resolveUrlParamsToBuffer({
            "param1": url.parse("http://www.example.com/pic1.jpg")
          })
          .then((params) => {
            expect(params.param1).to.be.an.instanceof(Buffer);
          });
      });



      it('updates also the initial parameters object', () => {
        let initialParams = {
          "param1": url.parse("http://www.example.com/pic1.jpg")
        };

        return UrlParamsResolver.resolveUrlParamsToBuffer(initialParams)
          .then(() => {
            expect(initialParams.param1).to.be.an.instanceof(Buffer);
          });
      });
    });

    describe('when multiple params are passed', () => {

      beforeEach(() => {
        nock('http://www.example.com')
          .get('/pic1.jpg')
          .reply(200, 'pic1 content');
        nock('http://www.example.com')
          .get('/pic2.jpg')
          .reply(200, 'pic2 content');
      });

      it('resolves the content of all urls and preserves the other params', () => {
        let initialParams = {
          "param1": url.parse("http://www.example.com/pic1.jpg"),
          "param2": "some text",
          "param3": 42,
          "param4": url.parse("http://www.example.com/pic2.jpg")
        };

        return UrlParamsResolver.resolveUrlParamsToBuffer(initialParams)
          .then((params) => {
            expect(params.param1).to.be.an.instanceof(Buffer);
            expect(params.param2).to.equal("some text");
            expect(params.param3).to.equal(42);
            expect(params.param4).to.be.an.instanceof(Buffer);
            expect(initialParams.param1).to.be.an.instanceof(Buffer);
            expect(initialParams.param2).to.equal("some text");
            expect(initialParams.param3).to.equal(42);
            expect(initialParams.param4).to.be.an.instanceof(Buffer);
          });
      });

      it('resolves the content of all urls and preserves urls passed as strings', () => {
        let initialParams = {
          "param1": url.parse("http://www.example.com/pic1.jpg"),
          "param2": "http://www.example.com/pic2.jpg",
          "param3": 42
        };

        return UrlParamsResolver.resolveUrlParamsToBuffer(initialParams)
          .then((params) => {
            expect(params.param1).to.be.an.instanceof(Buffer);
            expect(params.param2).to.equal("http://www.example.com/pic2.jpg");
            expect(params.param3).to.equal(42);
            expect(initialParams.param1).to.be.an.instanceof(Buffer);
            expect(initialParams.param2).to.equal("http://www.example.com/pic2.jpg");
            expect(initialParams.param3).to.equal(42);
          });
      });
    });

    describe('when a request is not successful', () => {

      beforeEach(() => {
        nock('http://www.example.com')
          .get('/pic1.jpg')
          .reply(404, 'not found');
      });

      describe('when it is the only parameter', () => {

        it('rejects the promise', () => {
          return expect(UrlParamsResolver.resolveUrlParamsToBuffer({
            "param1": url.parse("http://www.example.com/pic1.jpg")
          }))
            .to.be.rejected
            .then((error) => {
              expect(error).to.be.an.instanceOf(Error);
              expect(error.message).to.equal('Failed to load page, status code: 404');
            });
        });
      });

      describe('when there are other parameters', () => {

        it('rejects the promise', () => {
          return expect(UrlParamsResolver.resolveUrlParamsToBuffer({
            "param1": "some text",
            "param2": url.parse("http://www.example.com/pic1.jpg")
          }))
            .to.be.rejected
            .then((error) => {
              expect(error).to.be.an.instanceOf(Error);
              expect(error.message).to.equal('Failed to load page, status code: 404');
            });
        });
      });

      describe('when there are other urls', () => {

        beforeEach(() => {
          nock('http://www.example.com')
            .get('/pic2.jpg')
            .reply(200, 'pic2 content');
        });

        it('rejects the promise', () => {
          return expect(UrlParamsResolver.resolveUrlParamsToBuffer({
            "param1": url.parse("http://www.example.com/pic2.jpg"),
            "param2": url.parse("http://www.example.com/pic1.jpg")
          }))
            .to.be.rejected
            .then((error) => {
              expect(error).to.be.an.instanceOf(Error);
              expect(error.message).to.equal('Failed to load page, status code: 404');
            });
        });
      });
    });
  });
});