import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

import "qrc:/Service"

ApplicationWindow {
    title: qsTr("MonkeyTask")
    width: 640
    height: 480
    visible: true

    Component.onCompleted: {
        stackview.push(loginPageComponent);
    }

    MonkeyService {
        id: monkeyService


    }

    StackView {
          id: stackview
          anchors.fill: parent
    }

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
