var supertest = require('supertest');
var chai = require('chai');
var expect = require('chai').expect;
var url = require('url');

var configServer = require('../../ths-env/config.js');

var serviceAdminUrl = {};
serviceAdminUrl.protocol = configServer.service.admin.protocol;
serviceAdminUrl.hostname = configServer.service.admin.hostname;
serviceAdminUrl.port = configServer.service.admin.port;
serviceAdminUrl.pathname = configServer.service.admin.pathname;

var adminServer = supertest.agent(url.format(serviceAdminUrl));

chai.use(require('chai-json-schema'));

var adminDeviceSchema = {
    title: 'admin device schema v1',
    type: 'object',
    required: [
        'id',
        'associateId',
        'name',
        'serialNumber',
        'macAddress',
        'firmwareVersion',
        'deviceType',
        'storeId',
        'storeStartDate',
        'createdAt',
        'updatedAt',
        '_activation',
        '_status',
        '_config',
        '_endpoint'],
    properties: {
        id: {
            type: 'string'
        },
        name: {
            type: 'string'
        },
        serialNumber: {
            type: 'string'
        },
        macAddress: {
            type: 'string'
        },
        firmwareVersion: {
            type: 'string'
        },
        deviceType: {
            type: 'string'
        },
        createdAt: {
            type: 'string'
        },
        updatedAt: {
            type: 'string'
        },
        _activation: {
            type: 'object'
        },
        _status: {
            type: 'object'
        },
        _config: {
            type: 'object'
        },
        _endpoint: {
            type: 'object'
        }
    }
};

var deviceValid1 = {
    serialNumber: 'THS001',
    macAddress: 'AB-1E-55-19-79-D1',
    firmwareVersion: 'v0.0.1'
};

describe('Services', function () {
    describe('Admin', function () {
        describe('Customer', function () {
            describe('related to all customers', function () {
                it('when get customers, the response must be empty and 200 OK', function (done) {
                    adminServer
                        .get('/customers')
                        .set('Accept', 'application/json')
                        .expect(200)
                        .expect(function (res) {
                            expect(res.body).to.be.empty;
                        })
                        .end(function (err, res) {
                            if (err) {
                                done(err);
                                return;
                            }
                            done();
                        });
                });

                it('when create a customer1 with valid params, the response should be 200 OK', function (done) {
                    adminServer
                        .post('/customers')
                        .set('Content-Type', 'application/json')
                        .set('Accept', 'application/json')
                        .send(customerValid1)
                        .expect(200)
                        .expect(function (res) {
                            expect(res.body).to.be.jsonSchema(adminCustomerSchema);
                            expect(res.body.id).to.be.not.empty;
                            expect(res.body.social).to.be.not.empty;
                            expect(res.body.name).to.be.not.empty;
                            expect(res.body.createdAt).to.be.not.empty;
                            expect(res.body.updatedAt).to.be.not.empty;
                            expect(res.body._history).to.be.empty;
                            expect(res.body._wardrobe).to.be.empty;
                        })
                        .end(function (err, res) {
                            if (err) {
                                done(err);
                                return;
                            }
                            customerValid1 = res.body;
                            done();
                        });
                });

                it('when get customers, the response must not be empty and 200 OK', function (done) {
                    adminServer
                        .get('/customers')
                        .set('Accept', 'application/json')
                        .expect(200)
                        .expect(function (res) {
                            expect(res.body).to.be.not.empty;
                        })
                        .end(function (err, res) {
                            if (err) {
                                done(err);
                                return;
                            }
                            done();
                        });
                });

                it('when create a customer2 with valid params, the response should be 200 OK', function (done) {
                    adminServer
                        .post('/customers')
                        .set('Content-Type', 'application/json')
                        .set('Accept', 'application/json')
                        .send(customerValid2)
                        .expect(200)
                        .expect(function (res) {
                            expect(res.body).to.be.jsonSchema(adminCustomerSchema);
                            expect(res.body.id).to.be.not.empty;
                            expect(res.body.social).to.be.not.empty;
                            expect(res.body.name).to.be.not.empty;
                            expect(res.body.createdAt).to.be.not.empty;
                            expect(res.body.updatedAt).to.be.not.empty;
                            expect(res.body._history).to.be.empty;
                            expect(res.body._wardrobe).to.be.empty;
                        })
                        .end(function (err, res) {
                            if (err) {
                                done(err);
                                return;
                            }
                            customerValid2 = res.body;
                            done();
                        });
                });
            });
        });
   });
});
