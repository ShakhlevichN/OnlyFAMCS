#include "SignalingClient.h"
#include <QJsonArray>
#include <QDebug>

SignalingClient::SignalingClient(QObject *parent)
    : QObject(parent)
    , m_webSocket(new QWebSocket())
    , m_isSearching(false)
    , m_reconnectTimer(new QTimer(this))
    , m_reconnectAttempts(0)
{
    connect(m_webSocket, &QWebSocket::connected, this, &SignalingClient::onConnected);
    connect(m_webSocket, &QWebSocket::disconnected, this, &SignalingClient::onDisconnected);
    connect(m_webSocket, &QWebSocket::textMessageReceived, this, &SignalingClient::onTextMessageReceived);
    connect(m_webSocket, QOverload<QAbstractSocket::SocketError>::of(&QWebSocket::error), 
            this, &SignalingClient::onError);
    
    connect(m_reconnectTimer, &QTimer::timeout, this, &SignalingClient::reconnect);
    m_reconnectTimer->setSingleShot(true);
}

SignalingClient::~SignalingClient()
{
    disconnectFromServer();
    m_webSocket->deleteLater();
}

void SignalingClient::connectToServer(const QString& url, const QString& token)
{
    m_serverUrl = url;
    m_token = token;
    // Add token as query parameter for WebSocket authentication
    QString wsUrl = url;
    if (!token.isEmpty()) {
        wsUrl += "?token=" + token;
    }
    m_webSocket->open(QUrl(wsUrl));
}

void SignalingClient::disconnectFromServer()
{
    if (m_webSocket->state() == QAbstractSocket::ConnectedState) {
        m_webSocket->close();
    }
    m_reconnectTimer->stop();
    m_reconnectAttempts = 0;
}

void SignalingClient::searchForPartner()
{
    if (!isConnected()) {
        emit connectionError("Not connected to server");
        return;
    }
    
    m_isSearching = true;
    emit searchStatusChanged(true);
    
    QJsonObject message;
    message["type"] = "search";
    message["id"] = m_myId;
    sendMessage(message);
}

void SignalingClient::sendOffer(const QString& sdp)
{
    QJsonObject message;
    message["type"] = "offer";
    message["to"] = m_partnerId;
    message["from"] = m_myId;
    message["sdp"] = sdp;
    sendMessage(message);
}

void SignalingClient::sendAnswer(const QString& sdp)
{
    QJsonObject message;
    message["type"] = "answer";
    message["to"] = m_partnerId;
    message["from"] = m_myId;
    message["sdp"] = sdp;
    sendMessage(message);
}

void SignalingClient::sendIceCandidate(const QString& candidate, const QString& sdpMid, int sdpMLineIndex)
{
    QJsonObject message;
    message["type"] = "ice-candidate";
    message["to"] = m_partnerId;
    message["from"] = m_myId;
    message["candidate"] = candidate;
    message["sdpMid"] = sdpMid;
    message["sdpMLineIndex"] = sdpMLineIndex;
    sendMessage(message);
}

void SignalingClient::nextPartner()
{
    if (m_partnerId.isEmpty()) {
        searchForPartner();
        return;
    }
    
    QJsonObject message;
    message["type"] = "next";
    message["id"] = m_myId;
    message["partnerId"] = m_partnerId;
    sendMessage(message);
    
    m_partnerId.clear();
    m_isSearching = true;
    emit searchStatusChanged(true);
    emit partnerDisconnected();
}

bool SignalingClient::isConnected() const
{
    return m_webSocket->state() == QAbstractSocket::ConnectedState;
}

void SignalingClient::onConnected()
{
    qDebug() << "Connected to signaling server";
    m_reconnectAttempts = 0;
    emit connected();
}

void SignalingClient::onDisconnected()
{
    qDebug() << "Disconnected from signaling server";
    m_isSearching = false;
    emit searchStatusChanged(false);
    emit disconnected();
    
    // Attempt reconnection if not manually disconnected
    if (m_reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
        m_reconnectTimer->start(2000 * (m_reconnectAttempts + 1));
        m_reconnectAttempts++;
    }
}

void SignalingClient::onTextMessageReceived(const QString& message)
{
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8());
    if (!doc.isObject()) {
        qWarning() << "Invalid JSON message received";
        return;
    }
    
    handleSignalingMessage(doc.object());
}

void SignalingClient::onError()
{
    QString errorString = m_webSocket->errorString();
    qWarning() << "WebSocket error:" << errorString;
    emit connectionError(errorString);
}

void SignalingClient::reconnect()
{
    if (!isConnected() && m_reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
        qDebug() << "Attempting reconnection" << m_reconnectAttempts + 1;
        m_webSocket->open(QUrl(m_serverUrl));
    }
}

void SignalingClient::sendMessage(const QJsonObject& message)
{
    if (!isConnected()) {
        qWarning() << "Cannot send message: not connected";
        return;
    }
    
    QJsonDocument doc(message);
    m_webSocket->sendTextMessage(doc.toJson(QJsonDocument::Compact));
}

void SignalingClient::handleSignalingMessage(const QJsonObject& msg)
{
    QString type = msg["type"].toString();
    
    if (type == "id") {
        m_myId = msg["id"].toString();
        qDebug() << "Received ID:" << m_myId;
    }
    else if (type == "partner-found") {
        m_partnerId = msg["partnerId"].toString();
        m_isSearching = false;
        emit searchStatusChanged(false);
        emit partnerFound(m_partnerId);
        qDebug() << "Partner found:" << m_partnerId;
    }
    else if (type == "offer") {
        QString from = msg["from"].toString();
        QString sdp = msg["sdp"].toString();
        m_partnerId = from;
        emit offerReceived(from, sdp);
    }
    else if (type == "answer") {
        QString sdp = msg["sdp"].toString();
        emit answerReceived(sdp);
    }
    else if (type == "ice-candidate") {
        QString candidate = msg["candidate"].toString();
        QString sdpMid = msg["sdpMid"].toString();
        int sdpMLineIndex = msg["sdpMLineIndex"].toInt();
        emit iceCandidateReceived(candidate, sdpMid, sdpMLineIndex);
    }
    else if (type == "partner-disconnected") {
        m_partnerId.clear();
        emit partnerDisconnected();
    }
    else if (type == "connected") {
        QString userId = msg["userId"].toString();
        if (userId == m_myId) {
            emit connectionStateChanged();
        }
    }
    else {
        qWarning() << "Unknown message type:" << type;
    }
}
