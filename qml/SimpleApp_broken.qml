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
    
    property bool showAuth: true  // Default to auth screen
    property bool isRegisterMode: false
    
    // Auth screen
    Item {
        id: authScreen
        visible: showAuth
        
        Rectangle {
            color: "#2b2b2b"
            
            StackLayout {
                id: authStack
                currentIndex: isRegisterMode ? 1 : 0
                
                // Login Form
                Item {
                    anchors.centerIn: parent
                    width: parent.width * 0.9
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 25
                    
                    Text {
                        text: "Welcome Back"
                        color: "white"
                        font.pixelSize: 28
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    TextField {
                        id: loginEmail
                        placeholderText: "Email"
                        Layout.fillWidth: true
                        Material.accent: Material.Blue
                        font.pixelSize: 16
                        height: 40
                    }
                    
                    TextField {
                        id: loginPassword
                        placeholderText: "Password"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                        Material.accent: Material.Blue
                        font.pixelSize: 16
                        height: 40
                    }
                    
                    Button {
                        text: "Login"
                        Layout.fillWidth: true
                        Material.background: Material.Blue
                        enabled: loginEmail.text.length > 0 && loginPassword.text.length > 0
                        font.pixelSize: 16
                        height: 45
                    }
                        
                        onClicked: {
                            authManager.loginUser(loginEmail.text, loginPassword.text)
                        }
                    }
                    
                    Text {
                        text: "Don't have an account? <a href='#'>Register</a>"
                        color: "white"
                        
                        MouseArea {
                            onClicked: isRegisterMode = true
                        }
                    }
                }
                
                // Register Form
                Item {
                    anchors.centerIn: parent
                    width: parent.width * 0.9
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 20
                    
                    Text {
                        text: "Create Account"
                        color: "white"
                        font.pixelSize: 28
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    TextField {
                        id: registerUsername
                        placeholderText: "Username"
                        Layout.fillWidth: true
                        Material.accent: Material.Blue
                        font.pixelSize: 16
                        height: 40
                    }
                    
                    TextField {
                        id: registerEmail
                        placeholderText: "Email"
                        Layout.fillWidth: true
                        Material.accent: Material.Blue
                        font.pixelSize: 16
                        height: 40
                    }
                    
                    TextField {
                        id: registerPassword
                        placeholderText: "Password"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                        Material.accent: Material.Blue
                        font.pixelSize: 16
                        height: 40
                    }
                    
                    TextField {
                        id: registerConfirmPassword
                        placeholderText: "Confirm Password"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                        Material.accent: Material.Blue
                        font.pixelSize: 16
                        height: 40
                    }
                    
                    Button {
                        text: "Register"
                        Layout.fillWidth: true
                        Material.background: Material.Blue
                        enabled: registerUsername.text.length > 0 && 
                                registerEmail.text.length > 0 && 
                                registerPassword.text.length > 0 &&
                                registerPassword.text === registerConfirmPassword.text
                        font.pixelSize: 16
                        height: 45
                    }
                        
                        onClicked: {
                            authManager.registerUser(
                                registerUsername.text,
                                registerEmail.text,
                                registerPassword.text,
                                "",  // display_name
                                0,   // age
                                "",  // gender
                                ""   // interests
                            );
                        }
                    }
                    
                    Text {
                        text: "Already have an account? <a href='#'>Login</a>"
                        color: "white"
                        
                        MouseArea {
                            onClicked: isRegisterMode = false
                        }
                    }
                    }
                }
            }
        }
    }
    }
    
    // Main menu screen
    Item {
        id: mainMenuScreen
        anchors.fill: parent
        visible: !showAuth
        
            anchors.fill: parent
            color: "#2b2b2b"
            
            ColumnLayout {
                Layout.alignment: Qt.AlignCenter
                spacing: 30
                width: parent.width * 0.8
                
                // User info
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    color: "#3c3c3c"
                    radius: 10
                    
                    RowLayout {
                        anchors.margins: 15
                        
                        Rectangle {
                            width: 50
                            height: 50
                            radius: 25
                            color: Material.accent
                            
                            Text {
                                Layout.alignment: Qt.AlignCenter
                                text: "U"
                                color: "white"
                                font.pixelSize: 24
                                font.bold: true
                            }
                        }
                        
                        Text {
                            text: "Welcome User!"
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        
                        Button {
                            text: "Logout"
                            Material.background: Material.Red
                            
                            onClicked: {
                                authManager.logout()
                            }
                        }
                    }
                }
                
                // Menu title
                Text {
                    text: "Choose Chat Type"
                    color: "white"
                    font.pixelSize: 32
                    font.bold: true
                }
                
                // Chat options
                RowLayout {
                    spacing: 20
                    
                    // Video Chat
                    Rectangle {
                        width: 300
                        height: 200
                        color: "#4a4a4a"
                        radius: 15
                        
                        ColumnLayout {
                            anchors.margins: 20
                            
                            Text {
                                text: "Video Chat"
                                color: "white"
                                font.pixelSize: 24
                                font.bold: true
                            }
                            
                            Text {
                                text: "Random video calls\nwith strangers"
                                color: "#cccccc"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Item { Layout.fillHeight: true }
                            
                            Button {
                                text: "Start Video Chat"
                                Layout.fillWidth: true
                                Material.background: Material.Blue
                                
                                onClicked: {
                                    errorDialog.showError("Video chat coming soon!")
                                }
                            }
                        }
                    }
                    
                    // Text Chat
                    Rectangle {
                        width: 300
                        height: 200
                        color: "#4a4a4a"
                        radius: 15
                        
                        ColumnLayout {
                            anchors.margins: 20
                            
                            Text {
                                text: "Text Chat"
                                color: "white"
                                font.pixelSize: 24
                                font.bold: true
                            }
                            
                            Text {
                                text: "Random text conversations\nwith strangers"
                                color: "#cccccc"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Item { Layout.fillHeight: true }
                            
                            Button {
                                text: "Start Text Chat"
                                Layout.fillWidth: true
                                Material.background: Material.Green
                                
                                onClicked: {
                                    errorDialog.showError("Text chat coming soon!")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Error dialog
    Dialog {
        id: errorDialog
        title: "Error"
        modal: true
        standardButtons: Dialog.Ok
        width: 400
        
        property string errorMessage: ""
        
        Text {
            text: errorDialog.errorMessage
            wrapMode: Text.WordWrap
        }
        
        function showError(message) {
            errorMessage = message
            open()
        }
    }
    
    // Success dialog
    Dialog {
        id: successDialog
        title: "Success"
        modal: true
        standardButtons: Dialog.Ok
        width: 400
        
        property string successMessage: ""
        
        Text {
            text: successDialog.successMessage
            wrapMode: Text.WordWrap
        }
        
        function showSuccess(message) {
            successMessage = message
            open()
        }
    }
    
    // Connections to AuthManager
    Connections {
        target: authManager
        
        function onLoginSuccess() {
            successDialog.showSuccess("Login successful!")
            // Switch to main menu after successful login
            showAuth = false
        }
        
        function onLoginError(message) {
            errorDialog.showError("Login failed: " + message)
        }
        
        function onRegistrationSuccess() {
            successDialog.showSuccess("Registration successful!")
            // Switch to main menu after successful registration
            showAuth = false
        }
        
        function onRegistrationError(message) {
            errorDialog.showError("Registration failed: " + message)
        }
        
        function onLoginStatusChanged() {
            // This will trigger visibility change
            showAuth = !authManager.isLoggedIn
        }
    }
}

