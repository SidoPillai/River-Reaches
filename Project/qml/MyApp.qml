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

import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1


import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "controls" as Awesome

//------------------------------------------------------------------------------

App {
    id: app
    width: 375
    height: 600

    // App Variables
    property alias fontSourceSansProReg : fontSourceSansProReg
    property alias awesome : awesome

    property string databaseName: "RiverReachesComponent"
    property string tableName: "river_reaches_4"
    property string tableNameForAlerts: "alerts_5"
    property string tableNameForFolderInfo: "folder_info"

    // Scale factor
    property double scaleFactor: AppFramework.displayScaleFactor

    AppConfigData {
        id: appConfigData
    }

    FontLoader {
        id: fontSourceSansProReg
        source: app.folder.fileUrl("assets/fonts/FiraSans-Regular.ttf")
    }

    FontAwesome {
        id: awesome
        resource: app.folder.fileUrl("assets/fonts/fontawesome-webfont.ttf")
    }

    GetAppData{
        id: getRiverReachDataRequest
    }

    LocalStorage {
        id: localStorage
    }

    AppUtilityFunctions {
        id: appUtilityFunctions
    }

    JsonFileManager {
        id: jsonFileManager
    }

    StackView {
        id: stackView
        width: app.width
        height: app.height
        initialItem: mainView
    }

    Component {
        id: mainView

        MainViewPage {
            id: mainPageView
        }
    }

    SpatialReference {
        id: sr4326
        wkid: 4326
    }

    SpatialReference {
        id: sr3857
        wkid: 3857
    }
}

//------------------------------------------------------------------------------
