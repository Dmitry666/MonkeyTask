import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import QtQuick.Layouts 1.1

import Qt.labs.settings 1.0

Rectangle {
    id: root

    signal logined

    property bool userLogined

    //property string loginText
    //property string passwordText

    Component.onCompleted: {
        if(root.userLogined) {
            root.loginUser(usetSettings.login, usetSettings.password);
        }
    }

    function loginUser(login, password) {
        monkeyService.sendRequest(
            'GET',
            '/login?login=%1&password=%2'.arg(login).arg(password),
            null,
            function(error, responseText){

                if(error || responseText.toLowerCase() !== "ok") {

                    root.userLogined = false;
                    console.error("Error login.");
                    return;
                }

                console.debug("User logined");

                root.userLogined = true;
                root.logined();
            }
        );
    }

    Settings {
        id: usetSettings

        category: "User"
        property alias login: loginField.text
        property alias password: passwordField.text
        property alias userLogined: root.userLogined
    }

    Column {
        id: column

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
        }

        TextField {
            id: loginField
            anchors {
                left: parent.left
                right: parent.right
            }

            placeholderText: qsTr("Login")
            //font.pixelSize: 23 * root.uiScale
            maximumLength: 64

            text: usetSettings.login
            horizontalAlignment: TextField.AlignHCenter
            //verticalAlignment: Text.AlignVCenter

            /*
            style: TextFieldStyle {
                textColor: "#393939"
                background: Item {}
            }
            */
        }

        TextField {
            id: passwordField
            anchors {
                left: parent.left
                right: parent.right
            }

            placeholderText: qsTr("Password")
            //font.pixelSize: 23 * root.uiScale
            maximumLength: 64

            horizontalAlignment: TextField.AlignHCenter
            //verticalAlignment: Text.AlignVCenter

            echoMode: TextInput.Password
            /*
            style: TextFieldStyle {
                textColor: "#393939"
                background: Item {}
            }
            */
        }

        Button {
            id: loginButton
            anchors {
                left: parent.left
                right: parent.right
            }

            enabled: loginField.text.length > 0 && passwordField.text.length > 0
            text: qsTr("Login")

            onClicked: {

                //usetSettings.login = loginField.text;
                console.debug("Click login");
                root.loginUser(loginField.text, passwordField.text);

            }
        }
    } // End column.
}

