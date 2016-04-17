import QtQuick 2.0

Rectangle {
    id: root

    property int group: 0
    signal clicked

    property var groupToText: {
        0: qsTr("Today"),
        1: qsTr("Week"),
        2: qsTr("Year")
    }

    property var groupToColor: {
        0: "yellow",
        1: "green",
        2: "blue"
    }

    color: groupToColor[root.group]

    Text {
        anchors.centerIn: parent
        text: groupToText[root.group]
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked();
        }
    }

    DropArea {
        id: dragTarget

        property alias group: root.group
        property string taskId
        //property string colorKey: "red"
        //property alias dropProxy: dragTarget

        anchors.fill: parent
        //keys: [ taskId ]

        onEntered: {
            console.debug("DropArea entered");
        }
        onDropped: {
            console.debug("DropArea droped");
        }



        Rectangle {
            id: dropRectangle

            anchors.fill: parent
            color: "gray"
            opacity: 0.0

            states: [
                State {
                    when: dragTarget.containsDrag
                    PropertyChanges {
                        target: dropRectangle
                        opacity: 0.5
                    }
                }
            ]
        }
    }
}
