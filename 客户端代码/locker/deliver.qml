import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: deliverView
    width: 480
    height: 854
    color: "#F8F8F8"
    property string cabinet_size: '0'

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
        height: 100
        color: "#1E90FF"

        // 返回按钮
        Rectangle {
            width: 70
            height: 70
            radius: 35
            color: "white"
            anchors {
                left: parent.left
                leftMargin: 15
                verticalCenter: parent.verticalCenter
            }

            Image {
                source: "qrc:/icons/back.png"
                width: 40
                height: 40
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {

                    stackView.pop()
                }

            }
        }

        Text {
            text: "快递投递"
            font.pixelSize: 28
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }
    }

    // 主要内容区域
    Column {
        anchors {
            top: header.bottom
            topMargin: 20
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        spacing: 15

        // 快递号输入区域
        Rectangle {
            width: parent.width - 40
            height: 90
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            radius: 12
            border.color: "#1E90FF"
            border.width: 2

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Image {
                    source: "qrc:/icons/parcel.png"  // 包裹图标
                    width: 40
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                }

                Column {
                    width: parent.width - 50
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Text {
                        text: "快递号"
                        font.pixelSize: 20
                        color: "#666666"
                    }

                    Rectangle {
                        width: parent.width
                        height: 40
                        color: "transparent"

                        TextInput {
                            id: parcelField
                            anchors.fill: parent
                            font.pixelSize: 24
                            color: "#333333"
                            maximumLength: 20

                            Text {
                                text: "请输入快递号"
                                font.pixelSize: 20
                                color: "#999999"
                                visible: !parcelField.text && !parcelField.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }

        // 手机号输入区域
        Rectangle {
            width: parent.width - 40
            height: 90
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            radius: 12
            border.color: "#1E90FF"
            border.width: 2

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Image {
                    source: "qrc:/icons/phone.png"
                    width: 40
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                }

                Column {
                    width: parent.width - 50
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Text {
                        text: "手机号码"
                        font.pixelSize: 20
                        color: "#666666"
                    }

                    Rectangle {
                        width: parent.width
                        height: 40
                        color: "transparent"

                        TextInput {
                            id: phoneNumberField
                            anchors.fill: parent
                            font.pixelSize: 24
                            color: "#333333"
                            maximumLength: 11
                            inputMethodHints: Qt.ImhDigitsOnly
                            validator: RegularExpressionValidator{regularExpression: /^[0-9]{11}$/}

                            Text {
                                text: "请输入11位手机号"
                                font.pixelSize: 20
                                color: "#999999"
                                visible: !phoneNumberField.text && !phoneNumberField.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }

        // 确认手机号输入区域
        Rectangle {
            width: parent.width - 40
            height: 90
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            radius: 12
            border.color: "#1E90FF"
            border.width: 2

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Image {
                    source: "qrc:/icons/phone_confirm.png"  // 确认手机号图标
                    width: 40
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                }

                Column {
                    width: parent.width - 50
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Text {
                        text: "确认手机号"
                        font.pixelSize: 20
                        color: "#666666"
                    }

                    Rectangle {
                        width: parent.width
                        height: 40
                        color: "transparent"

                        TextInput {
                            id: phoneNumberConfirmField
                            anchors.fill: parent
                            font.pixelSize: 24
                            color: "#333333"
                            maximumLength: 11
                            inputMethodHints: Qt.ImhDigitsOnly
                            validator: RegularExpressionValidator{regularExpression: /^[0-9]{11}$/}

                            Text {
                                text: "请再次输入手机号"
                                font.pixelSize: 20
                                color: "#999999"
                                visible: !phoneNumberConfirmField.text && !phoneNumberConfirmField.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }

        // 柜子尺寸选择区域
        Rectangle {
            width: parent.width - 40
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            radius: 12
            border.color: "#1E90FF"
            border.width: 2

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: "柜子尺寸"
                    font.pixelSize: 20
                    color: "#666666"
                }

                // 柜子尺寸选择按钮
                Row {
                    width: parent.width
                    height: 50
                    spacing: 15

                    // 小柜
                    Rectangle {
                        id: smallCabinet
                        width: (parent.width - 30) / 3
                        height: 50
                        color: cabinet_size === '0' ? "#1E90FF" : "#F5F5F5"
                        radius: 8
                        border.color: "#1E90FF"
                        border.width: 2

                        Text {
                            text: "小柜"
                            font.pixelSize: 22
                            color: cabinet_size === '0' ? "white" : "#333333"
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                cabinet_size = '0'
                            }
                        }
                    }

                    // 中柜
                    Rectangle {
                        id: mediumCabinet
                        width: (parent.width - 30) / 3
                        height: 50
                        color: cabinet_size === '1' ? "#1E90FF" : "#F5F5F5"
                        radius: 8
                        border.color: "#1E90FF"
                        border.width: 2

                        Text {
                            text: "中柜"
                            font.pixelSize: 22
                            color: cabinet_size === '1' ? "white" : "#333333"
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                cabinet_size = '1'
                            }
                        }
                    }

                    // 大柜
                    Rectangle {
                        id: largeCabinet
                        width: (parent.width - 30) / 3
                        height: 50
                        color: cabinet_size === '2' ? "#1E90FF" : "#F5F5F5"
                        radius: 8
                        border.color: "#1E90FF"
                        border.width: 2

                        Text {
                            text: "大柜"
                            font.pixelSize: 22
                            color: cabinet_size === '2' ? "white" : "#333333"
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                cabinet_size = '2'
                            }
                        }
                    }
                }
            }
        }

        // 结果显示区域
        Rectangle {
            width: parent.width - 40
            height: 70
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            radius: 10
            border.color: "#E0E0E0"
            border.width: 2

            Text {
                id: receivedText
                anchors.fill: parent
                anchors.margins: 8
                text: "请填写投递信息"
                font.pixelSize: 18
                color: "#666666"
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // 按钮区域
        Row {
            width: parent.width - 40
            height: 80
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            // 投递按钮
            Rectangle {
                id: deliverButton
                width: (parent.width - 10) * 0.6
                height: 80
                color: "#32CD32"
                radius: 15

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Image {
                        source: "qrc:/icons/delivery1.png"  // 投递图标
                        width: 40
                        height: 40
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "投 递"
                        font.pixelSize: 26
                        font.bold: true
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(phoneNumberField.text === "" || parcelField.text === ""){
                            receivedText.text = "请输入包裹号和手机号"
                            receivedText.color = "#FF0000"
                        } else if(phoneNumberField.text.length !== 11){
                            receivedText.text = "请输入11位手机号"
                            receivedText.color = "#FF0000"
                        } else if(phoneNumberField.text !== phoneNumberConfirmField.text){
                            receivedText.text = "两次输入的手机号不一致"
                            receivedText.color = "#FF0000"
                        } else {
                            // 扩展请求格式：'d' + 尺寸 + 快递号 + '\0' + 收件人手机号 + '\0' + 快递员手机号 + '\0'
                            var requestData = 'd' + cabinet_size + parcelField.text + '\0' + phoneNumberField.text + '\0' + window.courierPhone + '\0';
                            udpClient.sendMessage(requestData, host, port);
                            parcelField.text = ""
                            phoneNumberField.text = ""
                            phoneNumberConfirmField.text = ""
                            receivedText.text = "正在处理投递，请稍候..."
                            receivedText.color = "#333333"
                        }
                    }

                    onPressed: deliverButton.color = Qt.darker("#32CD32", 1.2)
                    onReleased: deliverButton.color = "#32CD32"
                    onCanceled: deliverButton.color = "#32CD32"
                }
            }

            // 完成按钮
            Rectangle {
                id: finishButton
                width: (parent.width - 10) * 0.4
                height: 80
                color: "#666666"
                radius: 15

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Image {
                        source: "qrc:/icons/login.png"  // 完成图标
                        width: 35
                        height: 35
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "完 成"
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        stackView.pop(null)  // 返回主页面
                    }

                    onPressed: finishButton.color = Qt.darker("#666666", 1.2)
                    onReleased: finishButton.color = "#666666"
                    onCanceled: finishButton.color = "#666666"
                }
            }
        }

        // 底部信息
        Item {
            width: parent.width
            height: 60

            Text {
                anchors.centerIn: parent
                text: "客服电话: 400-000-0000"
                font.pixelSize: 18
                color: "#666666"
            }
        }
    }

    // 监听UDP模块的"收到消息"信号
    Connections {
        target: udpClient
        function onMsgDeliver(message) {
            if(message === "没有找到合适的空闲柜子" || message === "请不要重复投递") {
                receivedText.text = message
                receivedText.color = "#FF0000"
            } else {
                receivedText.text = "请将包裹存入" + message + "号柜子"
                receivedText.color = "#32CD32"
            }
        }
    }
}
