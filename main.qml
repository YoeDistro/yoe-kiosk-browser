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

    WebEngineView {
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
    }

    InputPanel {
      id: inputPanel
      y: Qt.inputMethod.visible ? parent.height - inputPanel.height : parent.height
      anchors.left: parent.left
      anchors.right: parent.right
    }
  }
}
