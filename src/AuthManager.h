#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonDocument>
#include <QSettings>

class AuthManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY loginStatusChanged)
    Q_PROPERTY(QString token READ token NOTIFY tokenChanged)
    Q_PROPERTY(QJsonObject currentUser READ currentUser NOTIFY userChanged)

public:
    explicit AuthManager(QObject *parent = nullptr);
    ~AuthManager();

    // Properties
    bool isLoggedIn() const;
    QString token() const;
    QJsonObject currentUser() const;

    // Methods
    Q_INVOKABLE void registerUser(const QString &username, 
                                 const QString &email, 
                                 const QString &password,
                                 const QString &displayName = QString(),
                                 int age = 0,
                                 const QString &gender = QString(),
                                 const QString &interests = QString());
    
    Q_INVOKABLE void loginUser(const QString &email, const QString &password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void loadStoredCredentials();
    Q_INVOKABLE void getProfile();
    Q_INVOKABLE void updateProfile(const QString &displayName, 
                                 int age, 
                                 const QString &gender, 
                                 const QString &interests);

signals:
    void loginStatusChanged();
    void tokenChanged();
    void userChanged();
    void registrationSuccess();
    void registrationError(const QString &error);
    void loginSuccess();
    void loginError(const QString &error);
    void profileUpdated();
    void profileUpdateError(const QString &error);

private slots:
    void onRegisterResponse();
    void onLoginResponse();
    void onProfileResponse();
    void onNetworkError(QNetworkReply::NetworkError error);

private:
    void saveCredentials();
    void clearCredentials();
    void setCurrentUser(const QJsonObject &user);
    void setToken(const QString &token);
    
    QNetworkAccessManager *m_networkManager;
    QSettings *m_settings;
    QString m_token;
    QJsonObject m_currentUser;
    QString m_serverUrl;
    
    static const QString TOKEN_KEY;
    static const QString USER_KEY;
};

#endif // AUTHMANAGER_H
