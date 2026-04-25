#ifndef CAMERAHANDLER_H
#define CAMERAHANDLER_H

#include <QObject>
#include <QCamera>
#include <QMediaCaptureSession>
#include <QVideoSink>
#include <QVideoFrame>
#include <QImage>

class CameraHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVideoSink* videoSink READ videoSink WRITE setVideoSink NOTIFY videoSinkChanged)

public:
    explicit CameraHandler(QObject *parent = nullptr);
    ~CameraHandler();

    QVideoSink* videoSink() const;
    void setVideoSink(QVideoSink* sink);

    Q_INVOKABLE void startCamera();
    Q_INVOKABLE void stopCamera();
    Q_INVOKABLE bool isCameraAvailable() const;

signals:
    void videoSinkChanged();
    void cameraError(const QString& error);
    void frameReady(const QVideoFrame& frame);

private slots:
    void handleCameraError(QCamera::Error error);
    void processFrame(const QVideoFrame& frame);

private:
    QCamera* m_camera;
    QMediaCaptureSession* m_captureSession;
    QVideoSink* m_videoSink;
    bool m_isRunning;
};

#endif // CAMERAHANDLER_H
