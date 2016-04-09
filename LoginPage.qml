import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import QtQuick.Layouts 1.1

import Qt.labs.settings 1.0

Rectangle {
    id: root

    signal logined


    //property string loginText
    //property string passwordText

    Settings {
        //id: settings

        category: "User"
        property alias login: loginField.text
        //property alias password: root.passwordText
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

                console.debug("Click login");
                monkeyService.sendRequest(
                    'GET',
                    '/login?login=%1&password=%2'.arg(loginField.text).arg(passwordField.text),
                    null,
                    function(error, responseText){

                        if(error || responseText.toLowerCase() !== "ok") {

                            console.error("Error login.");
                            return;
                        }

                        console.debug("User logined");
                        root.logined();
                    }
                );
            }
        }
    } // End column.
}

