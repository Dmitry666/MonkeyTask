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
        //getTasks();
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
                        "task_id": task.id,
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

        var task = {
            "body": body,
            "order": 1000,
            "group": root.currentGroup
        }
        var jsonText = JSON.stringify(task);
        monkeyService.sendRequest(
            'POST',
            '/api/task',
            jsonText,
            function(error, responseText) {
                console.debug(responseText);

                var newTask = JSON.parse(responseText);


                taskModel.append({
                    "task_id": newTask.id,
                    "body": newTask.body,
                    "create_date": newTask.create_date,
                    "order": newTask.order,
                    "group": newTask.group,
                    "state": newTask.state
                });
                //taskModel.append(task);
            }
        );
    }

    function findIndexById(id) {
        for(var i=0; i<taskModel.count; i++) {
            if( taskModel.get(i).task_id === id) {
                return i;
            }
        }

        return -1;
    }

    function updateTask(id, task, callback) {

        console.debug("updateTask");

        var jsonText = JSON.stringify(task);
        monkeyService.sendRequest(
            'PUT',
            '/api/task/:%1'.arg(id),
            jsonText,
            function(error, responseText) {
                console.debug(responseText);
                callback();
            }
        );
    }

    function updateBody(id, body) {

        var task = {
            "body": body
        }

        updateTask(
            id,
            task,
            function() {
                var index = findIndexById(id);
                if(index !== -1 ) {
                    taskModel.setProperty(index, "body", body);
                } else {
                    console.error("Not found task. Update all");
                    getTasks();
                }
            }
        );
    }

    function updateState(id, state) {

        var task = {
            "state": state
        }

        updateTask(
            id,
            task,
            function() {
                var index = findIndexById(id);
                if(index !== -1 ) {
                    taskModel.setProperty(index, "state", state);
                } else {
                    console.error("Not found task. Update all");
                    getTasks();
                }
            }
        );
    }


    function updateGroup(id, group) {

        var task = {
            "group": group
        }

        updateTask(
            id,
            task,
            function() {
                var index = findIndexById(id);
                if(index !== -1 ) {
                    taskModel.setProperty(index, "group", group);
                } else {
                    console.error("Not found task. Update all");
                    getTasks();
                }
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
        id: dndContainer
        anchors.fill: parent
    }

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

                taskId: model.task_id
                title: model.body
                status: model.state
                //type: model.type

                onResolved: {
                    //model.state = model.state === 0 ? 1 : 0; //
                    root.updateState(model.task_id, model.state === 0 ? 1 : 0);
                }
                onChanged: {
                    root.updateBody(model.task_id, text);
                }
                onChangeGroup: {
                    root.updateGroup(model.task_id, group);
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

