import QtQuick 2.5
import QtPositioning 5.3
import QtGraphicalEffects 1.0
import QtSensors 5.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.WebMap 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

Item {
    id: _root
    anchors.fill: parent
    visible: false

    property string selectedItemGeomX: ""
    property string selectedItemGeomY: ""

    property var selectedPolylineStartNode
    property var selectedPolylineEndNode

    signal closeButtonClicked()
    signal openReviewItemClicked(var itemData)
    signal setUpAlertButtonClicked(var itemData)


    property var riverReachInfoModel: riverReachInfoModel

    ListModel {
        id: riverReachInfoModel
    }

    function show(){
        welcomeWrapper.visible = false;
        _root.visible = true;
    }

    function init(){
        welcomeWrapper.visible = true;
        busyDialog.visible = false;
        _root.visible = true;
    }

    function hide(){
        _root.visible = false;
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
            text: appConfigData.addItemPageTitleText
            color: appConfigData.themeColorGreen
            font.pixelSize: appConfigData.fontSize16
            font.family: app.fontSourceSansProReg.name
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: closeAddItemPageButton
            width: appConfigData.closeAddItemPageBtnWidth
            height: parent.height
            color: "transparent"
            anchors {
                left: parent.left
                leftMargin: appConfigData.closeAddItemPageBtnLeftMargin
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

                    if(!searchBarWrapper.visible){

                        _root.visible = false;

                        resetAddItemPage();

                        closeButtonClicked();

                    } else {
                        //                        searchBarWrapper.visible = false;
                        //                        toggleSearchBarButtonIcon.visible = true;

                        hideRiverSearchBar();
                    }

                }
            }
        }

        Rectangle {
            id: toggleSearchBarButton
            width: appConfigData.defaultAppBtnHeight
            height: parent.height
            color: "transparent"
            anchors {
                right: parent.right
                rightMargin: appConfigData.defaultAppBtnHorizontalMargin
                verticalCenter: parent.verticalCenter
            }

            Text {
                id: toggleSearchBarButtonIcon
                anchors.centerIn: parent
                color: appConfigData.themeColorGreen
                font.pixelSize: appConfigData.fontSize20
                font.family: awesome.family
                text: awesome.loaded ? awesome.icons.fa_search : ""
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    searchBarWrapper.visible = true;
                    toggleSearchBarButtonIcon.visible = false;
                }
            }
        }

        Rectangle {
            id: searchBarWrapper
            height: parent.height
            width: parent.width - closeAddItemPageButton.width
            anchors {
                left: closeAddItemPageButton.right
            }
            color: "transparent"
            visible: false

            Rectangle {
                id: riverSearchBarTextInputWrapper
                width: parent.width * 0.95
                height: parent.height * 0.8

                color: appConfigData.themeColorLightestGray

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: parent.width - riverSearchBarIcon.width
                    height: parent.height

                    anchors.left: parent.left
                    anchors.leftMargin: 5 * app.scaleFactor

                    color: "transparent"

                    Rectangle {
                        id: riverSearchBarTextInputLabelRect
                        width: parent.width
                        height: parent.height
                        color: "transparent"

                        Text {
                            text: "Search places..."
                            color: appConfigData.themeColorDarkGray
                            font.pixelSize: appConfigData.fontSize14
                            font.family: app.fontSourceSansProReg.name
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    TextInput {
                        id: riverSearchBarTextInput
                        text: ""
                        color: appConfigData.themeColorDarkGray
                        selectionColor: "green"
                        font.pixelSize: appConfigData.fontSize14
                        font.bold: true
                        width: parent.width
                        anchors.centerIn: parent
                        focus: true
                        clip: true

                        onTextChanged: {
                            riverSearchBarTextEnterHandler();
                        }
                    }
                }



                Rectangle {
                    id: riverSearchBarIcon
                    width: height
                    height: parent.height * 0.8
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    color: "transparent"

                    Text {
                        id: riverSearchBarIconText
                        anchors.centerIn: parent
                        color: appConfigData.themeColorGreen
                        font.pixelSize: appConfigData.fontSize20
                        font.family: awesome.family
                        text: awesome.loaded ? awesome.icons.fa_search : ""
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log('search the river by name');
                            addressLocatorOnclickedHandler();
                        }
                    }
                }
            }


        }
    }
    //End of Top Nav Bar

    Rectangle {
        id: welcomeWrapper
        width: parent.width
        height: parent.height
        z: 100
        color: "transparent"

        Image {
            id: welcomeWrapperBackgroundImage
            anchors.fill: parent
            source: "assets/images/map-background.png"
            fillMode: Image.PreserveAspectCrop
        }

        FastBlur {
            anchors.fill: welcomeWrapper
            source: welcomeWrapperBackgroundImage
            radius: 24
        }

        RectangularGlow {
            id: welcomeNavBarGlowEffect
            anchors.fill: welcomeWrapperNavBar
            glowRadius: 10
            spread: 0
            color: appConfigData.welcomeDialogGlowEffectColor
            cornerRadius: 0
        }

        RectangularGlow {
            id: welcomeDialogGlowEffect
            anchors.fill: welcomeDialog
            glowRadius: 10
            spread: 0
            color: appConfigData.welcomeDialogGlowEffectColor
            cornerRadius: 0
        }

        RectangularGlow {
            id: welcomeDialogLogoGlowEffect
            anchors.fill: welcomeDialogLogoBackground
            glowRadius: 10
            spread: 0.1
            color: appConfigData.welcomeDialogGlowEffectColor
            cornerRadius: 50
        }

        Rectangle {
            id: welcomeWrapperNavBar
            width: parent.width
            height: 70 * app.scaleFactor
            color: appConfigData.themeColorLightGray

            Text {
                id: welcomeWrapperNavBarText
                anchors.centerIn: parent
                text: "<b>River</b> Reaches"
                color: appConfigData.themeColorGreen
                font.pixelSize: appConfigData.fontSize28
                font.family: app.fontSourceSansProReg.name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle {
            id: welcomeDialogLogoBackground
            width: 100 * app.scaleFactor
            height: 100 * scaleFactor
            radius: width * 0.5
            color: "white"

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: welcomeDialog.top
                topMargin: - (welcomeDialogLogoBackground.height / 2)
            }
        }

        Rectangle {
            id: welcomeDialog
            width: parent.width * 0.8
            height: 240 * app.scaleFactor
            color: "white"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 120 * app.scaleFactor + welcomeWrapperNavBar.height
            }

            Rectangle {
                id: welcomeDialogLogo
                width: 90 * app.scaleFactor
                height: 90 * scaleFactor
                radius: width * 0.5
                color: appConfigData.themeColorGreen

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: - (welcomeDialogLogo.height / 2)
                }

                Image {
                    id: welcomeDialogLogoImage
                    anchors.fill: parent
                    source: "assets/images/WhiteWave.png"
                    fillMode: Image.PreserveAspectFit
                }
            }

            Rectangle {
                id: welcomeDialogMessageWrapper
                width: parent.width * 0.9
                height: parent.height - (welcomeDialogLogo.height / 2) - (30 * app.scaleFactor)
                //                color: "#636363"

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: 15 * app.scaleFactor
                }

                Rectangle {
                    id: welcomeDialogTitle
                    width: parent.width
                    height: 50 * app.scaleFactor

                    anchors {
                        top: parent.top
                    }

                    Text {
                        id: welcomeDialogTitleText
                        anchors.centerIn: parent
                        text: "Welcome!"
                        color: "#636363"
                        font.pixelSize: appConfigData.fontSize28
                        font.family: app.fontSourceSansProReg.name
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: 1
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    id: welcomeDialogMessage
                    width: parent.width
                    height: 50 * app.scaleFactor

                    anchors {
                        top: welcomeDialogTitle.bottom
                    }

                    Text {
                        id: welcomeDialogMessageText
                        width: parent.width
                        anchors.centerIn: parent
                        text: "Get started by choosing a river and setting some alerting rules..."
                        color: "#636363"
                        font.pixelSize: appConfigData.fontSize12
                        font.family: app.fontSourceSansProReg.name
                        wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere
                        maximumLineCount: 2
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    id: welcomeDialogButton
                    width: parent.width
                    height: 50 * app.scaleFactor

                    color: appConfigData.themeColorGreen

                    anchors {
                        top: welcomeDialogMessage.bottom
                        topMargin: 10 * app.scaleFactor
                    }

                    Text {
                        id: welcomeDialogButtonText
                        text: "Choose a River"
                        anchors.centerIn: parent
                        font.family: app.fontSourceSansProReg.name
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: "white"
                        font.pixelSize: appConfigData.fontSize24
                    }
                }
            }

            //            MouseArea {
            //                anchors.fill: parent
            //                onClicked: {
            ////                    welcomeWrapper.visible = false;
            //                }
            //            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                welcomeWrapper.visible = false;
            }
        }

    } //End of Welcome Wrapper

    Rectangle {
        id: selectionBtnsWrapper
        width: parent.width * 0.8
        height: 50 * app.scaleFactor
        z: 100
        visible: false
        color: "transparent"

        anchors {
            bottom: map.bottom
            horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: parent.width * 0.5
            height: parent.height * 0.8
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    streamSelectionBtnClickedHandler('upstream');
                }
            }

            RectangularGlow {
                id: upstreamBtnRectGlowEffect
                anchors.fill: upstreamBtnRect
                glowRadius: 10
                spread: 0.5
                color: appConfigData.welcomeDialogGlowEffectColor
                cornerRadius: 50
            }

            Rectangle {
                id: upstreamBtnRect
                width: parent.width * 0.9
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                z: 100

                Rectangle {
                    width: parent.width * 0.8
                    height: parent.height * 0.9
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: upstreamBtnText.left
                        anchors.rightMargin: 5 * app.scaleFactor
                        color: appConfigData.themeColorLighterGray
                        font.pixelSize: appConfigData.fontSize16
                        font.family: awesome.family
                        text: awesome.loaded ? awesome.icons.fa_angle_up : ""
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        id: upstreamBtnText
                        text: "Upstream"
                        anchors.centerIn: parent
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: app.fontSourceSansProReg.name
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: appConfigData.themeColorLighterGray
                        font.pixelSize: appConfigData.fontSize12
                        horizontalAlignment: Text.AlignLeft
                    }
                }
            }
        }

        Rectangle {

            width: parent.width * 0.5
            height: parent.height * 0.8
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    streamSelectionBtnClickedHandler('downstream');
                }
            }

            RectangularGlow {
                id: downstreamBtnRectGlowEffect
                anchors.fill: downstreamBtnRect
                glowRadius: 10
                spread: 0.5
                color: appConfigData.welcomeDialogGlowEffectColor
                cornerRadius: 50
            }

            Rectangle {
                id: downstreamBtnRect
                width: parent.width * 0.9
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                z: 100

                Rectangle {
                    width: parent.width * 0.8
                    height: parent.height * 0.9
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        //                        anchors.centerIn: parent
                        id: downstreamBtnIcon
                        anchors.verticalCenter: parent.verticalCenter
                        color: appConfigData.themeColorLighterGray
                        font.pixelSize: appConfigData.fontSize16
                        font.family: awesome.family
                        text: awesome.loaded ? awesome.icons.fa_angle_down : ""
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: "Downstream"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: downstreamBtnIcon.right
                        anchors.leftMargin: 5 * app.scaleFactor
                        font.family: app.fontSourceSansProReg.name
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: appConfigData.themeColorLighterGray
                        font.pixelSize: appConfigData.fontSize12
                        horizontalAlignment: Text.AlignLeft
                    }
                }
            }
        }
    }
    // end of selection btns wrapper

    Rectangle {
        id: riverPreviewFooterPanel
        width: parent.width
        height: 150 * app.scaleFactor
        z: 100
        visible: false
        color: "white"

        anchors {
            bottom: parent.bottom
        }

        Rectangle {
            id: riverPreviewFooterPanelTop
            width: parent.width
            height: parent.height  * 0.5

            anchors {
                top: parent.top
                left: parent.left
            }

            color: appConfigData.themeColorLightGray

            Rectangle {
                width: parent.width * 0.9
                height: parent.height * 0.8
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"

                Rectangle {
                    id: riverPreviewFooterRiverNameWrapper
                    width: parent.width
                    height: parent.height * 0.5
                    anchors.top: parent.top
                    color: "transparent"

                    Text {
                        id: riverTrendIconText
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                        color: appConfigData.themeColorGreen
                        font.pixelSize: appConfigData.fontSize24
                        font.family: awesome.family
                        text: awesome.loaded ? awesome.icons.fa_caret_up : ""
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        width: parent.width * 0.85
                        height: parent.height
                        color: "white"
                        anchors {
                            top: parent.top
                            left: riverTrendIconText.right
                            leftMargin: 10 * app.scaleFactor
                        }

                        TextInput {
                            id: riverPreviewFooterRiverNameTextInput
                            color: appConfigData.themeColorDarkerGray
                            font.pixelSize: appConfigData.fontSize16
                            width: parent.width
                            focus: true
                            cursorVisible: true
                            clip: true

                            anchors {
                                left: parent.left
                                leftMargin: 5 * app.scaleFactor
                                right: parent.right
                                rightMargin: 5 * app.scaleFactor
                                verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                Rectangle {
                    id: riverPreviewFooterRiverStatusWrapper
                    width: parent.width
                    height: parent.height  * 0.5
                    anchors.bottom: parent.bottom
                    color: "transparent"

                    Text {
                        id: riverPreviewFooterRiverQDiffText
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        font.family: app.fontSourceSansProReg.name
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: appConfigData.themeColorDarkerGray
                        font.pixelSize: appConfigData.fontSize10
                    }

                    Rectangle {
                        id: riverPreviewFooterRiverStatusTextDivider
                        width: 20 * app.scaleFactor
                        height: parent.height
                        anchors {
                            left: riverPreviewFooterRiverQDiffText.right
                        }
                        color: "transparent"

                        Rectangle {
                            width: 1 * app.scaleFactor
                            height: parent.height * 0.5
                            color: riverPreviewFooterRiverQDiffText.color

                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Text {
                        id: riverPreviewFooterRiverAnomalyText
                        anchors.left: riverPreviewFooterRiverStatusTextDivider.right
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: app.fontSourceSansProReg.name
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: appConfigData.themeColorDarkerGray
                        font.pixelSize: appConfigData.fontSize10
                    }
                }
            }
        }

        Rectangle {
            id: riverPreviewFooterPanelBottom
            width: parent.width
            height: parent.height  * 0.5
            color: appConfigData.themeColorGreen

            anchors {
                bottom: parent.bottom
                left: parent.left
            }

            Text {
                id:riverPreviewFooterPanelBottomBtnIcon
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: appConfigData.fontSize20
                font.family: awesome.family
                text: awesome.loaded ? awesome.icons.fa_pencil + "  Set-Up Alert" : ""
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    saveSelectedItem();
                }
            }
        }
    }

    Rectangle {
        id: riverPreviewFooterPanelDivider
        width: parent.width
        height: 1 * app.scaleFactor
        z: 100
        color: "transparent"

        anchors {
            bottom: map.bottom
        }
    }

    RectangularGlow {
        id:riverPreviewFooterPanelGlowEffect
        anchors.fill: riverPreviewFooterPanelDivider
        glowRadius: 10
        spread: 0
        color: appConfigData.welcomeDialogGlowEffectColor
        cornerRadius: 0
    }

    WebMap {
        id: map
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: topNavBar.height + (5 * app.scaleFactor)
            bottom: parent.bottom
        }
        wrapAroundEnabled: true
        rotationByPinchingEnabled: false
        magnifierOnPressAndHoldEnabled: false
        mapPanningByMagnifierEnabled: false
        zoomByPinchingEnabled: true
        webMapId: "4ed810d3995e494793e89d9eacd21d65"

        //CREATE USER POSITION DISPLAY
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
                verticalCenter: parent.verticalCenter
                margins: 10 * app.scaleFactor
            }
        }

        Query {
            id: queryRiverDataBySpatialRelationship
            spatialRelationship: Enums.SpatialRelationshipIntersects
            returnGeometry: true
            outFields: ["*"]
        }

        QueryTask {
            id: queryTaskRiverData
            url: app.info.propertyValue("riverWaterModelQueryURL")

            onQueryTaskStatusChanged: {

                if (queryTaskStatus === Enums.QueryTaskStatusCompleted){

                    if(queryResult.graphics[0]){

                        renderQueryResult(queryResult.graphics[0].geometry);

                        getStreamPolylineNodes(queryResult.graphics[0].geometry);

                        showAddItemDialog(queryResult.graphics[0].attributes, queryResult.graphics[0].geometry);

                    } else {
                        console.log("queryTaskRiverData: no feature found");
                    }
                }
                else if (queryTaskStatus === Enums.QueryTaskStatusErrored){
                    console.log("Query Error: ", queryError.message);
                }
            }
        }

        ServiceLocator {
            id: addressLocator
            url: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"

            onFindStatusChanged: {
                if (findStatus === Enums.FindStatusCompleted) {
                    if (findResults.length < 1) {
                        //                        console.log("No address Found");

                        //                        toastDialog.toastText = "Address could not be found";
                        //                        toastDialog.start();
                    } else {
                        var result = findResults[0];

                        var bufferGeom = result.location.buffer(10000);
                        map.zoomTo(bufferGeom);

                        searchBarWrapper.visible = false;
                        toggleSearchBarButtonIcon.visible = true;
                    }
                } else if (findStatus === Enums.FindStatusErrored) {
                    console.log(findError.message);
                }
            }
        }

        LocatorFindParameters {
            id: addressLocatorFindParameters
            text: riverSearchBarTextInput.text
            outSR: map.spatialReference
            maxLocations: 1
            sourceCountry: "US"
        }

        //ENABLE POSITION ONCE MAP IS CREATED
        onStatusChanged: {
            if (status === Enums.MapStatusReady) {
                map.addLayer(queryResultGraphicLayer);
                //                map.addLayer(riverWaterModelLayer);
                map.addLayer(graphicsLayerGeocode);
                positionSource.active = true;
                positionDisplay.mode = Enums.AutoPanModeDefault
            }
        }

        onMouseClicked: {
            mapClickEventHandler(mouse.mapPoint, 50);
        }
    }

    //    ArcGISDynamicMapServiceLayer {
    //        id: riverWaterModelLayer
    //        url: app.info.propertyValue("riverWaterModelLayerURL")
    //    }

    GraphicsLayer {
        id: queryResultGraphicLayer
    }

    Graphic {
        id: queryResultGraphic
        symbol: queryResultSimpleLineSymbol
    }

    GraphicsLayer {
        id: graphicsLayerGeocode
    }

    Graphic {
        id: locationGraphicGeocode
        symbol: simpleMarkerSymbolLocation
    }

    SimpleMarkerSymbol {
        id: simpleMarkerSymbolLocation
        color: "#909090"
        style: Enums.SimpleMarkerSymbolStyleCross
        size: 6
    }

    SimpleLineSymbol {
        id: queryResultSimpleLineSymbol
        width: 5
        color: "#56a5d8"
    }

    function mapClickEventHandler(mapPoint, searchDistance){

        resetAddItemPage();

        var searchRadiusGeometry = pointToExtent(mapPoint, 50);

        //        var searchRadiusGeometry = mapPoint.queryEnvelope().inflate(30 * map.resolution, 30 * map.resolution);

        selectedItemGeomX = mapPoint.x.toString();
        selectedItemGeomY = mapPoint.y.toString();

        queryWaterModelData(searchRadiusGeometry, "1=1");
    }

    function streamSelectionBtnClickedHandler(streamType){

        var selectedItemStationID = "";
        var selectedItemName = "";
        var node = (streamType === 'upstream') ? selectedPolylineStartNode : selectedPolylineEndNode;
        var nodeGeom = ArcGISRuntime.createObject("Point", {x: node[0], y: node[1]});

        for(var i = 0; i < riverReachInfoModel.count; i++) {
            var item = riverReachInfoModel.get(i);

            if(item.fieldName === 'station_id'){
                selectedItemStationID = item.fieldValue;
            }

            if(item.fieldName === 'stream_name'){
                selectedItemName = item.fieldValue;
            }
        }

        queryWaterModelData(nodeGeom, "egdb.DBO.LargeScale.station_id <> '" + selectedItemStationID + "' AND egdb.DBO.LargeScale.GNIS_NAME = '" + selectedItemName + "'");
    }

    function getStreamPolylineNodes(geometry){
        var geometryPaths = geometry.json.paths[0];

        selectedPolylineStartNode = geometryPaths[0];
        selectedPolylineEndNode = geometryPaths[geometryPaths.length - 1];
    }

    function queryWaterModelData(inputEventGeometry, whereClause){

        queryRiverDataBySpatialRelationship.geometry = inputEventGeometry;

        if(whereClause){
            queryRiverDataBySpatialRelationship.where = whereClause;
        }

        //        console.log("queryTaskRiverData - queryObject: " + JSON.stringify(queryRiverDataBySpatialRelationship.json));

        queryTaskRiverData.execute(queryRiverDataBySpatialRelationship);
    }

    function renderQueryResult(geometry) {

        resizeMap(false);

        queryResultGraphicLayer.removeAllGraphics();

        var cloneOfQueryResultGraphic = queryResultGraphic.clone();
        cloneOfQueryResultGraphic.geometry = geometry;
        queryResultGraphicLayer.addGraphic(cloneOfQueryResultGraphic);

        map.extent = geometry.queryEnvelope().scale(1.5);
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

        return computedExtent.toPolygon();
    }

    function resetAddItemPage(){

        riverReachInfoModel.clear();

        queryResultGraphicLayer.removeAllGraphics();

        resizeMap(true);

        riverPreviewFooterPanel.visible = false;

        selectionBtnsWrapper.visible = false;

        toggleSearchBarButtonIcon.visible = true;
    }

    //    function getAnomalyDesc(anomaly){

    //        var anomalyDesc = "";

    //        if(anomaly > 3){
    //            anomalyDesc = 'Above Normal';
    //        } else if (anomaly < 3){
    //            anomalyDesc = 'Below Normal';
    //        } else {
    //            anomalyDesc = 'Normal';
    //        }

    //        return anomalyDesc;
    //    }

    function resizeMap(isMarginToPageBottom) {

        if(isMarginToPageBottom){
            map.anchors.bottomMargin = 0;
        } else {
            //            map.anchors.bottomMargin = addItemDialog.height;
            map.anchors.bottomMargin = riverPreviewFooterPanel.height + (5 * app.scaleFactor);
        }
    }

    function updateDomElementTextValues(stationID, streamName, qOut, avgFlow, anomalyDesc, anomalyIcon, qDiffPct){

        riverPreviewFooterRiverNameTextInput.text = streamName;
        riverPreviewFooterRiverQDiffText.text = Math.round(qOut) + " cfs";
        riverPreviewFooterRiverAnomalyText.text = anomalyDesc + " (" + qDiffPct + ")";
        riverTrendIconText.text = anomalyIcon;
    }

    function updateDomElementTextColor(anomaly){
        var color = appUtilityFunctions.getColorByAnomaly(anomaly);
        riverTrendIconText.color = color;
        riverPreviewFooterRiverAnomalyText.color = color;
        riverPreviewFooterRiverQDiffText.color = color;
    }

    function showAddItemDialog(attributes, geometry){

        var stationID = attributes["egdb.DBO.LargeScale.station_id"].toString();
        var streamName = attributes["egdb.DBO.LargeScale.GNIS_NAME"].toString();
        var streamOrder = attributes["egdb.DBO.LargeScale.streamOrder"].toString();
        var flowRate = attributes["egdb.dbo.short_term_current.flowrate"].toString();
        var anomaly = attributes["egdb.dbo.short_term_current.anomaly"].toString();
        var qDiff = attributes["egdb.dbo.short_term_current.qdiff"].toFixed(1);
        var qOut = attributes["egdb.dbo.short_term_current.qout"].toFixed(1);
        var avgFlow = (attributes["egdb.dbo.short_term_current.qout"] - attributes["egdb.dbo.short_term_current.qdiff"]).toFixed(1);
        var qDiffPct =  ((attributes["egdb.dbo.short_term_current.qdiff"] / (attributes["egdb.dbo.short_term_current.qout"] - attributes["egdb.dbo.short_term_current.qdiff"])) * 100).toFixed(1)
        var alert1 = '0';
        var alert2 = '0';
        var alert3 = '0';
        var alert4 = '0';

        //        console.log("qDiff", qDiff);

        streamName = (streamName === ' ') ? 'No Name' : streamName;

        //riverReachInfoDataModel stores data that will be displayed on list view
        riverReachInfoModel.append({"fieldName": 'stream_name', "fieldValue": streamName});
        riverReachInfoModel.append({"fieldName": 'anomaly', "fieldValue": anomaly});
        riverReachInfoModel.append({"fieldName": 'avg_flow', "fieldValue": avgFlow});
        riverReachInfoModel.append({"fieldName": 'q_out', "fieldValue": qOut});
        riverReachInfoModel.append({"fieldName": 'q_diff', "fieldValue": qDiff});
        riverReachInfoModel.append({"fieldName": 'alert_1', "fieldValue": alert1});
        riverReachInfoModel.append({"fieldName": 'alert_2', "fieldValue": alert2});
        riverReachInfoModel.append({"fieldName": 'alert_3', "fieldValue": alert3});
        riverReachInfoModel.append({"fieldName": 'alert_4', "fieldValue": alert4});
        riverReachInfoModel.append({"fieldName": 'stream_order', "fieldValue": streamOrder});
        riverReachInfoModel.append({"fieldName": 'flow_rate', "fieldValue": flowRate});
        riverReachInfoModel.append({"fieldName": 'station_id', "fieldValue": stationID});
        riverReachInfoModel.append({"fieldName": 'x', "fieldValue": selectedItemGeomX});
        riverReachInfoModel.append({"fieldName": 'y', "fieldValue": selectedItemGeomY});

        updateDomElementTextValues(stationID, streamName, qOut, avgFlow, appUtilityFunctions.getAnomalyLabel(anomaly), awesome.icons[appUtilityFunctions.getAnomalyIcon(anomaly)], (qDiffPct > 0) ? "+" + qDiffPct.toString() + "%": qDiffPct.toString() + "%");

        updateDomElementTextColor(anomaly);

        riverPreviewFooterPanel.visible = true;

        selectionBtnsWrapper.visible = true;
    }

    function saveSelectedItem(){
        var itemData = {};

        for(var i = 0; i < riverReachInfoModel.count; i++) {
            var item = riverReachInfoModel.get(i);
            itemData[item.fieldName] = item.fieldValue;
        }

        itemData["stream_name"] = riverPreviewFooterRiverNameTextInput.text;
        itemData["isAddingNewItem"] = true;

        openReviewItemClicked(itemData);

        resetAddItemPage();

        hide();
    }

    function riverSearchBarTextEnterHandler(){
        if(riverSearchBarTextInput.text == ''){
            riverSearchBarTextInputLabelRect.visible = true;
        } else {
            riverSearchBarTextInputLabelRect.visible = false;
        }
    }

    function hideRiverSearchBar(){
        searchBarWrapper.visible = false;
        toggleSearchBarButtonIcon.visible = true;
    }

    function addressLocatorOnclickedHandler(){
        graphicsLayerGeocode.removeAllGraphics();
        addressLocatorFindParameters.text = riverSearchBarTextInput.text;
        addressLocator.find(addressLocatorFindParameters);
    }
}
