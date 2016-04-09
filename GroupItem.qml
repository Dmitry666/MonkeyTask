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

    /*
    DropArea {
        id: dragTarget

        property string colorKey
        property alias dropProxy: dragTarget

        anchors.fill: parent
        keys: [ colorKey ]

        onEntered: {
            console.debug("DropArea entered");
        }


        Rectangle {
            id: dropRectangle

            anchors.fill: parent
            color: colorKey

            states: [
                State {
                    when: dragTarget.containsDrag
                    PropertyChanges {
                        target: dropRectangle
                        color: "grey"
                    }
                }
            ]
        }

    }
    */
}
