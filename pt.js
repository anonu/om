var webPage = require('webpage');
var page = webPage.create();

var system = require('system');
var args = system.args;

console.log(args[1])

page.open(args[1], function (status) {
  console.log('Stripped down page text:\n' + page.plainText);
  phantom.exit();
});


