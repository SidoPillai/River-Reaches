import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "Components" as Components

Item {
    id: _root
    anchors.fill: parent
    visible: false
    z: 200

    property string imageName: ""
    property var itemAttributes

    signal closed()

    function show(imageURL, imgName, stationID){

        photoPreview.source = imageURL;

        imageName = imgName;

        itemAttributes = getItemAttribute(stationID);

        createTempImageFiles();

        _root.visible = true;

//        console.log("show preview page");

//        console.log("imageURL", imageURL);

//        console.log("stationID", stationID);
    }

    function hide(){

        _root.visible = false;

        removeTempImageFiles();

        resetPage();

        closed();
    }

    function resetPage(){
        photoTitleTextInput.text = "";
        photoDescTextInput.text = "";
    }

    function toggleBusyDialog(status){

        if(status){
            busyDialog.busyText = "Uploading...";
        } else {
            busyDialog.busyText = "Loading...";
        }

        busyDialogWrapper.visible = status;

        busyDialog.visible = status;

    }

    function createTempImageFiles(){

        removeTempImageFiles();

        packageFolder.copyFile(imageName, packageFolder.path + "/" + "PrimaryPhoto.jpeg");

        packageFolder.copyFile(imageName, packageFolder.path + "/" + "PrimaryThumbnail.jpeg");
    }

    function removeTempImageFiles(){

        packageFolder.removeFile("PrimaryPhoto.jpeg");

        packageFolder.removeFile("PrimaryThumbnail.jpeg");
    }

    function getItemAttribute(stationID){

        var result = localStorage.queryByKey(app.tableName, stationID);

        var attributes = {
            "attributes": {
                "Vetted":0,
                "Hidden":0,
                "Name": "",
                "LocationName": result.stream_name,
                "Description": "",
            },
            "geometry": {
                "type":"point",
                "x": result.x,
                "y": result.y,
                "spatialReference": {"wkid":102100}
            }
        };

        return attributes;
    }

    function validateItemAttribute(){

        var isFormInputValidate = true;

        if(photoTitleTextInput.text !== "") {
            itemAttributes.attributes.Name = photoTitleTextInput.text;
        } else {
            console.log("photoTitleText is empty");
            photoTitleText.color = "red";
            photoTitleText.text = "Title is required!";
            isFormInputValidate = false;
        }

        if(photoDescTextInput.text !== "") {
            itemAttributes.attributes.Description = photoDescTextInput.text;
        } else {
            console.log("photoDescTextInput is empty");
            photoDescText.color = "red";
            photoDescText.text = "Description is required!";
            isFormInputValidate = false;
        }

        return isFormInputValidate;
    }

    function addItemToCrowdsourceStoryMap(){

        var isFormInputValidate = validateItemAttribute();

        if(isFormInputValidate) {

            var req = new XMLHttpRequest();

            var params = 'f=pjson&adds=' + JSON.stringify([itemAttributes]);

            req.open("POST", appConfigData.crowdsourceStoryMapURL + "/applyEdits", true);

            //Send the proper header information along with the request
            req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            req.setRequestHeader("Content-length", params.length);
            req.setRequestHeader("Connection", "keep-alive");

            req.onreadystatechange = function() {

                if (req.readyState === XMLHttpRequest.DONE) {

                    var response = JSON.parse(req.responseText);

                    if(response.addResults.length){

                        var objectId = response.addResults[0].objectId;

                        addAttachmentToItem(objectId, "PrimaryPhoto.jpeg", function(response){

                            console.log("addAttachmentResultSuccess", response.addAttachmentResult.success);

                            if(response.addAttachmentResult.success){

                                addAttachmentToItem(objectId, "PrimaryThumbnail.jpeg", function(response){

                                    console.log("addAttachmentResultSuccess", response.addAttachmentResult.success);

                                    toastDialog.start();

                                    toggleBusyDialog(false);
                                });

                            } else {

                                console.log("Uploading PrimaryPhoto.jpeg failed");

                                toggleBusyDialog(false);
                            }

                        });
                    }
                }
            }

            req.onerror = function(){
              // what you want to be done when request failed
            }

            req.send(params);

            toggleBusyDialog(true);

        } else {
            console.log("invalide input");
        }


    }


    function addAttachmentToItem(itemObjectID, fileName, callback){

        addAttachmentNetworkRequest.url = appConfigData.crowdsourceStoryMapURL + "/" + itemObjectID + "/addAttachment";

        var obj = {"attachment": "@" + packageFolder.path + "/" + fileName, "f": "json"};

        addAttachmentNetworkRequest.callback = callback;

        addAttachmentNetworkRequest.send(obj);
    }


    NetworkRequest {
        id: addAttachmentNetworkRequest
        method: "POST"
        responseType: "json"

        property var callback;

        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE){
                callback(response);
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#fff"
        clip: true
        visible: photoPreview.source != ""

        Rectangle {
            id: busyDialogWrapper
            anchors.fill: parent
            color: "#636363"
            opacity: 0.3
            z: 900
            visible: false

            MouseArea {
                anchors.fill: parent
            }
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
            height: 50 * app.scaleFactor
            anchors.top: parent.top
            color: appConfigData.themeColorLightGray

            Text {
                id: titleText
                anchors.centerIn: parent
                text: "Contribute Photo"
                color: appConfigData.themeColorGreen
                font.pixelSize: appConfigData.navBarTitleTextFont
                font.family: app.fontSourceSansProReg.name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                id: closeItemDetailedInfoPageButton
                width: 50 * app.scaleFactor
                height: parent.height
                color: "transparent"
                anchors {
                    left: parent.left
                    leftMargin: 0 * app.scaleFactor
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
                        _root.hide();
                    }
                }
            }
            //end of close button
        }

        Rectangle {
            id: photoWrapper
            height: parent.height * 0.35
            width: parent.width * 0.9
            anchors {
                top: topNavBar.bottom
                topMargin: 10 * app.scaleFactor
                horizontalCenter: parent.horizontalCenter
            }
            color: appConfigData.themeColorLightGray

            Image {
                id: photoPreview
                fillMode: Image.PreserveAspectCrop
                clip: true
                autoTransform: true


                height: parent.height * 0.9
                width: parent.width * 0.9

                anchors {
                    centerIn: parent
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
            id: photoInfoFormWrapper
            height: parent.height * 0.35
            width: parent.width * 0.9
            color: appConfigData.themeColorLightGray

            anchors {
                top: photoWrapper.bottom
                topMargin: 15 * app.scaleFactor
                horizontalCenter: parent.horizontalCenter
            }

            GridLayout {

                anchors {
                    margins: 15
                    centerIn: parent
                }

                columns: 1
                rows: 4
                rowSpacing: 8 * app.scaleFactor

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    fill: parent
                }

                Text {
                    id: photoTitleText
                    text: "Title"
                    font.pixelSize: appConfigData.fontSize14
                    color: appConfigData.themeColorDarkestGray
                    font.family: app.fontSourceSansProReg.name
                }
                TextField {
                    id: photoTitleTextInput
                    Layout.fillWidth: true

                    font.family: app.fontSourceSansProReg.name
                    font.pixelSize: appConfigData.fontSize12

                    onTextChanged: {
                        photoTitleText.text = "Title";
                        photoTitleText.color = appConfigData.themeColorDarkestGray;
                    }

                    style: TextFieldStyle  {
                        textColor: appConfigData.themeColorDarkGray;

                        background: Rectangle {
                            radius: 0
                            border.width: 0
                        }
                    }

                }

                Text {
                    id: photoDescText
                    text: "Description"
                    font.pixelSize: appConfigData.fontSize14
                    color: appConfigData.themeColorDarkestGray
                    font.family: app.fontSourceSansProReg.name
                }

                TextArea {
                    id: photoDescTextInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    frameVisible: false

                    font.family: app.fontSourceSansProReg.name
                    font.pixelSize: appConfigData.fontSize12

                    style: TextAreaStyle  {
                        textColor: appConfigData.themeColorDarkGray;
                        backgroundColor: "#fff"
                    }

                    onTextChanged: {
                        photoDescText.text = "Description";
                        photoDescText.color = appConfigData.themeColorDarkestGray;
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
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            color: appConfigData.themeColorGreen

            Rectangle {
                width: parent.width * 0.5
                height: parent.height
                color: "transparent"
                anchors {
                    left: parent.left
                }

                Text {
                    anchors.centerIn: parent
                    color: "#fff"
                    font.pixelSize: appConfigData.fontSize20
                    font.family: awesome.family
                    text: awesome.loaded ? awesome.icons.fa_upload : ""
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("upload photo");

                        addItemToCrowdsourceStoryMap();
                    }
                }
            }

            Rectangle {
                width: parent.width * 0.5
                height: parent.height
                color: "transparent"
                anchors {
                    right: parent.right
                }

                Text {
                    anchors.centerIn: parent
                    color: "#fff"
                    font.pixelSize: appConfigData.fontSize20
                    font.family: awesome.family
                    text: awesome.loaded ? awesome.icons.fa_trash_o : ""
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        photoPage.removeImage(imageName)
                        _root.hide();
                    }
                }
            }
        }
        // end of bottom nav bars
    }

    Components.ToastDialog{
        id: toastDialog
        isDebug: false
        visible: false
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units(40)
        toastWidth: parent.width*0.8
        delay: 1500
        backgroundColor: "#888888"
        toastTextSize: appConfigData.fontSize11
        toastText: "Photo Uploaded Successfully!"
    }

}
