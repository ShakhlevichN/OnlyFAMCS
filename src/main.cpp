#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QDebug>
#include "AuthManager.h"
#include "VideoChatApp.h"

int main(int argc, char *argv[])
{
    // Set up application attributes
    QCoreApplication::setApplicationName("VideoChatRoulette");
    QCoreApplication::setOrganizationName("VideoChat");

    QApplication app(argc, argv);

    // Create auth manager first to check if user is logged in
    AuthManager authManager;
    authManager.loadStoredCredentials();

    // Create video chat app
    VideoChatApp videoChatApp;

    QQmlApplicationEngine engine;
    
    // Expose objects to QML
    engine.rootContext()->setContextProperty("authManager", &authManager);
    engine.rootContext()->setContextProperty("videoChatApp", &videoChatApp);
    
    // Load the simple app - single window with internal switching
    QUrl appUrl(QStringLiteral("qrc:/qml/SimpleApp.qml"));
    engine.load(appUrl);
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [](QObject *obj, const QUrl &objUrl) {
        if (!obj) {
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);

    return app.exec();
}
