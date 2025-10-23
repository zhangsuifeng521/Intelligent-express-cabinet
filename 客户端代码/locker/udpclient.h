#ifndef UDPCLIENT_H
#define UDPCLIENT_H

#include <QObject>
#include <QUdpSocket>
class UdpClient : public QObject
{
    Q_OBJECT
public:
    explicit UdpClient(QObject *parent = nullptr);

    // QML 可调用的函数，发送消息
    Q_INVOKABLE void sendMessage(const QString &message, const QString &host, quint16 port);

    // QML 可调用的函数，绑定套接字到某个端口
    Q_INVOKABLE void bindSocket(quint16 port);
signals:
    // 当接收到 UDP 消息时发送的信号，QML 通过此信号来获取接收到的消息
    void messageReceived(const QString &message);
    void msgLogin(const QString &message);
    void msgDeliver(const QString &message);
    void msgRegister(const QString &message);
    void msgPickup(const QString &message);
private slots:
    // 处理待接收的数据包的槽函数
    void onReadyRead();
private:
    // QUdpSocket 实例，用于发送和接收 UDP 数据包
    QUdpSocket *udpSocket;
};

#endif // UDPCLIENT_H
