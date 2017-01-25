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

#ifndef QmlApplication_H
#define QmlApplication_H

#include <QUrl>

//------------------------------------------------------------------------------

#ifndef QMLAPPLICATION_BASECLASS

#include <QGuiApplication>

#define QMLAPPLICATION_BASECLASS QGuiApplication

#else

#include <QApplication>

#endif

//------------------------------------------------------------------------------

class QmlApplication : public QMLAPPLICATION_BASECLASS
{
    Q_OBJECT

public:
    QmlApplication(int &argc, char **argv);

    bool notify(QObject* receiver, QEvent* event);

    void registerUrlScheme(const QString& urlScheme, const char* method = nullptr);
    void initialize();
    void openUrl(const QUrl& url);

    inline QObject* appObject() const { return m_AppObject; }
    void setAppObject(QObject* appObject);

    inline const QString& urlScheme() const { return m_UrlScheme; }

    static void setOpenUrl(const QUrl& url);

protected:
    bool event(QEvent* event);
    void processArguments();

private:
    QObject*                m_AppObject;
    QString                 m_UrlScheme;
    static QUrl             m_OpenUrl;
};

//------------------------------------------------------------------------------
#endif // QmlApplication_H

