# Yoe Kiosk Browser

The Yoe Kiosk Browser is a Qt WebEngine (Chromium) based browser
designed for embedded kiosk (full screen, single app) applications. In this scenario, the UI for the device
is a web application that displays in a browser running on the device.

![screenshot](screenshot.png)

## Features:

- designed to run fullscreen
- no URL bar
- embedded touchscreen virtual keyboard
- keyboard width can be configured
- supports 0°, 90° or 270° screen rotation in the application. No messing around with window managers or external environments.

## To build

### On a development machine

- install Qt dependencies
- `mkdir build`
- `cd build`
- `cmake ../`
- `make`

### On Embedded Linux Systems

Use the [Yoe Linux recipe](https://github.com/YoeDistro/yoe-distro/blob/master/sources/meta-yoe/dynamic-layers/qt6-layer/recipes-qt/kiosk-browser/yoe-kiosk-browser.bb).

## Settings

See [yoe-kiosk-browser-env](yoe-kiosk-browser-env)

## Reference

This project uses ideas from:

- [BEC Systems Kiosk Browser](https://github.com/cbrake/kiosk-browser/tree/qt-webengine)
- [Qt webview minibrowser](https://github.com/qt/qtwebview/tree/dev/examples/webview/minibrowser)
- [O. S. Systems qt-kiosk-browser](https://github.com/OSSystems/qt-kiosk-browser)
- [Qt Virtual Keyboard Examples](https://github.com/qt/qtvirtualkeyboard/tree/dev/examples/virtualkeyboard/basic)
- [Qt Web Browser](https://code.qt.io/cgit/qt-apps/qtwebbrowser.git/)
