// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls
import QtWebView
import QtQuick.Layouts
import QtQuick.VirtualKeyboard


ApplicationWindow {
    id: window
    visible: true
    x: initialX
    y: initialY
    width: initialWidth
    height: initialHeight
    title: webView.title

    menuBar: ToolBar {
        id: navigationBar
        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item { Layout.preferredWidth: 5 }

            TextField {
                Layout.fillWidth: true
                id: urlField
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhPreferLowercase
                text: webView.url
                onAccepted: webView.url = utils.fromUserInput(text)
             }

            Item { Layout.preferredWidth: 5 }

            Item { Layout.preferredWidth: 10 }
         }
         ProgressBar {
             id: progress
             anchors {
                left: parent.left
                top: parent.bottom
                right: parent.right
                leftMargin: parent.leftMargin
                rightMargin: parent.rightMargin
             }
             height:3
             z: Qt.platform.os === "android" ? -1 : -2
             background: Item {}
             visible: Qt.platform.os !== "ios" && Qt.platform.os !== "winrt"
             from: 0
             to: 100
             value: webView.loadProgress < 100 ? webView.loadProgress : 0
        }
    }

    Item {
        id: settingsDrawer
        anchors.right: parent.right
        ColumnLayout {
            Label {
                text: "JavaScript"
            }
            CheckBox {
                id: javaScriptEnabledCheckBox
                text: "enabled"
                onCheckStateChanged: webView.settings.javaScriptEnabled = (checkState == Qt.Checked)
            }
            Label {
                text: "Local storage"
            }
            CheckBox {
                id: localStorageEnabledCheckBox
                text: "enabled"
                onCheckStateChanged: webView.settings.localStorageEnabled = (checkState == Qt.Checked)
            }
            Label {
                text: "Allow file access"
            }
            CheckBox {
                id: allowFileAccessEnabledCheckBox
                text: "enabled"
                onCheckStateChanged: webView.settings.allowFileAccess = (checkState == Qt.Checked)
            }
            Label {
                text: "Local content can access file URLs"
            }
            CheckBox {
                id: localContentCanAccessFileUrlsEnabledCheckBox
                text: "enabled"
                onCheckStateChanged: webView.settings.localContentCanAccessFileUrls = (checkState == Qt.Checked)
            }
        }
    }

    WebView {
        id: webView
        url: initialUrl
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: inputPanel.top
        height: parent.height
        onLoadingChanged: function(loadRequest) {
            if (loadRequest.errorString)
                console.error(loadRequest.errorString);
        }

        Component.onCompleted: {
            javaScriptEnabledCheckBox.checkState = settings.javaScriptEnabled ? Qt.Checked : Qt.Unchecked
            localStorageEnabledCheckBox.checkState = settings.localStorageEnabled ? Qt.Checked : Qt.Unchecked
            allowFileAccessEnabledCheckBox.checkState = settings.allowFileAccess ? Qt.Checked : Qt.Unchecked
            localContentCanAccessFileUrlsEnabledCheckBox.checkState = settings.localContentCanAccessFileUrls ? Qt.Checked : Qt.Unchecked
        }
    }

    InputPanel {
      id: inputPanel
      y: Qt.inputMethod.visible ? parent.height - inputPanel.height : parent.height
      anchors.left: parent.left
      anchors.right: parent.right
    }
}
