var express = require('express')
//var sense = require('ds18b20');
var app = express()

app.get('/', function (req, res) {
    //sense.temperature('10-00080283a977', function(err, value) {
    //console.log('Current temperature is', value);
    //});
    res.send("Hello world!")
})

app.listen(3000)
