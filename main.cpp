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
  if (!QGuiApplication::styleHints()->showIsFullScreen()) {
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
  context->setContextProperty(QStringLiteral("initialKeyboardScale"),
                              keyboardScale);

  engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
  if (engine.rootObjects().isEmpty())
    return -1;

  return app.exec();
}
