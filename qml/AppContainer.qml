import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    id: appWindow
    width: 800
    height: 600
    visible: true
    title: "Video Chat Roulette"
    
    // Dark theme
    Material.theme: Material.Dark
    Material.accent: Material.Blue
    
    property bool isAuthenticated: false
    
    // Main content area
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: isAuthenticated ? mainMenuComponent : authWindowComponent
    }
    
    // Components
    Component {
        id: authWindowComponent
        
        AuthWindow {
            id: authWindow
            
            onVisibleChanged: {
                if (!visible && isAuthenticated) {
                    // Switch to main menu after successful auth
                    stackView.replace(mainMenuComponent)
                }
            }
            
            Connections {
                target: authManager
                
                function onLoginStatusChanged() {
                    isAuthenticated = authManager.isLoggedIn
                }
                
                function onRegistrationSuccess() {
                    isAuthenticated = true
                }
                
                function onLoginSuccess() {
                    isAuthenticated = true
                }
            }
        }
    }
    
    Component {
        id: mainMenuComponent
        
        MainMenu {
            id: mainMenu
            
            Connections {
                target: authManager
                
                function onLoginStatusChanged() {
                    if (!authManager.isLoggedIn) {
                        isAuthenticated = false
                        stackView.replace(authWindowComponent)
                    }
                }
            }
        }
    }
    
    // Check authentication status on startup
    Component.onCompleted: {
        isAuthenticated = authManager.isLoggedIn
    }
}
