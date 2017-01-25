import QtQuick 2.5
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import QtQuick.Layouts 1.1
import ".."

Item {
    id: alertDialog
    signal closed()
    signal discard()
    signal transitionInCompleted()
    signal transitionOutCompleted()

    property bool isDebug: false

    property string titleText: "Title"
    property string descriptionText: "This is description!"
    property string buttonText: qsTr("OK")

    property int titleTextSize: 14
    property int descriptionTextSize: 12
    property int buttonTextSize: theme.fontBodySize

    property color titleTextColor: appConfigData.themeColorDarkGray
    property color descriptionTextColor: appConfigData.themeColorDarkGray
    property color buttonBorderColor: theme.colorButtonBorder
    property color buttonTextColor: theme.colorButtonText
    property color buttonBackgroundColor: theme.colorButtonFilling
    property alias maskBackgroundColor: _root.maskBackgroundColor

    property alias transitionDuration: _root.transitionDuration

    function units(num) {
        return num ? parseInt(num * AppFramework.displayScaleFactor) : 0
    }

    function close(){
        _root._closeAnimation()
    }

    function open(){
        _root._openAnimation()
    }

    Theme {
        id: theme
    }

    anchors.fill: parent

    BasicDialog{
        id: _root

        header: Rectangle{
            width: parent.width
            height: {return titleText>""? headerText.contentHeight:0}
            color: "transparent"
            border.color: "pink"
            border.width: isDebug ? 1 : 0
            Text {
                width: parent.width
                font.family: app.fontSourceSansProReg.name

                id: headerText
                text: titleText
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 2
                font.pixelSize: titleTextSize
                font.bold: false
                color: titleTextColor
            }
        }

        content: Rectangle{
            width: parent.width
            height: {descriptionText>""?contentText.contentHeight:0}   //fit the children
            color: "transparent"
            border.color: "pink"
            border.width: isDebug ? 1 : 0
            Text {
                id: contentText
                font.family: app.fontSourceSansProReg.name
                width: parent.width
                text: descriptionText
                font.pixelSize: descriptionTextSize
                wrapMode: Text.Wrap
                color: descriptionTextColor
            }
        }


        footer: Rectangle{
            anchors.fill: parent
            color: "transparent"
            border.color: "pink"
            border.width: isDebug ? 1 : 0

            Rectangle {
                width: parent.width * 0.9
                height: parent.height
                color: "transparent"
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: parent.width * 0.47
                    height: parent.height
                    color: appConfigData.themeColorGreen
                    anchors.left: parent.left

                    Text {
                        anchors.centerIn: parent
                        text: "stay"
                        color: "#fff"
                        font.pixelSize: 16
                        font.family: app.fontSourceSansProReg.name
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            closed();
                        }
                    }
                }

                Rectangle {
                    width: parent.width * 0.47
                    height: parent.height
                    color: appConfigData.themeColorGreen
                    anchors.right: parent.right

                    Text {
                        anchors.centerIn: parent
                        text: "discard"
                        color: "#fff"
                        font.pixelSize: 16
                        font.family: app.fontSourceSansProReg.name
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            discard();
                        }
                    }
                }
            }


//            RowLayout{
//                Layout.fillHeight: true
//                Layout.fillWidth: false
//                anchors.right: parent.right

//                layoutDirection: Qt.RightToLeft
//                spacing: units(8)

//                BasicButton {
//                    width: units(100)
//                    height: units(36)
//                    fillColor: true
//                    fontPointSize: buttonTextSize
//                    textColor: buttonTextColor
//                    backgroundColor: buttonBackgroundColor
//                    buttonText: alertDialog.buttonText
//                    onButtonClicked: {
//                        closed()
//                    }
//                }

//                BasicButton {
//                    width: units(100)
//                    height: units(36)
//                    fillColor: true
//                    fontPointSize: buttonTextSize
//                    textColor: buttonTextColor
//                    backgroundColor: buttonBackgroundColor
//                    buttonText: alertDialog.buttonText
//                    onButtonClicked: {
//                        closed()
//                    }
//                }
//            }
        }

        onTransitionInCompleted: {
            alertDialog.transitionInCompleted()
        }

        onTransitionOutCompleted: {
            alertDialog.transitionOutCompleted()
        }
    }
}

