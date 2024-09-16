// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import QtWebView
import QtWebEngine
import QtQuick.Layouts
import QtQuick.VirtualKeyboard


ApplicationWindow {
    id: window
    visible: true
    width: initialWidth
    height: initialHeight
    title: webView.title

    Item {
        id: wrapper
        rotation: +initialRotation
        property bool isRotated: rotation === 90 || rotation === 270
        width: isRotated ? parent.height : parent.width
        height: isRotated ? parent.width : parent.height
        anchors.centerIn: parent

        Rectangle {
            id: loading
            anchors.fill: parent
            visible: true

            Text {
                text: "Loading ..."
                color: "blue"
                font.pixelSize: 24
                anchors.centerIn: parent
            }
        }

        // Greyish overlay
        Rectangle {
            id: overlay
            anchors.fill: parent
            color: "#80808080"  // Semi-transparent grey (hex format: #AARRGGBB)
            visible: dialogLoader.item !== null  // Show overlay only when the dialog is visible
            z: 1  // Ensure it's behind the dialog but above other content
        }

        Rectangle {
            id: failed
            anchors.fill: parent
            visible: false

            Text {
                text: "Error loading page"
                color: "red"
                font.pixelSize: 24
                anchors.centerIn: parent
            }
        }

        WebEngineView {
            id: webViewException
            url: exceptionUrl
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: inputPanel.top
            height: parent.height
            visible: false
            onLoadingChanged: function(loadRequest) {
                switch (loadRequest.status) {
                case WebEngineView.LoadFailedStatus:
                    console.log("exception page loading failure: ", loadRequest.errorString)
                }
            }
        }       

        Timer {
            interval: +retryInterval * 1000; running: true; repeat: true
            onTriggered: {
                if (webView.errorLoading) {
                    webView.url = initialUrl
                }
            }
        }

        WebEngineView {
            id: webView
            url: initialUrl
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: inputPanel.top
            height: parent.height
            visible: false
            property int loadTryCount: 0
            property bool errorLoading: false

            z: 0  // Ensure it's below the overlay

            onLoadingChanged: function(loadRequest) {
                switch (loadRequest.status) {
                case WebEngineView.LoadStartedStatus:
                    errorLoading = false
                    break
                    
                case WebEngineView.LoadSucceededStatus:
                    errorLoading = false
                    loading.visible = false
                    failed.visible = false
                    webView.visible = true
                    inputPanel.visible = true
                    loadTryCount = 0
                    break

                case WebEngineView.LoadStoppedStatus:
                case WebEngineView.LoadFailedStatus:
                    errorLoading = true
                    console.log("loading failure: ", loadRequest.errorString)
                    loadTryCount++
                    loading.visible = false
                    if (webViewException.url.toString().length > 0) {
                        webViewException.url = exceptionUrl + 
                            "?errorString=" + loadRequest.errorString +
                            "&errorCode=" + loadRequest.errorCode +
                            "&errorDomain=" + loadRequest.errorDomain +
                            "&status=" + loadRequest.status +
                            "&tryCount=" + loadTryCount
                        webViewException.visible = true
                        inputPanel.visible = true
                    } else {
                        failed.visible = true
                        inputPanel.visible = false
                    }
                    webView.visible = false
                    break
                }
            }

            onJavaScriptDialogRequested: function(request) {
                request.accepted = true;
                dialogLoader.openBrowserDialog(request);
            }

            onAuthenticationDialogRequested: function(request) {
                request.accepted = true;
                dialogLoader.openAuthenticationDialog(request);
            }
        }

        InputPanel {
            id: inputPanel
            visible: false
            z: 2  // Ensure the dialog is above the overlay
            y: Qt.inputMethod.visible ? parent.height - inputPanel.height : parent.height
            width: parent.width * +initialKeyboardScale
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // Define BrowserDialog as a reusable component
    Component {
        id: browserDialogComponent

        Item {
            width: 300
            height: 200
            signal closing()  // Define a closing signal

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            property QtObject request
            

            cancelButton.onClicked: {
                request.dialogReject();
                closing();
            }

            okButton.onClicked: {
                request.dialogAccept(prompt.text);
                closing();
            }

            property alias cancelButton: cancelButton
            property alias okButton: okButton
            property string message: "Message"
            property string title: "Title"
            property alias prompt: prompt

            // Rectangle as the background
            Rectangle {
                anchors.fill: parent  // Fill the entire Item
                color: "#FFFFFF"  // Solid background color (white)

                // Border settings
                border.color: "black"  // Border color (black)
                border.width: 1  // Border width

                radius: 5  // Optional: Rounded corners
            }

            ColumnLayout {
                id: columnLayout
                anchors.topMargin: 20
                anchors.top: parent.top
                anchors.bottomMargin: 20
                anchors.bottom: parent.bottom
                anchors.rightMargin: 20
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.left: parent.left

                Rectangle {
                    id: rectangle
                    width: parent.width
                    height: 30
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    color: "#D91824"
                    // Border settings
                    border.color: "black"  // Border color (black)
                    border.width: 1  // Border width

                    radius: 5  // Optional: Rounded corners

                    Text {
                        id: title
                        x: 54
                        y: 5
                        color: "#FFFFFF"
                        text: qsTr("Title")
                        font.pointSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item {
                    width: 10
                    height: 10
                }

                Text {
                    id: message
                    font.pointSize: 12
                }

                TextField {
                    id: prompt
                    width: 300
                    height: 22
                    Layout.fillWidth: true
                    font.pointSize: 12
                    color: "black"

                    background: Rectangle {
                        color: "white"
                        border.color: "black"
                        border.width: 1
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    id: rowLayout
                    width: 100
                    height: 100

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        id: cancelButton
                        text: qsTr("Cancel")
                        onClicked: {
                            request.dialogReject();
                        }
                    }

                    Button {
                        id: okButton
                        text: qsTr("OK")
                        onClicked: {
                            request.dialogAccept(prompt.text);
                        }
                    }
                }
            }

            Component.onCompleted: {
                console.log("### JavaScriptDialogRequest: " + request.type);
                switch (request.type) {
                case JavaScriptDialogRequest.DialogTypeAlert:
                    cancelButton.visible = false;
                    title.text = qsTr("Alert");
                    message.text = request.message;
                    prompt.text = "";
                    prompt.visible = false;
                    break;
                case JavaScriptDialogRequest.DialogTypeConfirm:
                    title.text = qsTr("Confirm");
                    message.text = request.message;
                    prompt.text = "";
                    prompt.visible = false;
                    break;
                case JavaScriptDialogRequest.DialogTypePrompt:
                    title.text = qsTr("Prompt");
                    message.text = request.message;
                    prompt.text = request.defaultText;
                    prompt.visible = true;
                    break;
                }
            }

            // onClosing signal handler
            onClosing: {
                console.log("Dialog is closing");  // Log a message
                dialogLoader.closeDialog();  // Call a function to close the dialog
                destroy();
            }
        }
    }

    // Define AuthenticationDialog as a reusable component
    Component {
        id: authenticationDialogComponent

        Item {
            width: 300
            height: 300
            signal closing()  // Define a closing signal

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            property QtObject request

            cancelButton.onClicked: {
                request.dialogReject();
                closing();
            }

            loginButton.onClicked: {
                console.log("### loginButton.onClicked: " + userName.text + "-" + password.text + "-" + request.realm + "-" + request.url);
                request.dialogAccept(userName.text, password.text);
                closing();
            }

            property alias cancelButton: cancelButton
            property alias loginButton: loginButton
            property alias userName: userName
            property alias password: password

            // Rectangle as the background
            Rectangle {
                anchors.fill: parent  // Fill the entire Item
                color: "#FFFFFF"  // Solid background color (white)

                // Border settings
                border.color: "black"  // Border color (black)
                border.width: 1  // Border width

                radius: 5  // Optional: Rounded corners
            }

            ColumnLayout {
                id: columnLayout
                anchors.topMargin: 20
                anchors.top: parent.top
                anchors.bottomMargin: 20
                anchors.bottom: parent.bottom
                anchors.rightMargin: 20
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.left: parent.left

                Rectangle {
                    id: rectangle
                    width: parent.width
                    height: 30
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    gradient: Gradient {
                        GradientStop {
                            position: 0
                            color: "#25a6e2"
                        }
                        GradientStop {
                            color: "#188bd0"
                        }
                    }

                    Text {
                        id: textArea
                        x: 54
                        y: 5
                        color: "#ffffff"
                        text: qsTr("Restricted Area")
                        font.pointSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item {
                    width: 40
                    height: 40
                }

                Text {
                    id: userNameText
                    text: qsTr("Username:")
                    font.pointSize: 12
                }

                TextField {
                    id: userName
                    width: 300
                    height: 22
                    Layout.fillWidth: true
                    font.pointSize: 12
                    color: "black"

                    background: Rectangle {
                        color: "white"
                        border.color: "black"
                        border.width: 1
                    }
                }

                Text {
                    id: passwordText
                    text: qsTr("Password:")
                    font.pointSize: 12
                }

                TextField {
                    id: password
                    width: 300
                    height: 26
                    Layout.fillWidth: true
                    font.pointSize: 12
                    color: "black"
                    echoMode: TextInput.Password

                    background: Rectangle {
                        color: "white"
                        border.color: "black"
                        border.width: 1
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                RowLayout {
                    id: rowLayout
                    width: 100
                    height: 100

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        id: cancelButton
                        text: qsTr("Cancel")
                    }

                    Button {
                        id: loginButton
                        text: qsTr("Login")
                    }
                }
            }

            // onClosing signal handler
            onClosing: {
                console.log("Dialog is closing");  // Log a message
                dialogLoader.closeDialog();  // Call a function to close the dialog
                destroy();
            }
        }
    }

    Loader {
        id: dialogLoader
        anchors.horizontalCenter: parent.horizontalCenter // Center horizontally
        y: ( parent.height * 0.3 ) // Position the dialog 30% from the top

        z: 2  // Ensure the dialog is above the overlay

        function openBrowserDialog(request) {
            console.log("### openBrowserDialog: " + request.type);

            if (dialogLoader.item) {
                dialogLoader.item.destroy();  // Destroy any previously loaded dialogs
            }

            // Create the component and pass the `request` as a property
            var dialogInstance = browserDialogComponent.createObject(dialogLoader, {
                "request": request
            });

            if (dialogInstance) {
                overlay.visible = true;
                console.log("### Successfully created dialog instance");
            } else {
                console.error("Failed to create BrowserDialog component");
            }
        }

        function openAuthenticationDialog(request) {
            console.log("### AuthenticationDialog: " + request.type);

            if (dialogLoader.item) {
                dialogLoader.item.destroy();  // Destroy any previously loaded dialogs
            }

            // Create the component and pass the `request` as a property
            var dialogInstance = authenticationDialogComponent.createObject(dialogLoader, {
                "request": request
            });

            if (dialogInstance) {
                overlay.visible = true;
                console.log("### Successfully created AuthenticationDialog instance");
            } else {
                console.error("Failed to create AuthenticationDialog component");
            }
        }

        function closeDialog() {
            dialogLoader.sourceComponent = null;  // Unload the dialog
            overlay.visible = false;
        }
    }

    
}

