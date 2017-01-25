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

INCLUDEPATH += $$PWD
DEPENDPATH += $$PWD

OTHER_FILES += \
    $$PWD/Info.plist \
    $$PWD/Images.xcassets/AppIcon.appiconset/Contents.json \
    $$PWD/Images.xcassets/LaunchImage.launchimage/Contents.json

QMAKE_INFO_PLIST = $$PWD/Info.plist
QMAKE_IOS_DEPLOYMENT_TARGET = 8.0

asset_catalog_appicon.name = "ASSETCATALOG_COMPILER_APPICON_NAME"
asset_catalog_appicon.value = "AppIcon"
QMAKE_MAC_XCODE_SETTINGS += asset_catalog_appicon

asset_catalog_launchimage.name = "ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME"
asset_catalog_launchimage.value = LaunchImage
QMAKE_MAC_XCODE_SETTINGS += asset_catalog_launchimage

QMAKE_IOS_TARGETED_DEVICE_FAMILY = 1,2

iphoneos {
    QMAKE_XCODE_CODE_SIGN_IDENTITY = ""

    QMAKE_POST_LINK += strip $${OUT_PWD}/Release-iphoneos/$${TARGET}.app/$${TARGET}
}

BUNDLE_DATA.files = \
    $$PWD/Images.xcassets

QMAKE_BUNDLE_DATA += BUNDLE_DATA

QTPLUGIN += \
        qtgeoservices_nokia \
        qtgeoservices_osm
