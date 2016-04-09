import QtQuick 2.0

RequestService {
    id: root

    signal logined
    signal logouted
    signal accessDenied
    signal error(int code)

    property string serviceName
    property string centralServer

    /*
    onCentralServerChanged: {
        if(centralServer !== "") {
            updateServerPool();
        }
    }
    */

    property var serversPool: [
        //{
        //    "alias": "default",
        //    "address": "https://vps3.unitsys.ru:3333",
        //    "online": true
        //}
    ]
    property int serverIndex: 0

    property bool active
    property bool connected
    property bool connecting

    property bool ignoreErrors: false

    Component.onCompleted: {
        //updateServerPool();
    }

    property var requests: []

    function isValid() {
        return serversPool.length > 0;
    }

    function loadLocalPool() {

        for(var i=0;i<instagramService.numServers(root.serviceName); i++) {
            var alias = instagramService.serverAlias(root.serviceName, i);
            var address = instagramService.serverAddress(root.serviceName, i);

            console.debug("Load local server %1: %2 - %3".arg(root.serviceName).arg(alias).arg(address));
            serversPool.push(
                {
                    "alias": alias,
                    "address": address,
                    "online": true
                }
            );
        }
    } // End load load.

    function getServiceAddress(funcSuccess, funcError) {

        console.debug("getServiceAddress by %1"
                    .arg(root.centralServer));

        var request = new XMLHttpRequest()
        request.open('GET', root.centralServer);

        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {

                if (request.status && request.status === 200) {

                    var jsonObject = JSON.parse(request.responseText);

                    var metaObject = jsonObject["meta"];
                    var code = metaObject["code"];

                    if(code === 200) {

                        var bodyObject = jsonObject["body"];
                        var listObject = bodyObject["list"];

                        instagramService.clearServerPool(root.serviceName);
                        root.serversPool = [];
                        for(var i = 0; i < listObject.length; i++) {

                            var serverInfo = listObject[i];

                            console.debug("New server %1:%2"
                                .arg(serverInfo.alias)
                                .arg(serverInfo.address));

                            root.serversPool.push(
                                {
                                    "alias": serverInfo.alias,
                                    "address": serverInfo.address,
                                    "online": serverInfo.online
                                }
                            );

                            instagramService.appendServer(
                                root.serviceName,
                                serverInfo.id,
                                serverInfo.alias,
                                serverInfo.address,
                                serverInfo.online);
                        }

                        instagramService.saveServerPool(root.serviceName);
                        funcSuccess();

                    } else if(code === 400) {
                        var message = metaObject["message_error"];
                        console.error("GetServiceAddress request: '%1' - '%2'."
                                      .arg(code)
                                      .arg(message));

                        funcError();
                        root.accessDenied();
                    } else {

                        var message = metaObject["message_error"];
                        console.error("GetServiceAddress request: '%1' - '%2'."
                                      .arg(code)
                                      .arg(message));

                        funcError();
                    }
                } else {
                    console.error("Central %1 (%2) server HTTP: %3 %4"
                                  .arg(root.serviceName)
                                  .arg(root.centralServer)
                                  .arg(request.status)
                                  .arg(request.statusText));
                    funcError();
                }
            } // End request.readyState === XMLHttpRequest.DONE
        } // End onreadystatechange.

        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.send();
    } // End get service address.


    function reconnectServer(authorizatationCallback, connectedCallback) {

        if(serversPool.length === 0) {
            console.debug("Server pool for '%1' is empty.", root.serviceName);
            return;
        }

        requests.push(connectedCallback);

        var reconnectFunction = function(time) {

            if(serverIndex >= serversPool.length) {
                serverIndex = 0;
            }

            var server = serversPool[serverIndex];

            var serverAlias = server.alias;
            root.address = server.address;

            console.debug("Reconnect to '%1(%2)'."
                          .arg(root.serviceName)
                          .arg(root.address));

            authorizatationCallback(
                function() { // success.

                    console.debug("Logined to '%1(%2)' success."
                                  .arg(root.serviceName)
                                  .arg(root.address)
                    );

                    if(!root.connected) {
                        root.connected = true;
                        root.logined(); /// ????
                    }

                    connecting = false;
                    var callbacks = requests;
                    requests = [];
                    for(var i = 0; i<callbacks.length;i++) {
                        var callback = callbacks[i];
                        callback(null);
                    }

                    //connectedCallback(null);
                }, // Edn success.
                function(e) { // error

                    console.debug("LoginTerminal '%1' denied: %2"
                        .arg(root.serviceName)
                        .arg(e.name + ': ' + e.message)
                    );

                    if(e.name === "AccessDenied") {

                        root.connected = false;
                        root.active = false;

                        connecting = false;
                        var callbacks = requests;
                        requests = [];
                        for(var i = 0; i<callbacks.length;i++) {
                            var callback = callbacks[i];
                            callback(new Error("Service access denied"));
                        }
                        //connectedCallback(new Error("Service access denied"));

                        if(!root.ignoreErrors) {
                            root.accessDenied(); // ????
                        }

                    } else {

                        if(time <= 0) {
                            root.connected = false;

                            connecting = false;
                            var callbacks = requests;
                            requests = [];
                            for(var i = 0; i<callbacks.length;i++) {
                                var callback = callbacks[i];
                                callback(new Error("Service don't avaliable"));
                            }
                            //connectedCallback(new Error("Service don't avaliable"));

                            if(!root.ignoreErrors) {
                                root.error(0); // ????
                            }

                            return;
                        }

                        root.serverIndex++;
                        reconnectFunction(time - 1);
                    }
                } // End error.
            );
        } // End reconnect function.

        if(!connecting) {
            connecting = true;
            reconnectFunction(5);
        }
    } // End reconnect server.


    function sendRequestPool(url, authorizatationCallback, callback) {

        var sendHttpRequestFunction = function() {
            sendHttpRequest(
                url,
                function(error, jsonObject) {

                    if(error !== null) {

                        reconnectServer(
                            authorizatationCallback,
                            function(error){

                                if(error === null) {
                                    sendHttpRequestFunction();
                                } else {
                                    callback(error);
                                }
                            }
                        );
                        return;
                    }

                    if(jsonObject["meta"] === undefined) {
                        console.error("Not found meta block for %1(%2)".arg(root.serviceName).arg(url));
                        callback(new Error("Meta block not found."));
                        return;
                    }

                    var metaObject = jsonObject.meta;

                    if(metaObject["code"] === undefined) {
                        console.error("Not found code block for %1(%2)".arg(root.serviceName).arg(url));
                        callback(new Error("Code field in meta block not found."));
                        return;
                    }

                    var code = metaObject.code;
                    if(code === 200) {  // Success meta code and callback body.

                        var bodyObject = jsonObject.body;
                        callback(null, bodyObject);

                    } else { // Error meta code and callback meta error.

                        var message = metaObject["message_error"];
                        var errorText = "%1(%2): '%3' - '%4'."
                            .arg(root.serviceName)
                            .arg(root.address)
                            .arg(code)
                            .arg(message);
                        console.error(errorText);
                        callback(new Error(errorText));
                    }
                }
            ); // End sendHttpRequest.
        }; // End sendHttpRequestFunction.

        if(connected) {
            sendHttpRequestFunction();
        } else {
            console.debug("Service '%1' don't connected, connect to server.".arg(root.serviceName));
            reconnectServer(
                authorizatationCallback,
                function(error){

                    if(error === null) {
                        sendHttpRequestFunction();
                    } else {
                        callback(error);
                    }
                }
            );
        }

    } // End request.

    function updateServerPool(callback) {

        //loadLocalPool();

        getServiceAddress(
            function() { // Success.
                root.active = true;
                callback();
            },
            function() { // Denied.
                loadLocalPool();
                root.active = true;
                callback();
            }
        );
    } // End updaye server pool.
}

