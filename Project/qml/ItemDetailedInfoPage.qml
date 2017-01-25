import QtQuick 2.5
import QtGraphicalEffects 1.0

import "Components" as Components

Item {
    id: _root
    anchors.fill: parent
    visible: false

    property var selectedItemData
    property string itemStationID: ""
    property string itemName: ""
    property string responseDataInJSON: ""

    property string temperature: ""
    property string weatherIconUrlStr: ""

    property real qOutValue: 0
    property real qDiffValue: 0

    property bool isAddingNewItem: false

    signal closeButtonClicked()
    signal backToAddItemPage()
    signal backToOverviewPage()
    signal editAlertButtonClicked(var itemData)
    signal addAlertButtonClicked(var itemData)

    ListModel {
        id: riverReachDetailedInfoModel
    }

    ListModel {
        id: alertsModel
    }

    Rectangle {
        width: parent.width
        height: parent.height
        color: "#fff"
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
        z: 100

        Text {
            id: titleText
            anchors.centerIn: parent
            text: ""
            color: appConfigData.themeColorGreen
            font.pixelSize: appConfigData.navBarTitleTextFont
            font.family: app.fontSourceSansProReg.name
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 1
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            width: 200 * app.scaleFactor
        }

        Rectangle {
            id: closeItemDetailedInfoPageButton
            width: appConfigData.defaultAppBtnHeight
            height: parent.height
            color: "transparent"
            anchors {
                left: parent.left
                leftMargin: appConfigData.navBarClosePageBtnLeftMargin
                verticalCenter: parent.verticalCenter
            }

            Text {
                id: closeAddItemPageButtonIcon
                anchors.centerIn: parent
                color: appConfigData.themeColorGreen
                font.pixelSize: appConfigData.fontSize20
                font.family: awesome.family
                text: awesome.loaded ? awesome.icons.fa_chevron_left : ""
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(isAddingNewItem){

                        alert.titleText = "You have unsaved item"
                        alert.descriptionText = "Do you want to leave this page and discard the unsaved river reach or stay on this page?"

                        alert.visible=true;
                        alert.open();

                    } else {

                        if(!alertsModel.count){
                            openAlertDialog();
                            return;
                        }

                        closeButtonClicked();

                        _root.hide();
                    }
                }
            }
        }
        //end of close button

        Rectangle {
            id: weatherInfoRect
            height: parent.height
            width: 50 * app.scaleFactor
            anchors {
                right: parent.right
                top: parent.top
            }
            color: "transparent"
            visible: (temperatureText.text === "") ? false : true

            Image {
                id: weatherIcon
                width: height
                height: parent.height
                anchors.centerIn: parent
                source: weatherIconUrlStr
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
                    id: temperatureText
                    text: temperature
                    color: "#fff"
                    font.pixelSize: appConfigData.fontSize12
                    font.family: app.fontSourceSansProReg.name

                    anchors {
                        centerIn: parent
                    }
                }
            }
        }

    }
    //End of Top Nav Bar

    Rectangle {
        id: summaryCardWrapper
        width: parent.width * 0.95
        height: 50 * app.scaleFactor
        color: "transparent"

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: topNavBar.bottom
            topMargin: 10 * app.scaleFactor
        }

        RiverInfoSummaryCard {
            id: riverInfoSummaryCard
            hideCameraIcon: isAddingNewItem
            stationID: itemStationID
        }
    }

    Rectangle {
        id: topButtonsWrapper
        width: parent.width * 0.95
        height: 40 * app.scaleFactor
        color: "transparent"

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: summaryCardWrapper.bottom
            topMargin: 5 * app.scaleFactor
        }

        Rectangle {
            width: parent.width * 0.5
            height: parent.height
            color: appConfigData.themeColorLightGray

            anchors {
                left: parent.left
            }

            Text {
                id: topLeftButtonText
                anchors.centerIn: parent
                text: "Alerts"
                color: (alertsWrapper.visible) ? appConfigData.themeColorGreen : appConfigData.themeColorLighterGray
                font.pixelSize: appConfigData.fontSize18
                font.family: app.fontSourceSansProReg.name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                id: topLeftButtonUnderline
                width: parent.width
                height: 3 * app.scaleFactor
                color: (alertsWrapper.visible) ? appConfigData.themeColorGreen : "transparent"

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
            }

            Rectangle {
                width: 1 * app.scaleFactor
                height: parent.height
                color: appConfigData.themeColorLightestGray

                anchors {
                    right: parent.right
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    toggleConditionWrapper(false);
                }
            }
        }

        Rectangle {
            width: parent.width * 0.5
            height: parent.height
            color: appConfigData.themeColorLightGray

            anchors {
                right: parent.right
            }

            Text {
                id: topRightButtonText
                anchors.centerIn: parent
                text: "Conditions"
                color: (conditionsWrapper.visible) ? appConfigData.themeColorGreen : appConfigData.themeColorLighterGray
                font.pixelSize: appConfigData.fontSize18
                font.family: app.fontSourceSansProReg.name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                id: topRightButtonUnderline
                width: parent.width
                height: 3 * app.scaleFactor
                color: (conditionsWrapper.visible) ? appConfigData.themeColorGreen : "transparent"

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    toggleConditionWrapper(true);
                }
            }
        }

    }
    //end of topButtonsWrapper

    Rectangle {
        id: alertsWrapper
        width: parent.width * 0.95
        visible: !conditionsWrapper.visible

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: topButtonsWrapper.bottom
            bottom: saveItemBtn.top
            bottomMargin: 10 * app.scaleFactor
        }

        Rectangle {
            id: alertsTopButtonsWrapper
            width: parent.width
            height: 30 * app.scaleFactor
            anchors {
                top: parent.top
                topMargin: 1 * app.scaleFactor
            }

            Text {
                id: alertCountText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                text: "2 Alerts Set-Up"
                color: appConfigData.themeColorLighterGray
                font.pixelSize: appConfigData.fontSize10
                font.family: app.fontSourceSansProReg.name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }
        }
        // ends of alerts button wrapper

        Rectangle {
            id: helpMessageRect
            width: parent.width
            height: 100 * app.scaleFactor
            anchors{
                horizontalCenter: parent.horizontalCenter
                top: alertsTopButtonsWrapper.bottom
                topMargin: 5 * app.scaleFactor
            }
            visible: (alertsModel.count > 0) ? false : true
            color: appConfigData.themeColorLightGray

            Text {
                anchors {
                    centerIn: parent
                }
                width: parent.width * 0.7
                text: "No alerts set up yet \nwould you like to create one?"
                color: appConfigData.themeColorGray
                font.pixelSize: appConfigData.fontSize12
                font.family: app.fontSourceSansProReg.name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }
        }

        ListView {
            id: listAlerts
            width: parent.width
            height: alertsModel.count * (80 * app.scaleFactor)
            anchors {
                top: alertsTopButtonsWrapper.bottom
                topMargin: 5 * app.scaleFactor
                horizontalCenter: parent.horizontalCenter
            }
            orientation: ListView.Vertical
            clip: true
            delegate: alertsDelegate
            model: alertsModel
            spacing: 8 * app.scaleFactor

        }
        // end of listAlerts

        Component {
            id: alertsDelegate

            Rectangle {
                id: alertsComponent
                width: listAlerts.width
                height: 70 * app.scaleFactor
                color: appConfigData.themeColorLightGray

                Rectangle {
                    id: alertsComponentTopRect
                    width: parent.width
                    height: parent.height * 0.65
                    anchors {
                        top: parent.top
                    }
                    color: "transparent"

                    Rectangle {
                        id: alertsComponentTopRectLeft
                        width: parent.width * 0.8
                        height: parent.height
                        anchors {
                            left: parent.left
                            top: parent.top
                        }
                        color: "transparent"

                        Text {
                            text: itemName + "\n" + type + "s" + " to " + appUtilityFunctions.numberWithCommas(value) + " cfs"
                            color: appConfigData.themeColorDarkGray
                            font.pixelSize: appConfigData.fontSize12
                            font.family: app.fontSourceSansProReg.name
                            anchors.verticalCenter: parent.verticalCenter
                            wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                            anchors {
                                left: parent.left
                                leftMargin: 5 * app.scaleFactor
                                verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Rectangle {
                        id: alertsComponentTopRectRight
                        width: parent.width * 0.2
                        height: parent.height
                        anchors {
                            right: parent.right
                        }
                        color: "transparent"

                        Text {
                            id: alertsComponentTopRectIcon
                            anchors {
                                right: parent.right
                                rightMargin: 10 * app.scaleFactor
                                verticalCenter: parent.verticalCenter
                            }
                            color: appConfigData.themeColorGreen
                            font.pixelSize: appConfigData.fontSize16
                            font.family: awesome.family
                            text: awesome.loaded ? awesome.icons.fa_pencil: ""
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {

                                var data = {
                                    "index": index,
                                    "oid": oid,
                                    "stationID": itemStationID,
                                    "riverName": itemName,
                                    "alertValue": value,
                                    "status": status,
                                    "qOut": qOutValue,
                                    "qDiff": qDiffValue,
                                    "type": "edit",
                                    "alertType": type
                                }
                                editAlertButtonClicked(data);
                            }
                        }
                    }
                }

                Rectangle {
                    id: alertsComponentBottomRect
                    width: parent.width
                    height: parent.height * 0.35
                    anchors {
                        bottom: parent.bottom
                    }
                    color: appConfigData.themeColorGray

                    Text {
                        id: alertsComponentBottomRectIcon
                        anchors {
                            left: parent.left
                            leftMargin: 5 * app.scaleFactor
                            verticalCenter: parent.verticalCenter
                        }
                        color: "white"
                        font.pixelSize: appConfigData.fontSize12
                        font.family: awesome.family
                        text: (alertTime !== 999) ? awesome.icons.fa_exclamation_circle : ""
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        id: alertsComponentBottomRectText
                        text: (alertTime !== 999) ? " in " + appUtilityFunctions.formatAlertTime(alertTime): "No recent activity"
                        color: "#fff"
                        font.pixelSize: appConfigData.fontSize10
                        font.family: app.fontSourceSansProReg.name
                        anchors {
                            left: alertsComponentBottomRectIcon.right
                            leftMargin: 5 * app.scaleFactor
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }

        Rectangle {
            id: addAlertButtonWrapper
            width: parent.width * 0.5
            height: 40 * app.scaleFactor
            anchors {
                top: (listAlerts.count > 0) ? listAlerts.bottom: helpMessageRect.bottom
                right: parent.right
            }
            visible: (alertsModel.count === 4) ? false : true

            Text {
                color: appConfigData.themeColorGreen
                font.pixelSize: appConfigData.fontSize14
                font.family: awesome.family
                text: awesome.loaded ? awesome.icons.fa_plus + "  Add an Alert" : ""
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                anchors {
                    right: parent.right
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var data = {
                        "stationID": itemStationID,
                        "riverName": itemName,
                        "alertValue": qOutValue,
                        "status": "active",
                        "qOut": qOutValue,
                        "qDiff": qDiffValue,
                        "type": "add",
                        "alertType": "increase"
                    };
                    addAlertButtonClicked(data);
                }
            }
        }
        // end of addAlertButtonWrapper

    }
    // end of alertsWrapper

    Rectangle {
        id: conditionsWrapper
        width: parent.width * 0.95
        visible: true

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: topButtonsWrapper.bottom
            topMargin: 10 * app.scaleFactor
            bottom: saveItemBtn.top
            bottomMargin: 10 * app.scaleFactor
        }

        Rectangle {
            id: conditionChartWrapper
            width: parent.width
            height: 100 * app.scaleFactor

            anchors {
                top: parent.top
                left: parent.left
            }

            Rectangle {
                id: chartItemContainer
                width: parent.width * 0.9
                height: parent.height * 0.9
//                anchors.top: riverPreviewFooterPanelLeftTop.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    height: parent.height
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter

                    RiverInfoChart {
                        id: riverInfoChart
                        container: chartItemContainer
                    }
                }
            }
        }
        // end of conditionChartWrapper

        ListView {
            id: listConditions
            width: parent.width * 0.8
            anchors {
                top: conditionChartWrapper.bottom
                topMargin: 10 * app.scaleFactor
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            orientation: ListView.Vertical
            clip: true
            delegate: conditionsDelegate
            model: riverReachDetailedInfoModel
            spacing: 0 * app.scaleFactor
        }
        // end of listConditions

        Component {
            id: conditionsDelegate

            Rectangle {
                id: conditionsComponent
                width: listConditions.width
                height: 25 * app.scaleFactor
                color: (index % 2) ? appConfigData.themeColorLightGray : "white"

                Rectangle {
                    id: conditionsComponentLeftRect
                    width: parent.width * 0.35
                    height: parent.height
                    anchors.left: parent.left

                    color: "transparent"

                    Text {
                        text: formatedTimeData
                        color: appConfigData.themeColorDarkGray
                        font.pixelSize: appConfigData.fontSize8
                        font.family: app.fontSourceSansProReg.name
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                        anchors {
                            right: parent.right
                            rightMargin: 10 * app.scaleFactor
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Rectangle {
                    width: parent.width * 0.6
                    height: parent.height
                    anchors.left: conditionsComponentLeftRect.right
                    color: "transparent"

                    Text {
                        text: appUtilityFunctions.numberWithCommas(qout) + " cfs  (" + qDiffPct + "%)"
                        color: (modelType == "shortTerm") ? appUtilityFunctions.getColorByAnomaly(anomaly) : appConfigData.riverChartItemOver14HoursColor
                        font.pixelSize: appConfigData.fontSize10
                        font.family: app.fontSourceSansProReg.name
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                        anchors {
                            left: parent.left
                            leftMargin: 10 * app.scaleFactor
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
    // end of conditionsWrapper

    RectangularGlow {
        id: saveItemBtnGlowEffect
        anchors.fill: saveItemBtn
        glowRadius: 10
        spread: 0
        color: appConfigData.welcomeDialogGlowEffectColor
        cornerRadius: 0
    }

    Rectangle {
        id: saveItemBtn
        width: parent.width
        height: 65 * app.scaleFactor
        color: appConfigData.themeColorGreen

        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        Text {
            id: saveItemBtnIcon
            text: isAddingNewItem ? "Save" : "Go to My Rivers"
            color: "white"
            font.pixelSize: appConfigData.fontSize20
            font.family: app.fontSourceSansProReg.name
            anchors.centerIn: parent
            wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {

                if(isAddingNewItem && alertsModel.count){
                    localStorage.insert(app.tableName, selectedItemData);
                } else if(isAddingNewItem && !alertsModel.count){
                    openAlertDialog();
                    return false;
                }

                if(!isAddingNewItem && !alertsModel.count){
                    openAlertDialog();
                    return false;
                }

                _root.hide();

                closeButtonClicked();
            }
        }
    }

    Components.AlertDialog{
        id: alert
        visible: false
        z: parent.z+100
        titleText: "You have unsaved item"
        descriptionText: "Do you want to leave this page and discard the unsaved river reach or stay on this page?"

        onClosed: {
            alert.close();
        }

        onDiscard: {
            alert.close();

            if(alertsModel.count){
                localStorage.remove(app.tableNameForAlerts, itemStationID);
            }

            localStorage.remove(app.tableName, itemStationID);

            if(isAddingNewItem){
                backToAddItemPage();
            } else {
                backToOverviewPage();
            }

            _root.hide();
        }

        onTransitionOutCompleted: {
            alert.visible=false
        }
    }

    function show(itemData){

        resetPage();

        if(itemData){
            selectedItemData = itemData;

            itemStationID = (itemData["station_id"]) ? itemData["station_id"] : itemStationID;
            itemName = (itemData["stream_name"]) ? itemData["stream_name"] : itemName;

            responseDataInJSON = (itemData["responseDataInJson"]) ? itemData["responseDataInJson"] : responseDataInJSON;

            temperature = (itemData["temperature"]) ? itemData["temperature"]  + "°" : temperature;
            weatherIconUrlStr = (itemData["weatherIconURL"]) ? itemData["weatherIconURL"] : weatherIconUrlStr;

            if(itemData["isAddingNewItem"]){
                isAddingNewItem = true;
                temperature = "";
                getRiverReachDataRequest.getData({"stationID": itemStationID}, getRiverDataOnSuccessHandler);
                toggleConditionWrapper(false);
            } else {
                isAddingNewItem = false;
                getRiverDataOnSuccessHandler(JSON.parse(responseDataInJSON));
                toggleConditionWrapper(true);
            }

        } else {
            getRiverDataOnSuccessHandler(JSON.parse(responseDataInJSON));
        }

        if(itemStationID === "" || itemName === ""){
            console.log("stationID and riverName is required to initialize the detailed page");
            return false;
        }

        temperatureText.text = temperature;
        weatherIcon.source = weatherIconUrlStr;

        itemStationID = itemStationID.toString();

        updateNavBarTitle(itemName);

        _root.visible = true;

    }

    function hide(){

        _root.visible = false;

        resetPage();
    }

    function resetWeatheInfo(){
        temperatureText.text = "";
        weatherIcon.source = "";

    }

    function openAlertDialog(){
        alert.titleText = "You have no alert set up";
        alert.descriptionText = "Do you want to leave this page and remove this river reach from the list or stay on this page?";

        alert.visible=true;
        alert.open();
    }

    function getAlertsDataFromDB(stationID, riverReachDataRequestResponse){

        var result = localStorage.queryAllValuesByKey(app.tableNameForAlerts, stationID);
        var numItems = result.rows.length;

        if(!numItems){
            console.log("no alerts found for river reach: " + stationID);
        } else {

            for (var i=0; i < numItems; i++) {

                var alertValue = result.rows.item(i).value;
                var alertType = result.rows.item(i).alert_type;
                var alertStatus = result.rows.item(i).alert_status;
                var alertTime = 999;
                var alertInfo;

                if(alertStatus === "active"){
                    //function to check if there will be alert in next 10 days
                    alertInfo = getAlertTime(alertValue, alertType, riverReachDataRequestResponse);
                    alertTime = alertInfo.alertTime;
                }

                alertsModel.append({
                    "index": i + 1,
                    "oid": result.rows.item(i).id,
                    "value": alertValue,
                    "status": alertStatus,
                    "type": alertType,
                    "alertTime": alertTime
                });

//                riverInfoChart.riverReachPreviewChartModel.append(alertInfo);
            }
        }

        alertCountText.text = numItems + " Alerts Set-Up:";
    }

    function getAlertTime(alertValue, alertType, riverReachDataRequestResponse){

        var previousQout = 0;
        var alertTime = 0;

        var alertInfo;
        var alertAnomaly;
        var alertQOut;
        var alertQDiff;
        var alertQDiffPct;
        var alertIndex;

        for(var i = 0; i < parseInt(appConfigData.numOfItemsInShortTerm); i++) {

            var qout = riverReachDataRequestResponse[i].attributes[appConfigData.qOutFieldName];
            var timeValue = riverReachDataRequestResponse[i].attributes[appConfigData.timeValueFieldName];
            var qDiff = riverReachDataRequestResponse[i].attributes[appConfigData.qDiffFieldName];
            var anomay = riverReachDataRequestResponse[i].attributes[appConfigData.anomalyFieldName];
            var qDiffPct = qDiff / (qout - qDiff);

            if(previousQout){

                alertAnomaly = anomay;
                alertQOut = qout;
                alertQDiff = qDiff;
                alertQDiffPct = qDiffPct;
                alertIndex = i;

                if(alertType === "increase" && qout > previousQout && qout >= parseFloat(alertValue) && parseFloat(alertValue) > previousQout){
                    alertTime = timeValue;
                    break;
                }

                if(alertType === "decrease" && previousQout > qout && parseFloat(alertValue) >= qout && parseFloat(alertValue) < previousQout){
                    alertTime = timeValue;
                    break;
                }
            }

            previousQout = qout;
        }

        alertTime = (alertTime !== 0) ? Math.round(itemsOverviewPage.getHourDiff(alertTime)): 999

        alertInfo = {
            "alertTime": alertTime,
            "anomaly": alertAnomaly,
            "qout": alertQOut.toString(),
            "qdiff": alertQDiff.toString(),
            "qdiffpct": alertQDiffPct.toFixed(3),
            "index": alertIndex,
            "isActiveAlertIndicator": true
        };

        return alertInfo;
    }

    function updateSummaryCardAlertData(response){

        var alertData = itemsOverviewPage.getMostRecentAlert(itemStationID, response);

        updateSummaryCardSize(alertData.alertValue);

        populateSummaryCardData([
            {"key": "streamName", "value": itemName},
            {"key": "alertValue", "value": alertData.alertValue},
            {"key": "alertTime", "value": alertData.alertTime},
            {"key": "alertType", "value": alertData.alertType},
        ]);
    }

    function updateSummaryCardSize(alertValue){
        if(alertValue !== "0"){
            summaryCardWrapper.height = 90 * app.scaleFactor;
        } else {
            summaryCardWrapper.height = 70 * app.scaleFactor;
        }
    }

    function populateSummaryCardData(data){
        for (var i = 0, len = data.length; i < len; i++) {
            riverInfoSummaryCard[data[i].key] = data[i].value;
        }
    }

    function updateNavBarTitle(value){
        titleText.text = value;
    }

    function resetPage(){

        qOutValue = 0;
        qDiffValue = 0;

        alertsModel.clear();
        riverReachDetailedInfoModel.clear();

        resetWeatheInfo();
    }

    function getRiverDataOnSuccessHandler(result) {

        var startTimeValue;

        var response = JSON.parse(result.responseText);

        response = itemsOverviewPage.arrangeRiverDataByTime(response.features);

        responseDataInJSON = JSON.stringify(result);

        for(var i = 0; i < response.length; i++) {

            var formatedTimeData;
            var qDiff = response[i].attributes[appConfigData.qDiffFieldName];
            var qOut = response[i].attributes[appConfigData.qOutFieldName];
            var qDiffPct =  (( qDiff / ( qOut - qDiff)) * 100).toFixed(1);
            var anomaly = response[i].attributes[appConfigData.anomalyFieldName];
            var timeValue = response[i].attributes[appConfigData.timeValueFieldName];

            if(i === 0){
                startTimeValue = timeValue;

                formatedTimeData = appUtilityFunctions.formatTimeData(timeValue);

                qOutValue = qOut;
                qDiffValue = qDiff;

                var summaryData = [
                    {"key": "qOut", "value": qOut.toFixed(1)},
                    {"key": "anomaly", "value": anomaly},
                    {"key": "qDiffPct", "value": qDiffPct},
                ];

                populateSummaryCardData(summaryData);

            } else {
                var hourDiff = appUtilityFunctions.getHourDiff(startTimeValue, timeValue);
                formatedTimeData = "+" + appUtilityFunctions.formatAlertTime(hourDiff);
            }

            riverReachDetailedInfoModel.append({
               "index": i + 1,
               "timevalue": timeValue,
               "anomaly": anomaly,
               "qout": qOut.toFixed(1),
               "qdiff": qDiff.toFixed(1),
               "qDiffPct": qDiffPct,
               "formatedTimeData": formatedTimeData,
               "modelType": (i < 15) ? "shortTerm" : "mediumTerm"
            });
        }

        riverInfoChart.createChart(response);

        updateSummaryCardAlertData(response);

        getAlertsDataFromDB(itemStationID, response);
    }

    function toggleConditionWrapper(visibleBool){
        conditionsWrapper.visible = visibleBool;
    }

}
