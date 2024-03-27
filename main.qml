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
            console.log("exception onLoadingChanged: loadRequest: ", loadRequest)
        }
    }       

    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: {
            if (!webView.visible) {
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
        onLoadingChanged: function(loadRequest) {
            console.log("main onLoadingChanged: loadRequest: ", loadRequest)
            console.log("main onLoadingChanged: loadRequest.status: ", loadRequest.status)
            switch (loadRequest.status) {
            case WebEngineView.LoadSucceededStatus:
                console.log("Page loaded!")
                loading.visible = false
                failed.visible = false
                webView.visible = true
                inputPanel.visible = true
                break
            case WebEngineView.LoadFailedStatus:
                loading.visible = false
                if (webViewException.url.toString().length > 0) {
                    console.log("Displaying exception web page")
                    webViewException.visible = true
                    inputPanel.visible = true
                } else {
                    console.log("Displaying failed page")
                    failed.visible = true
                }
                webView.visible = false
                inputPanel.visible = false
                break
            }
        }
    }

    InputPanel {
      id: inputPanel
      visible: false
      y: Qt.inputMethod.visible ? parent.height - inputPanel.height : parent.height
      width: parent.width * +initialKeyboardScale
      anchors.horizontalCenter: parent.horizontalCenter
    }
  }
}
