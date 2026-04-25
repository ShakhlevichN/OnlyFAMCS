#include "VideoChatApp.h"
#include <QQmlContext>
#include <QQmlComponent>
#include <QDebug>
#include <QCoreApplication>

VideoChatApp::VideoChatApp(QObject *parent)
    : QObject(parent)
    , m_engine(new QQmlApplicationEngine(this))
    , m_isConnected(false)
    , m_isSearching(false)
    , m_connectionStatus("Disconnected")
{
    // Initialize components
    m_authManager = new AuthManager(this);
    m_cameraHandler = new CameraHandler(this);
    m_signalingClient = new SignalingClient(this);
    m_webrtcManager = new WebRTCManager(this);
    
    // Setup connections between components
    setupConnections();
    
    // Expose objects to QML
    m_engine->rootContext()->setContextProperty("videoChatApp", this);
    m_engine->rootContext()->setContextProperty("authManager", m_authManager);
    m_engine->rootContext()->setContextProperty("cameraHandler", m_cameraHandler);
    m_engine->rootContext()->setContextProperty("signalingClient", m_signalingClient);
    m_engine->rootContext()->setContextProperty("webrtcManager", m_webrtcManager);
    
    // Load QML
    // const QUrl url(QStringLiteral("qrc:/qml/main.qml")); // Commented out - not used
    QObject::connect(m_engine, &QQmlApplicationEngine::objectCreated,
                     this, [](QObject *obj, const QUrl &objUrl) {
        if (!obj) {
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);
    // m_engine->load(url); // Commented out - not used
}

VideoChatApp::~VideoChatApp()
{
    disconnectFromServer();
}

bool VideoChatApp::isConnected() const
{
    return m_isConnected;
}

bool VideoChatApp::isSearching() const
{
    return m_isSearching;
}

QString VideoChatApp::connectionStatus() const
{
    return m_connectionStatus;
}

void VideoChatApp::connectToServer(const QString& url)
{
    if (!m_authManager->isLoggedIn()) {
        emit errorMessage("Please login first");
        return;
    }
    m_signalingClient->connectToServer(url, m_authManager->token());
}

void VideoChatApp::disconnectFromServer()
{
    m_signalingClient->disconnectFromServer();
    m_webrtcManager->closeConnection();
    m_cameraHandler->stopCamera();
}

void VideoChatApp::startChat()
{
    if (!m_signalingClient->isConnected()) {
        emit errorMessage("Not connected to server");
        return;
    }
    
    // Start camera
    m_cameraHandler->startCamera();
    
    // Create WebRTC peer connection
    m_webrtcManager->createPeerConnection();
    
    // Search for partner
    m_signalingClient->searchForPartner();
}

void VideoChatApp::nextPartner()
{
    // Close current WebRTC connection
    m_webrtcManager->closeConnection();
    
    // Create new peer connection
    m_webrtcManager->createPeerConnection();
    
    // Search for new partner
    m_signalingClient->nextPartner();
}

void VideoChatApp::stopChat()
{
    m_webrtcManager->closeConnection();
    m_cameraHandler->stopCamera();
    m_partnerId.clear();
    updateConnectionStatus();
}

void VideoChatApp::onConnected()
{
    m_isConnected = true;
    updateConnectionStatus();
    emit connectionStateChanged();
}

void VideoChatApp::onDisconnected()
{
    m_isConnected = false;
    m_isSearching = false;
    m_partnerId.clear();
    updateConnectionStatus();
    emit connectionStateChanged();
    emit searchStatusChanged();
}

void VideoChatApp::onPartnerFound(const QString& partnerId)
{
    m_partnerId = partnerId;
    m_isSearching = false;
    updateConnectionStatus();
    emit searchStatusChanged();
    
    // Create offer as the caller
    m_webrtcManager->createOffer();
}

void VideoChatApp::onOfferReceived(const QString& from, const QString& sdp)
{
    m_partnerId = from;
    m_isSearching = false;
    updateConnectionStatus();
    emit searchStatusChanged();
    
    // Create answer to the offer
    m_webrtcManager->createAnswer(sdp);
}

void VideoChatApp::onAnswerReceived(const QString& sdp)
{
    m_webrtcManager->handleAnswer(sdp);
}

void VideoChatApp::onIceCandidateReceived(const QString& candidate, const QString& sdpMid, int sdpMLineIndex)
{
    m_webrtcManager->addIceCandidate(candidate, sdpMid, sdpMLineIndex);
}

void VideoChatApp::onPartnerDisconnected()
{
    m_partnerId.clear();
    updateConnectionStatus();
    emit partnerDisconnected();
}

void VideoChatApp::onConnectionError(const QString& error)
{
    emit errorMessage(error);
}

void VideoChatApp::onWebRTCConnectionFailed(const QString& error)
{
    emit errorMessage(error);
    nextPartner();
}

void VideoChatApp::onRemoteVideoTrackAdded()
{
    // Handle remote video track - this would be connected to QML VideoOutput
    qDebug() << "Remote video track added";
}

void VideoChatApp::updateConnectionStatus()
{
    if (!m_isConnected) {
        m_connectionStatus = "Disconnected";
    } else if (m_isSearching) {
        m_connectionStatus = "Searching for partner...";
    } else if (!m_partnerId.isEmpty()) {
        m_connectionStatus = "Connected to partner";
    } else {
        m_connectionStatus = "Connected to server";
    }
    
    emit connectionStatusChanged();
}

void VideoChatApp::setupConnections()
{
    // Signaling client connections
    connect(m_signalingClient, &SignalingClient::connected, this, &VideoChatApp::onConnected);
    connect(m_signalingClient, &SignalingClient::disconnected, this, &VideoChatApp::onDisconnected);
    connect(m_signalingClient, &SignalingClient::partnerFound, this, &VideoChatApp::onPartnerFound);
    connect(m_signalingClient, &SignalingClient::offerReceived, this, &VideoChatApp::onOfferReceived);
    connect(m_signalingClient, &SignalingClient::answerReceived, this, &VideoChatApp::onAnswerReceived);
    connect(m_signalingClient, &SignalingClient::iceCandidateReceived, this, &VideoChatApp::onIceCandidateReceived);
    connect(m_signalingClient, &SignalingClient::partnerDisconnected, this, &VideoChatApp::onPartnerDisconnected);
    connect(m_signalingClient, &SignalingClient::connectionError, this, &VideoChatApp::onConnectionError);
    connect(m_signalingClient, &SignalingClient::searchStatusChanged, this, [this](bool isSearching) {
        m_isSearching = isSearching;
        updateConnectionStatus();
        emit searchStatusChanged();
    });
    
    // WebRTC manager connections
    connect(m_webrtcManager, &WebRTCManager::offerCreated, m_signalingClient, &SignalingClient::sendOffer);
    connect(m_webrtcManager, &WebRTCManager::answerCreated, m_signalingClient, &SignalingClient::sendAnswer);
    connect(m_webrtcManager, &WebRTCManager::iceCandidateGenerated, m_signalingClient, &SignalingClient::sendIceCandidate);
    connect(m_webrtcManager, &WebRTCManager::connectionFailed, this, &VideoChatApp::onWebRTCConnectionFailed);
    connect(m_webrtcManager, &WebRTCManager::remoteVideoTrackAdded, this, &VideoChatApp::onRemoteVideoTrackAdded);
    connect(m_webrtcManager, &WebRTCManager::connectionStateChanged, this, [this]() {
        m_isConnected = m_webrtcManager->isConnected();
        updateConnectionStatus();
        emit connectionStateChanged();
    });
    
    // Camera handler connections
    connect(m_cameraHandler, &CameraHandler::cameraError, this, &VideoChatApp::errorMessage);
}
