#include "AuthManager.h"
#include <QNetworkRequest>
#include <QJsonArray>
#include <QDebug>

const QString AuthManager::TOKEN_KEY = "auth_token";
const QString AuthManager::USER_KEY = "current_user";

AuthManager::AuthManager(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_settings(new QSettings("VideoChatRoulette", "Auth", this))
    , m_serverUrl("http://localhost:8080")
{
    // Load stored credentials on startup
    loadStoredCredentials();
}

AuthManager::~AuthManager()
{
}

bool AuthManager::isLoggedIn() const
{
    return !m_token.isEmpty() && !m_currentUser.isEmpty();
}

QString AuthManager::token() const
{
    return m_token;
}

QJsonObject AuthManager::currentUser() const
{
    return m_currentUser;
}

void AuthManager::registerUser(const QString &username, 
                              const QString &email, 
                              const QString &password,
                              const QString &displayName,
                              int age,
                              const QString &gender,
                              const QString &interests)
{
    QJsonObject userData;
    userData["username"] = username;
    userData["email"] = email;
    userData["password"] = password;
    
    if (!displayName.isEmpty())
        userData["display_name"] = displayName;
    if (age > 0)
        userData["age"] = age;
    if (!gender.isEmpty())
        userData["gender"] = gender;
    if (!interests.isEmpty())
        userData["interests"] = interests;

    QJsonDocument doc(userData);
    QByteArray data = doc.toJson();

    QUrl url(m_serverUrl + "/api/register");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply *reply = m_networkManager->post(request, data);
    connect(reply, &QNetworkReply::finished, this, &AuthManager::onRegisterResponse);
    connect(reply, &QNetworkReply::errorOccurred,
            this, &AuthManager::onNetworkError);
}

void AuthManager::loginUser(const QString &email, const QString &password)
{
    QJsonObject loginData;
    loginData["email"] = email;
    loginData["password"] = password;

    QJsonDocument doc(loginData);
    QByteArray data = doc.toJson();

    QUrl url(m_serverUrl + "/api/login");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply *reply = m_networkManager->post(request, data);
    connect(reply, &QNetworkReply::finished, this, &AuthManager::onLoginResponse);
    connect(reply, &QNetworkReply::errorOccurred,
            this, &AuthManager::onNetworkError);
}

void AuthManager::logout()
{
    clearCredentials();
    emit loginStatusChanged();
    emit tokenChanged();
    emit userChanged();
}


void AuthManager::getProfile()
{
    if (!isLoggedIn()) {
        emit profileUpdateError("Not logged in");
        return;
    }
    
    QUrl url(m_serverUrl + "/api/profile");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", ("Bearer " + m_token).toUtf8());

    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, &AuthManager::onProfileResponse);
    connect(reply, &QNetworkReply::errorOccurred,
            this, &AuthManager::onNetworkError);
}

void AuthManager::loadStoredCredentials()
{
    m_token = m_settings->value(TOKEN_KEY).toString();
    
    QByteArray userData = m_settings->value(USER_KEY).toByteArray();
    if (!userData.isEmpty()) {
        QJsonDocument doc = QJsonDocument::fromJson(userData);
        m_currentUser = doc.object();
    }

    if (!m_token.isEmpty() && !m_currentUser.isEmpty()) {
        emit loginStatusChanged();
        emit tokenChanged();
        emit userChanged();
    }
}

void AuthManager::updateProfile(const QString &displayName, 
                               int age, 
                               const QString &gender, 
                               const QString &interests)
{
    QJsonObject profileData;
    profileData["display_name"] = displayName;
    if (age > 0)
        profileData["age"] = age;
    if (!gender.isEmpty())
        profileData["gender"] = gender;
    if (!interests.isEmpty())
        profileData["interests"] = interests;

    QJsonDocument doc(profileData);
    QByteArray data = doc.toJson();

    QUrl url(m_serverUrl + "/api/profile");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", ("Bearer " + m_token).toUtf8());

    QNetworkReply *reply = m_networkManager->put(request, data);
    connect(reply, &QNetworkReply::finished, this, &AuthManager::onProfileResponse);
    connect(reply, &QNetworkReply::errorOccurred,
            this, &AuthManager::onNetworkError);
}

void AuthManager::onRegisterResponse()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QByteArray data = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    QJsonObject response = doc.object();

    if (reply->error() == QNetworkReply::NoError) {
        // Registration successful, save token and user
        setToken(response["access_token"].toString());
        setCurrentUser(response["user"].toObject());
        saveCredentials();
        
        emit registrationSuccess();
        emit loginSuccess();
        emit loginStatusChanged();
        emit tokenChanged();
        emit userChanged();
    } else {
        QString error = response["detail"].toString();
        if (error.isEmpty()) {
            error = "Registration failed";
        }
        emit registrationError(error);
    }

    reply->deleteLater();
}

void AuthManager::onLoginResponse()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QByteArray data = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    QJsonObject response = doc.object();

    if (reply->error() == QNetworkReply::NoError) {
        // Login successful, save token and user
        setToken(response["access_token"].toString());
        setCurrentUser(response["user"].toObject());
        saveCredentials();
        
        emit loginSuccess();
        emit loginStatusChanged();
        emit tokenChanged();
        emit userChanged();
    } else {
        QString error = response["detail"].toString();
        if (error.isEmpty()) {
            error = "Login failed";
        }
        emit loginError(error);
    }

    reply->deleteLater();
}

void AuthManager::onProfileResponse()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QByteArray data = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    QJsonObject response = doc.object();

    if (reply->error() == QNetworkReply::NoError) {
        setCurrentUser(response);
        saveCredentials();
        
        emit profileUpdated();
        emit userChanged();
    } else {
        QString error = response["detail"].toString();
        if (error.isEmpty()) {
            error = "Profile update failed";
        }
        emit profileUpdateError(error);
    }

    reply->deleteLater();
}

void AuthManager::onNetworkError(QNetworkReply::NetworkError error)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    QString errorString;
    switch (error) {
    case QNetworkReply::ConnectionRefusedError:
        errorString = "Connection refused. Is the server running?";
        break;
    case QNetworkReply::TimeoutError:
        errorString = "Connection timeout";
        break;
    case QNetworkReply::HostNotFoundError:
        errorString = "Server not found";
        break;
    default:
        errorString = "Network error: " + reply->errorString();
        break;
    }

    // Emit appropriate error based on the context
    if (reply->url().toString().contains("/register")) {
        emit registrationError(errorString);
    } else if (reply->url().toString().contains("/login")) {
        emit loginError(errorString);
    } else if (reply->url().toString().contains("/profile")) {
        emit profileUpdateError(errorString);
    }

    reply->deleteLater();
}

void AuthManager::saveCredentials()
{
    m_settings->setValue(TOKEN_KEY, m_token);
    m_settings->setValue(USER_KEY, QJsonDocument(m_currentUser).toJson());
}

void AuthManager::clearCredentials()
{
    m_token.clear();
    m_currentUser = QJsonObject();
    m_settings->remove(TOKEN_KEY);
    m_settings->remove(USER_KEY);
}

void AuthManager::setCurrentUser(const QJsonObject &user)
{
    m_currentUser = user;
}

void AuthManager::setToken(const QString &token)
{
    m_token = token;
}
