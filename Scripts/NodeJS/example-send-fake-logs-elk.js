var async = require('async');
var faker = require('faker');
var moment = require('moment');
var winston = require('winston');
require('winston-logstash');

winston.setLevels(winston.config.npm.levels);
var logger = new (winston.Logger)({
    transports: [
        new (winston.transports.Logstash)({
            host: process.env.SERVICE_ELK_LOGSTASH_HOSTNAME,
            port: process.env.SERVICE_ELK_LOGSTASH_PORT,
            max_connect_retries: -1,
            node_name: 'ths-admin'
        })
    ]
});

var USERS_ID = ['112233', '223344', '556677'];
var APP_IDS = ['device', 'totem', 'mobile'];
var APP_CTX = ['ctx-tap', 'ctx-nav'];
var PRODUCTS_WE01 = [
    {
        parentSku: 'WXX01',
        sku: 'WXX01-XS-Orange',
        color: 'orange',
        size: 'S',
        name: 'NAME PRODUCT'
    }
];

function randomNumber(low, high) {
    return Math.round(Math.random() * (high - low) + low);
}

function randomProduct() {
    switch (randomNumber(1, 25)) {
    case 1:
        return faker.random.array_element(PRODUCTS_WE01);
    }
}

faker.random.array_element = function (array) {
    var r = Math.floor(Math.random() * array.length);
    return array[r];
};

function randomAddWadrobe(dates) {
    var product = randomProduct();
    var _userId = faker.random.array_element(USERS_ID);
    var date = faker.date.between(dates.startDate, dates.endDate);
    var timestamp = getValidDate(date);
    logger.info('[func][create] - successful response', {
        userId: _userId,
        productData: {
            storeId: 'ID',
            parentSku: product.parentSku,
            sku: product.sku,
            name: product.name,
            color: product.color,
            size: product.size,
            price: <value>,
            description: 'Product description...',
            details: 'Product details...'
        },
        method: 'add...',
        timestamp: timestamp
    });
}

function randomGetProducInfo(dates) {
    var product = randomProduct();
    var _userId = faker.random.array_element(USERS_ID);
    var date = faker.date.between(dates.startDate, dates.endDate);
    var timestamp = getValidDate(date);
    logger.info('[Store][Get Product Info] - successful response',
        {
            userId: _userId,
            productData: {
                storeId: 'ID',
                parentSku: product.parentSku,
                sku: product.sku,
                name: product.name,
                color: product.color,
                size: product.size,
                price: 65.45,
                description: 'Product description...',
                details: 'Product details...'
            },
            method: 'get...',
            thsAppId: faker.random.array_element(APP_IDS),
            thsAppContext: faker.random.array_element(APP_CTX),
            timestamp: timestamp
        });
}

function getMonthDateRange(year, month) {
    var startDate = moment([year, month]).startOf('month');
    var endDate = moment(startDate).endOf('month');
    return { startDate: startDate, endDate: endDate };
}

function getValidDate(date) {
    var VALID_HOURS_AM = [8, 9, 10, 11];
    var VALID_HOURS_PM = [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22];
    var newDate = date;
    if (date.getUTCHours() < 8) {
        date.setHours(faker.random.array_element(VALID_HOURS_AM));
    } else if (date.getUTCHours() > 22) {
        date.setHours(faker.random.array_element(VALID_HOURS_PM));
    }
    return newDate;
}

console.info('[ELK Service] - Sending fake data...');
var YEARS = [2016, 2017];
var TOTAL_PRODUCT_VIEWS = 16000;
var C_RATIOS = [0.75, 0.5, 0.25, 0.15, 0.01, 0.05];
var MONTH_WEIGHT = [
    1.0, // jan
    1.5, // fev
    0.5, // mar
    0.6, // apr
    1.0, // mai
    1.2, // jun
    1.4, // jul
    1.1, // ago
    0.9, // set
    1.0, // oct
    0.9, // nov
    2.3  // dec
];

async.each(YEARS, function (year, callback) {
    for (var monthIdx = 0; monthIdx < 12; monthIdx++) {
        // get start and end time of week - from 08:00:00 - 24:00
        var month = getMonthDateRange(year, monthIdx);
        if (year === 2017 && monthIdx === 6)
            break;

        // generate log
        var max_views = TOTAL_PRODUCT_VIEWS * MONTH_WEIGHT[monthIdx];
        for (var k = 0; k < max_views; k++) {
            randomGetProducInfo(month);
            if (k < Math.ceil(TOTAL_PRODUCT_VIEWS * faker.random.array_element(C_RATIOS))) {
                randomAddWadrobe(month);
            }
        }
    }
});

// Wait to send the fake logs for Logstash service
setTimeout(function () {
    console.info('[ELK Service] - Fake data sent successfully.');
}, 120 * 1000);

