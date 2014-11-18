var express = require('express')
var sense = require('ds18b20');
var app = express()

app.get('/sensors/temperature', function (req, res) {
    sense.temperature(process.env.DS18B20_SENSOR_ID, function(err, value) {
        res.setHeader('Content-Type', 'application/json');
        res.json({ temperature: value})
    });
})

app.listen(3000)
