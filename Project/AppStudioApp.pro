#-------------------------------------------------------------------------------
# Copyright 2015 Esri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#-------------------------------------------------------------------------------

mac {
    cache()
}

CONFIG += appframework-platform

CONFIG += appframework-webview

#DEFINES += RELEASE_TYPE=\\\"\\\"

CONFIG += c++11 arcgis_appstudio_qml resources_big

unix:!macx:!android:!ios {
    CONFIG += platform_linux
    message("linux")
}

CONFIG += qtquickcompiler

QT += core gui xml network positioning sensors multimedia sql
QT += qml quick

!android:qtHaveModule(webengine) {
    QT += webengine
    DEFINES += QT_WEBVIEW_WEBENGINE_BACKEND
}

osx|platform_linux|win32:!winrt {
    DEFINES += DESKTOP_PLATFORM
    DEFINES += DESKTOP_SPLASH_SCREEN
    CONFIG += desktop_splash
}

CONFIG += depends_widget

desktop_splash | depends_widget {
    DEFINES += QMLAPPLICATION_BASECLASS=QApplication
    QT += widgets
}

excludeStaticPlugins = 

#-------------------------------------------------------------------------------

TEMPLATE = app

VERSION = 1.0.10

!android:!ios:!win32 {
    TARGET = RiverReaches
}

win32 {
    TARGET = AppStudioApp
}

android {
    TARGET = AppStudioApp
}

ios {
    TARGET = AppStudioApp
}

#-------------------------------------------------------------------------------

HEADERS += \
    AppInfo.h \
    QmlApplication.h \
    Utility.h

SOURCES += \
    main.cpp \
    QmlApplication.cpp

RESOURCES += \
    qml/qml.qrc \
    Resources/Resources.qrc

SUBDIRS += \
    Installer

OTHER_FILES += \
    wizard.xml \
    wizard.png

#-------------------------------------------------------------------------------

win32 {
    contains(QMAKE_PLATFORM, "winphone") {
        include (WinRT/WinRT.pri)
        WIN_PLATFORM=winphone
    }
    else {
        contains(QMAKE_PLATFORM, "winrt") {
            WIN_PLATFORM=winrt
        }
        else {
            include (Win/Win.pri)
            WIN_PLATFORM = windows
        }
    }

    contains(QT_ARCH, "x86_64"):{
        WIN_ARCH=x64
    }
    else {
        contains(QT_ARCH, "i386"):{
            WIN_ARCH=x86
        }
        else {
            WIN_ARCH=$$QT_ARCH
        }
    }

    message("WIN_PLATFORM="$$WIN_PLATFORM)
    message("WIN_ARCH="$$WIN_ARCH)

    DIR=$${WIN_PLATFORM}/$${WIN_ARCH}
}

macx {
    include (Mac/Mac.pri)
    DIR = osx/x86
    contains(QT_ARCH, x86_64) {
      DIR = osx/x64
    }
}

ios {
    include (iOS/iOS.pri)
    DIR = ios
}

android {
    include (Android/Android.pri)
    DIR = android
}

unix:!macx:!android:!ios {
    DIR = Linux/x86
    contains(QT_ARCH, x86_64) {
      DIR = Linux/x64
    }
}

!ios {
    DESTDIR = $$PWD/../Output/$$DIR
    DEST = $$PWD/../Intermediate/$$DIR
    OBJECTS_DIR = $$DEST/obj
    MOC_DIR = $$DEST/moc
    RCC_DIR = $$DEST/qrc
    UI_DIR = $$DEST/ui
}

#-------------------------------------------------------------------------------

