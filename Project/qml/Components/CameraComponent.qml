import QtMultimedia 5.5
import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtPositioning 5.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

import Qt.labs.folderlistmodel 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Dialogs 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Multimedia 1.0

Item {
    id: cameraComponent
    anchors.fill: parent
    property bool isDebug: false

    signal dismissed(url filePath)
    signal transitionInCompleted()
    signal transitionOutCompleted()

    property alias transitionType: _root.transitionType
    property alias transitionDuration: _root.transitionDuration
    property alias transition: _root.transition
    property alias transitionXOffset:_root.transitionXOffset

    property var currentTime
    property int cameraFlashMode: 0
    property int cameraExposureMode: 0
    property real cameraCurrentZoomScale: 1.0
    property real cameraOldZoomScale: 1.0
    property int captureResolution: 800
    property int rotationOriginX: 0
    property int rotationOriginY: 0
    property int rotationAngle: 0
    property url filePath
    property bool isBackCamera: true

    property var fileInfo

    property string photoNamePrefix: ""
    property string folderInfoTableName: ""
    property bool isSupportFlash: false

    ImageObject { id: imageObject }

    ExifInfo{ id: exifInfo}

    FileFolder{
        id: packageFolder

        Component.onCompleted: {
//            makeFolder();
        }
    }

    function units(num) {
        return num ? parseInt(num*AppFramework.displayScaleFactor) : 0
    }

    function pressed_time(){
        currentTime = Date.now()
    }

    function isClicked(){
        return Date.now()-currentTime<1000
    }

    function getFilePath(){
        return filePath
    }

    function getRotateAngle(){
        var rotate = 0;
        switch(Screen.orientation){
        case 1:
            rotate = 0;
            break;
        case 2:
            rotate = isBackCamera?270:90;
            break;
        case 4:
            rotate = 180;
            break;
        case 8:
            rotate = isBackCamera?90:270
            break;
        }
        return rotate;
    }

    function getRotateOrientation(){
        var rotate = 0;
        switch(Screen.orientation){
        case 1:
            rotate = isBackCamera?6:8;
            break;
        case 2:
            rotate = 1;
            break;
        case 4:
            rotate = isBackCamera?8:6;
            break;
        case 8:
            rotate = 3;
            break;
        }
        return rotate;
    }

    function switchCamera() {
        if (QtMultimedia.availableCameras.length > 0) {

            var cameraIndex = 0;
            for (var i = 0; i < QtMultimedia.availableCameras.length; i++)
            {
                if (QtMultimedia.availableCameras[i].deviceId === camera.deviceId) {
                    cameraIndex = i;
                    break;
                }
            }

            cameraIndex = (cameraIndex + 1) % QtMultimedia.availableCameras.length;
            if(QtMultimedia.availableCameras.length>1) isBackCamera = !isBackCamera
            camera.stop();
            camera.deviceId = QtMultimedia.availableCameras[cameraIndex].deviceId;
            switch(cameraFlashMode){
            case 0:
                camera.flash.mode = Camera.FlashAuto;
                flash_icon.source = "./images/flash_auto.png"
                break;
            case 1:
                camera.flash.mode = Camera.FlashOn;
                flash_icon.source = "./images/flash_on.png"
                break;
            case 2:
                camera.flash.mode = Camera.FlashOff;
                flash_icon.source = "./images/flash_off.png"
                break;
            }
            cameraCurrentZoomScale = 1.0
            camera.start();
        }
    }

    function updatePackageFolderURL(url){
        packageFolder.url = url;
    }

    function transitionIn(type_in){
        _root.transitionIn(type_in)
    }

    function transitionOut(type_out){
        _root.transitionOut(type_out)
    }

    Page{
        id: _root
        transitionType: transition.none
        footerHeight: 0
        headerHeight: 0

//        x: -parent.height //hide camera initially

        content: Rectangle{
            id: contentContainer
            anchors.fill: parent
            color:"black"

            Camera {
                id: camera

                cameraState: cameraComponent.visible ? Camera.ActiveState : Camera.UnloadedState

                imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

                captureMode: Camera.CaptureStillImage

                exposure {
                    exposureCompensation: -1.0
                    exposureMode: Camera.ExposureAuto
                }

                flash.mode: Camera.FlashAuto

                focus{
                    focusMode: Camera.FocusContinuous
                    focusPointMode: Camera.FocusPointAuto
                }

                imageCapture {

                    onImageMetadataAvailable: {
                        console.log("metadata: ", requestId, key, value)
                    }

                    onImageCaptured: {

                    }

                    onCapturedImagePathChanged:{

                        cameraComponent.filePath = AppFramework.resolvedPathUrl(camera.imageCapture.capturedImagePath);

                        if(Qt.platform.os === "ios"){
                            imageObject.load(cameraComponent.filePath);
                            imageObject.rotate(getRotateAngle());
                            imageObject.save(cameraComponent.filePath);
                        }

                        photoPreview.source = cameraComponent.filePath;
                        cameraComponent.fileInfo = AppFramework.fileInfo(cameraComponent.filePath);
                        name_textInput.text = cameraComponent.fileInfo.fileName;
                        nameContainer.visible = true
                        busyIndicator.visible = false
                        busyIndicator.running = false

//                        console.log("cameraComponent.fileInfo.path", cameraComponent.fileInfo.path);

                        if(!localStorage.getCountOfItems(folderInfoTableName)){
                            localStorage.insertToAlerts(folderInfoTableName, [{"field": "path", "value": cameraComponent.fileInfo.path}]);

                            console.log("The fileInfo path is added to the folderInfoTable", cameraComponent.fileInfo.path);
                        }
                    }
                }

                Component.onCompleted: {
                    isSupportFlash = AppFrameworkMultimedia.isCameraFlashModeSupported(camera, Camera.FlashOn);
                }
            }

//--------------------------------------------------------------------------------

            VideoOutput {
                id: videoOutPut
                source: camera
                autoOrientation: true
                anchors.fill: parent
                //orientation: rotationForVideo
                fillMode: VideoOutput.PreserveAspectFit

                PinchArea{
                    id: pinchArea
                    enabled: photoPreview.source==""
                    anchors.fill: parent
                    onPinchUpdated: {
                        cameraCurrentZoomScale = pinch.scale*cameraOldZoomScale
                        if(cameraCurrentZoomScale<1) cameraCurrentZoomScale=1.0
                        if(cameraCurrentZoomScale>camera.maximumDigitalZoom) cameraCurrentZoomScale = camera.maximumDigitalZoom
                        camera.setDigitalZoom(cameraCurrentZoomScale)
                    }
                    onPinchFinished: {
                        cameraOldZoomScale = Math.min(Math.max(cameraCurrentZoomScale,1.0),camera.maximumDigitalZoom)
                    }

                }
            }

//--------------------------------------------------------------------------------

            Rectangle{
                anchors.fill: parent
                color: "black"
                clip: true
                visible: photoPreview.source!=""
                Image {
                    id: photoPreview
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    autoTransform: true
                    clip: true
                }
            }

//------------------------ header bar --------------------------------------------------

            Rectangle{
                id: headerRec
                width: parent.width
                height: units(40)
                color: "#80000000"
                border.color: "pink"
                border.width: isDebug? 1:0

                Row{
                    height: parent.height
                    width: implicitWidth
                    layoutDirection: Qt.RightToLeft
                    anchors.right: parent.right
                    spacing: 0
                    Rectangle{
                        id: flashRec
                        width: parent.height
                        height: parent.height
                        color: "transparent"
                        border.color: "pink"
                        border.width: isDebug? 1:0
                        visible: isSupportFlash
                        Image{
                            id: flash_icon
                            anchors.fill: parent
                            anchors.margins: units(8)
                            fillMode: Image.PreserveAspectFit
                            source: "./images/flash_auto.png"
                        }

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                cameraFlashMode = (cameraFlashMode+1)%3;
                                switch(cameraFlashMode){
                                case 0:
                                    flash_icon.source = "./images/flash_auto.png";
                                    camera.flash.mode = Camera.FlashAuto;
                                    break;
                                case 1:
                                    flash_icon.source = "./images/flash_on.png";
                                    camera.flash.mode = Camera.FlashOn;
                                    break;
                                case 2:
                                    flash_icon.source = "./images/flash_off.png";
                                    camera.flash.mode = Camera.FlashOff;
                                    break;
                                }
                            }
                        }
                    }

                }

                FocusScope{
                    id: nameContainer
                    width: parent.width-parent.height*2
                    height: parent.height * 0.8
                    visible: false
                    anchors.left: closeBtn.right
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle{
                        id: nameRect
                        focus: false
                        anchors.fill: parent
                        radius: units(3)
                        color: name_textInput.focus? "white" : "transparent"
                    }

                    TextInput{
                        id: name_textInput
                        anchors.fill: parent
                        anchors.leftMargin: units(10)
                        anchors.rightMargin: units(10)
                        color: focus? "black" : "white"
                        readOnly: false
                        visible: true
                        cursorVisible: false
                        font.pixelSize: parseInt(height/2)
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: TextEdit.Wrap

                        property string fileExtension: ""
                        property string oldFileName: ""

                        onFocusChanged: {
                            if(focus) {
                                oldFileName = text;
                                fileExtension = text.split(".")[1];
                                text = text.split(".")[0];
                            }
                        }

                        onAccepted: {
                            text = text + "." + fileExtension;
                            focus = false;
                            cursorVisible = false;
                        }
                    }
                }

                Rectangle{
                    id: closeBtn
                    width: parent.height
                    height: parent.height
                    anchors.left: parent.left
                    color: "transparent"
                    border.color: "pink"
                    border.width: isDebug? 1:0
                    Image{
                        anchors.fill: parent
                        anchors.margins: units(8)
                        fillMode: Image.PreserveAspectFit
                        source: "./images/close.png"
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            dismissed(cameraComponent.filePath);
                            transitionOut(transition.centerIn);
                        }
                    }
                }

            }

