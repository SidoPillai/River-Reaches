import QtQuick 2.5
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import ".."
Item {
    id: toastDialog
    property bool isDebug: false

    property int toastRadius: units(15)
    property alias toastWidth: toastContainer.width
    property int toastHight: units(44)
    property color backgroundColor: "#80000000"

    property string toastText: "Some toast!"
    property int toastTextSize: units(12)
    property color toastTextColor: theme.colorToastText
    property int transitionDuration: 500
    property int delay: 5000

    visible: false

    anchors.fill: parent

    Theme{
        id:theme
    }

    function units(num) {
        return num ? parseInt(num*AppFramework.displayScaleFactor) : 0
    }

    function start(){
        visible = true
        toastFadeInAnimation.start()
        timer.start()

    }

    Rectangle{
        id: toastContainer
//        border.color: Qt.lighter(backgroundColor)
//        border.width: units(3)
//        anchors.fill: toastText
        width: parent.width*0.95
        height: textInsideToast.contentHeight+units(12)
        clip: true
        radius: toastRadius
        color: backgroundColor
        anchors{
            horizontalCenter: parent.horizontalCenter

            top: parent.top
            topMargin: Math.min(parent.height-toastContainer.height-units(20),parent.height*0.8)
        }

        Text{
            id: textInsideToast
            text: toastText
            color: toastTextColor
            anchors.centerIn: parent
            horizontalAlignment:Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            maximumLineCount: 1
            font.pixelSize: toastTextSize
            font.bold: false
            width: parent.width
        }

    }

    DropShadow {
        id: toastShadow
        anchors.fill: toastContainer

        radius: units(4)
        samples: units(9)
        color: Qt.lighter(backgroundColor)
        source: toastContainer
    }

    NumberAnimation{
        id: toastFadeInAnimation
        properties: "opacity"
        targets: [toastShadow, toastContainer]
        from: 0.0
        to: 1.0
        duration: transitionDuration
        easing.type: Easing.InOutQuad
    }


    NumberAnimation{
        id: toastFadeOutAnimation
        properties: "opacity"
        targets: [toastShadow, toastContainer]
        from: 1.0
        to: 0.0
        duration: transitionDuration
        easing.type: Easing.InOutQuad
        onStopped: {
            visible:false
        }
    }

    Timer{
        id: timer
        interval: delay
        repeat:false
        running:false
        onTriggered: {
            toastFadeOutAnimation.start()
        }
    }

//    Component.onCompleted: toastFadeInAnimation.start()

}
