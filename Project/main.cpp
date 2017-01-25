/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#include <QDebug>
#include <QSettings>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QCommandLineParser>
#include <QQuickView>
#include <QDir>
#include <QTranslator>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariantMap>
#include <QQuickItem>
#include <QQmlContext>

#ifdef Q_OS_WIN
#include <Windows.h>
#endif

#include "AppInfo.h"
#include "QmlApplication.h"
#include "Utility.h"

#ifdef Q_OS_IOS
#include <QtPlugin>
#endif

#ifdef Q_OS_ANDROID
#include <QtPlugin>
#endif

#ifdef QT_WEBVIEW_WEBENGINE_BACKEND
#include <QtWebEngine>
#endif // QT_WEBVIEW_WEBENGINE_BACKEND

#ifdef DESKTOP_SPLASH_SCREEN
#include <QSplashScreen>
#endif

//------------------------------------------------------------------------------

#define kSettingsFormat                 QSettings::IniFormat

//------------------------------------------------------------------------------

#define kArgShowName                    "show"
#define kArgShowValueName               "showOption"
#define kArgShowDescription             "Show option maximized | minimized | fullscreen | normal | default"
#define kArgShowDefault                 "show"

#define kArgLocaleName                  "locale"
#define kArgLocaleShortName             "l"
#define kArgLocaleValueName             "localeOption"
#define kArgLocaleDescription           "Locale option. Overrides the system language."
#define kArgLocaleDefault               "en"

#define kShowMaximized                  "maximized"
#define kShowMinimized                  "minimized"
#define kShowFullScreen                 "fullscreen"
#define kShowNormal                     "normal"

//------------------------------------------------------------------------------

#define kAppInfoFile                    ":/qml/appinfo.json"
#define kKeyDisplay                     "display"
#define kKeyDesktop                     "desktop"
#define kKeyMinimumWidth                "minimumWidth"
#define kKeyMinimumHeight               "minimumHeight"
#define kFullScreen                     "fullScreen"
#define kUrlScheme                      "urlScheme"

//------------------------------------------------------------------------------

