import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: pickupView
    width: 480
    height: 854
    color: "#F8F8F8"

    // 添加对主窗口的引用
    property var mainWindow: ApplicationWindow.window

    // 背景图片
    Image {
        source: "qrc:/images/background1.jpg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        opacity: 0.99
    }

    // 顶部标题栏
    Rectangle {
        id: header
        width: parent.width
        height: 150
        color: "#1E90FF"

        // 返回按钮
        Rectangle {
            width: 100
            height: 100
            radius: 50
            color: "white"
            anchors {
                left: parent.left
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }

            Image {
                source: "qrc:/icons/back.png"
                width: 60
                height: 60
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                anchors.fill: parent
                onClicked: stackView.pop()
            }
        }

        Text {
            text: "取件服务"
            font.pixelSize: 36
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }
    }

    // 主要内容区域
    ColumnLayout {
        anchors {
            top: header.bottom
            topMargin: 60
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        spacing: 40

        // 取件码输入区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            Layout.leftMargin: 40
            Layout.rightMargin: 40
            color: "white"
            radius: 20
            border.color: "#1E90FF"
            border.width: 3

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 25
                spacing: 20

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Image {
                        source: "qrc:/icons/keyboard.png"
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 50
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "请输入8位取件码"
                        font.pixelSize: 28
                        color: "#333333"
                        Layout.fillWidth: true
                    }
                }

                // 取件码输入框 - 修复点击激活
                Rectangle {
                    id: inputContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: "#F5F5F5"
                    radius: 15
                    border.color: pickupCodeField.activeFocus ? "#1E90FF" : "#CCCCCC"
                    border.width: 2

                    TextInput {
                        id: pickupCodeField
                        anchors.fill: parent
                        anchors.margins: 15
                        font.pixelSize: 32
                        color: "#333333"
                        maximumLength: 8
                        inputMethodHints: Qt.ImhDigitsOnly
                        horizontalAlignment: Text.AlignHCenter
                        validator: RegularExpressionValidator{regularExpression: /^[0-9]{8}$/}

                        // 自动隐藏系统键盘，使用自定义键盘
                        onActiveFocusChanged: {
                            if (activeFocus) {
                                customNumberKeyboard.visible = true
                                // 隐藏系统虚拟键盘
                                Qt.inputMethod.hide()
                            } else {
                                customNumberKeyboard.visible = false
                            }
                        }

                        // 占位文本
                        Text {
                            text: "输入8位数字取件码"
                            font.pixelSize: 26
                            color: "#999999"
                            visible: !pickupCodeField.text && !pickupCodeField.activeFocus
                            anchors.centerIn: parent
                        }
                    }

                    // 点击整个区域激活输入框和自定义键盘
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pickupCodeField.forceActiveFocus()
                            customNumberKeyboard.visible = true
                        }
                    }
                }
            }
        }

        // 按钮区域
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            Layout.leftMargin: 40
            Layout.rightMargin: 40
            spacing: 30

            // 取件按钮
            Rectangle {
                id: pickupButton
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "#32CD32"
                radius: 25

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Image {
                        source: "qrc:/icons/pickup2.png"
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "取 件"
                        font.pixelSize: 32
                        font.bold: true
                        color: "white"
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(pickupCodeField.text === "" || pickupCodeField.text.length !== 8){
                            receivedText.text = "请输入8位数字取件码"
                            receivedText.color = "#FF0000"
                        } else {
                            udpClient.sendMessage('p' + pickupCodeField.text + '\0', host, port)
                            receivedText.text = "正在查询，请稍候..."
                            receivedText.color = "#333333"
                        }
                    }

                    onPressed: pickupButton.color = Qt.darker("#32CD32", 1.2)
                    onReleased: pickupButton.color = "#32CD32"
                    onCanceled: pickupButton.color = "#32CD32"
                }
            }

            // 完成按钮
            Rectangle {
                id: finishButton
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "#1E90FF"
                radius: 25

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Image {
                        source: "qrc:/icons/home.png"
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "完 成"
                        font.pixelSize: 32
                        font.bold: true
                        color: "white"
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: stackView.pop()

                    onPressed: finishButton.color = Qt.darker("#1E90FF", 1.2)
                    onReleased: finishButton.color = "#1E90FF"
                    onCanceled: finishButton.color = "#1E90FF"
                }
            }
        }

        // 结果显示区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            Layout.leftMargin: 40
            Layout.rightMargin: 40
            color: "white"
            radius: 20
            border.color: "#E0E0E0"
            border.width: 2

            Text {
                id: receivedText
                anchors.fill: parent
                anchors.margins: 20
                text: "等待输入取件码..."
                font.pixelSize: 26
                color: "#666666"
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // 底部信息
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "客服电话: 400-000-0000"
            font.pixelSize: 22
            color: "#666666"
        }
    }

    // 自定义数字键盘 - 修复高度计算
    // 在 pickup.qml 中替换现有的自定义数字键盘
    Rectangle {
        id: customNumberKeyboard
        width: parent.width
        height: 380  // 增加高度
        anchors.bottom: parent.bottom
        color: "#F0F0F0"
        visible: false
        z: 100

        // 键盘标题栏
        Rectangle {
            width: parent.width
            height: 50
            color: "#1E90FF"

            Text {
                text: "数字键盘"
                font.pixelSize: 24
                color: "white"
                anchors.centerIn: parent
            }

            // 关闭按钮
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: "transparent"
                anchors {
                    right: parent.right
                    rightMargin: 15
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "×"
                    font.pixelSize: 30
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pickupCodeField.focus = false
                        customNumberKeyboard.visible = false
                    }
                }
            }
        }

        GridLayout {
            anchors {
                top: parent.top
                topMargin: 60
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 15
            }
            columns: 3
            rows: 4
            columnSpacing: 12
            rowSpacing: 12

            // 数字键 1-9
            Repeater {
                model: 9
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#CCCCCC"
                    border.width: 2

                    Text {
                        text: index + 1
                        font.pixelSize: 32  // 增大字体
                        font.bold: true
                        color: "#333333"
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (pickupCodeField.text.length < 8) {
                                pickupCodeField.text += (index + 1)
                            }
                        }
                        onPressed: parent.color = "#E8E8E8"
                        onReleased: parent.color = "white"
                        onCanceled: parent.color = "white"
                    }
                }
            }

            // 0 键
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 10
                border.color: "#CCCCCC"
                border.width: 2

                Text {
                    text: "0"
                    font.pixelSize: 32  // 增大字体
                    font.bold: true
                    color: "#333333"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (pickupCodeField.text.length < 8) {
                            pickupCodeField.text += "0"
                        }
                    }
                    onPressed: parent.color = "#E8E8E8"
                    onReleased: parent.color = "white"
                }
            }

            // 删除键
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#FF6B6B"
                radius: 10

                Text {
                    text: "⌫"
                    font.pixelSize: 28
                    font.bold: true
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pickupCodeField.text = pickupCodeField.text.substring(0, pickupCodeField.text.length - 1)
                    }
                    onPressed: parent.color = Qt.darker("#FF6B6B", 1.2)
                    onReleased: parent.color = "#FF6B6B"
                }
            }

            // 完成键 - 单独一行
            Rectangle {
                Layout.columnSpan: 3
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: "#32CD32"
                radius: 10

                Text {
                    text: "完成输入"
                    font.pixelSize: 26
                    font.bold: true
                    color: "white"
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pickupCodeField.focus = false
                        customNumberKeyboard.visible = false
                    }
                    onPressed: parent.color = Qt.darker("#32CD32", 1.2)
                    onReleased: parent.color = "#32CD32"
                }
            }
        }
    }

    // 监听UDP模块的"收到消息"信号
    Connections {
        target: udpClient
        function onMsgPickup(message) {
            if(message === "查询失败,取件码错误！") {
                receivedText.text = message
                receivedText.color = "#FF0000"
            } else {
                pickupCodeField.text = ""
                receivedText.text = "请到：" + message + "号柜子提取包裹"
                receivedText.color = "#32CD32"
            }
        }
    }
}
