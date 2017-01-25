import QtQuick 2.5

Item {
    id: _root
    anchors.fill: parent

    property string stationID: ""
    property string streamName: ""
    property real qOut: 0
    property int anomaly: 3
    property real qDiffPct: 0

    property bool showAlertIcon: false
    property real alertValue: 0
    property int alertTime: 0
    property string alertType: ""

    property bool hideCameraIcon: false

    Rectangle {
        id: card
        height: topRect.height + bottomRect.height
        width: parent.width
        color: appConfigData.themeColorLightGray

        Rectangle {
            id: topRect
            width: parent.width
            height: 50 * app.scaleFactor
            anchors {
                top: parent.top
            }
            color: "transparent"

            Rectangle {
                id: riverReachInfoLeftWrapper
                width: parent.width * 0.8
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
                        text: streamName
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
                        text: appUtilityFunctions.numberWithCommas(qOut) + " cfs"
                        color: appUtilityFunctions.getColorByAnomaly(anomaly)
                        font.pixelSize: appConfigData.fontSize10
                        font.family: app.fontSourceSansProReg.name
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                        anchors {
                            left: parent.left
                            leftMargin: 10 * app.scaleFactor
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
                width: parent.width * 0.15
                height: parent.height
                anchors {
                    top: parent.top
                    right: parent.right
                }
                color: "transparent"
                visible: (!hideCameraIcon) ? true : false

                Text {
                    id: cameraButtonIcon
                    anchors.centerIn: parent
                    color: appConfigData.themeColorGreen
                    font.pixelSize: appConfigData.fontSize18
                    font.family: awesome.family
                    text: awesome.loaded ? awesome.icons.fa_camera : ""
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        console.log("open photo page");
                        photoPage.show(stationID);
                        itemDetailedInfoPage.hide();
                    }
                }
            }
        }

        Rectangle {
            id: bottomRect
            width: parent.width
            height: (parseInt(alertValue) !== 0) ? 20 * app.scaleFactor : 0 * app.scaleFactor
            anchors {
                bottom: parent.bottom
            }
            color: appConfigData.themeColorGray
            visible: (parseInt(alertValue) !== 0) ? true : false

            Text {
                text: (alertValue !== "0") ? streamName + " " + alertType + " " + appUtilityFunctions.numberWithCommas(alertValue) + " cfs" : ""
                color: "white"
                font.pixelSize: appConfigData.fontSize10
                font.family: app.fontSourceSansProReg.name
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                anchors {
                    left: parent.left
                    leftMargin: 10 * app.scaleFactor
                }
            }

            Text {
                text: (alertValue !== "0") ? "in " + appUtilityFunctions.formatAlertTime(alertTime): ""
                color: "white"
                font.pixelSize: appConfigData.fontSize10
                font.family: app.fontSourceSansProReg.name
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                anchors {
                    right: parent.right
                    rightMargin: 10 * app.scaleFactor
                }
            }
        }
    }
}
