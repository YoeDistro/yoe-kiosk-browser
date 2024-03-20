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
        visible: true

        Text {
            text: "Error loading page"
            color: "red"
            font.pixelSize: 24
            anchors.centerIn: parent
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
            console.log("onLoadingChanged: loadRequest: ", loadRequest)
            switch (loadRequest.status) {
            case WebEngineView.LoadSucceededStatus:
                console.log("Page loaded!")
                loading.visible = false
                failed.visible = false
                webView.visible = true
                inputPanel.visible = true
            case WebEngineView.LoadFailedStatus:
                console.log("Page failed!")
                loading.visible = false
                failed.visible = true
                webView.visible = false
                inputPanel.visible = false
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
