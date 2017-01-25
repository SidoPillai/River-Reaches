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

#include <QUrl>
#include <QDebug>
#include <QFileOpenEvent>
#include <QDesktopServices>
#include <QMetaObject>
#include <QQmlProperty>

#include "QmlApplication.h"

//------------------------------------------------------------------------------

#define kMethodOpenUrl                  "openUrl"
#define kMethodBackButtonClicked        "backButtonClicked"
#define kPropertyBackButtonAction       "backButtonAction"

//------------------------------------------------------------------------------

QUrl QmlApplication::m_OpenUrl;

//------------------------------------------------------------------------------

QmlApplication::QmlApplication(int &argc, char **argv) :
    QMLAPPLICATION_BASECLASS(argc, argv),
    m_AppObject(nullptr)
{
    //Disable QStyle support when using QApplication and use platform dependent styles
    if (QCoreApplication::instance()->inherits("QApplication"))
    {
        qDebug() << Q_FUNC_INFO << "App inherits QApplication";

        QString styleName;
#if defined(Q_OS_ANDROID) && !defined(Q_OS_ANDROID_NO_SDK)
        styleName =  QLatin1String("Android");
#elif defined(Q_OS_IOS)
        styleName =  QLatin1String("iOS");
#elif defined(Q_OS_WINRT)
        styleName =  QLatin1String("WinRT");
#else
        styleName =  QLatin1String("Base");
#endif
        qputenv("QT_QUICK_CONTROLS_STYLE", styleName.toLatin1());
    }
}

//--------------------------------------------------------------------------

bool QmlApplication::notify(QObject* receiver, QEvent* event)
{
    switch (event->type())
    {
    case QEvent::Close:
#ifdef Q_OS_ANDROID
        if (appObject())
        {
            QQmlProperty backButtonActionProperty(appObject(), kPropertyBackButtonAction);

            auto backButtonAction = backButtonActionProperty.read().toInt();

            switch (backButtonAction)
            {
            case 1: // Signal
                QMetaObject::invokeMethod(appObject(), kMethodBackButtonClicked);
                return false;

            case 2: // Ignore
                return false;

            case 0: // Quit
            default:
                break;
            }
        }
#endif
        break;

    default:
        break;
    }

    return QMLAPPLICATION_BASECLASS::notify(receiver, event);
}

//--------------------------------------------------------------------------

void QmlApplication::registerUrlScheme(const QString& urlScheme, const char* method)
{
    if (!appObject())
    {
        qWarning() << Q_FUNC_INFO << "Null appObject";
        return;
    }

    if (urlScheme.isEmpty())
    {
        qWarning() << Q_FUNC_INFO << "Empty urlScheme value";
        return;
    }

    qDebug() << Q_FUNC_INFO << "Registering urlScheme:" << urlScheme << "to" << appObject();

    m_UrlScheme = urlScheme;
    QDesktopServices::setUrlHandler(urlScheme, appObject(), method != nullptr ? method : kMethodOpenUrl);
}

//--------------------------------------------------------------------------

void QmlApplication::initialize()
{
    qDebug() << Q_FUNC_INFO;

    processArguments();

    if (!m_OpenUrl.isEmpty() && m_OpenUrl.scheme() == urlScheme())
    {
        openUrl(m_OpenUrl);
    }
}

//--------------------------------------------------------------------------

void QmlApplication::processArguments()
{
    foreach (const auto& argument, arguments())
    {
        if (!urlScheme().isEmpty() && argument.startsWith(urlScheme(), Qt::CaseInsensitive))
        {
            auto url = QUrl(argument);
            if (url.scheme() == urlScheme())
            {
                setOpenUrl(url);
            }
        }
    }
}

//--------------------------------------------------------------------------

void QmlApplication::setOpenUrl(const QUrl& url)
{
    qDebug() << Q_FUNC_INFO << url;
    m_OpenUrl = url;
}

//--------------------------------------------------------------------------

void QmlApplication::openUrl(const QUrl& url)
{
    QDesktopServices::openUrl(url);
}

//--------------------------------------------------------------------------

void QmlApplication::setAppObject(QObject* appObject)
{
    m_AppObject = appObject;
}

//--------------------------------------------------------------------------

bool QmlApplication::event(QEvent* event)
{
    switch (event->type())
    {
    case QEvent::FileOpen:
    {
        auto fileOpenEvent = static_cast<QFileOpenEvent*>(event);

        qDebug() << Q_FUNC_INFO << fileOpenEvent->url();

        QDesktopServices::openUrl(fileOpenEvent->url());

        return true;
    }

    default:
        break;
    }

    return QMLAPPLICATION_BASECLASS::event(event);
}

//--------------------------------------------------------------------------

