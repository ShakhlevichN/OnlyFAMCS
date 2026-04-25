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
    
    // Set server URL for remote connection
    Component.onCompleted: {
        authManager.setServerUrl("http://84.233.195.37:8080")
    }
    
    property bool showAuth: true
    property bool isRegisterMode: false
    property bool showVideoChat: false
    property bool showTextChat: false
    property bool isSearchingPartner: false
    property bool isConnectedToPartner: false
    
    // Auth screen
    Item {
        id: authScreen
        anchors.fill: parent
        visible: showAuth
        
        Rectangle {
            anchors.fill: parent
            color: "#2b2b2b"
            
            // Login Form
            Item {
                visible: !isRegisterMode
                anchors.centerIn: parent
                width: parent.width * 0.6
                height: parent.height * 0.8
                
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
                        Layout.alignment: Qt.AlignHCenter
                        Material.accent: Material.Blue
                        font.pixelSize: 16
                        height: 40
                    }
                    
                    TextField {
                        id: loginPassword
                        placeholderText: "Password"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        Material.accent: Material.Blue
                        font.pixelSize: 16
                        height: 40
                    }
                    
                    Button {
                        text: "Login"
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        Material.background: Material.Blue
                        enabled: loginEmail.text.length > 0 && loginPassword.text.length > 0
                        font.pixelSize: 16
                        font.bold: true
                        height: 45
                        
                        onClicked: {
                            authManager.loginUser(loginEmail.text, loginPassword.text)
                        }
                    }
                    
                    Text {
                        text: "Don't have an account? <a href='#' style='color: " + Material.accent + "; text-decoration: underline;'>Register</a>"
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 12
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: isRegisterMode = true
                        }
                    }
                }
            }
            
            // Register Form
            Item {
                visible: isRegisterMode
                anchors.centerIn: parent
                width: parent.width * 0.6
                height: parent.height * 0.8
                
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
                        Layout.alignment: Qt.AlignHCenter
                        Material.accent: Material.Blue
                        font.pixelSize: 16
                        height: 40
                    }
                    
                    TextField {
                        id: registerEmail
                        placeholderText: "Email"
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        Material.accent: Material.Blue
                        font.pixelSize: 16
                        height: 40
                    }
                    
                    TextField {
                        id: registerPassword
                        placeholderText: "Password"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        Material.accent: Material.Blue
                        font.pixelSize: 16
                        height: 40
                    }
                    
                    TextField {
                        id: registerConfirmPassword
                        placeholderText: "Confirm Password"
                        echoMode: TextInput.Password
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        Material.accent: Material.Blue
                        font.pixelSize: 16
                        height: 40
                    }
                    
                    Button {
                        text: "Register"
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        Material.background: Material.Blue
                        enabled: registerUsername.text.length > 0 && 
                                registerEmail.text.length > 0 && 
                                registerPassword.text.length > 0 &&
                                registerPassword.text === registerConfirmPassword.text
                        font.pixelSize: 16
                        font.bold: true
                        height: 45
                        
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
                        text: "Already have an account? <a href='#' style='color: " + Material.accent + "; text-decoration: underline;'>Login</a>"
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 12
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: isRegisterMode = false
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
        
        Rectangle {
            anchors.fill: parent
            color: "#2b2b2b"
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 30
                width: parent.width * 0.7
                
                // User info
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    height: 80
                    color: "#3c3c3c"
                    radius: 10
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        
                        Rectangle {
                            width: 50
                            height: 50
                            radius: 25
                            color: Material.accent
                            
                            Text {
                                anchors.centerIn: parent
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
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Chat options
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20
                    
                    // Video Chat
                    Rectangle {
                        width: 280
                        height: 180
                        color: "#4a4a4a"
                        radius: 15
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            
                            Text {
                                text: "Video Chat"
                                color: "white"
                                font.pixelSize: 24
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Random video calls\nwith strangers"
                                color: "#cccccc"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Item { Layout.fillHeight: true }
                            
                            Button {
                                text: "Start Video Chat"
                                Layout.fillWidth: true
                                Material.background: Material.Blue
                                
                                onClicked: {
                                    // Connect to server and start video chat
                                    videoChatApp.connectToServer("ws://84.233.195.37:8080/ws")
                                    videoChatApp.startChat()
                                    showAuth = false
                                    showVideoChat = true
                                    showTextChat = false
                                    isSearchingPartner = true
                                    isConnectedToPartner = false
                                }
                            }
                        }
                    }
                    
                    // Text Chat
                    Rectangle {
                        width: 280
                        height: 180
                        color: "#4a4a4a"
                        radius: 15
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            
                            Text {
                                text: "Text Chat"
                                color: "white"
                                font.pixelSize: 24
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "Random text conversations\nwith strangers"
                                color: "#cccccc"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Item { Layout.fillHeight: true }
                            
                            Button {
                                text: "Start Text Chat"
                                Layout.fillWidth: true
                                Material.background: Material.Green
                                
                                onClicked: {
                                    // Connect to server and start text chat
                                    videoChatApp.connectToServer("ws://localhost:8080/ws")
                                    videoChatApp.startChat()
                                    showAuth = false
                                    showVideoChat = false
                                    showTextChat = true
                                    isSearchingPartner = true
                                    isConnectedToPartner = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Video Chat Screen
    Item {
        id: videoChatScreen
        anchors.fill: parent
        visible: showVideoChat
        
        Rectangle {
            anchors.fill: parent
            color: "#2b2b2b"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // Header
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "#1a1a1a"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        
                        Text {
                            text: "Video Chat"
                            color: "white"
                            font.pixelSize: 20
                            font.bold: true
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Next"
                            Material.background: Material.Blue
                            visible: isConnectedToPartner
                            
                            onClicked: {
                                videoChatApp.nextPartner()
                                isSearchingPartner = true
                                isConnectedToPartner = false
                            }
                        }
                        
                        Button {
                            text: "End"
                            Material.background: Material.Red
                            
                            onClicked: {
                                videoChatApp.stopChat()
                                showAuth = false
                                showVideoChat = false
                                showTextChat = false
                                isSearchingPartner = false
                                isConnectedToPartner = false
                            }
                        }
                    }
                }
                
                // Video area
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#333333"
                    
                    // Searching overlay
                    Rectangle {
                        anchors.fill: parent
                        color: "#2b2b2b"
                        visible: isSearchingPartner
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20
                            
                            Rectangle {
                                width: 60
                                height: 60
                                color: "#444444"
                                radius: 30
                                Layout.alignment: Qt.AlignHCenter
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "..."
                                    color: "white"
                                    font.pixelSize: 24
                                    font.bold: true
                                }
                            }
                            
                            Text {
                                text: "Searching for a stranger..."
                                color: "#cccccc"
                                font.pixelSize: 16
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Video content (placeholder)
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 20
                        color: "#1a1a1a"
                        border.color: "#444444"
                        border.width: 2
                        radius: 10
                        visible: !isSearchingPartner
                        
                        Text {
                            anchors.centerIn: parent
                            text: "📹 Video chat area"
                            color: "#666666"
                            font.pixelSize: 18
                        }
                    }
                }
            }
        }
    }
    
    // Text Chat Screen
    Item {
        id: textChatScreen
        anchors.fill: parent
        visible: showTextChat
        
        Rectangle {
            anchors.fill: parent
            color: "#2b2b2b"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // Header
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "#1a1a1a"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        
                        Text {
                            text: "Chat Roulette"
                            color: "white"
                            font.pixelSize: 20
                            font.bold: true
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: "Next"
                            Material.background: Material.Blue
                            visible: isConnectedToPartner
                            
                            onClicked: {
                                videoChatApp.nextPartner()
                                clearMessages()
                                isSearchingPartner = true
                                isConnectedToPartner = false
                            }
                        }
                        
                        Button {
                            text: "End"
                            Material.background: Material.Red
                            
                            onClicked: {
                                videoChatApp.stopChat()
                                showAuth = false
                                showVideoChat = false
                                showTextChat = false
                                isSearchingPartner = false
                                isConnectedToPartner = false
                            }
                        }
                    }
                }
                
                // Chat area
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#333333"
                    
                    // Searching overlay
                    Rectangle {
                        anchors.fill: parent
                        color: "#2b2b2b"
                        visible: isSearchingPartner
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20
                            
                            Rectangle {
                                width: 60
                                height: 60
                                color: "#444444"
                                radius: 30
                                Layout.alignment: Qt.AlignHCenter
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "..."
                                    color: "white"
                                    font.pixelSize: 24
                                    font.bold: true
                                }
                            }
                            
                            Text {
                                text: "Searching for a stranger..."
                                color: "#cccccc"
                                font.pixelSize: 16
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                    
                    // Chat messages
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 10
                        visible: !isSearchingPartner
                        
                        ListView {
                            id: messageList
                            model: ListModel {
                                id: messageModel
                            }
                            delegate: Item {
                                width: messageList.width
                                height: messageColumn.height + 20
                                
                                ColumnLayout {
                                    id: messageColumn
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: 10
                                    spacing: 5
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: messageText.contentHeight + 15
                                        color: model.isMe ? "#1976d2" : "#424242"
                                        radius: 18
                                        Layout.alignment: model.isMe ? Qt.AlignRight : Qt.AlignLeft
                                        
                                        Text {
                                            id: messageText
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            text: model.text
                                            color: "white"
                                            font.pixelSize: 14
                                            wrapMode: Text.WordWrap
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Message input
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "#1a1a1a"
                    visible: !isSearchingPartner
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        
                        TextField {
                            id: messageInput
                            Layout.fillWidth: true
                            placeholderText: "Type a message..."
                            Material.accent: Material.Blue
                            font.pixelSize: 14
                            background: Rectangle {
                                color: "#424242"
                                radius: 20
                                border.color: "#555555"
                                border.width: 1
                            }
                            
                            onAccepted: sendMessage()
                        }
                        
                        Button {
                            text: "Send"
                            Material.background: Material.Blue
                            width: 70
                            height: 35
                            
                            onClicked: sendMessage()
                        }
                    }
                }
            }
        }
    }
    
    // Functions for text chat
    function sendMessage() {
        if (messageInput.text.trim() !== "") {
            addMessage(messageInput.text, true)
            messageInput.text = ""
            // Send message to server here
        }
    }
    
    function addMessage(text, isMe) {
        messageModel.append({"text": text, "isMe": isMe})
        messageList.positionViewAtEnd()
    }
    
    function clearMessages() {
        messageModel.clear()
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
            showAuth = false
        }
        
        function onLoginError(message) {
            errorDialog.showError("Login failed: " + message)
        }
        
        function onRegistrationSuccess() {
            successDialog.showSuccess("Registration successful! Please login.")
            isRegisterMode = false
        }
        
        function onRegistrationError(message) {
            errorDialog.showError("Registration failed: " + message)
        }
        
        function onLoginStatusChanged() {
            showAuth = !authManager.isLoggedIn
        }
    }
    
    // Connections to VideoChatApp
    Connections {
        target: videoChatApp
        
        function onConnectionStateChanged() {
            if (videoChatApp.isConnected) {
                isSearchingPartner = false
                isConnectedToPartner = true
                if (showTextChat) {
                    addMessage("Connected to stranger!", false)
                }
            } else {
                isSearchingPartner = true
                isConnectedToPartner = false
            }
        }
        
        function onPartnerDisconnected() {
            if (showTextChat) {
                addMessage("Stranger disconnected", false)
            }
            isSearchingPartner = true
            isConnectedToPartner = false
        }
    }
}
