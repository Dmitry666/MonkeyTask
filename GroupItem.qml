import QtQuick 2.0

Rectangle {
    id: root

    property int group: 0
    signal clicked

    //color:

    Text {
        anchors.centerIn: parent
        text: root.group
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked();
        }
    }

    DropArea {
        id: dragTarget

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
