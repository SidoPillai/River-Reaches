import QtQuick 2.5
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import ".."
Item {
    property bool isDebug: false
    property real aspectRatio: 1/2
    property color backgroundColor: theme.colorButtonBorder

    property string busyText: qsTr("Loading...")
    property int busyTextSize: theme.fontTitleSize
    property color busyTextColor: theme.colorBody
    property string indicatorImageName: "loading.gif"

    property int transitionDuration: 200

    Theme{
        id:theme
    }

    function units(num) {
        return num ? parseInt(num*AppFramework.displayScaleFactor) : 0
    }

    function open() {
        busyFadeInAnimation.start();
    }

    function close(){
        busyFadeOutAnimation.start();
    }

    anchors.fill: parent

    Rectangle{
        id: busyContainer
        border.color: "#000000"
        border.width: isDebug? 1: 0

        width: height/aspectRatio
        height: textInside.contentHeight+loadingImage.height+units(48)
        radius: units(4)
        clip: true
        color: backgroundColor
        anchors{
            centerIn: parent
        }

        Rectangle{
            color: "transparent"
            anchors{
                fill: parent
                centerIn: parent
                margins: units(24)
            }
            AnimatedImage{
                id: loadingImage
                anchors.horizontalCenter: parent.horizontalCenter
                width: units(40)
                height: units(40)
                anchors.top: parent.top
                source: {return "images/"+indicatorImageName}
            }

            Text{
                id: textInside
                anchors.top: loadingImage.bottom
                text: busyText
                color: busyTextColor
                horizontalAlignment:Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 1
                font.pixelSize: busyTextSize
                font.bold: false
                width: parent.width
            }
        }

        states: State{
            when: (busyContainer.opacity==0.0)
            PropertyChanges {target: busyContainer; visible: false}
        }

    }

    NumberAnimation{
        id: busyFadeInAnimation
        properties: "opacity"
        targets: [busyContainer]
        from: 0.0
        to: 1.0
        duration: transitionDuration
        easing.type: Easing.InOutQuad
    }


    NumberAnimation{
        id: busyFadeOutAnimation
        properties: "opacity"
        targets: [busyContainer]
        from: 1.0
        to: 0.0
        duration: transitionDuration
        easing.type: Easing.InOutQuad
    }

    Component.onCompleted: busyFadeInAnimation.start()

}
