import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    id: window
    width: 1200
    height: 800
    visible: true
    title: qsTr("Video Chat Roulette")
    
    // Dark theme
    Material.theme: Material.Dark
    Material.accent: Material.Blue
    
    property bool connected: videoChatApp.isConnected
    property bool searching: videoChatApp.isSearching
    property string status: videoChatApp.connectionStatus
    
    VideoChatWindow {
        id: chatWindow
        anchors.fill: parent
        
        onConnectToServer: {
            videoChatApp.connectToServer("ws://localhost:8080")
        }
        
        onStartChat: {
            videoChatApp.startChat()
        }
        
        onNextPartner: {
            videoChatApp.nextPartner()
        }
        
        onStopChat: {
            videoChatApp.stopChat()
        }
    }
    
    // Error message dialog
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
    
    // Connect to error signals
    Connections {
        target: videoChatApp
        function onErrorMessage(message) {
            errorDialog.showError(message)
        }
    }
}
