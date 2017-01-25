import QtQuick 2.5
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

import "Components" as Components

Item {
    id: _root
    anchors.fill: parent
    visible: false

    property string stationID: ""

    FileFolder {
        id: packageFolder
    }

    ListModel {
        id: photoModel
    }

    function show(id){

        stationID = id;

        scanImageFolder();

        _root.visible = true;
    }

    function hide(){
        resetPage();

        _root.visible = false;
    }

    function resetPage(){
        photoModel.clear();
    }

    function scanImageFolder() {

        photoModel.clear();

        var pathNames = localStorage.queryAllValues(app.tableNameForFolderInfo);

        var numItems = pathNames.rows.length;

        if(numItems){
            var path = pathNames.rows.item(0).path;

            path = "file:///" + path.replace(/\"/g, "");

            console.log("image folder path: ", path);

            packageFolder.url = path;

            var images = packageFolder.fileNames("IMG-" + stationID + "-*");

            populateAllImages(images, path);

            cameraComponent.updatePackageFolderURL(path);

            cameraComponent.photoNamePrefix = stationID;
        }
    }

    function populateAllImages(obj, folderPath){
        for (var property in obj) {
            if (obj.hasOwnProperty(property)) {
                var link = folderPath + "/" + obj[property];
                photoModel.append({"imgLink": link, "imgName": obj[property]});
            }
        }
    }

    function removeAllImages(obj){
        for (var property in obj) {
            if (obj.hasOwnProperty(property)) {
                packageFolder.removeFile(obj[property]);
            }
        }
    }

    function removeImage(imgName) {
        packageFolder.removeFile(imgName);
        console.log(imgName, " is removed");
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
            text: "Photo"
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

                    itemDetailedInfoPage.show();
                }
            }
        }
    }
    //end of topNavBar


    Rectangle {
        id: mainContainer
        width: parent.width
        height: parent.height - (topNavBar.height + bottomNavBar.height + 20 * app.scaleFactor)
        anchors {
            top: topNavBar.bottom
            topMargin: 10 * app.scaleFactor
            bottom: bottomNavBar.top
            bottomMargin: 10 * app.scaleFactor
            horizontalCenter: parent.horizontalCenter
        }

//        color: "#123456"

        GridView {
            id: gridView
            anchors.fill: parent
            cellWidth: parent.width / 3
            cellHeight: cellWidth
            focus: true
            model: photoModel

//            highlight: Rectangle { width: 80; height: 80; color: "lightsteelblue" }

            delegate: Item {
                width: mainContainer.width / 3
                height: width

                Image {
                    anchors.centerIn: parent
                    height: parent.height
                    width: height
                    source: imgLink
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 512
                    sourceSize.height: 512
                    autoTransform: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                        photoPreviewPage.show(imgLink, imgName, stationID);

                        gridView.visible = false;

//                        hide();
                    }
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
        height: 65 * app.scaleFactor
        color: appConfigData.themeColorGreen

        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        Rectangle {
            width: parent.width * 0.9
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

//            Rectangle {
//                width: parent.width * 0.5
//                height: parent.height
//                anchors.left: parent.left
//                color: "transparent"

//                Text {
//                    anchors.centerIn: parent
//                    color: "white"
//                    font.pixelSize: 12
//                    font.family: awesome.family
//                    text: awesome.loaded ? awesome.icons.fa_image + "  Upload Photo" : ""
//                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                    maximumLineCount: 1
//                    elide: Text.ElideRight
//                    horizontalAlignment: Text.AlignHCenter
//                }

//                MouseArea {
//                    anchors.fill: parent
//                    onClicked: {
//                        console.log("upload the photo");
//                    }
//                }
//            }

            Rectangle {
                width: parent.width * 0.8
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: appConfigData.fontSize16
                    font.family: awesome.family
                    text: awesome.loaded ? awesome.icons.fa_camera + "  Take Photo" : ""
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("take a photo for river: ", stationID);

                        cameraComponent.transitionIn(4);

//                        _root.hide();
                    }
                }
            }
        }
    }

    PhotoPreviewPage {

        id: photoPreviewPage

        onClosed: {
            scanImageFolder();

            gridView.visible = true;
        }
    }

    Components.CameraComponent{
        id: cameraComponent
        folderInfoTableName: app.tableNameForFolderInfo
        photoNamePrefix: stationID
        transitionType: transition.none
        onDismissed: {
//            console.log(filePath);
            scanImageFolder();
        }
    }

}
