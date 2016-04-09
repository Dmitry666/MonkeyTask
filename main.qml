import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

import Qt.labs.settings 1.0

import "qrc:/Service"

ApplicationWindow {
    id: window

    title: qsTr("MonkeyTask")
    width: 640
    height: 480
    visible: true

    /*
    //property bool logined: value
    Component.onCompleted: {
        if(usetSettings.logined) {

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

                    body.state = "work";
                    mainPage.getTasks();
                }
            );

        }

        //stackview.push(loginPageComponent);
    }*/


    MonkeyService {
        id: monkeyService
    }

    Item {
        id: body
        anchors.fill: parent

        state: "login" //settings.state


        states: [
            State {
                name: "login"
                PropertyChanges { target: loginPage; visible: true }
                PropertyChanges { target: mainPage; visible: false }
            },
            State {
                name: "work"
                PropertyChanges { target: loginPage; visible: false }
                PropertyChanges { target: mainPage; visible: true }
            }
        ]

        LoginPage {
            id: loginPage
            anchors.fill: parent
            onLogined: {
                body.state = "work";
                mainPage.getTasks();
            }
        }
        MainPage {
            id: mainPage
            anchors.fill: parent
        }
    }

    /*
    StackView {
          id: stackview
          anchors.fill: parent
    }
    */

    // Components
    Component {
        id: loginPageComponent
        LoginPage {
            onLogined: {
                stackview.clear();
                stackview.push(mainPageComponent);
            }
        }
    }

    Component {
        id: mainPageComponent
        MainPage {

        }
    }

    Component {
        id: settingsPageComponent
        SettingsPage {

        }
    }
}
