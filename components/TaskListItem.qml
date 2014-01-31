import QtQuick 2.0
import "../qml-air"
import "../qml-air/ListItems" as ListItem
import "../qml-air/listutils.js" as ListUtils

ListItem.BaseListItem {
    id: listItem

    property var model
    property var itemIndex
    property bool trimmed: label.implicitWidth > label.width
    style: !isComplete && isPast && !modelData.done ? "danger" : "default"

    toolTip: trimmed ? model.text : ""

    onRightClicked: {
        itemMenu.index = itemIndex
        itemMenu.open(caller)
    }

    Icon {
        id: icon

        width: height
        name: model.done ? "check-square-o" : "square-o"
        size: listItem.fontSize
        color: textColor

        mouseEnabled: true
        onClicked: {
            var list = tasks
            model.done = !model.done
            list[modelIndex][itemIndex] = model
            tasks = list
        }

        anchors {
            left: parent.left
            leftMargin: margins + (model.done ? 1 : 0)
            verticalCenter: parent.verticalCenter
        }
    }

    Label {
        id: label

        style: listItem.style
        color: textColor
        elide: Text.ElideRight
        text: formatText(model.text)

        MouseArea {
            anchors.fill: parent
            onClicked: textField.forceActiveFocus()
        }
        visible: !textField.editing

        anchors {
            verticalCenter: parent.verticalCenter
            left: icon.right
            right: dragItem.left
            leftMargin: margins + (model.done ? -1 : 0)
            rightMargin: margins
        }
    }

    TextField {
        id: textField

        style: listItem.style
        //color: textColor
        //elide: Text.ElideRight
        hidden: true
        text: model.text
        visible: textField.editing

        anchors {
            verticalCenter: parent.verticalCenter
            left: icon.right
            right: dragItem.left
            leftMargin: margins + (model.done ? -1 : 0)
            rightMargin: margins
        }
    }

    Icon {
        id: dragItem
        width: height
        name: "bars"
        size: listItem.fontSize
        color: textColor

        mouseEnabled: true

        anchors {
            right: parent.right
            rightMargin: margins
            verticalCenter: parent.verticalCenter
        }

        MouseArea {
             id: dragArea
             anchors.fill: parent
             property int positionStarted: 0
             property int positionEnded: 0
             property int positionsMoved: Math.floor((positionEnded - positionStarted)/listItem.height)
             property int newPosition: index + positionsMoved
             property bool held: false
             drag.axis: Drag.YAxis

             onPressed: {
                 print("ON PRESS AND OLD")
                  listItem.z = 2
                  positionStarted = listItem.y
                  dragArea.drag.target = listItem
                  listItem.opacity = 0.5
                  listView.interactive = false
                  held = true
                  drag.maximumY = (list.height - listItem.height - 1 + listItem.contentY)
                  drag.minimumY = 0
             }

             onReleased: {
                  if (Math.abs(positionsMoved) < 1 && held == true) {
                       listItem.y = positionStarted
                       listItem.opacity = 1
                       listView.interactive = true
                       dragArea.drag.target = null
                       held = false
                  } else {
                       if (held == true) {
                           var list = tasks[modelIndex]
                            if (newPosition < 1) {
                                 listItem.z = 1
                                 list.move(index,0,1)
                                 listItem.opacity = 1
                                 listView.interactive = true
                                 dragArea.drag.target = null
                                 held = false
                            } else if (newPosition > listView.count - 1) {
                                 listItem.z = 1
                                 list.move(index,listView.count - 1,1)
                                 listItem.opacity = 1
                                 listView.interactive = true
                                 dragArea.drag.target = null
                                 held = false
                            } else {
                                 listItem.z = 1
                                 list.move(index,newPosition,1)
                                 listItem.opacity = 1
                                 listView.interactive = true
                                 dragArea.drag.target = null
                                 held = false
                            }
                       }
                       var tasksList = tasks
                       tasksList[modelIndex] = list
                       tasks = tasksList
                  }
             }
        }
    }
}
