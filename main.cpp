// Copyright (C) 2017 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include <QDebug>
#include <QGuiApplication>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QScreen>
#include <QStyleHints>
#include <QtCore/QCommandLineOption>
#include <QtCore/QUrl>
#include <QtQml/QQmlContext>
#include <QtWebView/QtWebView>
#include <QTextStream>
#include <QLoggingCategory>
#include <QWebEngineView>
#include <QWebEngineSettings>
#include <QQuickWindow>
#include <QWindow>

// Workaround: As of Qt 5.4 QtQuick does not expose QUrl::fromUserInput.
class Utils : public QObject {
  Q_OBJECT
public:
  Utils(QObject *parent = nullptr) : QObject(parent) {}
  Q_INVOKABLE static QUrl fromUserInput(const QString &userInput);
};

QUrl Utils::fromUserInput(const QString &userInput) {
  if (userInput.isEmpty())
    return QUrl::fromUserInput("about:blank");
  const QUrl result = QUrl::fromUserInput(userInput);
  return result.isValid() ? result : QUrl::fromUserInput("about:blank");
}

#include "main.moc"

int main(int argc, char *argv[]) {
  qputenv("QT_IM_MODULE", "qtvirtualkeyboard");

  QByteArray url = qgetenv("YOE_KIOSK_BROWSER_URL");
  if (url == "") {
    url = "https://yoedistro.org";
  }
  qDebug() << "YOE_KIOSK_BROWSER_URL=" << url;

  QByteArray exceptionUrl = qgetenv("YOE_KIOSK_BROWSER_EXCEPTION_URL");
  qDebug() << "YOE_KIOSK_BROWSER_EXCEPTION_URL=" << exceptionUrl;

  QByteArray rotate = qgetenv("YOE_KIOSK_BROWSER_ROTATE");
  if (rotate == "") {
    rotate = "0";
  }
  qDebug() << "YOE_KIOSK_BROWSER_ROTATE=" << rotate;

  QByteArray keyboardScale = qgetenv("YOE_KIOSK_BROWSER_KEYBOARD_SCALE");
  if (keyboardScale == "") {
    keyboardScale = "1";
  }
  qDebug() << "YOE_KIOSK_BROWSER_KEYBOARD_SCALE=" << keyboardScale;

  QByteArray useDefaultDialogs = qgetenv("YOE_KIOSK_BROWSER_DEFAULT_DIALOGS");
  if (useDefaultDialogs == "") {
    useDefaultDialogs = "0";
  }
  qDebug() << "YOE_KIOSK_BROWSER_DEFAULT_DIALOGS=" << useDefaultDialogs;

  QByteArray dialogColor = qgetenv("YOE_KIOSK_BROWSER_DIALOG_COLOR");
  if (dialogColor == "") {
    dialogColor = "#FFFFFF";
  }
  qDebug() << "YOE_KIOSK_BROWSER_DIALOG_COLOR=" << dialogColor;

  QByteArray retryInterval = qgetenv("YOE_KIOSK_BROWSER_RETRY_INTERVAL");
  if (retryInterval == "") {
    retryInterval = "5";
  }
  qDebug() << "YOE_KIOSK_BROWSER_RETRY_INTERVAL=" << retryInterval;

  QByteArray fullscreen = qgetenv("YOE_KIOSK_BROWSER_FULLSCREEN");
  if (fullscreen == "") {
    fullscreen = "0";
  }
  qDebug() << "YOE_KIOSK_BROWSER_FULLSCREEN=" << fullscreen;

  QByteArray touchQuirk = qgetenv("YOE_KIOSK_BROWSER_TOUCH_QUIRK");
  if (touchQuirk == "") {
    touchQuirk = "0";
  }
  qDebug() << "YOE_KIOSK_BROWSER_TOUCH_QUIRK=" << touchQuirk;

  QByteArray ignoreCertificateErrors = qgetenv("YOE_KIOSK_BROWSER_IGNORE_CERT_ERR");
  if (ignoreCertificateErrors == "1") {
    // Set the environment variable for the entire process
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("QTWEBENGINE_CHROMIUM_FLAGS", "--ignore-certificate-errors");
    // Apply environment to the process (manually for the application)
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS", QByteArray("--ignore-certificate-errors"));
  } else {
    ignoreCertificateErrors == "0";
  }
  qDebug() << "YOE_KIOSK_BROWSER_IGNORE_CERT_ERR=" << ignoreCertificateErrors;

  //! [0]
  QtWebView::initialize();
  QGuiApplication app(argc, argv);
  //! [0]
  QGuiApplication::setApplicationDisplayName(
      QCoreApplication::translate("main", "QtWebView Example"));
  QCoreApplication::setApplicationVersion(QT_VERSION_STR);

  QQmlApplicationEngine engine;
  QQmlContext *context = engine.rootContext();
  context->setContextProperty(QStringLiteral("utils"), new Utils(&engine));
  context->setContextProperty(QStringLiteral("initialUrl"), url);
  context->setContextProperty(QStringLiteral("exceptionUrl"), exceptionUrl);
  QRect geometry = QGuiApplication::primaryScreen()->availableGeometry();
  if (!QGuiApplication::styleHints()->showIsFullScreen() && 
      !(fullscreen == "1")) {
    const QSize size = geometry.size() * 4 / 5;
    const QSize offset = (geometry.size() - size) / 2;
    const QPoint pos =
        geometry.topLeft() + QPoint(offset.width(), offset.height());
    geometry = QRect(pos, size);
  }
  context->setContextProperty(QStringLiteral("initialX"), geometry.x());
  context->setContextProperty(QStringLiteral("initialY"), geometry.y());
  context->setContextProperty(QStringLiteral("initialWidth"), geometry.width());
  context->setContextProperty(QStringLiteral("initialHeight"),
                              geometry.height());
  context->setContextProperty(QStringLiteral("initialRotation"), rotate);
  context->setContextProperty(QStringLiteral("retryInterval"), retryInterval);
  context->setContextProperty(QStringLiteral("initialKeyboardScale"),
                              keyboardScale);
  context->setContextProperty(QStringLiteral("useDefaultDialogs"),
                              useDefaultDialogs);
  context->setContextProperty(QStringLiteral("dialogColor"),
                              dialogColor);

  engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
  if (engine.rootObjects().isEmpty())
    return -1;

  // On some touchscreens the first input of a touch event wont activate the 
  // correct focus. This quirk solves this issue.
  if (touchQuirk == "1") {
    // Get the main window object from the QML engine
    QQuickWindow* quickWindow = qobject_cast<QQuickWindow*>(engine.rootObjects().first());

    if (quickWindow) {
        // Cast QQuickWindow to QWindow, and activate it
        QWindow *window = qobject_cast<QWindow*>(quickWindow);
        if (window) {
            window->show();
            window->raise();           // Bring the window to the front
            window->requestActivate(); // Ensure the window is activated and focused
        }
    }
  }
  

  return app.exec();
}
