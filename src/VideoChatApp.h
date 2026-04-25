#ifndef VIDEOCHATAPP_H
#define VIDEOCHATAPP_H

#include <QObject>
#include <QQmlApplicationEngine>
#include <QVideoSink>
#include "AuthManager.h"
#include "CameraHandler.h"
#include "SignalingClient.h"
#include "WebRTCManager.h"

class VideoChatApp : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionStateChanged)
    Q_PROPERTY(bool isSearching READ isSearching NOTIFY searchStatusChanged)
    Q_PROPERTY(QString connectionStatus READ connectionStatus NOTIFY connectionStatusChanged)

public:
    explicit VideoChatApp(QObject *parent = nullptr);
    ~VideoChatApp();

    bool isConnected() const;
    bool isSearching() const;
    QString connectionStatus() const;

    Q_INVOKABLE void connectToServer(const QString& url);
    Q_INVOKABLE void disconnectFromServer();
    Q_INVOKABLE void startChat();
    Q_INVOKABLE void nextPartner();
    Q_INVOKABLE void stopChat();

signals:
    void connectionStateChanged();
    void searchStatusChanged();
    void connectionStatusChanged();
    void errorMessage(const QString& error);
    void partnerDisconnected();

private slots:
    void onConnected();
    void onDisconnected();
    void onPartnerFound(const QString& partnerId);
    void onOfferReceived(const QString& from, const QString& sdp);
    void onAnswerReceived(const QString& sdp);
    void onIceCandidateReceived(const QString& candidate, const QString& sdpMid, int sdpMLineIndex);
    void onPartnerDisconnected();
    void onConnectionError(const QString& error);
    void onWebRTCConnectionFailed(const QString& error);
    void onRemoteVideoTrackAdded();

private:
    void updateConnectionStatus();
    void setupConnections();

    AuthManager* m_authManager;
    CameraHandler* m_cameraHandler;
    SignalingClient* m_signalingClient;
    WebRTCManager* m_webrtcManager;
    QQmlApplicationEngine* m_engine;
    
    bool m_isConnected;
    bool m_isSearching;
    QString m_connectionStatus;
    QString m_partnerId;
};

#endif // VIDEOCHATAPP_H
