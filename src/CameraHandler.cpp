#include "CameraHandler.h"
#include <QCameraDevice>
#include <QMediaDevices>

CameraHandler::CameraHandler(QObject *parent)
    : QObject(parent)
    , m_camera(nullptr)
    , m_captureSession(new QMediaCaptureSession(this))
    , m_videoSink(nullptr)
    , m_isRunning(false)
{
    // Set up the capture session
    m_captureSession->setVideoSink(m_videoSink);
}

CameraHandler::~CameraHandler()
{
    stopCamera();
}

QVideoSink* CameraHandler::videoSink() const
{
    return m_videoSink;
}

void CameraHandler::setVideoSink(QVideoSink* sink)
{
    if (m_videoSink != sink) {
        m_videoSink = sink;
        m_captureSession->setVideoSink(sink);
        emit videoSinkChanged();
    }
}

void CameraHandler::startCamera()
{
    if (m_isRunning) {
        return;
    }

    // Get default camera
    const QList<QCameraDevice> cameras = QMediaDevices::videoInputs();
    if (cameras.isEmpty()) {
        emit cameraError("No camera found");
        return;
    }

    m_camera = new QCamera(cameras.first(), this);
    
    // Connect error signal
    connect(m_camera, &QCamera::errorOccurred, this, &CameraHandler::handleCameraError);
    
    // Set up capture session
    m_captureSession->setCamera(m_camera);
    
    // Start camera
    m_camera->start();
    m_isRunning = true;
}

void CameraHandler::stopCamera()
{
    if (m_camera && m_isRunning) {
        m_camera->stop();
        m_camera->deleteLater();
        m_camera = nullptr;
        m_isRunning = false;
    }
}

bool CameraHandler::isCameraAvailable() const
{
    const QList<QCameraDevice> cameras = QMediaDevices::videoInputs();
    return !cameras.isEmpty();
}

void CameraHandler::handleCameraError(QCamera::Error error)
{
    QString errorMessage;
    switch (error) {
    case QCamera::NoError:
        errorMessage = "No error";
        break;
    case QCamera::CameraError:
        errorMessage = "General camera error";
        break;
    default:
        errorMessage = "Unknown camera error";
        break;
    }
    emit cameraError(errorMessage);
}

void CameraHandler::processFrame(const QVideoFrame& frame)
{
    emit frameReady(frame);
}
