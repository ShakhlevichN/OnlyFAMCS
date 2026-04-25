import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    id: mainWindow
    anchors.fill: parent
    
    // Dark theme
    Material.theme: Material.Dark
    Material.accent: Material.Blue
    
    property alias userDisplayName: userDisplayNameText.text
    property alias userEmail: userEmailText.text
    
    function showSuccess(message) {
        successDialog.successMessage = message
        successDialog.open()
    }
    
    function showError(message) {
        errorDialog.errorMessage = message
        errorDialog.open()
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#2b2b2b"
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 30
            width: parent.width * 0.8
            
            // User info section
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
                            text: userDisplayName.charAt(0).toUpperCase()
                            color: "white"
                            font.pixelSize: 24
                            font.bold: true
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            id: userDisplayNameText
                            text: "User"
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        
                        Text {
                            id: userEmailText
                            text: "user@example.com"
                            color: "#cccccc"
                            font.pixelSize: 14
                        }
                    }
                    
                    Button {
                        text: "Logout"
                        Material.background: Material.Red
                        
                        onClicked: {
                            authManager.logout()
                            // AppContainer will handle the switch automatically
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
            GridLayout {
                Layout.alignment: Qt.AlignHCenter
                columns: 2
                columnSpacing: 20
                rowSpacing: 20
                
                // Video Chat Roulette
                Rectangle {
                    width: 300
                    height: 200
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
                            wrapMode: Text.WordWrap
                        }
                        
                        Item { Layout.fillHeight: true }
                        
                        Button {
                            text: "Start Video Chat"
                            Layout.fillWidth: true
                            Material.background: Material.Blue
                            
                            onClicked: {
                                showSuccess("Opening video chat...")
                                // TODO: Navigate to video chat within same window
                            }
                        }
                    }
                }
                
                // Text Chat Roulette
                Rectangle {
                    width: 300
                    height: 200
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
                            wrapMode: Text.WordWrap
                        }
                        
                        Item { Layout.fillHeight: true }
                        
                        Button {
                            text: "Start Text Chat"
                            Layout.fillWidth: true
                            Material.background: Material.Green
                            
                            onClicked: {
                                showSuccess("Text chat coming soon!")
                            }
                        }
                    }
                }
            }
            
            // Additional options
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20
                
                Button {
                    text: "Profile"
                    Material.background: Material.Purple
                    
                    onClicked: {
                        authManager.getProfile()
                        showSuccess("Profile feature coming soon!")
                    }
                }
                
                Button {
                    text: "Settings"
                    Material.background: Material.Orange
                    
                    onClicked: {
                        showSuccess("Settings coming soon!")
                    }
                }
                
                Button {
                    text: "About"
                    Material.background: Material.Cyan
                    
                    onClicked: {
                        showSuccess("Video Chat Roulette v1.0\nCreated with Qt6 and FastAPI")
                    }
                }
            }
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
    }
    
    // Load user info on startup
    Component.onCompleted: {
        if (authManager.isLoggedIn) {
            var user = authManager.currentUser
            if (user) {
                userDisplayName = user.display_name || user.username || "User"
                userEmail = user.email || "user@example.com"
            }
        }
    }
    
    // Connections to AuthManager
    Connections {
        target: authManager
        
        function onLoginStatusChanged() {
            if (!authManager.isLoggedIn) {
                // User logged out - AppContainer will handle switch
            }
        }
        
        function onUserChanged() {
            var user = authManager.currentUser
            if (user) {
                userDisplayName = user.display_name || user.username || "User"
                userEmail = user.email || "user@example.com"
            }
        }
    }
}
