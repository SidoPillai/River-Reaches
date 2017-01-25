import QtQuick 2.5
import QtGraphicalEffects 1.0

Item {
    id: _root
    anchors.fill: parent
    visible: false

    property var selectedItemData
    property string alertStatus
    property string alertType: ""

    signal closeButtonClicked()
    signal saveItemButtonClicked(var itemData)

    function show(itemData){

        _root.resetHighlightLineColor();

        selectedItemData = itemData;

        alertStatus = selectedItemData["status"];

        alertType = selectedItemData["alertType"];

        updateDomElementsContent(selectedItemData);

        _root.visible = true;
    }

    function hide(){
        _root.resetPage();
        _root.visible = false;
    }

    function resetPage(){

    }

    function resetHighlightLineColor(){
        riverReachCurrentFlowHighlightLine.color = appConfigData.themeColorLightestGray;
        riverReachMonAvgHighlightLine.color = appConfigData.themeColorLightestGray;
    }

    function updateDomElementsContent(data){
        riverNameBannerText.text = data["riverName"];
        alertValueTextInput.text = parseFloat(data["alertValue"]).toFixed(1);

        if(data["type"] === "add"){
            riverReachCurrentFlowHighlightLine.color = appConfigData.themeColorGreen;
            titleText.text = "Add Alert";
        } else {
            titleText.text = "Edit Alert";
        }
    }

    function toggleAlertStatus(){
        if(alertStatus === 'active') {
            alertStatus = 'inactive';
        } else {
            alertStatus = 'active';
        }
    }

    function updateAddAlertDialogContent(textInputValue){

        var pctFromMonAvg = 0;
        var pctFromCurrentFlow = 0;

        var qOut = selectedItemData["qOut"];
        var qDiff = selectedItemData["qDiff"];
        var monAvg = qOut - qDiff;

        pctFromCurrentFlow = (textInputValue === "") ? 0 : (parseFloat(textInputValue) - qOut)/qOut;
        pctFromMonAvg =  (textInputValue === "") ? 0 : (parseFloat(textInputValue) - monAvg)/monAvg;

        riverReachCurrentFlowText.text = qOut.toFixed(1);

        editAlertDialogPctFromCurrentFlowText.text = getMathSymbol(pctFromCurrentFlow) + (Math.round((pctFromCurrentFlow * 100) * 10)/10).toString() +
                                                    "% from Current Flow";

        riverReachMonAvgText.text = monAvg.toFixed(1);

        editAlertDialogPctFromMonAvgText.text = getMathSymbol(pctFromMonAvg) + (Math.round((pctFromMonAvg * 100) * 10)/10).toString() +
                                                "% from Month Ave";

        if(textInputValue === ""){
            saveAlertBtn.color = appConfigData.themeColorGray
            saveAlertBtnIcon.opacity  = 0.2

            addAlertBtnWrapper.color = appConfigData.themeColorGray
            addAlertBtnIcon.opacity  = 0.2
        } else {
            saveAlertBtn.color = appConfigData.themeColorGreen
            saveAlertBtnIcon.opacity  = 1

            addAlertBtnWrapper.color = appConfigData.themeColorGreen
            addAlertBtnIcon.opacity  = 1
        }

    }

    function getMathSymbol(num){
        if(typeof num === "string"){
            num = parseFloat(num);
        }

        return (num > 0) ? "+" : "";
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
            text: "Edit Alert"
            color: appConfigData.themeColorGreen
            font.pixelSize: appConfigData.navBarTitleTextFont
            font.family: app.fontSourceSansProReg.name
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: closeAddItemPageButton
            width: appConfigData.navBarClosePageBtnWidth
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
                    hide();
                    closeButtonClicked();
                }
            }
        }
    }
    //end of topNavBar

    Rectangle {
        id: riverNameBanner
        width: parent.width
        height: 40 * app.scaleFactor
        color: appConfigData.themeColorGreen
        z: 100

        anchors {
            top: topNavBar.bottom
        }

        Text {
            id: riverNameBannerText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: appConfigData.navBarTitleTextFont
            font.family: app.fontSourceSansProReg.name
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }
    //end of riverNameBanner

    Rectangle {
        id: mainContainer
        width: parent.width
        anchors {
            top: riverNameBanner.bottom
            bottom: bottomBtnsWrapper.top
        }

        Rectangle {
            id: switchAlertTypeDialogWrapper
            height: parent.height * 0.3
            width: parent.width * 0.9
            color: appConfigData.themeColorLightGray

            anchors {
                top: parent.top
                topMargin: 10 * app.scaleFactor
                horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                height: parent.height * 0.7
                width: parent.width * 0.9
                color: "transparent"

                anchors {
                    centerIn: parent
                }

                Rectangle {
                    height: parent.height * 0.5
                    width: parent.width
                    color: "transparent"

                    anchors {
                        top: parent.top
                    }

                    Rectangle {
                        height: parent.height
                        width: parent.width * 0.3
                        color: "transparent"

                        anchors {
                            left: parent.left
                        }

                        Text {
                            anchors {
                                centerIn: parent
                            }
                            color: (alertType === "increase") ? appConfigData.themeColorGreen:  appConfigData.themeColorLighterGray
                            font.pixelSize: appConfigData.fontSize14
                            font.family: awesome.family
                            text: (alertType === "increase") ? awesome.icons.fa_check_circle_o: awesome.icons.fa_circle_o
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Rectangle {
                        height: parent.height
                        width: parent.width * 0.7
                        color: "transparent"

                        anchors {
                            right: parent.right
                        }

                        Text {
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            color: (alertType === "increase") ? appConfigData.themeColorGreen: appConfigData.themeColorLighterGray
                            font.pixelSize: appConfigData.fontSize14
                            font.family: awesome.family
                            text: awesome.loaded ? awesome.icons.fa_arrow_up + "  Increases to..." : ""
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            alertType = "increase";
                        }
                    }
                }

                Rectangle {
                    height: parent.height * 0.5
                    width: parent.width
                    color: "transparent"

                    anchors {
                        bottom: parent.bottom
                    }

                    Rectangle {
                        height: parent.height
                        width: parent.width  * 0.3
                        color: "transparent"

                        anchors {
                            left: parent.left
                        }

                        Text {
                            anchors {
                                centerIn: parent
                            }
                            color: (alertType === "decrease") ? appConfigData.themeColorGreen: appConfigData.themeColorLighterGray
                            font.pixelSize: appConfigData.fontSize14
                            font.family: awesome.family
                            text: (alertType === "decrease") ? awesome.icons.fa_check_circle_o: awesome.icons.fa_circle_o
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Rectangle {
                        height: parent.height
                        width: parent.width  * 0.7
                        color: "transparent"

                        anchors {
                            right: parent.right
                        }

                        Text {
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            color: (alertType === "decrease") ? appConfigData.themeColorGreen: appConfigData.themeColorLighterGray
                            font.pixelSize: appConfigData.fontSize14
                            font.family: awesome.family
                            text: awesome.loaded ? awesome.icons.fa_arrow_down + "  Decreases to..." : ""
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            alertType = "decrease";
                        }
                    }
                }
            }

            //left side border
            Rectangle {
                height: parent.height
                width: 5 * app.scaleFactor
                color: appConfigData.themeColorGreen

                anchors {
                    top: parent.top
                    left: parent.left
                }
            }
        }

        Rectangle {
            id: editAlertDialogWrapper
            height: parent.height * 0.45
            width: parent.width * 0.9
            color: appConfigData.themeColorLightGray

            anchors {
                top: switchAlertTypeDialogWrapper.bottom
                topMargin: 10 * app.scaleFactor
                horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                id: editAlertDialog
                width: parent.width * 0.9
                height: parent.height * 0.7
                anchors {
                    top: parent.top
                    topMargin: 10 * app.scaleFactor
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                color: "transparent"

                Rectangle {
                    width: parent.width * 0.65
                    height: parent.height
                    anchors {
                        left: parent.left
                    }
                    color: "transparent"

                    Rectangle {
                        height: alertValueTextInputWrapper.height + editAlertDialogPctFromMonAvgTextRect.height + editAlertDialogPctFromCurrentFlowTextRect.height + 10 * app.scaleFactor
                        width: parent.width
                        color: "transparent"
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            id: alertValueTextInputWrapper
                            width: parent.width * 0.6
                            height: 40 * app.scaleFactor
                            anchors {
                                left: parent.left
                                leftMargin: 5 * app.scaleFactor
                            }

                            TextInput {
                                id: alertValueTextInput
                                color: appConfigData.themeColorDarkerGray
                                font.pixelSize: appConfigData.fontSize16
                                width: parent.width * 0.9
                                focus: true
                                cursorVisible: true
                                clip: true

                                anchors {
                                    left: parent.left
                                    leftMargin: 5 * app.scaleFactor
                                    verticalCenter: parent.verticalCenter
                                }

                                onTextChanged: {
                                    updateAddAlertDialogContent(alertValueTextInput.text);
                                    resetHighlightLineColor();
                                }
                            }
                        }

                        Text {
                            id: riverPreviewFooterRiverNameText
                            text: "cfs"
                            anchors {
                                verticalCenter: alertValueTextInputWrapper.verticalCenter
                                left: alertValueTextInputWrapper.right
                                leftMargin: 5 * app.scaleFactor
                            }
                            font.family: app.fontSourceSansProReg.name
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            color: appConfigData.themeColorDarkestGray
                            font.pixelSize: appConfigData.fontSize14
                        }

                        Rectangle {
                            id: editAlertDialogPctFromMonAvgTextRect
                            width: parent.width * 0.9
                            height: 15 * app.scaleFactor
                            color: "transparent"
                            anchors {
                                left: parent.left
                                leftMargin: 5 * app.scaleFactor
                                top: alertValueTextInputWrapper.bottom
                                topMargin: 5 * app.scaleFactor
                            }

                            Text {
                                id: editAlertDialogPctFromMonAvgText
                                text: ""
                                width: parent.width
                                font.family: app.fontSourceSansProReg.name
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                color: appConfigData.themeColorLighterGray
                                font.pixelSize: appConfigData.fontSize10
                                maximumLineCount: 1
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignLeft
                            }
                        }

                        Rectangle {
                            id: editAlertDialogPctFromCurrentFlowTextRect
                            width: parent.width * 0.9
                            height: 15 * app.scaleFactor
                            color: "transparent"
                            anchors {
                                left: parent.left
                                leftMargin: 5 * app.scaleFactor
                                top: editAlertDialogPctFromMonAvgTextRect.bottom
                                topMargin: 5 * app.scaleFactor
                            }

                            Text {
                                id: editAlertDialogPctFromCurrentFlowText
                                text: ""
                                width: parent.width
                                font.family: app.fontSourceSansProReg.name
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                color: appConfigData.themeColorLighterGray
                                font.pixelSize: appConfigData.fontSize10
                                maximumLineCount: 1
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignLeft
                            }
                        }
                    }


                    //right side border
                    Rectangle {
                        height: parent.height * 0.8
                        width: 1 * app.scaleFactor
                        color: appConfigData.themeColorLightestGray

                        anchors {
                            right: parent.right
                            rightMargin: 5 * app.scaleFactor
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }
                //end of left rect

                Rectangle {
                    width: parent.width * 0.35
                    height: parent.height * 0.8
                    color: "transparent"
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: parent.width * 0.9
                        height: parent.height * 0.5
                        color: "transparent"
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            id: riverReachMonAvgText
                            text: ""
                            anchors {
                                top: parent.top
                                topMargin: parent.height * 0.15
                            }
                            width: parent.width
                            font.family: app.fontSourceSansProReg.name
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            color: appConfigData.themeColorDarkerGray
                            font.pixelSize: appConfigData.fontSize16
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignRight

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    alertValueTextInput.text = riverReachMonAvgText.text;

                                    riverReachCurrentFlowHighlightLine.color = appConfigData.themeColorLightestGray;
                                    riverReachMonAvgHighlightLine.color = appConfigData.themeColorGreen;
                                }
                            }
                        }

                        Text {
                            id: riverReachMonAvgLabel
                            text: "Month Avg"
                            anchors {
                                top: riverReachMonAvgText.bottom
                            }
                            width: parent.width
                            font.family: app.fontSourceSansProReg.name
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            color: appConfigData.themeColorLighterGray
                            font.pixelSize: appConfigData.fontSize11
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignRight

                        }

                        Rectangle {
                            id: riverReachMonAvgHighlightLine
                            height: riverReachMonAvgText.height + riverReachMonAvgLabel.height
                            width: 2 * app.scaleFactor
                            color: appConfigData.themeColorLightestGray

                            anchors {
                                top: riverReachMonAvgText.top
                                right: parent.right
                                rightMargin: -10 * app.scaleFactor
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width * 0.9
                        height: parent.height * 0.5
                        color: "transparent"
                        anchors {
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            id: riverReachCurrentFlowText
                            text: ""
                            anchors {
                                top: parent.top
                                topMargin: parent.height * 0.15
                            }
                            width: parent.width
                            font.family: app.fontSourceSansProReg.name
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            color: appConfigData.themeColorDarkerGray
                            font.pixelSize: appConfigData.fontSize16
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignRight

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    alertValueTextInput.text = riverReachCurrentFlowText.text;

                                    riverReachCurrentFlowHighlightLine.color = appConfigData.themeColorGreen;
                                    riverReachMonAvgHighlightLine.color = appConfigData.themeColorLightestGray;
                                }
                            }
                        }

                        Text {
                            id: riverReachCurrentFlowLabel
                            text: "Current Flow"
                            anchors {
                                top: riverReachCurrentFlowText.bottom
                            }
                            width: parent.width
                            font.family: app.fontSourceSansProReg.name
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            color: appConfigData.themeColorLighterGray
                            font.pixelSize: appConfigData.fontSize11
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignRight
                        }

                        Rectangle {
                            id: riverReachCurrentFlowHighlightLine
                            height: riverReachCurrentFlowText.height + riverReachCurrentFlowLabel.height
                            width: 2 * app.scaleFactor
                            color: appConfigData.themeColorLightestGray

                            anchors {
                                top: riverReachCurrentFlowText.top
                                right: parent.right
                                rightMargin: -10 * app.scaleFactor
                            }
                        }
                    }
                }
                //end of right rect
            }
            // end of editAlertDialog


            //left side border
            Rectangle {
                height: parent.height
                width: 5 * app.scaleFactor
                color: appConfigData.themeColorGreen

                anchors {
                    top: parent.top
                    left: parent.left
                }
            }
        }
    }
    // end of main container

    RectangularGlow {
        id: bottomBtnsWrapperGlowEffect
        anchors.fill: bottomBtnsWrapper
        glowRadius: 10
        spread: 0
        color: appConfigData.welcomeDialogGlowEffectColor
        cornerRadius: 0
    }

    Rectangle {
        id: bottomBtnsWrapper
        width: parent.width
        height: 70 * app.scaleFactor
        color: appConfigData.themeColorGreen
        visible: (selectedItemData !== undefined && selectedItemData["type"] && selectedItemData["type"] === "edit") ? true : false

        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        Rectangle {
            id: deleteAlertBtn
            width: parent.width * 0.25
            height: parent.height
            color: "transparent"
            anchors.left: parent.left

            Text {
                id:deleteAlertBtnIcon
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: appConfigData.fontSize12
                font.family: awesome.family
                text: awesome.loaded ? awesome.icons.fa_minus_circle + "\nDelete" : ""
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                width: 1 * app.scaleFactor
                height: parent.height
                anchors.right: parent.right
                color: appConfigData.themeColorLightestGray
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    localStorage.removeAlertByKey(app.tableNameForAlerts, selectedItemData["oid"]);
                    closeButtonClicked();
                }
            }
        }

        Rectangle {
            id: pauseAlertBtn
            width: parent.width * 0.25
            height: parent.height
            color: "transparent"
            anchors.left: deleteAlertBtn.right

            Text {
                id: pauseAlertBtnIcon
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: appConfigData.fontSize12
                font.family: awesome.family
                text: (alertStatus === 'active') ? awesome.icons.fa_pause + "\nMute" : awesome.icons.fa_play + "\nUnmute"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                width: 1 * app.scaleFactor
                height: parent.height
                anchors.right: parent.right
                color: appConfigData.themeColorLightestGray
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    toggleAlertStatus();
                }
            }
        }

        Rectangle {
            id: saveAlertBtn
            width: parent.width * 0.5
            height: parent.height
            color: "transparent"
            anchors.right: parent.right

            Text {
                id:saveAlertBtnIcon
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: appConfigData.fontSize14
                font.family: awesome.family
                text: awesome.loaded ? awesome.icons.fa_check + "  Save" : ""
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {

                    if(saveAlertBtn.color === appConfigData.themeColorGreen){
                        localStorage.updateAlertByKey(app.tableNameForAlerts, selectedItemData["oid"], alertValueTextInput.text, alertStatus, alertType);
                        closeButtonClicked();
                    } else {
                        return false;
                    }

                }
            }
        }
    }

    Rectangle {
        id: addAlertBtnWrapper
        width: parent.width
        height: 70 * app.scaleFactor
        color: appConfigData.themeColorGreen
        visible: (selectedItemData !== undefined && selectedItemData["type"] && selectedItemData["type"] === "edit") ? false : true

        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        Rectangle {
            id: addAlertBtn
            width: parent.width * 0.5
            height: parent.height
            color: "transparent"
            anchors.centerIn: parent

            Text {
                id:addAlertBtnIcon
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: appConfigData.fontSize14
                font.family: awesome.family
                text: awesome.loaded ? awesome.icons.fa_check + "  Save" : ""
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {

                    var data = [
                        {"field": "station_id", "value": selectedItemData["stationID"]},
                        {"field": "value", "value": alertValueTextInput.text},
                        {"field": "alert_status", "value": "active"},
                        {"field": "alert_type", "value": alertType}
                    ];

                    if(addAlertBtnWrapper.color === appConfigData.themeColorGreen){
                        localStorage.insertToAlerts(app.tableNameForAlerts, data);
                        closeButtonClicked();
                    } else {
                        return false;
                    }


                }
            }
        }

    }

}
