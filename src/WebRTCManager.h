#ifndef WEBRTCMANAGER_H
#define WEBRTCMANAGER_H

#include <QObject>
#include <QVideoSink>
#include <QVideoFrame>
#include <QTimer>
#include <memory>
#include <functional>

#include <rtc/rtc.hpp>

// Forward declarations for libdatachannel
namespace rtc {
    class Track;
}

class WebRTCManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionStateChanged)

public:
    explicit WebRTCManager(QObject *parent = nullptr);
    ~WebRTCManager();

    bool isConnected() const;

    Q_INVOKABLE void createPeerConnection();
    Q_INVOKABLE void createOffer();
    Q_INVOKABLE void createAnswer(const QString& offerSdp);
    Q_INVOKABLE void handleAnswer(const QString& answerSdp);
    Q_INVOKABLE void addIceCandidate(const QString& candidate, const QString& sdpMid, int sdpMLineIndex);
    Q_INVOKABLE void setLocalVideoSink(QVideoSink* sink);
    Q_INVOKABLE void closeConnection();

signals:
    void connectionStateChanged();
    void offerCreated(const QString& sdp);
    void answerCreated(const QString& sdp);
    void iceCandidateGenerated(const QString& candidate, const QString& sdpMid, int sdpMLineIndex);
    void remoteVideoTrackAdded();
    void connectionFailed(const QString& error);

private slots:
    void processLocalVideoFrame();

private:
    void setupPeerConnection();
    void onDataChannelMessage(const std::string& message);
    void onTrack(std::shared_ptr<rtc::Track> track);
    void onLocalDescription(rtc::Description description);
    void onLocalCandidate(rtc::Candidate candidate);
    void onStateChange(rtc::PeerConnection::State state);
    void onGatheringStateChange(rtc::PeerConnection::GatheringState state);
    void onSignalingStateChange(rtc::PeerConnection::SignalingState state);

    std::unique_ptr<rtc::PeerConnection> m_peerConnection;
    QVideoSink* m_localVideoSink;
    QVideoSink* m_remoteVideoSink;
    QTimer* m_videoTimer;
    bool m_isConnected;
    QString m_localSdpMid;
    int m_localSdpMLineIndex;
    
    // STUN server configuration
    static const QString STUN_SERVER;
};

#endif // WEBRTCMANAGER_H
