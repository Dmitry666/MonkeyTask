import QtQuick 2.0

Rectangle {
    id: root

    property alias text: textItem.text
    signal clicked

    color: mouseArea.pressed ? "green" : "blue"

    width: 100
    height: 50

    Text {
        id: textItem
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            root.clicked();
        }
    }
}

