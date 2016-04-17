import QtQuick 2.0
import QtQuick.Controls 1.3

Rectangle {
    id: root

    height: 50
    color: "gray"

    property string taskId
    property string type: "task"
    property string title
    property int status
    property bool edit

    property string colorKey: "blue"

    signal resolved
    signal changed(string text)
    signal changeGroup(int group)

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

            visible: !root.edit

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: statusRect.right
                right: rightRow.left

                margins: 5
            }

            verticalAlignment: Text.AlignVCenter

            MouseArea {
                anchors.fill: parent
                onDoubleClicked: {
                    root.edit = true;
                }
            }
        }

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: statusRect.right
                right: rightRow.left

                margins: 5
            }

            visible: root.edit

            TextEdit {
                id: editText

                anchors.fill: parent

                text: root.title


                verticalAlignment: Text.AlignVCenter
            }
        }

        /*
        MouseArea {
            onDoubleClicked: {

            }
        }
        */
        Row {
            id: rightRow
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }

            Rectangle {
                id: editButton
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: height

                color: root.edit ? "red" : "yellow"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.edit = !root.edit;
                        if(!root.edit && root.title != editText.text) {
                            root.changed(editText.text);
                        }
                    }
                }
            } // End edit button.

            MouseArea {
               id: mouseArea

               anchors {
                   top: parent.top
                   bottom: parent.bottom
               }

               width: height

               drag.target: tile

               onReleased: {

                   if(tile.Drag.target !== null) {

                       var newGroup = tile.Drag.target.group;
                       console.debug("New group: ", newGroup);
                       root.changeGroup(newGroup);

                   }

                   //parent = mouseArea;
                   //parent = tile.Drag.target !== null ? tile.Drag.target : mouseArea
               }

               Rectangle {
                   id: tile

                   width: mouseArea.width
                   height: mouseArea.height
                   anchors {
                       horizontalCenter: parent.horizontalCenter;
                       verticalCenter: parent.verticalCenter
                   }

                   color: colorKey

                   //Drag.keys: [ root.taskId ]
                   Drag.active: mouseArea.drag.active
                   Drag.hotSpot.x: 32
                   Drag.hotSpot.y: 32

                   states: State {
                       when: mouseArea.drag.active
                       ParentChange {
                           target: tile
                           parent: root
                       }
                       AnchorChanges {
                           target: tile;
                           anchors.verticalCenter: undefined;
                           anchors.horizontalCenter: undefined
                       }
                   }

               }
            }
        } // End row.
    }


    Item {
        id: emptyBody
        anchors.fill: parent

        Button {
            anchors.fill: parent
        }
    }



} // End delegate.
