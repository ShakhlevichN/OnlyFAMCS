#include "WebRTCManager.h"
#include <rtc/rtc.hpp>
#include <QDebug>
#include <QVideoFrameFormat>
#include <QImage>
#include <QBuffer>
#include <QIODevice>

const QString WebRTCManager::STUN_SERVER = "stun:stun.l.google.com:19302";

WebRTCManager::WebRTCManager(QObject *parent)
    : QObject(parent)
    , m_localVideoSink(nullptr)
    , m_remoteVideoSink(nullptr)
    , m_videoTimer(new QTimer(this))
    , m_isConnected(false)
    , m_localSdpMid("")
    , m_localSdpMLineIndex(0)
{
    // Initialize libdatachannel logging
    rtc::InitLogger(rtc::LogLevel::Warning);
    
    // Setup video frame processing timer
    connect(m_videoTimer, &QTimer::timeout, this, &WebRTCManager::processLocalVideoFrame);
    m_videoTimer->setInterval(33); // ~30 FPS
}

WebRTCManager::~WebRTCManager()
{
    closeConnection();
}

bool WebRTCManager::isConnected() const
{
    return m_isConnected;
}

void WebRTCManager::createPeerConnection()
{
    try {
        setupPeerConnection();
    } catch (const std::exception& e) {
        emit connectionFailed(QString("Failed to create peer connection: %1").arg(e.what()));
    }
}

void WebRTCManager::createOffer()
{
    if (!m_peerConnection) {
        emit connectionFailed("Peer connection not initialized");
        return;
    }
    
    try {
        auto configuration = rtc::Configuration();
        configuration.iceServers.push_back(rtc::IceServer(STUN_SERVER.toStdString()));
        
        m_peerConnection->setLocalDescription(rtc::Description::Type::Offer);
    } catch (const std::exception& e) {
        emit connectionFailed(QString("Failed to create offer: %1").arg(e.what()));
    }
}

void WebRTCManager::createAnswer(const QString& offerSdp)
{
    if (!m_peerConnection) {
        emit connectionFailed("Peer connection not initialized");
        return;
    }
    
    try {
        rtc::Description offer(offerSdp.toStdString(), rtc::Description::Type::Offer);
        m_peerConnection->setRemoteDescription(offer);
        m_peerConnection->setLocalDescription(rtc::Description::Type::Answer);
    } catch (const std::exception& e) {
        emit connectionFailed(QString("Failed to create answer: %1").arg(e.what()));
    }
}

void WebRTCManager::handleAnswer(const QString& answerSdp)
{
    if (!m_peerConnection) {
        emit connectionFailed("Peer connection not initialized");
        return;
    }
    
    try {
        rtc::Description answer(answerSdp.toStdString(), rtc::Description::Type::Answer);
        m_peerConnection->setRemoteDescription(answer);
    } catch (const std::exception& e) {
        emit connectionFailed(QString("Failed to handle answer: %1").arg(e.what()));
    }
}

void WebRTCManager::addIceCandidate(const QString& candidate, const QString& sdpMid, int sdpMLineIndex)
{
    if (!m_peerConnection) {
        return;
    }
    
    try {
        rtc::Candidate iceCandidate(candidate.toStdString(), sdpMid.toStdString());
        m_peerConnection->addRemoteCandidate(iceCandidate);
    } catch (const std::exception& e) {
        qWarning() << "Failed to add ICE candidate:" << e.what();
    }
}

void WebRTCManager::setLocalVideoSink(QVideoSink* sink)
{
    m_localVideoSink = sink;
    if (m_localVideoSink) {
        m_videoTimer->start();
    } else {
        m_videoTimer->stop();
    }
}

void WebRTCManager::closeConnection()
{
    m_videoTimer->stop();
    m_peerConnection.reset();
    m_isConnected = false;
    emit connectionStateChanged();
}

void WebRTCManager::processLocalVideoFrame()
{
    // This would process frames from local camera and send them via WebRTC
    // Implementation depends on how we integrate with CameraHandler
}

void WebRTCManager::setupPeerConnection()
{
    auto configuration = rtc::Configuration();
    configuration.iceServers.push_back(rtc::IceServer(STUN_SERVER.toStdString()));
    
    m_peerConnection = std::make_unique<rtc::PeerConnection>(configuration);
    
    // Set up callbacks
    m_peerConnection->onLocalDescription([this](rtc::Description description) {
        onLocalDescription(description);
    });
    
    m_peerConnection->onLocalCandidate([this](rtc::Candidate candidate) {
        onLocalCandidate(candidate);
    });
    
    m_peerConnection->onStateChange([this](rtc::PeerConnection::State state) {
        onStateChange(state);
    });
    
    m_peerConnection->onGatheringStateChange([this](rtc::PeerConnection::GatheringState state) {
        onGatheringStateChange(state);
    });
    
    m_peerConnection->onSignalingStateChange([this](rtc::PeerConnection::SignalingState state) {
        onSignalingStateChange(state);
    });
    
    m_peerConnection->onTrack([this](std::shared_ptr<rtc::Track> track) {
        onTrack(track);
    });
}

void WebRTCManager::onDataChannelMessage(const std::string& message)
{
    // Handle data channel messages if needed
}

void WebRTCManager::onTrack(std::shared_ptr<rtc::Track> track)
{
    // Handle incoming video/audio track
    if (track->direction() == rtc::Description::Direction::RecvOnly) {
        emit remoteVideoTrackAdded();
        
        // Set up track message handler for video frames
        track->onMessage([this, track](rtc::message_variant message) {
            if (std::holds_alternative<rtc::binary>(message)) {
                auto binary = std::get<rtc::binary>(message);
                // Convert binary data to QVideoFrame and display
                // This is a simplified version - actual implementation would need proper video decoding
                if (m_remoteVideoSink) {
                    // Create a dummy frame for now
                    QVideoFrame frame(QVideoFrameFormat(QSize(640, 480), QVideoFrameFormat::Format_ARGB8888));
                    m_remoteVideoSink->setVideoFrame(frame);
                }
            }
        });
    }
}

void WebRTCManager::onLocalDescription(rtc::Description description)
{
    QString sdp = QString::fromStdString(description.generateSdp());
    QString type = (description.type() == rtc::Description::Type::Offer) ? "offer" : "answer";
    
    if (description.type() == rtc::Description::Type::Offer) {
        emit offerCreated(sdp);
    } else {
        emit answerCreated(sdp);
    }
}

void WebRTCManager::onLocalCandidate(rtc::Candidate candidate)
{
    QString candidateStr = QString::fromStdString(candidate.candidate());
    QString sdpMid = QString::fromStdString(candidate.mid());
    int sdpMLineIndex = 0; // Candidate doesn't have mlineIndex in this version
    
    emit iceCandidateGenerated(candidateStr, sdpMid, sdpMLineIndex);
}

void WebRTCManager::onStateChange(rtc::PeerConnection::State state)
{
    switch (state) {
    case rtc::PeerConnection::State::Connected:
        m_isConnected = true;
        emit connectionStateChanged();
        break;
    case rtc::PeerConnection::State::Disconnected:
    case rtc::PeerConnection::State::Failed:
    case rtc::PeerConnection::State::Closed:
        m_isConnected = false;
        emit connectionStateChanged();
        break;
    default:
        break;
    }
}

void WebRTCManager::onGatheringStateChange(rtc::PeerConnection::GatheringState state)
{
    // Handle gathering state changes if needed
}

void WebRTCManager::onSignalingStateChange(rtc::PeerConnection::SignalingState state)
{
    // Handle signaling state changes if needed
}
