#ifndef SIGNALINGCLIENT_H
#define SIGNALINGCLIENT_H

#include <QObject>
#include <QWebSocket>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>

class SignalingClient : public QObject
{
    Q_OBJECT

public:
    explicit SignalingClient(QObject *parent = nullptr);
    ~SignalingClient();

    Q_INVOKABLE void connectToServer(const QString& url, const QString& token);
    Q_INVOKABLE void disconnectFromServer();
    Q_INVOKABLE void searchForPartner();
    Q_INVOKABLE void sendOffer(const QString& sdp);
    Q_INVOKABLE void sendAnswer(const QString& sdp);
    Q_INVOKABLE void sendIceCandidate(const QString& candidate, const QString& sdpMid, int sdpMLineIndex);
    Q_INVOKABLE void nextPartner();

    bool isConnected() const;

signals:
    void connected();
    void disconnected();
    void connectionError(const QString& error);
    void partnerFound(const QString& partnerId);
    void offerReceived(const QString& from, const QString& sdp);
    void answerReceived(const QString& sdp);
    void iceCandidateReceived(const QString& candidate, const QString& sdpMid, int sdpMLineIndex);
    void partnerDisconnected();
    void searchStatusChanged(bool isSearching);
    void connectionStateChanged();

private slots:
    void onConnected();
    void onDisconnected();
    void onTextMessageReceived(const QString& message);
    void onError();
    void reconnect();

private:
    void sendMessage(const QJsonObject& message);
    void handleSignalingMessage(const QJsonObject& msg);

    QWebSocket* m_webSocket;
    QString m_serverUrl;
    QString m_token;
    QString m_myId;
    QString m_partnerId;
    bool m_isSearching;
    QTimer* m_reconnectTimer;
    int m_reconnectAttempts;
    static const int MAX_RECONNECT_ATTEMPTS = 5;
};

#endif // SIGNALINGCLIENT_H
