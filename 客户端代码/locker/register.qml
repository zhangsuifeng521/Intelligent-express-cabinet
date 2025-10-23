import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: registerView
    width: 480
    height: 854
    color: "#F8F8F8"
    property string company: ""

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
        height: 100  // 进一步降低标题栏高度
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
                onClicked: stackView.pop()
            }
        }

        Text {
            text: "快递员注册"
            font.pixelSize: 28  // 减小字体
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }
    }

    // 主要内容区域 - 使用更紧凑的布局
    Column {
        anchors {
            top: header.bottom
            topMargin: 20  // 减少顶部间距
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        spacing: 15  // 大幅减少组件间距

        // 手机号输入区域
        Rectangle {
            width: parent.width - 40  // 减少边距
            height: 90  // 降低高度
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

        // 密码输入区域
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
                    source: "qrc:/icons/password.png"
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
                        text: "密码"
                        font.pixelSize: 20
                        color: "#666666"
                    }

                    Rectangle {
                        width: parent.width
                        height: 40
                        color: "transparent"

                        TextInput {
                            id: passWordField
                            anchors.fill: parent
                            font.pixelSize: 24
                            color: "#333333"
                            maximumLength: 16
                            echoMode: TextInput.Password

                            Text {
                                text: "请输入密码"
                                font.pixelSize: 20
                                color: "#999999"
                                visible: !passWordField.text && !passWordField.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }

        // 确认密码输入区域
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
                    source: "qrc:/icons/password_confirm.png"
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
                        text: "确认密码"
                        font.pixelSize: 20
                        color: "#666666"
                    }

                    Rectangle {
                        width: parent.width
                        height: 40
                        color: "transparent"

                        TextInput {
                            id: passWordConfirmField
                            anchors.fill: parent
                            font.pixelSize: 24
                            color: "#333333"
                            maximumLength: 16
                            echoMode: TextInput.Password

                            Text {
                                text: "请再次输入密码"
                                font.pixelSize: 20
                                color: "#999999"
                                visible: !passWordConfirmField.text && !passWordConfirmField.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }

        // 快递公司选择区域
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
                    source: "qrc:/icons/company.png"
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
                        text: "快递公司"
                        font.pixelSize: 20
                        color: "#666666"
                    }

                    // 快递公司下拉选择
                    Rectangle {
                        width: parent.width
                        height: 40
                        color: "#F5F5F5"
                        radius: 6

                        ComboBox {
                            id: courierSelector
                            anchors.fill: parent
                            anchors.margins: 3
                            font.pixelSize: 20

                            // 下拉选项数据模型
                            model: ListModel {
                                id: courierList
                                ListElement { code: "JD";  name: "京东快递" }
                                ListElement { code: "SF";  name: "顺丰快递" }
                                ListElement { code: "EMS"; name: "邮政EMS快递" }
                                ListElement { code: "ST";  name: "申通快递" }
                                ListElement { code: "YT";  name: "圆通快递" }
                                ListElement { code: "YD";  name: "韵达快递" }
                                ListElement { code: "JT";  name: "极兔快递" }
                            }

                            textRole: "name"

                            onCurrentIndexChanged: {
                                company = courierList.get(currentIndex).name
                            }

                            // 设置默认选中第一项
                            Component.onCompleted: {
                                currentIndex = 0
                                company = courierList.get(0).name
                            }
                        }
                    }
                }
            }
        }

        // 结果显示区域
        Rectangle {
            width: parent.width - 40
            height: 70  // 降低高度
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            radius: 10
            border.color: "#E0E0E0"
            border.width: 2

            Text {
                id: receivedText
                anchors.fill: parent
                anchors.margins: 8
                text: "请填写注册信息"
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
            height: 80  // 降低高度
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            // 确认注册按钮
            Rectangle {
                id: confirmButton
                width: (parent.width - 10) * 0.6
                height: 80
                color: "#32CD32"
                radius: 15

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Image {
                        source: "qrc:/icons/confirm.png"
                        width: 40
                        height: 40
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "确 认"
                        font.pixelSize: 26
                        font.bold: true
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        //验证合理性
                        if(phoneNumberField.text === "" || passWordField.text === "" || passWordConfirmField.text === ""){
                            receivedText.text = "请填写所有信息"
                            receivedText.color = "#FF0000"
                        } else if(phoneNumberField.text.length !== 11){
                            receivedText.text = "请输入11位手机号"
                            receivedText.color = "#FF0000"
                        } else if(passWordField.text !== passWordConfirmField.text){
                            receivedText.text = "两次输入的密码不一致"
                            receivedText.color = "#FF0000"
                        } else {
                            udpClient.sendMessage('r' + phoneNumberField.text + '\0' + passWordField.text + '\0' + company + '\0', host, port)
                            receivedText.text = "正在注册，请稍候..."
                            receivedText.color = "#333333"
                        }
                    }

                    onPressed: confirmButton.color = Qt.darker("#32CD32", 1.2)
                    onReleased: confirmButton.color = "#32CD32"
                    onCanceled: confirmButton.color = "#32CD32"
                }
            }

            // 取消按钮
            Rectangle {
                id: cancelButton
                width: (parent.width - 10) * 0.4
                height: 80
                color: "#666666"
                radius: 15

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Image {
                        source: "qrc:/icons/cancel.png"
                        width: 35
                        height: 35
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "取 消"
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: stackView.pop()

                    onPressed: cancelButton.color = Qt.darker("#666666", 1.2)
                    onReleased: cancelButton.color = "#666666"
                    onCanceled: cancelButton.color = "#666666"
                }
            }
        }

        // 底部信息 - 确保有空间显示
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
        function onMsgRegister(message) {
            receivedText.text = "服务器回复: " + message
            if(message === "注册成功！！") {
                receivedText.color = "#32CD32"
                // 注册成功后可选择自动返回登录页面
                registerSuccessTimer.start()
            } else {
                receivedText.color = "#FF0000"
            }
        }
    }

    // 注册成功返回定时器
    Timer {
        id: registerSuccessTimer
        interval: 2000
        onTriggered: {
            stackView.pop() // 返回登录页面
        }
    }
}
