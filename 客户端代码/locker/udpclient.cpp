// 引入头文件（必须加，否则找不到UdpClient的“说明书”）
#include "udpclient.h"
// 引入数据报工具（处理网络消息的“包裹”）
#include <QNetworkDatagram>
#include <unistd.h>

// 构造函数的实现（创建对象时执行）
UdpClient::UdpClient(QObject *parent)
    : QObject{parent}  // 给父类QObject传参数（不用管）
{
    // 1. 创建“网络天线”（udpSocket），并交给Qt管理（不用手动删）
    udpSocket = new QUdpSocket(this);

    // 2. 关键连接：当“天线”收到消息时，调用onReadyRead处理
    // （相当于“天线”收到信号后，自动喊处理函数来干活）
    connect(udpSocket, &QUdpSocket::readyRead, this, &UdpClient::onReadyRead);
}

// 发送消息的实现（界面调用这个函数发消息）
void UdpClient::sendMessage(const QString &message, const QString &host, quint16 port) {
    // 1. 把文字消息转成网络能传输的“二进制数据”（网络只认二进制）
    QByteArray data = message.toUtf8();

    // 2. 用“天线”把数据发出去（参数：数据、对方地址、对方端口）
    udpSocket->writeDatagram(data, QHostAddress(host), port);
}

void UdpClient::bindSocket(quint16 port) {
    // 关键：如果已经绑定过端口，先解除绑定（避免重复绑定导致错误）
    if (udpSocket->state() == QUdpSocket::BoundState) {
        udpSocket->close(); // 关闭当前绑定
    }
    // 重新绑定到指定端口
    bool isBound = udpSocket->bind(QHostAddress::Any, port);

    // 可以添加绑定结果的提示（可选，方便调试）
    if (isBound) {
        qDebug() << "绑定端口" << port << "成功！";
    } else {
        qDebug() << "绑定端口" << port << "失败！错误原因：" << udpSocket->errorString();
    }
}

// 处理收到消息的实现（内部函数，自动被调用）
void UdpClient::onReadyRead() {
    // 循环处理所有收到的消息（可能一次收到多个）
    while (udpSocket->hasPendingDatagrams()) {
        // 1. 接收一个消息“包裹”
        QNetworkDatagram datagram = udpSocket->receiveDatagram();

        // 2. 把“包裹”里的二进制数据转成文字
        //QString receivedMsg = QString(datagram.data());
        QByteArray data = datagram.data();
        switch (data[0]) {
        case 'l':
            emit msgLogin(QString(&data[1]));          //这里的信号由qml那边处理 Connection{....}
            break;
        case 'r':
            emit msgRegister(QString(&data[1]));

            break;
        case 'd':
            emit msgDeliver(QString(&data[1]));
            if(fork()==0)
            {
                execlp("digital","digital",&data[1],NULL);
            }
            break;
        case 'p':
            emit msgPickup(QString(&data[1]));
            if(fork()==0)
            {
                execlp("digital","digital",&data[1],NULL);
            }
            break;
        default:
            // 3. 发信号“喊一声”：“我收到消息啦！”（界面会听到这个信号）
            emit messageReceived(QString(data));
            break;
        }

    }
}
