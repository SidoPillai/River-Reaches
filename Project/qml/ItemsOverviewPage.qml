import QtQuick 2.5
import QtGraphicalEffects 1.0
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.WebMap 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

import "Components" as Components

Item {
    id: _root
    anchors.fill: parent
    visible: false

    // Configurable variables
    property string databaseName: app.databaseName
    property string tableName: app.tableName
    property int riverReachInfoTextMargin: 10
    property var envelopeCollection: []

    property color riverReachNameTextColor: "#636363"

    property int removeItemButtonOffsetValue:  0
    property bool isSwipingEventEnd: true

    property string sortField: "activity"

    signal showDetailedPageClicked(var itemData)
    signal addNewItemButtonClicked()
    signal openInfoPageButtonClicked()
    signal openAddRiverReachTriggered()

    ListModel {
        id: riverReachesModel
    }

    Component.onCompleted: {

    }

    function show(){

        toggleBusyDialog(true);

        riverReachesModel.clear();

        riverReachLocationGraphicLayer.removeAllGraphics();

        envelopeCollection.length = 0;

        jsonFileManager.createNewFeatureCollection();

        getAllRiverReachItems(getRiverDataOnSuccessHandler, getRiverDataOnErrorHandler);

        _root.visible = true;
    }

    function hide(){
        _root.visible = false;
    }

    function getAllRiverReachItems(callback, errorHandler) {

        var result = localStorage.queryAllValues(tableName);
        var numItems = result.rows.length;

        if(!numItems){
            //direct user to add item page if the result lsit is empty
            openAddRiverReachTriggered();

        } else {
            for (var i=0; i < numItems; i++) {

                var stationID = result.rows.item(i).station_id;

                var riverReachData = {
                    "stationID": stationID,
                    "streamName": result.rows.item(i).stream_name,
                    "x": result.rows.item(i).x,
                    "y": result.rows.item(i).y,
                    "numItems": numItems
                };

                jsonFileManager.addNewFeature(stationID);

                getRiverReachDataRequest.getData(riverReachData, callback, errorHandler);
            }
        }
    }

    function getHourDiff(toTime){
        var now = new Date().getTime();
        var diff = toTime - now;
        diff = diff / 60 / 60 / 1000;

        return diff;
    }

    function addDays(time, numOfDays){
        var date = new Date(time);
        date.setDate(date.getDate() + numOfDays);
        return date;
    }

    function getAlertsDataFromDB(stationID){
        var alerts = [];
        var result = localStorage.queryAllAlertsByKey(app.tableNameForAlerts, stationID);
        var numItems = result.rows.length;

        if(!numItems){
            console.log("ItemOverviewPage: no alerts found for river reach: " + stationID);
        } else {
            for (var i=0; i < numItems; i++) {

                alerts.push({
                                "id": result.rows.item(i).id,
                                "station_id": result.rows.item(i).station_id,
                                "value": result.rows.item(i).value,
                                "type": result.rows.item(i).alert_type,
                                "status": result.rows.item(i).alert_status,
                                "send_notification": result.rows.item(i).send_notification,
                                "notification_time": result.rows.item(i).notification_time
                            });
            }

            jsonFileManager.updateAlerts(stationID, alerts);
        }

        alerts.sort(function(a, b){
            return parseInt(a.value) - parseInt(b.value)
        });

        return alerts;
    }

    function arrangeRiverDataByTime(data){

        var currentTime = new Date();
        var periodEndTime = addDays(currentTime, 3);

        data = data.filter(function(d){
            var itemTiveValue = new Date(d.attributes[appConfigData.timeValueFieldName]);
            return itemTiveValue < periodEndTime;
        });

        data.sort(function(a, b){
            return parseInt(a.attributes[appConfigData.timeValueFieldName]) - parseInt(b.attributes[appConfigData.timeValueFieldName]);
        });

        return data;
    }

    function closest (num, arr) {
        var curr = arr[0];
        var diff = Math.abs (num - curr);

        for (var val = 0; val < arr.length; val++) {
            var newdiff = Math.abs (num - arr[val]);
            if (newdiff < diff) {
                diff = newdiff;
                curr = arr[val];
            }
        }
        return curr;
    }

    function getMostRecentAlert(stationID, riverReachDataRequestResponse){

        stationID = stationID.toString();

        var previousQout = 0;
        var alertValue = 0;
        var alertTime = 0;
        var alertType = "";

        var alerts = getAlertsDataFromDB(stationID);

        var alertsValueOnly = alerts.map(function(d){
            return d.value;
        });

        if(alerts.length){

            for(var i = 0; i < parseInt(appConfigData.numOfItemsInShortTerm); i++) {

                var qout = riverReachDataRequestResponse[i].attributes[appConfigData.qOutFieldName];
                var timeValue = riverReachDataRequestResponse[i].attributes[appConfigData.timeValueFieldName];

                var nearestAlert = 0;

                if(previousQout){

                    nearestAlert = closest(qout, alertsValueOnly);

                    var alertItem = alerts.filter(function( obj ) {
                        return obj.value === nearestAlert;
                    })[0];

                    if(alertItem.type === "increase" && qout > previousQout && qout >= +alertItem.value && +alertItem.value > previousQout){
                        alertValue = alertItem.value;
                        alertTime = timeValue;
                        alertType = "exceeds";
                        break;
                    }

                    if(alertItem.type === "decrease" && previousQout > qout && +alertItem.value >= qout && +alertItem.value < previousQout){
                        alertValue = alertItem.value;
                        alertTime = timeValue;
                        alertType = "drops below";
                        break;
                    }
                }

                previousQout = qout;
            }
        }

        return {
            "alertValue": alertValue.toString(),
            "alertTime": (alertTime !== 0) ? Math.round(getHourDiff(alertTime)): 999,
                                             "alertType": alertType
        };
    }

    function getRiverDataOnSuccessHandler(result) {

        var response = JSON.parse(result.responseText);

        response = arrangeRiverDataByTime(response.features);

        var streamName = result.riverData.streamName;

        var stationID = response[0].attributes[appConfigData.stationIDFieldName];
        var currentAnomaly = response[0].attributes[appConfigData.anomalyFieldName];
        var currentQOut = Math.round(response[0].attributes[appConfigData.qOutFieldName] * 10) / 10;
        var currentQDiff = Math.round(response[0].attributes[appConfigData.qDiffFieldName] * 10) / 10;

        var currentQDiffPct =  ((currentQDiff / (currentQOut - currentQDiff)) * 100).toFixed(1);
        var x = result.riverData.x.toString();
        var y = result.riverData.y.toString();

        var alertData = getMostRecentAlert(stationID, response);

        riverReachesModel.append({
                                     "stationID": stationID,
                                     "name": streamName,
                                     "anomaly": currentAnomaly,
                                     "qDiff": currentQDiff,
                                     "qOut": currentQOut,
                                     "qDiffPct": currentQDiffPct,
                                     "alertValue": alertData.alertValue,
                                     "alertTime": alertData.alertTime,
                                     "alertType": alertData.alertType,
                                     "xCoord": x,
                                     "yCoord": y,
                                     "temperature": "",
                                     "weatherIconURL": "",
                                     "responseDataInJson": JSON.stringify(result)
                                 });

        sortRiverReachesModel(sortField);

        populatePoint(x, y, stationID, streamName, currentAnomaly, alertData.alertValue, alertData.alertTime, alertData.alertType);

        if(riverReachesModel.count === result.riverData.numItems) {
            toggleBusyDialog(false);

            //            console.log(JSON.stringify(jsonFileManager.riverReachDataCollection));

            jsonFileManager.saveFile();
        }
    }

    function getRiverDataOnErrorHandler(){
        console.log("error when fetch data");
        toggleBusyDialog(false);
        return;
    }

    function sortRiverReachesModel(fieldName){
        var items = [];

        function compareName(a, b) {
            if (a.name < b.name)
                return -1;
            if (a.name > b.name)
                return 1;
            return 0;
        }

        for(var i=0; i < riverReachesModel.count; i++){
            items.push(JSON.stringify(riverReachesModel.get(i)));
        }

        items = items.map(function(d){
            return JSON.parse(d);
        });

        if(fieldName === "name"){
            items.sort(compareName);
        } else if (fieldName === "activity"){
            items.sort(function(a, b){
                return a.alertTime - b.alertTime;
            });
        } else if (fieldName === "status"){
            items.sort(function(a, b){
                return b.qOut - a.qOut;
            });
        }

        riverReachesModel.clear();

        for(var n=0; n< items.length; n++){
            riverReachesModel.append(items[n]);
        }
    }

    function toggleBusyDialog(showDialog){
        if(showDialog){
            busyDialog.visible = true;
            listRiverReaches.visible = false;
        } else {
            busyDialog.visible = false;
            listRiverReaches.visible = true;
        }
    }

    Rectangle {
        width: parent.width
        height: parent.height
    }

    RectangularGlow {
        id: topNavBarGlowEffect
        anchors.fill: topNavBar
        glowRadius: 10
        spread: 0
        color: appConfigData.welcomeDialogGlowEffectColor
        cornerRadius: 0
    }

    Rectangle {
        id: topNavBar
        width: parent.width
        height: appConfigData.topNavBarHeight
        color: appConfigData.themeColorLightGray

        Text {
            id: titleText
            anchors.centerIn: parent
            text: appConfigData.itemOverviewPageTitleText
            color: appConfigData.themeColorGreen
            font.pixelSize: appConfigData.itemOverviewPageTitleTextFont
            font.family: app.fontSourceSansProReg.name
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: addRiverReachButton
            width: appConfigData.defaultAppBtnHeight
            height: parent.height
            color: "transparent"
            anchors {
                right: parent.right
                rightMargin: appConfigData.defaultAppBtnHorizontalMargin
                verticalCenter: parent.verticalCenter
            }
            visible: (riverReachesModel.count === 15) ? false : true

            Text {
                id: alertChartValuePlusBtnText
                anchors.centerIn: parent
                color: appConfigData.themeColorGreen
                font.pixelSize: appConfigData.fontSize22
                font.family: awesome.family
                text: awesome.loaded ? awesome.icons.fa_plus : ""
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    addNewItemButtonClicked();
                }
            }
        }

        Rectangle {
            id: openInfoPageButton
            width: appConfigData.defaultAppBtnHeight
            height: parent.height
            color: "transparent"
            anchors {
                left: parent.left
                leftMargin: appConfigData.defaultAppBtnHorizontalMargin
                verticalCenter: parent.verticalCenter
            }

            Text {
                id: openInfoPageButtonText
                anchors.centerIn: parent
                color: appConfigData.themeColorGreen
                font.pixelSize: appConfigData.fontSize22
                font.family: awesome.family
                text: awesome.loaded ? awesome.icons.fa_info_circle : ""
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    openInfoPageButtonClicked();
                }
            }
        }
    }

    RectangularGlow {
        id: bottomNavBarGlowEffect
        anchors.fill: bottomNavBar
        glowRadius: 10
        spread: 0
        color: appConfigData.welcomeDialogGlowEffectColor
        cornerRadius: 0
    }

    Rectangle {
        id: bottomNavBar
        width: parent.width
        height: appConfigData.itemOverviewPageBottomBarHeight
        color: appConfigData.themeColorLightGray
        opacity: appConfigData.itemOverviewPageBottomBarOpacity

        anchors {
            bottom: parent.bottom
        }

        Rectangle {
            id: bottomNavBarLeftButton
            width: parent.width / 2
            height: parent.height
            color: "transparent"

            anchors {
                left: parent.left
            }

            Text {


                id: bottomNavBarLeftButtonText
                anchors.centerIn: parent
                text: "List"
                color: appConfigData.themeColorGreen
                font.pixelSize: appConfigData.fontSize18
                font.family: app.fontSourceSansProReg.name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                id: bottomNavBarLeftButtonUnderline
                width: parent.width * appConfigData.bottomBarButtonUnderlineWidthRatio
                height: appConfigData.bottomBarButtonUnderlineHeight
                color: appConfigData.themeColorGreen

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: appConfigData.bottomBarButtonUnderlineBottomMargin
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    bottomNavBarLeftButtonUnderline.color = appConfigData.themeColorGreen;
                    bottomNavBarRightButtonUnderline.color = "transparent";

                    bottomNavBarLeftButtonText.color = appConfigData.themeColorGreen;
                    bottomNavBarRightButtonText.color = appConfigData.themeColorLighterGray;

                    listRiverReaches.visible = true;
                    map.visible = false;
                }
            }
        }

        Rectangle {
            id: bottomNavBarRightButton
            width: parent.width / 2
            height: parent.height
            color: "transparent"

            anchors {
                right: parent.right
            }

            Text {
                id: bottomNavBarRightButtonText
                anchors.centerIn: parent
                text: "Map"
                color: appConfigData.themeColorLighterGray
                font.pixelSize: appConfigData.fontSize18
                font.family: app.fontSourceSansProReg.name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                id: bottomNavBarRightButtonUnderline
                width: parent.width * appConfigData.bottomBarButtonUnderlineWidthRatio
                height: appConfigData.bottomBarButtonUnderlineHeight
                color: "transparent"

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: appConfigData.bottomBarButtonUnderlineBottomMargin
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    bottomNavBarLeftButtonUnderline.color = "transparent";
                    bottomNavBarRightButtonUnderline.color = appConfigData.themeColorGreen;

                    bottomNavBarLeftButtonText.color = appConfigData.themeColorLighterGray;
                    bottomNavBarRightButtonText.color = appConfigData.themeColorGreen;

                    listRiverReaches.visible = false;
                    map.visible = true;

                    zoomToLayerExtent(riverReachLocationGraphicLayer);
                }
            }
        }

    }
    //-----------------------------

    Rectangle {
        id: sortBtnsWrapper
        width: parent.width  * 0.95
        height: 20 * app.scaleFactor

        anchors {
            top: topNavBar.bottom
            topMargin: 10 * app.scaleFactor
            horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            id: sortByStatusRect
            height: parent.height
            width: parent.width * 0.25
            anchors {
                left: parent.left
            }

            Text {
                id: sortByStatusText
                anchors.left: parent.left
                text: "Current Flow"
                color: (sortField == 'status') ? appConfigData.themeColorGreen : appConfigData.themeColorLighterGray
                font.pixelSize: appConfigData.sortBtnsTextFont
                font.family: app.fontSourceSansProReg.name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                id: sortByStatusUnderline
                width: sortByStatusText.width
                height: appConfigData.bottomBarButtonUnderlineHeight
                color: (sortField == 'status') ? appConfigData.themeColorGreen : "transparent"

                anchors {
                    left: parent.left
                    bottom: parent.bottom
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {

                    sortField = 'status';

                    sortRiverReachesModel(sortField);

                }
            }
        }

        Rectangle {
            id: sortByNameRect
            height: parent.height
            width: parent.width * 0.25
            anchors {
                left: sortByStatusRect.right
            }

            Text {
                id: sortByNameText
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Name"
                color: (sortField == 'name') ? appConfigData.themeColorGreen : appConfigData.themeColorLighterGray
                font.pixelSize: appConfigData.sortBtnsTextFont
                font.family: app.fontSourceSansProReg.name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                id: sortByNameUnderline
                width: sortByNameText.width
                height: appConfigData.bottomBarButtonUnderlineHeight
                color: (sortField == 'name') ? appConfigData.themeColorGreen : "transparent"

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {

                    sortField = 'name';

                    sortRiverReachesModel(sortField);

                }
            }
        }

        Rectangle {
            id: sortByActivityRect
            height: parent.height
            width: parent.width * 0.3
            anchors {
                right: parent.right
            }

            Text {
                id: sortByActivityText
                anchors.right: parent.right
                text: "Alert Activity"
                color: (sortField == 'activity') ? appConfigData.themeColorGreen : appConfigData.themeColorLighterGray
                font.pixelSize: appConfigData.sortBtnsTextFont
                font.family: app.fontSourceSansProReg.name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                id: sortByActivityUnderline
                width: sortByActivityText.width
                height: appConfigData.bottomBarButtonUnderlineHeight
                color: (sortField == 'activity') ? appConfigData.themeColorGreen : "transparent"

                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    //                    bottomMargin: appConfigData.bottomBarButtonUnderlineBottomMargin
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {

                    sortField = 'activity';

                    sortRiverReachesModel(sortField);
                }
            }
        }
    }

    //    Components.BusyDialog{
    //        id: busyDialog
    //        isDebug: false
    //        backgroundColor: appConfigData.themeColorLightGray
    //        busyTextColor: appConfigData.themeColorGreen
    //        busyTextSize: 10
    //        aspectRatio: 1
    //        busyText: "Loading..."
    //        indicatorImageName: "loading.gif"
    //    }

    ListView {
        id: listRiverReaches
        width: parent.width * 0.95
        height: parent.height - ( topNavBar.height +  sortBtnsWrapper.height + bottomNavBar.height)
        anchors {
            top: sortBtnsWrapper.bottom
            topMargin: 5 * app.scaleFactor
            bottom: bottomNavBar.top
            bottomMargin:  5 * app.scaleFactor
            horizontalCenter: parent.horizontalCenter
        }
        orientation: ListView.Vertical
        clip: true
        delegate: riverReachesDelegate
        model: riverReachesModel
        spacing: 12 * app.scaleFactor

    }
    // end of listRiverReaches

    Component {
        id: riverReachesDelegate

        Rectangle {
            id: rectriverReachComponent
            width: listRiverReaches.width
            //            height: Math.max(60 * app.scaleFactor, (riverReachName.implicitHeight + (20 * app.scaleFactor)))
            //            height: 70 * app.scaleFactor
            height: riverReachComponentTopRect.height +  riverReachComponentBottomRect.height
            color: appConfigData.themeColorLightGray

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(removeItemButton.visible === true){
                        removeItemButton.visible = false;
                    } else {

                        var data = {
                            "stream_name": name,
                            "station_id": stationID,
                            "alertValue": alertValue,
                            "alertTime": alertTime,
                            "alertType": alertType,
                            "x": xCoord,
                            "y": yCoord,
                            "weatherIconURL": weatherIconURL,
                            "temperature": temperature,
                            "responseDataInJson": responseDataInJson
                        };

                        showDetailedPageClicked(data);
                    }
                }
                onPressAndHold: {
                    removeItemButton.visible = true;
                }
            }

            Rectangle {
                id: riverReachComponentTopRect
                width: parent.width
                height: 50 * app.scaleFactor
                anchors {
                    top: parent.top
                }
                color: "transparent"

                Rectangle {
                    id: riverReachInfoLeftWrapper
                    width: parent.width - weatherInfoRect.width
                    height: parent.height
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                    color: "transparent"

                    Rectangle {
                        id: riverReachInfoLeftTopWrapper
                        width: parent.width
                        height: parent.height * 0.45
                        anchors {
                            left: parent.left
                            top: parent.top
                            topMargin: 5 * app.scaleFactor
                        }
                        color: "transparent"

                        Text {
                            id: riverTrendIconText
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            color: appUtilityFunctions.getColorByAnomaly(anomaly)
                            font.pixelSize: (appUtilityFunctions.getAnomalyIcon(anomaly) === 'fa_circle') ? appConfigData.fontSize12: appConfigData.fontSize24
                            font.family: awesome.family
                            text: awesome.icons[appUtilityFunctions.getAnomalyIcon(anomaly)]
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter

                            anchors {
                                left: parent.left
                                leftMargin: appConfigData.itemOverviewPageRiverReachNameLeftMargin
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            id: riverReachName
                            text: name
                            color: appConfigData.themeColorDarkGray
                            font.pixelSize: appConfigData.fontSize16
                            font.family: app.fontSourceSansProReg.name
                            anchors.verticalCenter: parent.verticalCenter
                            wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                            anchors {
                                left: riverTrendIconText.right
                                leftMargin: appConfigData.itemOverviewPageRiverReachNameLeftMargin
                                verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Rectangle {
                        id: riverReachInfoLeftBottomWrapper
                        width: parent.width
                        height: parent.height / 2
                        anchors {
                            left: parent.left
                            bottom: parent.bottom
                        }
                        color: "transparent"

                        Text {
                            id: qOutText
                            //                            width: parent.width
                            text: appUtilityFunctions.numberWithCommas(qOut) + " cfs"
                            color: appUtilityFunctions.getColorByAnomaly(anomaly)
                            font.pixelSize: appConfigData.fontSize10
                            font.family: app.fontSourceSansProReg.name
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            //                            wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                            anchors {
                                left: parent.left
                                leftMargin: riverReachInfoTextMargin * app.scaleFactor
                            }
                        }

                        Rectangle {
                            id: riverReachInfoLeftBottomWrapperDivider
                            width: 1 * app.scaleFactor
                            height: parent.height * 0.6
                            anchors {
                                left: qOutText.right
                                leftMargin: 10 * app.scaleFactor
                                verticalCenter: parent.verticalCenter
                            }
                            color: appConfigData.themeColorLightestGray
                        }

                        Text {
                            id: anomalyText
                            text: appUtilityFunctions.getAnomalyLabel(anomaly) + "  (" + appUtilityFunctions.numberWithCommas(qDiffPct) + "%)"
                            color: appUtilityFunctions.getColorByAnomaly(anomaly)
                            font.pixelSize: appConfigData.fontSize10
                            font.family: app.fontSourceSansProReg.name
                            anchors.verticalCenter: parent.verticalCenter
                            wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                            anchors {
                                left: riverReachInfoLeftBottomWrapperDivider.right
                                leftMargin: 10 * app.scaleFactor
                            }
                        }
                    }
                }

                Rectangle {
                    id: weatherInfoRect
                    height: parent.height
                    width: 50 * app.scaleFactor
                    anchors {
                        right: parent.right
                        //                        rightMargin: 5 * app.scaleFactor
                        top: parent.top
                    }
                    color: "transparent"

                    Image {
                        id: weatherIcon
                        width: height
                        height: parent.height
                        anchors.centerIn: parent
                        source: weatherIconURL
                    }

                    Rectangle {
                        height: 20 * app.scaleFactor
                        width: parent.width
                        anchors {
                            left: parent.left
                            bottom: parent.bottom
                        }
                        color: appConfigData.themeColorDarkestGray
                        opacity: (temperature !== "") ? 0.7 : 0

                        Text {
                            text: temperature + "°"
                            color: "#fff"
                            font.pixelSize: appConfigData.fontSize12
                            font.family: app.fontSourceSansProReg.name

                            anchors {
                                centerIn: parent
                            }
                        }
                    }
                }

                // remove button
                Rectangle {
                    id: removeItemButton
                    width: appConfigData.defaultAppBtnHeight
                    height: parent.height
                    color: "red"
                    visible: false
                    //                    x: parent.width

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                    }

                    Text {
                        id: removeItemButtonTextIcon
                        text: awesome.icons.fa_trash_o
                        color: "white"
                        font.pixelSize: appConfigData.fontSize18
                        font.family: awesome.family
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                        anchors {
                            centerIn: parent
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            localStorage.remove(tableName, stationID);
                            localStorage.remove(app.tableNameForAlerts, stationID);
                            jsonFileManager.removeFeature(stationID);
                            _root.show();
                        }
                    }
                }
            }


            Rectangle {
                id: riverReachComponentBottomRect
                width: parent.width
                height: (alertValue !== "0") ? 20 * app.scaleFactor : 0 * app.scaleFactor
                anchors {
                    bottom: parent.bottom
                }
                color: appConfigData.themeColorGray
                visible: (alertValue !== "0") ? true : false

                Text {
                    id: riverReachComponentBottomRectIcon
                    text: (alertValue !== "0") ? awesome.icons.fa_exclamation_circle : ""
                    color: "white"
                    font.pixelSize: appConfigData.fontSize11
                    font.family: awesome.family
                    anchors.verticalCenter: parent.verticalCenter
                    wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                    anchors {
                        left: parent.left
                        leftMargin: 5 * app.scaleFactor
                    }
                }

                Text {
                    text: (alertValue !== "0") ? name + " " + alertType + " " + appUtilityFunctions.numberWithCommas(alertValue) + " cfs" : ""
                    color: "white"
                    font.pixelSize: appConfigData.fontSize10
                    font.family: app.fontSourceSansProReg.name
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    width: 250 * app.scaleFactor
                    //                    wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                    anchors {
                        left: riverReachComponentBottomRectIcon.right
                        leftMargin: 5 * app.scaleFactor
                    }
                }

                Text {
                    text: (alertValue !== "0") ? "in " + appUtilityFunctions.formatAlertTime(alertTime) : ""
                    color: "white"
                    font.pixelSize: appConfigData.fontSize10
                    font.family: app.fontSourceSansProReg.name
                    anchors.verticalCenter: parent.verticalCenter
                    wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                    anchors {
                        right: parent.right
                        rightMargin: riverReachInfoTextMargin * app.scaleFactor
                    }
                }
            }
        }

    } // end of riverReachesDelegate

    WebMap {
        id: map
        anchors {
            left: parent.left
            right: parent.right
            top: topNavBar.bottom
            bottom: bottomNavBar.top
        }

        visible: false
        esriLogoVisible: false
        webMapId: "52b357c2d4334d74bba090d312a5c1ff"
        wrapAroundEnabled: false
        rotationByPinchingEnabled: false
        magnifierOnPressAndHoldEnabled: false
        mapPanningByMagnifierEnabled: false
        zoomByPinchingEnabled: true

        positionDisplay {

            id: positionDisplay
            zoomScale: 900000
            mode: Enums.AutoPanModeDefault

            positionSource: PositionSource {
                id: positionSource
            }
        }

        ZoomButtons {
            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: 10
            }
        }

        onMouseClicked: {
            identifyFeatures(mouse.mapPoint, 50);
        }

        onStatusChanged: {
            if(status === Enums.MapStatusReady) {
                console.log("Map is Ready!");
                map.addLayer(riverReachLocationGraphicLayer);

                //                zoomToLayerExtent(riverReachLocationGraphicLayer);

                //                zoomToMapLayer();
            }
        }
    }

    GraphicsLayer {
        id: riverReachLocationGraphicLayer
        renderer: uvr
    }

    Graphic {
        id: riverReachLocationGraphic
    }

    UniqueValueRenderer {
        id: uvr
        attributeNames: ["anomaly"]
        defaultSymbol: SimpleMarkerSymbol {
            color: "grey"
            size: 10
        }
        Component.onCompleted: {
            addValue(uvi1);
            addValue(uvi2);
            addValue(uvi3);
            addValue(uvi4);
            addValue(uvi5);
        }
    }

    UniqueValueInfo {
        id: uvi1
        value: ["1"]
        symbol: PictureMarkerSymbol {
            image: "assets/images/anormally-1.png"
            width: 12
            height: 12
        }
    }

    UniqueValueInfo {
        id: uvi2
        value: ["2"]
        symbol: PictureMarkerSymbol {
            image: "assets/images/anormally-2.png"
            width: 12
            height: 12
        }
    }

    UniqueValueInfo {
        id: uvi3
        value: ["3"]
        symbol: SimpleMarkerSymbol {
            color: "#909090"
            size: 12
        }
    }

    UniqueValueInfo {
        id: uvi4
        value: ["4"]
        symbol: PictureMarkerSymbol {
            image: "assets/images/anormally-4.png"
            width: 12
            height: 12
        }
    }

    UniqueValueInfo {
        id: uvi5
        value: ["5"]
        symbol: PictureMarkerSymbol {
            image: "assets/images/anormally-5.png"
            width: 12
            height: 12
        }
    }

    function populatePoint(x, y, station_id, name, anomaly, alertValue, alertTime, alertType){
        var riverLocationGeom = ArcGISRuntime.createObject("Point", {x: parseFloat(x), y: parseFloat(y)});
        riverLocationGeom.spatialReference = sr3857;

        var projPoint = riverLocationGeom.project(sr4326);

        var cloneOfRiverGraphic = riverReachLocationGraphic.clone();
        cloneOfRiverGraphic.geometry = riverLocationGeom;
        cloneOfRiverGraphic.attributes = {
            "station_id": station_id,
            "name": name,
            "anomaly": anomaly,
            "alertValue": alertValue,
            "alertTime": alertTime,
            "alertType": alertType,
            "x": x,
            "y": y
        };

        riverReachLocationGraphicLayer.addGraphic(cloneOfRiverGraphic);

        fetchWeatherData(station_id, projPoint.x, projPoint.y);
    }

    function fetchWeatherData(stationID, lon, lat){

        getWeatherData({"lat": lat, "lon": lon}, function(result){
            for(var i = 0; i < riverReachesModel.count; i++) {
                if(riverReachesModel.get(i).stationID === stationID){
                    riverReachesModel.get(i).temperature = result.data.temperature[0];
                    riverReachesModel.get(i).weatherIconURL = result.data.iconLink[0];
                    break;
                }
            }
        });
    }

    function identifyFeatures(mapPoint, toleranceInPixel){

        var queryExtent = pointToExtent(mapPoint, toleranceInPixel);

        for(var i = 0, len = riverReachLocationGraphicLayer.graphics.length; i < len; i++){

            var pointExtent = riverReachLocationGraphicLayer.graphics[i].geometry.queryEnvelope();

            var isIntersecting = queryExtent.isIntersecting(pointExtent);

            if(isIntersecting){

                for(var k = 0; k < riverReachesModel.count; k++) {
                    if(riverReachesModel.get(k).stationID === riverReachLocationGraphicLayer.graphics[i].attributes.station_id){

                        var data = {
                            "stream_name": riverReachesModel.get(k).name,
                            "station_id": riverReachesModel.get(k).stationID,
                            "alertValue": riverReachesModel.get(k).alertValue,
                            "alertTime": riverReachesModel.get(k).alertTime,
                            "alertType": riverReachesModel.get(k).alertType,
                            "x": riverReachesModel.get(k).xCoord,
                            "y": riverReachesModel.get(k).yCoord,
                            "weatherIconURL": riverReachesModel.get(k).weatherIconURL,
                            "temperature": riverReachesModel.get(k).temperature,
                            "responseDataInJson": riverReachesModel.get(k).responseDataInJson
                        };

                        showDetailedPageClicked(data);

                        break;
                    }
                }

                break;
            }
        }

    }

    function pointToExtent(mapPoint, toleranceInPixel){

        var pixelWidth = map.extent.width / map.width;

        var toleraceInMapCoords = toleranceInPixel * pixelWidth;

        var computedExtent = ArcGISRuntime.createObject("Envelope", {
                                                            xMin: mapPoint.x - toleraceInMapCoords,
                                                            yMin: mapPoint.y - toleraceInMapCoords,
                                                            xMax: mapPoint.x + toleraceInMapCoords,
                                                            yMax: mapPoint.y + toleraceInMapCoords
                                                        });

        return computedExtent;
    }

    function zoomToLayerExtent(layer){

        var graphics = layer.graphics;

        var mergedEnvelope;

        var layerExtent;

        if(graphics.length > 1) {

            for (var i = 0, len = graphics.length; i < len; i++){

                var geom = graphics[i].geometry;

                var envelope = geom.queryEnvelope();

                if(!mergedEnvelope){
                    mergedEnvelope = envelope;
                } else {
                    mergedEnvelope = mergedEnvelope.mergeEnvelope(envelope);
                }
            }

            layerExtent = mergedEnvelope.scale(1.8);

        } else {
            layerExtent = ArcGISRuntime.createObject("Envelope", {
                                                         xMin:  -14353758.387036715,
                                                         yMin:  959712.489412366,
                                                         xMax:  -7015193.075259449,
                                                         yMax:  8084161.313429447,
                                                     });
        }

        map.extent = layerExtent;
    }

    function getWeatherData(data, callback) {
        var xmlhttp = new XMLHttpRequest();
        var url = "http://forecast.weather.gov/MapClick.php?lat=" + data.lat + "&lon=" + data.lon + "&FcstType=json";

        xmlhttp.onreadystatechange = function() {
            if (xmlhttp.readyState === XMLHttpRequest.DONE && xmlhttp.status == 200) {
                callback(JSON.parse(xmlhttp.responseText));
            } else {
                console.log("No weather forecast found!!!")
            }
        }
        xmlhttp.open("GET", url, true);
        xmlhttp.send();
    }

}
