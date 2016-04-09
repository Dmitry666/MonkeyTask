import QtQuick 2.0
import QtQuick.Controls 1.3

Rectangle {
    id: root

    height: 50
    color: "gray"

    property string type: "task"
    property string title
    property int status

    property string colorKey: "blue"

    signal resolved

    states: [
        State {
            name: "task"
            PropertyChanges { target: taskBody; visible: true }
            PropertyChanges { target: emptyBody; visible: false }
        },
        State {
            name: "empty"
            PropertyChanges { target: taskBody; visible: false }
            PropertyChanges { target: emptyBody; visible: true }
        }
    ]
    state: root.type

    Item {
        id: taskBody
        anchors.fill: parent

        Rectangle {
            id: statusRect
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom

                margins: 5
            }

            width: height

            color: root.status === 0 ? "blue" : "green"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.resolved();
                }
            }
        }

        Text {
            id: title
            text: root.title
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: statusRect.right
                right: mouseArea.left

                margins: 5
            }

            verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
           id: mouseArea

           anchors {
               right: parent.right
               top: parent.top
               bottom: parent.bottom
           }

           width: height

           drag.target: tile

           onReleased: parent = tile.Drag.target !== null ? tile.Drag.target : root

           Rectangle {
               id: tile

               width: mouseArea.width
               height: mouseArea.height
               anchors.fill: parent

               color: colorKey

               Drag.keys: [ colorKey ]
               Drag.active: mouseArea.drag.active
               Drag.hotSpot.x: 32
               Drag.hotSpot.y: 32
               states: State {
                   when: mouseArea.drag.active
                   ParentChange { target: tile; parent: root }
                   AnchorChanges {
                       target: tile;
                       anchors.verticalCenter: undefined;
                       anchors.horizontalCenter: undefined }
               }

           }
       }
    }


    Item {
        id: emptyBody
        anchors.fill: parent

        Button {
            anchors.fill: parent
        }
    }



} // End delegate.
