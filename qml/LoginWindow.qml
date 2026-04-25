import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    id: loginWindow
    width: 400
    height: 600
    visible: true
    title: "Video Chat Roulette - Login"
    
    // Dark theme
    Material.theme: Material.Dark
    Material.accent: Material.Blue
    
    property bool isRegisterMode: false
    
    StackLayout {
        id: stackLayout
        anchors.fill: parent
        currentIndex: isRegisterMode ? 1 : 0
        
        // Login Form
        Rectangle {
            color: "#2b2b2b"
            
            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width * 0.8
                spacing: 20
                
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
                    
                    validator: RegExpValidator { regExp: /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/ }
                }
                
                TextField {
                    id: loginPassword
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                    Material.accent: Material.Blue
                }
                
                Button {
                    text: "Login"
                    Layout.fillWidth: true
                    Material.background: Material.Blue
                    enabled: loginEmail.text.length > 0 && loginPassword.text.length > 0
                    
                    onClicked: {
                        authManager.loginUser(loginEmail.text, loginPassword.text)
                    }
                }
                
                Text {
                    text: "Don't have an account? <a href='#'>Register</a>"
                    color: "white"
                    Layout.alignment: Qt.AlignHCenter
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: isRegisterMode = true
                    }
                }
            }
        }
        
        // Register Form
        Rectangle {
            color: "#2b2b2b"
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: 20
                
                ColumnLayout {
                    width: parent.width
                    spacing: 15
                    
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
                    }
                    
                    TextField {
                        id: registerEmail
                        placeholderText: "Email"
                        Layout.fillWidth: true
                        Material.acent: Material.Blue
                        
                        validator: RegExpValidator { regExp: /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/ }
                    }
                    
                    TextField {
                        id: registerPassword
                        placeholderText: "Password"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                        Material.accent: Material.Blue
                    }
                    
                    TextField {
                        id: registerConfirmPassword
                        placeholderText: "Confirm Password"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                        Material.accent: Material.Blue
                    }
                    
                    TextField {
                        id: registerDisplayName
                        placeholderText: "Display Name (optional)"
                        Layout.fillWidth: true
                        Material.accent: Material.Blue
                    }
                    
                    TextField {
                        id: registerAge
                        placeholderText: "Age (optional)"
                        Layout.fillWidth: true
                        Material.accent: Material.Blue
                        
                        validator: IntValidator { bottom: 1; top: 120 }
                    }
                    
                    ComboBox {
                        id: registerGender
                        Layout.fillWidth: true
                        model: ["", "Male", "Female", "Other"]
                        currentIndex: 0
                    }
                    
                    TextField {
                        id: registerInterests
                        placeholderText: "Interests (comma-separated, optional)"
                        Layout.fillWidth: true
                        Material.accent: Material.Blue
                    }
                    
                    Button {
                        text: "Register"
                        Layout.fillWidth: true
                        Material.background: Material.Blue
                        enabled: registerUsername.text.length > 0 && 
                                registerEmail.text.length > 0 && 
                                registerPassword.text.length > 0 &&
                                registerPassword.text === registerConfirmPassword.text
                        
                        onClicked: {
                            var age = parseInt(registerAge.text) || 0;
                            var gender = registerGender.currentText.toLowerCase();
                            if (gender === "") gender = "";
                            
                            authManager.registerUser(
                                registerUsername.text,
                                registerEmail.text,
                                registerPassword.text,
                                registerDisplayName.text,
                                age,
                                gender,
                                registerInterests.text
                            );
                        }
                    }
                    
                    Text {
                        text: "Already have an account? <a href='#'>Login</a>"
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: isRegisterMode = false
                        }
                    }
                }
            }
        }
    }
    
    // Loading indicator
    BusyIndicator {
        anchors.centerIn: parent
        running: false
        visible: running
    }
    
    // Error dialog
    Dialog {
        id: errorDialog
        title: "Error"
        modal: true
        standardButtons: Dialog.Ok
        
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
        
        property string successMessage: ""
        
        Text {
            text: successDialog.successMessage
            wrapMode: Text.WordWrap
        }
        
        onAccepted: {
            if (successMessage.includes("Registration successful") || 
                successMessage.includes("Login successful")) {
                // Close login window and open main app
                loginWindow.close()
                mainAppWindow.show()
            }
        }
        
        function showSuccess(message) {
            successMessage = message
            open()
        }
    }
    
    // Connections to AuthManager
    Connections {
        target: authManager
        
        function onRegistrationSuccess() {
            successDialog.showSuccess("Registration successful! Welcome to Video Chat Roulette!")
        }
        
        function onRegistrationError(message) {
            errorDialog.showError("Registration failed: " + message)
        }
        
        function onLoginSuccess() {
            successDialog.showSuccess("Login successful! Welcome back!")
        }
        
        function onLoginError(message) {
            errorDialog.showError("Login failed: " + message)
        }
    }
}
