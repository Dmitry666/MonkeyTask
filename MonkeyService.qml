import QtQuick 2.0

Item {
    id: root

    //serviceName: "MonkeyTasl"
    //centralServer: '%1/Myselfie/List?token=%2'
    //                    .arg(settings.centralServer)
     //                   .arg(settings.serviceToken)

    //signal settingsUpdated(var settingsBody)
    //signal finishUpdatePool

    property string address: "http://vps4.unitsys.ru:9999"

    /*
    property bool firstLogin: true

    property bool waitPong
    property bool firstPing: true;
    Timer {
        id: pingTimer
        interval: (!root.connected) ? 10000 : 60000
        //interval: (!root.connected) ? 10000 : 500
        repeat: true
        running: !waitPong
        onTriggered: {
            firstPing = false;
            ping();
        }
    }
    */

    function sendRequest(type, url, body, callback) {

        var query = "%1%2".arg(root.address).arg(url);
        console.debug(query);

        var request = new XMLHttpRequest()
        request.open(type, query);

        request.onreadystatechange = function() {

            if (request.readyState === XMLHttpRequest.DONE) {

                if (request.status === 200) {

                    callback(null, request.responseText);

                } else if(request.status === 0) {

                    console.error("HTTP(%1): %2 %3".arg(url).arg(request.status).arg(request.statusText));

                } else {

                    var message = 'Status %1 %2'.arg(request.status).arg(request.statusText);
                    callback(new Error(message));
                }

            } // End request.readyState === XMLHttpRequest.DONE
        } // End onreadystatechange.

        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.send(body);
    }

    /*
    function loginTerminal(funcSuccess, funcError) {

        function AccessDeniedError(message) {
          this.name = 'AccessDenied';
          this.message = message;
        }
        AccessDeniedError.prototype = Object.create(Error.prototype);
        AccessDeniedError.prototype.constructor = AccessDeniedError;

        function UnknownServiceError(message) {
          this.name = 'UnknownError';
          this.message = message;
        }
        UnknownServiceError.prototype = Object.create(Error.prototype);
        UnknownServiceError.prototype.constructor = UnknownServiceError;

        if(instagramService.serviceToken === "") {
            funcError(new AccessDeniedError("Token is empty"));
            return;
        }

        var query = '/Common/Login?token=%1'
            .arg(instagramService.serviceToken);

        sendHttpRequest(
            query,
            function(error, jsonObject){

                if(error === null) {

                    var metaObject = jsonObject.meta;
                    var code = metaObject.code;
                    if(code === 200) {  // Success meta code and callback body.

                        var bodyObject = jsonObject.body;
                        instagramService.terminalId = bodyObject.id;

                        if(bodyObject["trial"] !== undefined) {
                            instagramService.trial = true;
                            var seconds = bodyObject["trial"]["seconds"] / (60 * 60 * 24) + 1;
                            instagramService.trialDays = seconds;

                            console.debug("Trial version. Seconds: %1.".arg(seconds));
                        }

                        funcSuccess();

                        if(firstLogin) {
                            startUp();
                            firstLogin = false;
                        }
                    } else if(code === 400) {
                        var message = metaObject["message_error"];
                        var errorText = "%1(%2): '%3' - '%4'."
                            .arg(root.serviceName)
                            .arg(root.address)
                            .arg(code)
                            .arg(message);
                        console.error(errorText);

                        funcError(new AccessDeniedError("Token not valid"));
                    } else {
                        var message = metaObject["message_error"];
                        var errorText = "%1(%2): '%3' - '%4'."
                            .arg(root.serviceName)
                            .arg(root.address)
                            .arg(code)
                            .arg(message);
                        console.error(errorText);

                        funcError(new UnknownServiceError("UnknownService"));
                    }
                } else {

                    funcError(error);
                }
            }
        );
    }  // End login terminal.


    function logoutTerminal(callback) {

        sendRequest(
            '/Common/Logout',
            function(error, bodyObject){
                if(error === null) {
                    logouted();
                }
                callback(error);
            }
        );
    } // End logout terminal.
    */

    /*
    // Ping () - Ping that terminal working
    function ping() {

        waitPong = true;
        sendRequest(
            '/Status/Ping',
            function(error, bodyObject){

                waitPong = false;
                //console.debug("Status sended to server.");
            }
        );
    } // End set status.


    Component.onCompleted: {
        if(instagramService.serviceToken === "") {
            accessDenied();
            return;
        }

        if(centralServer !== "") {
            updateServerPool(function(){
                root.finishUpdatePool();
            });
        }
    }
    */
}

