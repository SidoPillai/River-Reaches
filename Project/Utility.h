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

#ifndef __UTILITY__
#define __UTILITY__

#include <QString>
#include <QVariantMap>
#include <QPixmap>
#include <QPainter>
#include <QTranslator>
#include <QCoreApplication>

//------------------------------------------------------------------------------

#define kQrcPrefix                      ":/qml/"
#define kOptionBackgroundColor          "launchImageBackgroundColor"
#define kOptionBackgroundImage          "launchImageBackground"
#define kOptionOverlayImage             "launchImageOverlay"
#define kOptionIconImage                "appIcon"
#define kKeyResources                   "resources"
#define kDefaultAppIcon                 "appicon.png"
#define kDefaultBackgroundImage         "launchimage-background.png"
#define kDefaultOverlayImage            "launchimage-overlay.png"
#define kTranslations                   "translations"
#define kTranslationsPath               "path"
#define kTranslationsFileName           "fileName"

//------------------------------------------------------------------------------

inline QPixmap createLaunchImage(const QVariantMap& appInfo, int width, int height)
{
    QVariantMap resources = qvariant_cast<QVariantMap>(appInfo.value(kKeyResources, QVariantMap()));

    QPixmap backgroundPixmap(kQrcPrefix + resources.value(kOptionBackgroundImage, kDefaultBackgroundImage).toString());
    QPixmap overlayPixmap(kQrcPrefix + resources.value(kOptionOverlayImage, kDefaultOverlayImage).toString());
    QPixmap iconPixmap(kQrcPrefix + resources.value(kOptionIconImage, kDefaultAppIcon).toString());

    QPixmap targetPixmap(width, height);
    QPainter painter(&targetPixmap);

    painter.fillRect(0, 0, width, height, QColor(resources.value(kOptionBackgroundColor, "white").toString()));

    if (!backgroundPixmap.isNull())
    {
        auto pixmap = backgroundPixmap.scaled(width,
                                              height,
                                              Qt::KeepAspectRatioByExpanding,
                                              Qt::SmoothTransformation);

        if (pixmap.isNull())
        {
            qDebug() << Q_FUNC_INFO << "Error transforming background" << backgroundPixmap << width << height;

            return QPixmap();
        }

        painter.drawPixmap((width - pixmap.width()) / 2, (height - pixmap.height()) / 2, pixmap);
    }

    if (!overlayPixmap.isNull())
    {
        auto pixmap = overlayPixmap.scaled(width,
                                           height,
                                           Qt::KeepAspectRatio,
                                           Qt::SmoothTransformation);

        if (pixmap.isNull())
        {
            qDebug() << Q_FUNC_INFO << "Error transforming overlay" << overlayPixmap << width << height;

            return QPixmap();
        }

        painter.drawPixmap((width - pixmap.width()) / 2, (height - pixmap.height()) / 2, pixmap);
    }

    if (overlayPixmap.isNull() && backgroundPixmap.isNull() && !iconPixmap.isNull())
    {
        auto iconSize = width < height ? width : height;
        iconSize /= 3;

        auto pixmap = iconPixmap.scaled(iconSize,
                                        iconSize,
                                        Qt::KeepAspectRatio,
                                        Qt::SmoothTransformation);

        if (pixmap.isNull())
        {
            qDebug() << Q_FUNC_INFO << "Error transforming icon" << iconPixmap << iconSize;

            return QPixmap();
        }

        painter.drawPixmap((width - pixmap.width()) / 2, (height - pixmap.height()) / 2, pixmap);
    }

    painter.end();

    return targetPixmap;
}

//------------------------------------------------------------------------------

inline void loadTranslator(const QVariantMap& translatorInfo, const QString& locale)
{
    QVariant path = translatorInfo[kTranslationsPath];

    QVariant fileNames = translatorInfo[kTranslationsFileName];

    if (!path.isValid() || path.isNull() || !fileNames.isValid() || fileNames.isNull())
    {
        return;
    }

    foreach (const QString fileName, fileNames.toStringList())
    {
        QTranslator *translator = new QTranslator();

        QString translationFile = fileName + "_" + QLocale(locale).name();
        QString translationFolder = kQrcPrefix + path.toString();

        if (translator->load(translationFile, translationFolder))
        {
            qDebug() << "Loading " << translationFolder << "/" << translationFile;
            QCoreApplication::installTranslator(translator);
        }
    }
}

//------------------------------------------------------------------------------

inline void installTranslator(const QVariantMap& appInfo, const QString& locale)
{
    QVariant translations = appInfo[kTranslations];

    if (translations.isNull() || !translations.isValid())
    {
        return;
    }

    if (translations.userType() == qMetaTypeId<QVariantList>())
    {
        foreach (const QVariant& translation, translations.toList())
        {
            if (translation.type() == qMetaTypeId<QVariantMap>())
            {
                loadTranslator(translation.toMap(), locale);
            }
        }
    }
    else if (translations.userType() == qMetaTypeId<QVariantMap>())
    {
        loadTranslator(translations.toMap(), locale);
    }
}

//------------------------------------------------------------------------------

#endif // UTILITY
