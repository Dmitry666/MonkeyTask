import QtQuick 2.0

Item {
    id: root

    property string address: "https://vps3.unitsys.ru:3333"
    property real timeoutTime: 30.0

    Timer {
        id: requestTimer
    }

    /*
    var MAX_TIME = 10000;
    var REQUEST_PERIOD = 1000;

    var trysomethingmanytimes = function(param, callback) {

        var intervalID = setInterval(function() {
            try(param, function(err, data) {
                if (!err) {
                    clearInterval(intervalID);
                    clearTimeout(timeoutID);
                    callback(null, 'VSE OK');
                }
            });
        }, REQUEST_PERIOD);

        setTimeout(function() {
            callback(new Error('VSE PO PIZDE'));
            clearInterval(intervalID);
            },
            MAX_TIME
        );
    }
    */

    function sendHttpRequest(url, callback) {

        /*
        function HttpError(message) {
          this.name = 'httperror';
          this.message = message;
        }
        HttpError.prototype = Object.create(Error.prototype);
        HttpError.prototype.constructor = HttpError;
        */

        var query = "%1%2".arg(root.address).arg(url);
        console.debug(query);

        var sendFunction = function(time) {

            var request = new XMLHttpRequest()
            request.open('GET', query);

            request.onreadystatechange = function() {

                if (request.readyState === XMLHttpRequest.DONE) {

                    if (request.status === 200) {

                        var jsonObject = JSON.parse(request.responseText);
                        callback(null, jsonObject);
                    //} else { // request.status === 0)
                    } else if(request.status === 0) {

                        console.error("HTTP(%1): %2 %3".arg(url).arg(request.status).arg(request.statusText));

                        var newTime = time - 1;
                        if(newTime <= 0) {
                            callback(new Error('No connection'));
                            return;
                        }

                        sendFunction(newTime);
                    } else {

                        var message = 'Status %1 %2'.arg(request.status).arg(request.statusText);
                        console.error(message);

                        callback(new Error(message));
                    }

                } // End request.readyState === XMLHttpRequest.DONE
            } // End onreadystatechange.

            request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.send();
        }

        sendFunction(3);
    } // End request.
}