int main(int argc, char *argv[])
{
    qDebug() << "Initializing application";

    qputenv("QML_DISABLE_DISK_CACHE", "1");

    QmlApplication app(argc, argv);

#ifdef Q_OS_IOS
    Q_IMPORT_PLUGIN(ArcGISGeoServices);
    Q_IMPORT_PLUGIN(GeoPositionInfoSourceFactoryCoreLocation);
#endif

#ifdef Q_OS_ANDROID
#ifdef USE_STATIC_PLUGIN_qsqlite
#pragma message( "Importing QSQLiteDriverPlugin" )
    Q_IMPORT_PLUGIN(QSQLiteDriverPlugin);
#endif
#ifdef USE_STATIC_PLUGIN_qjpeg
#pragma message( "Importing QJpegPlugin" )
    Q_IMPORT_PLUGIN(QJpegPlugin);
#endif
#ifdef USE_STATIC_PLUGIN_qgif
#pragma message( "Importing QGifPlugin" )
    Q_IMPORT_PLUGIN(QGifPlugin);
#endif
#ifdef USE_STATIC_PLUGIN_qtquick2plugin
#pragma message( "Importing QtQuick2Plugin" )
    Q_IMPORT_PLUGIN(QtQuick2Plugin);
#endif
#ifdef USE_STATIC_PLUGIN_qmllocalstorageplugin
#pragma message( "Importing QQmlLocalStoragePlugin" )
    Q_IMPORT_PLUGIN(QQmlLocalStoragePlugin);
#endif
#ifdef USE_STATIC_PLUGIN_windowplugin
#pragma message( "Importing QtQuick2WindowPlugin" )
    Q_IMPORT_PLUGIN(QtQuick2WindowPlugin);
#endif
#ifdef USE_STATIC_PLUGIN_qtqmlstatemachine
#pragma message( "Importing QtQmlStateMachinePlugin" )
    Q_IMPORT_PLUGIN(QtQmlStateMachinePlugin);
#endif
#ifdef USE_STATIC_PLUGIN_modelsplugin
#pragma message( "Importing QtQmlModelsPlugin" )
    Q_IMPORT_PLUGIN(QtQmlModelsPlugin);
#endif
#ifdef USE_STATIC_PLUGIN_qtquickextrasplugin
#pragma message( "Importing QtQuickExtrasPlugin" )
    Q_IMPORT_PLUGIN(QtQuickExtrasPlugin);
#endif
#ifdef USE_STATIC_PLUGIN_qtquickcontrolsplugin
#pragma message( "Importing QtQuickControlsPlugin" )
    Q_IMPORT_PLUGIN(QtQuickControlsPlugin)
#endif
#ifdef USE_STATIC_PLUGIN_dialogplugin
#pragma message( "Importing QtQuick2DialogsPlugin" )
    Q_IMPORT_PLUGIN(QtQuick2DialogsPlugin);
#endif
#ifdef USE_STATIC_PLUGIN_qquicklayoutsplugin
#pragma message( "Importing QtQuickLayoutsPlugin" )
    Q_IMPORT_PLUGIN(QtQuickLayoutsPlugin);
#endif

#endif

    QCoreApplication::setApplicationName(kApplicationName);
    QCoreApplication::setApplicationVersion(kApplicationVersion);
    QCoreApplication::setOrganizationName(kOrganizationName);
#ifdef Q_OS_MAC
    QCoreApplication::setOrganizationDomain(kOrganizationName);
#else
    QCoreApplication::setOrganizationDomain(kOrganizationDomain);
#endif

    QmlApplication::setApplicationDisplayName(kApplicationDisplayName);

    QSettings::setDefaultFormat(kSettingsFormat);

#ifdef Q_OS_WIN
    // Force usage of OpenGL ES through ANGLE on Windows
    QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
#endif

    // Initialize license

#ifdef kClientId
    QCoreApplication::instance()->setProperty("ArcGIS.Runtime.clientId", kClientId);
#ifdef kLicense
    QCoreApplication::instance()->setProperty("ArcGIS.Runtime.license", kLicense);
#endif
#endif

    // Set Release Type

#ifdef RELEASE_TYPE
    QCoreApplication::instance()->setProperty("releaseType", RELEASE_TYPE);
#endif

    // Initialize WebView
#ifdef QT_WEBVIEW_WEBENGINE_BACKEND
    QtWebEngine::initialize();
#endif // QT_WEBVIEW_WEBENGINE_BACKEND

    // Read appinfo.json
    QFile file(kAppInfoFile);
    QVariantMap appInfo;
    QString urlScheme;

    if (file.exists() && file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QByteArray json = file.readAll();
        file.close();

        QJsonDocument jsonDocument = QJsonDocument::fromJson(json);
        if (jsonDocument.isObject())
        {
            appInfo = jsonDocument.object().toVariantMap();

            urlScheme = appInfo.value(kUrlScheme, "").toString();
        }
    }

    QString locale = QLocale::system().uiLanguages().at(0);

#ifdef DESKTOP_PLATFORM
#ifdef DESKTOP_SPLASH_SCREEN
    QSplashScreen* splashScreen = nullptr;

    if (!app.arguments().contains("-nosplash", Qt::CaseInsensitive))
    {
        // Generate 620x300 splash screen image
        QPixmap pixmap = createLaunchImage(appInfo, 620, 300);

        if (!pixmap.isNull())
        {
            splashScreen = new QSplashScreen(pixmap);
            splashScreen->show();
            splashScreen->showMessage(QString("Initializing... "));
            app.processEvents();
        }
    }
#endif

    // Process command line

    QCommandLineOption showOption(kArgShowName, kArgShowDescription, kArgShowValueName, kArgShowDefault);

    QCommandLineOption localeOption(QStringList() << kArgLocaleShortName << kArgLocaleName, kArgLocaleDescription, kArgLocaleValueName, kArgLocaleDefault);

    QCommandLineParser commandLineParser;

    commandLineParser.setApplicationDescription(kApplicationDescription);
    commandLineParser.addOption(showOption);
    commandLineParser.addOption(localeOption);
    commandLineParser.addHelpOption();
    commandLineParser.addVersionOption();
    commandLineParser.process(app);

    if (commandLineParser.isSet(kArgLocaleName))
    {
        locale = commandLineParser.value(kArgLocaleName).toLower();
    }

#endif

    // Load and install translation files

    if (!appInfo.isEmpty())
    {
        installTranslator(appInfo, locale);
    }

    // Intialize application window

    QQuickView view;
    view.engine()->addImportPath((QDir(QCoreApplication::applicationDirPath()).filePath("qml")));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setTitle(kApplicationDisplayName);
    view.setSource(QUrl(kApplicationSourceUrl));

    auto topLevelObject = view.rootObject();

    app.setAppObject(topLevelObject);

    if (!urlScheme.isEmpty())
    {
        app.registerUrlScheme(urlScheme);
    }

    app.initialize();


#ifdef DESKTOP_PLATFORM
    // Set Desktop windows display properties

    auto fullScreenMode = false;

    if (!appInfo.isEmpty())
    {
        QVariantMap display = qvariant_cast<QVariantMap>(appInfo.value(kKeyDisplay, QVariantMap()));

        auto desktop = display.value(kKeyDesktop).toMap();
        auto minimumWidth = desktop.value(kKeyMinimumWidth).toInt();
        auto minimumHeight = desktop.value(kKeyMinimumHeight).toInt();

        fullScreenMode = desktop.value(kFullScreen).isValid() ? desktop.value(kFullScreen).toBool() : false;

        if (minimumWidth > 0)
        {
            view.setMinimumWidth(minimumWidth);
        }
        if (minimumHeight > 0)
        {
            view.setMinimumHeight(minimumHeight);
        }
    }

    // Show app window

    auto showValue = commandLineParser.value(kArgShowName).toLower();

    if (showValue.compare(kShowMinimized) == 0)
    {
        view.showMinimized();
    }
    else if (showValue.compare(kShowMaximized) == 0)
    {
        view.showMaximized();
    }
    else if (showValue.compare(kShowNormal) == 0)
    {
        view.showNormal();
    }
    else if ((showValue.compare(kShowFullScreen) == 0) || fullScreenMode)
    {
        view.showFullScreen();
    }
    else
    {
        view.show();
    }

#else
    view.show();
#endif


#ifdef DESKTOP_SPLASH_SCREEN
    if (splashScreen)
    {
        splashScreen->deleteLater();
    }
#endif

    return app.exec();
}

//------------------------------------------------------------------------------
