import QtQuick 2.4
import QtQuick.Controls 1.3
import Qt.labs.settings 1.0

import com.monkey.models 1.0

import "qrc:/Components"

Rectangle {
    id: root

    color: "green"
    property int currentGroup: 0

    Settings {
        //id: settings

        category: "Tasks"
        property alias currentGroup: root.currentGroup
    }

    Component.onCompleted: {

        console.debug("MainPage onCompleted");
        getTasks();
    }

    function getTasks() {

        console.debug("getTasks");
        monkeyService.sendRequest(
            'GET',
            '/api/task',
            null,
            function(error, responseText) {

                if(error) {
                    return;
                }

                var jsonObject = JSON.parse(responseText);

                taskModel.clear();

                var nbTasks = jsonObject.length;
                for(var i=0; i<nbTasks; i++) {

                    var task = jsonObject[i];

                    taskModel.append({
                        "id": task.id,
                        "body": task.body,
                        "create_date": task.create_date,
                        "order": task.order,
                        "group": task.group,
                        "state": task.state
                    });
                }

                //taskModel.append({"type": "empty"});
            }
        );
    } // End getTasks.

    function getTask(id) {

        console.debug("getTask");
        monkeyService.sendRequest(
            'GET',
            '/api/task/:%1'.arg(id),
            null,
            function(error, responseText) {

            }
        );
    }

    function createTask(body) {

        console.debug("createTask");


        var jsonText = JSON.stringify(task);
        monkeyService.sendRequest(
            'POST',
            '/api/task',
            jsonText,
            function(error, responseText) {
                console.debug(responseText);

                var task = {
                    "body": body,
                    "order": 1000,
                    "group": root.currentGroup
                }
                taskModel.append(task);
            }
        );
    }

    function updateTask(id, title) {

        console.debug("updateTask");
        //taskModel.setProperty(index, "", "")

        monkeyService.sendRequest(
            'PUT',
            '/api/task/:%1'.arg(id),
            null,
            function(error, responseText) {
                console.debug(responseText);
            }
        );
    }

    function deleteTask(id) {

        console.debug("deleteTask");
        //taskModel.remove();
        monkeyService.sendRequest(
            'DELETE',
            '/api/task/:%1'.arg(id),
            null,
            function(error, responseText) {
                console.debug(responseText);
            }
        );
    }

    ListModel {
        id: taskModel
    }

    FilterPropertyModel {
        id: filterModel
        sourceModel: taskModel
        propertyName: "group"
        propertyValue: root.currentGroup
    }

    /*
    SortPropertyModel {
        id: sortModel
        sourceModel: filterModel
        propertyName: "number"
    }


    ListModel {
        id: fullModel
    }
    */
    //

    Item {
        id: body
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: footer.top
        }

        ListView {
            id: listView
            anchors {
                left: parent.left
                right: parent.right

                top: parent.top
                bottom: tools.top
            }

            model: filterModel
            delegate: TaskItem {

                width: listView.width
                height: 50

                title: model.body
                status: model.state
                //type: model.type

                onResolved: {
                    model.state = 1; //
                }
            } // End delegate.
        } // End list view.

        // TODO. Create empty task in list view.
        Item {
            id: tools
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 50

            Button {
                id: addTaskButton
                text: qsTr("Add")

                anchors.centerIn: parent

                onClicked: {

                    createTask("Empty");
                }
            }
        }
    } // End body.

    Item {
        id: footer
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: parent.height * 0.1

        GroupItem {
            id: leftGroup

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }

            width: parent.width / 2
            color: "red"

            group: (currentGroup + 1) % 3
            onClicked: {
                root.currentGroup = group;
            }
        }

        GroupItem {
            id: rightGroup
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }

            width: parent.width / 2
            color: "blue"

            group: (currentGroup + 2) % 3
            onClicked: {
                root.currentGroup = group;
            }
        }
    } // End footer.
}

