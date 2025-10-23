import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: loginView
    width: 480
    height: 854
    color: "#F8F8F8"

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
        height: 120  // 稍微降低标题栏高度
        color: "#1E90FF"

        // 返回按钮
        Rectangle {
            width: 80
            height: 80
            radius: 40
            color: "white"
            anchors {
                left: parent.left
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }

            Image {
                source: "qrc:/icons/back.png"
                width: 50
                height: 50
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                anchors.fill: parent
                onClicked: stackView.pop()
            }
        }

        Text {
            text: "快递员登录"
            font.pixelSize: 32  // 稍微减小字体
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }
    }

    // 主要内容区域 - 使用更紧凑的布局
    Column {
        anchors {
            top: header.bottom
            topMargin: 30  // 减少顶部间距
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        spacing: 25  // 减少组件间距

        // 手机号输入区域
        Rectangle {
            width: parent.width - 60  // 减少边距
            height: 120  // 稍微降低高度
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            radius: 15
            border.color: "#1E90FF"
            border.width: 2

            Row {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Image {
                    source: "qrc:/icons/phone.png"
                    width: 50
                    height: 50
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                }

                Column {
                    width: parent.width - 65
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Text {
                        text: "手机号码"
                        font.pixelSize: 22
                        color: "#666666"
                    }

                    Rectangle {
                        width: parent.width
                        height: 50
                        color: "transparent"

                        TextInput {
                            id: phoneNumberField
                            anchors.fill: parent
                            font.pixelSize: 26
                            color: "#333333"
                            maximumLength: 11
                            inputMethodHints: Qt.ImhDigitsOnly
                            validator: RegularExpressionValidator{regularExpression: /^[0-9]{11}$/}

                            Text {
                                text: "请输入11位手机号"
                                font.pixelSize: 22
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
            width: parent.width - 60
            height: 120
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            radius: 15
            border.color: "#1E90FF"
            border.width: 2

            Row {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Image {
                    source: "qrc:/icons/password.png"
                    width: 50
                    height: 50
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                }

                Column {
                    width: parent.width - 65
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Text {
                        text: "密码"
                        font.pixelSize: 22
                        color: "#666666"
                    }

                    Rectangle {
                        width: parent.width
                        height: 50
                        color: "transparent"

                        TextInput {
                            id: passWordField
                            anchors.fill: parent
                            font.pixelSize: 26
                            color: "#333333"
                            maximumLength: 16
                            echoMode: TextInput.Password

                            Text {
                                text: "请输入密码"
                                font.pixelSize: 22
                                color: "#999999"
                                visible: !passWordField.text && !passWordField.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }

        // 结果显示区域
        Rectangle {
            width: parent.width - 60
            height: 100  // 降低高度
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            radius: 15
            border.color: "#E0E0E0"
            border.width: 2

            Text {
                id: receivedText
                anchors.fill: parent
                anchors.margins: 10
                text: "请输入手机号和密码登录"
                font.pixelSize: 22
                color: "#666666"
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // 按钮区域
        Row {
            width: parent.width - 60
            height: 100  // 降低高度
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15

            // 登录按钮
            Rectangle {
                id: loginButton
                width: (parent.width - 15) * 0.6
                height: 100
                color: "#32CD32"
                radius: 20

                Row {
                    anchors.centerIn: parent
                    spacing: 15

                    Image {
                        source: "qrc:/icons/login.png"
                        width: 50
                        height: 50
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "登 录"
                        font.pixelSize: 30
                        font.bold: true
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(phoneNumberField.text === "" || passWordField.text === ""){
                            receivedText.text = "请输入手机号和密码"
                            receivedText.color = "#FF0000"
                        } else if(phoneNumberField.text.length !== 11){
                            receivedText.text = "请输入11位手机号"
                            receivedText.color = "#FF0000"
                        } else {
                            udpClient.sendMessage('l' + phoneNumberField.text + '\0' + passWordField.text + '\0', host, port)

                            receivedText.text = "正在登录，请稍候..."
                            receivedText.color = "#333333"
                        }
                    }

                    onPressed: loginButton.color = Qt.darker("#32CD32", 1.2)
                    onReleased: loginButton.color = "#32CD32"
                    onCanceled: loginButton.color = "#32CD32"
                }
            }

            // 注册按钮
            Rectangle {
                id: registerButton
                width: (parent.width - 15) * 0.4
                height: 100
                color: "#1E90FF"
                radius: 20

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Image {
                        source: "qrc:/icons/register.png"
                        width: 45
                        height: 45
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "注 册"
                        font.pixelSize: 26
                        font.bold: true
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        stackView.push("qrc:/page/register.qml")
                    }

                    onPressed: registerButton.color = Qt.darker("#1E90FF", 1.2)
                    onReleased: registerButton.color = "#1E90FF"
                    onCanceled: registerButton.color = "#1E90FF"
                }
            }
        }

        // 底部信息 - 确保有足够空间显示
        Item {
            width: parent.width
            height: 80  // 增加高度确保显示

            Text {
                anchors.centerIn: parent
                text: "客服电话: 400-000-0000"
                font.pixelSize: 20
                color: "#666666"
            }
        }
    }

    // 监听UDP模块的"收到消息"信号
    Connections {
        target: udpClient
        function onMsgLogin(message) {
            receivedText.text = "服务器回复: " + message
            if(message === "ok") {
                receivedText.color = "#32CD32"
                window.courierPhone = phoneNumberField.text;  // window是main.qml的根窗口id

                passWordField.text = ""  //登陆成功清空账号和密码
                phoneNumberField.text = ""
                // 关键：登录成功后，存储当前快递员手机号（全局属性，供投递页使用）

                receivedText.text = "请输入手机号和密码登录"
                stackView.push("qrc:/page/deliver.qml")
            } else {
                receivedText.color = "#FF0000"
            }
        }
    }

}
