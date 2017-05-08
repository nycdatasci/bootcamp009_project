// This script is a generic phantomjs script that opens a single url and returns html

"use strict";
var system = require('system');
var args = system.args;
var page = require('webpage').create();

page.onConsoleMessage = function(msg) {
    console.log(msg);
};
var url = args[1];
page.open(url, function(status) {
    if (status === "success") {
            page.evaluate(function() {
                console.log(document.body.innerHTML);    
        });
    } else {
      console.log("not success");  
    }
phantom.exit(1);
});