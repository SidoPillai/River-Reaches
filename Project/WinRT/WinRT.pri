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

OTHER_FILES += \
    $$PWD/WPAppxManifest.xml.in \
    $$PWD/assets/*.png

WINRT_MANIFEST = $$PWD/WPAppxManifest.xml.in

WINRT_MANIFEST.name = "RiverReaches"
WINRT_MANIFEST.description = "RiverReaches"
WINRT_MANIFEST.store_name = "@winPhonePackageDisplayName@"
WINRT_MANIFEST.version = "1.0.10.0"
WINRT_MANIFEST.identity = "@winPhonePackageName@"
WINRT_MANIFEST.phone_product_id = "@winPhoneProductId@"
WINRT_MANIFEST.publisher = "@winPhonePublisher@"
WINRT_MANIFEST.publisherid = "@winPhonePublisherId@"

#App Icon
WINRT_MANIFEST.logo_44x44 = $$PWD/assets/logo_44x44.png
WINRT_MANIFEST.logo_30x30 = $$PWD/assets/logo_30x30.png
WINRT_MANIFEST.logo_70x70 = $$PWD/assets/logo_70x70.png
WINRT_MANIFEST.logo_71x71 = $$PWD/assets/logo_71x71.png
WINRT_MANIFEST.logo_150x150 = $$PWD/assets/logo_150x150.png
WINRT_MANIFEST.logo_310x150 = $$PWD/assets/logo_310x150.png
WINRT_MANIFEST.logo_310x310 = $$PWD/assets/logo_310x310.png
WINRT_MANIFEST.logo_store = $$PWD/assets/logo_50x50.png

#Splash Screen
WINRT_MANIFEST.logo_480x800 = $$PWD/assets/logo_480x800.png
WINRT_MANIFEST.logo_620x300 = $$PWD/assets/logo_480x800.png
WINRT_MANIFEST.logo_splash = $$PWD/assets/logo_620x300.png

#Capabilities
WINRT_MANIFEST.capabilities += internetClient
WINRT_MANIFEST.capabilities_device += location
WINRT_MANIFEST.capabilities_device += webcam