//------------------------ footer bar ------------------------------------------------

            Rectangle{
                id: footerRec
                width: parent.width
                height: Math.max(parent.height/7,units(70))
                anchors{
                    bottom: parent.bottom
                    left:parent.left
                }

                color: "#80000000"
                Rectangle{
                    id: len
                    color: "transparent"
                    anchors.centerIn: parent
                    height: parent.height*0.6
                    width: parent.height*0.6
                    Image{
                        anchors.fill: parent
                        source:"./images/len.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea{
                        enabled: photoPreview.source==""
                        anchors.fill: parent
                        onPressed: {
                            len_pressed_anim.start()
                            pressed_time()
                            console.log("len pressed"+currentTime)
                        }

                        onReleased: {
                            len_released_anim.start()
                            console.log("len released"+currentTime);

                            if(isClicked()) {
                                len.visible = false
                                switcher.visible = false
                                flashRec.visible = false

                                photoNamePrefix = (photoNamePrefix !== "") ? "IMG-" + photoNamePrefix : "IMG";

                                var imageDate = new Date();
                                var imageName = photoNamePrefix + "-" +
                                        imageDate.getUTCFullYear().toString() +
                                        zeroPad(imageDate.getUTCMonth() + 1, 2) +
                                        zeroPad(imageDate.getUTCDate(), 2) +
                                        zeroPad(imageDate.getUTCHours(), 2) +
                                        zeroPad(imageDate.getUTCMinutes(), 2) +
                                        zeroPad(imageDate.getUTCSeconds(), 2) +
                                        ".jpg";

                                camera.imageCapture.captureToLocation(packageFolder.filePath(imageName))
//                                camera.imageCapture.captureToLocation(AppFramework.resolvedPathUrl("asset://"))
//                                camera.imageCapture.capture(imageName);
                                saveBtn.visible = true
                                deleteBtn.visible = true
                                busyIndicator.visible = true
                                busyIndicator.running = true
                                console.log("Clicked")
                            }
                        }
                    }

                    ParallelAnimation{
                        id: len_pressed_anim
                        NumberAnimation {
                            target: len
                            property: "height"
                            duration: 100
                            easing.type: Easing.InOutQuad
                            from: footerRec.height*0.6
                            to: footerRec.height*0.66
                        }

                        NumberAnimation {
                            target: len
                            property: "width"
                            duration: 100
                            easing.type: Easing.InOutQuad
                            from: footerRec.height*0.6
                            to: footerRec.height*0.66
                        }
                    }

                    ParallelAnimation{
                        id: len_released_anim
                        NumberAnimation {
                            target: len
                            property: "height"
                            duration: 100
                            easing.type: Easing.InOutQuad
                            from: footerRec.height*0.66
                            to: footerRec.height*0.6
                        }

                        NumberAnimation {
                            target: len
                            property: "width"
                            duration: 100
                            easing.type: Easing.InOutQuad
                            from: footerRec.height*0.66
                            to: footerRec.height*0.6
                        }
                    }
                }

                Rectangle{
                    id: switcher
                    color: "transparent"
                    visible: QtMultimedia.availableCameras.length > 1
                    height: parent.height*0.4
                    width: parent.height*0.4
                    anchors{
                        verticalCenter: parent.verticalCenter
                        right: len.left
                        rightMargin: Math.max(units(30), parent.width*0.15)
                    }

                    Image{
                        anchors.fill: parent
                        source:"./images/camera_swtich.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            switchCamera()
                            local_switcher_rotate_anim.start()
                        }
                    }


                    NumberAnimation {
                        id: local_switcher_rotate_anim
                        target: switcher
                        property: "rotation"
                        from: 0
                        to: 180
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                Rectangle{
                    id: saveBtn
                    color: "transparent"
                    height: parent.height*0.4
                    width: parent.height*0.4
                    visible: photoPreview.source!=""
                    anchors{
                        verticalCenter: parent.verticalCenter
                        right: parent.horizontalCenter
                        rightMargin: Math.max(units(30), parent.width*0.15)+parent.height*0.3
                    }

                    Image{
                        anchors.fill: parent
                        source:"./images/done_white.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            console.log("Image Saved")
                            photoPreview.source=""
                            flashRec.visible = isSupportFlash;
                            len.visible = true
                            switcher.visible = true
                            saveBtn.visible = false
                            deleteBtn.visible = false
                            nameContainer.visible = false

                            if(cameraComponent.fileInfo.fileName !== name_textInput.text){

                                var oldPath = cameraComponent.filePath.toString();
                                var newPath = oldPath.replace(cameraComponent.fileInfo.fileName, name_textInput.text);

                                console.log("**** ",oldPath, newPath, cameraComponent.fileInfo.fileName, name_textInput.text);

                                packageFolder.path = cameraComponent.fileInfo.filePath.toString().replace(cameraComponent.fileInfo.fileName,"")

                                if(packageFolder.renameFile(cameraComponent.fileInfo.fileName, name_textInput.text)){

                                    toast.toastText = "Image saved!"
                                    console.log("Camera Saved Image Path: ", cameraComponent.fileInfo.filePath.toString().replace(cameraComponent.fileInfo.fileName, name_textInput.text))
                                    cameraComponent.filePath = AppFramework.resolvedPathUrl(cameraComponent.fileInfo.filePath.toString().replace(cameraComponent.fileInfo.fileName, name_textInput.text))
                                } else{
                                    toast.toastText = "Failed to rename"
                                }

                                toast.start()
                            } else{
                                toast.toastText = "Image saved!"
                                toast.start()
                            }
                        }
                    }
                }

                Rectangle{
                    id: deleteBtn
                    color: "transparent"
                    height: parent.height*0.4
                    width: parent.height*0.4
                    visible: photoPreview.source!=""
                    anchors{
                        verticalCenter: parent.verticalCenter
                        left: len.visible? len.right: parent.horizontalCenter
                        leftMargin: len.visible? Math.max(units(30), parent.width*0.15):Math.max(units(30), parent.width*0.15)+parent.height*0.3
                    }
                    Image{
                        id: delete_icon
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        source: "./images/delete.png"
                    }

                    MouseArea{
                        anchors.fill: parent
                        onPressed: {
                            delete_icon.source="./images/delete_forever.png"
                        }
                        onReleased: {
                            delete_icon.source="./images/delete.png"
                            photoPreview.source=""
                            flashRec.visible = isSupportFlash;
                            len.visible = true
                            switcher.visible = true
                            saveBtn.visible = false
                            deleteBtn.visible = false
                            nameContainer.visible = false
                            packageFolder.removeFile(cameraComponent.fileInfo.fileName)
                            toast.toastText = "Image Removed"
                            toast.start()
                        }
                    }

                }
            }
        }

        onTransitionInCompleted: {
            cameraComponent.transitionInCompleted()
        }

        onTransitionOutCompleted: {
            cameraComponent.transitionOutCompleted()
        }
    }

    // text for debugging on mobile devices
    Rectangle{
        width: units(200)
        height: units(200)
        anchors.left: parent.left
        anchors.top: parent.top
        color: "white"
        visible: false
        Text {
            id: name
            text: "videooutput orientation: "+videoOutPut.orientation+"\n"+"imageview rotate: "+photoPreview.rotation+"\n"+"screen portait: "+Screen.orientation
            width: parent.width
            wrapMode: Text.Wrap
            anchors.centerIn: parent
            color:"black"
        }
    }

    ToastDialog{
        id: toast
        isDebug: false
        visible: false
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units(40)
        toastWidth: parent.width*0.8
        delay: 1000
        backgroundColor: "#888888"
        toastTextSize: appConfigData.fontSize11
        toastText: "Toast for the toast!"
    }

    BusyIndicator {
        id: busyIndicator
        visible: false
        running: false
        anchors.centerIn: parent
    }

    Component.onCompleted: {
        Screen.orientationUpdateMask = Qt.PortraitOrientation | Qt.InvertedLandscapeOrientation | Qt.InvertedPortraitOrientation | Qt.LandscapeOrientation
        camera.stop();
        Qt.inputMethod.hide();
    }

    function zeroPad(num, places) {
        var zero = places - num.toString().length + 1;
        return new Array(+(zero > 0 && zero)).join("0") + num;
    }
}
