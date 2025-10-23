import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.VirtualKeyboard
ApplicationWindow {
    id: window
    width: 480
    height: 854
    visible: true
    title: "丰巢快递柜"

    // 定义颜色方案 - 浅色风格
    property color primaryColor: "#1E90FF"  // 道奇蓝
    property color secondaryColor: "#32CD32"  // 绿色
    property color backgroundColor: "#F8F8F8"  // 更浅的灰色背景
    property color buttonColor: "#FFFFFF"  // 白色按钮
    property color textColor: "#333333"  // 深灰文字

    property string host:"192.168.9.120"
    property int port: 8888

    property string courierPhone

    // StackView用于页面导航
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainPage
    }

    // 主页面组件
    Component {
        id: mainPage

        Rectangle {
            id: mainContainer
            width: window.width
            height: window.height
            color: backgroundColor

            // 背景图片 - 添加浅色背景纹理
            Image {
                id: backgroundImage
                source: "qrc:/images/background1.jpg"  // 背景图片路径
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                opacity: 0.99 // 设置不透明度，避免影响文字阅读
            }

            // 顶部标题区域
            Rectangle {
                id: header
                width: parent.width
                height: 150  // 更高的标题区域
                color: primaryColor

                Text {
                    anchors.centerIn: parent
                    text: "丰巢快递柜"
                    font.pixelSize: 42  // 更大的字体
                    font.bold: true
                    color: "white"
                }

                // 顶部装饰图标
                Image {
                    source: "qrc:/icons/logo.png"  // 公司logo图标
                    anchors {
                        left: parent.left
                        leftMargin: 30
                        verticalCenter: parent.verticalCenter
                    }
                    width: 100
                    height: 100
                    fillMode: Image.PreserveAspectFit
                }
            }

            // 主要内容区域
            ColumnLayout {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 40
                spacing: 50  // 更大的间距
                width: parent.width * 0.85

                // 投递按钮
                Rectangle {
                    id: deliveryBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160  // 更高的按钮
                    color: buttonColor
                    radius: 20  // 更大的圆角
                    border.color: primaryColor
                    border.width: 3

                    // 简单的阴影效果 - 使用矩形模拟
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: parent.radius
                        border.color: "#40000000"
                        border.width: 2
                        anchors.topMargin: 2
                        anchors.leftMargin: 2
                        z: -1
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 30

                        // 大图标区域
                        Image {
                            source: "qrc:/icons/delivery.png"  // 需要添加的图标路径
                            Layout.preferredWidth: 100  // 更大的图标
                            Layout.preferredHeight: 100
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            text: "投        递"
                            font.pixelSize: 36  // 更大的字体
                            font.bold: true
                            color: textColor
                            Layout.fillWidth: true
                        }
                    }

                    // 点击区域
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stackView.push("qrc:/page/login.qml")
                        }

                        // 按下效果
                        onPressed: deliveryBtn.color = Qt.darker(buttonColor, 1.1)
                        onReleased: deliveryBtn.color = buttonColor
                    }
                }

                // 取件按钮
                Rectangle {
                    id: pickupBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160  // 更高的按钮
                    color: buttonColor
                    radius: 20  // 更大的圆角
                    border.color: secondaryColor
                    border.width: 3

                    // 简单的阴影效果 - 使用矩形模拟
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: parent.radius
                        border.color: "#40000000"
                        border.width: 2
                        anchors.topMargin: 2
                        anchors.leftMargin: 2
                        z: -1
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 30

                        // 大图标区域
                        Image {
                            source: "qrc:/icons/pickup1.png"  // 需要添加的图标路径
                            Layout.preferredWidth: 100  // 更大的图标
                            Layout.preferredHeight: 100
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            text: "取        件"
                            font.pixelSize: 36  // 更大的字体
                            font.bold: true
                            color: textColor
                            Layout.fillWidth: true
                        }
                    }

                    // 点击区域
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            stackView.push("qrc:/page/pickup.qml")
                        }

                        // 按下效果
                        onPressed: pickupBtn.color = Qt.darker(buttonColor, 1.1)
                        onReleased: pickupBtn.color = buttonColor
                    }
                }
            }

            // 底部信息区域
            Rectangle {
                id: footer
                width: parent.width
                height: 80
                anchors.bottom: parent.bottom
                color: "#E8E8E8"

                Text {
                    anchors.centerIn: parent
                    text: "客服电话: 400-000-0000"
                    font.pixelSize: 22  // 更大的字体
                    color: "#666666"
                }
            }
        }

    }
    // -------------------------- 虚拟键盘：InputPanel --------------------------
    // 作用：移动设备无物理键盘时，弹出虚拟键盘供输入
    InputPanel {
        id: inputPanel
        z: 99 // 层级最高（避免被其他控件遮挡，新手易漏导致键盘看不见）
        x: 0 // 键盘左对齐窗口
        y: window.height // 初始位置：窗口底部外侧（默认隐藏）
        width: window.width // 键盘宽度=窗口宽度

        // 状态管理：控制键盘显示/隐藏
        states: State {
            name: "visible" // 状态名：显示状态
            when: inputPanel.active // 触发条件：输入框被激活（用户点击TextField）
            // 状态变化：键盘从窗口底部移到窗口内
            PropertyChanges {
                target: inputPanel // 目标控件：虚拟键盘
                // 计算位置：窗口高度 - 键盘高度 = 键盘顶部对齐窗口底部
                y: window.height - inputPanel.height
            }
        }

        // 过渡动画：让键盘显示/隐藏更平滑（提升用户体验）
        transitions: Transition {
            from: "" // 从默认状态（隐藏）
            to: "visible" // 到显示状态
            reversible: true // 支持反向动画（隐藏时也平滑）
            ParallelAnimation { // 并行动画（只改y轴，这里简化）
                NumberAnimation {
                    properties: "y" // 动画属性：y轴位置
                    duration: 250 // 动画时长（250ms=0.25秒，太快要么慢）
                    easing.type: Easing.InOutQuad // 缓动曲线（先慢后快再慢，更自然）
                }
            }
        }

    }
}
