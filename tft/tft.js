var express = require('express');
var app = express();
var execPHP = require('./execphp.js')();

execPHP.phpFolder = '/tft/html';

app.use('*.php',function(request,response,next) {
	execPHP.parseFile(request.originalUrl,function(phpResult) {
		response.write(phpResult);
		response.end();
	});
});

app.use(express.static('/tft/html'));

app.listen(3003, function () {
	console.log('Node server listening on port 3003!');
});

