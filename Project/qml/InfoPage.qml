import QtQuick 2.5
import QtGraphicalEffects 1.0

Item {
    id: _root
    anchors.fill: parent
    visible: false

    signal closeButtonClicked()

    ListModel {
        id: infoContentModel

        ListElement {
            name: "description"
            title: "About this APP"
            value: "This App is designed for monitoring the river streamflow using the the <a target='_blank' href='http://doc.arcgis.com/en/living-atlas/item/?itemId=b9ec31770ee643509b942dfdec393b7f'>National Water Model</a> (NWM). This dataset provides the short term forecast, which is run every hour, predicting streamflow over the next fifteen hours at one hour intervals. Add river reaches by clicking on the features in the map, review the basic information and set the alerts. The app will be running as a background service to get the latest streamflow information for you selected river reaches on hourly basis, and will be sending you the notification if there are flows exceed above/drop below the alerts you set up in next 15 hours."
        }

        ListElement {
            name: "author"
            title: "Author Info"
            value: "Built by ArcGIS Content Team"
        }

        ListElement {
            name: "version number"
            title: "Version Number"
            value: "1.0.39"
        }
    }

    function show(){
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
        height: 50 * app.scaleFactor
        color: appConfigData.themeColorLightGray

        Text {
            id: titleText
            anchors.centerIn: parent
            text: "App Info"
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
            width: 50 * app.scaleFactor
            height: parent.height
            color: "transparent"
            anchors {
                left: parent.left
                leftMargin: 5 * app.scaleFactor
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
                    _root.visible = false;

                    closeButtonClicked();
                }
            }
        }
    }

    Rectangle {
        id: fullPageWrapper
        width: parent.width
        height: parent.height

//        color: "#363636"

        anchors {
            left: parent.left
            right: parent.right
            top: topNavBar.bottom
            topMargin: 10 * app.scaleFactor
            bottom: parent.bottom
        }

        Rectangle {
            id: infoContentWrapper
            width: parent.width
            height: parent.height - esriIconWrapper.height

            color: "transparent"

            anchors {
                top: parent.top
                bottom: esriIconWrapper.top
            }

            ListView {
                id: listInfoContentCards
                width: parent.width
                height: parent.height
                anchors {
                    top: parent.top
                }
                orientation: ListView.Vertical
                clip: true
                delegate: infoContentDelegate
                model: infoContentModel
            }

            Component {
                id: infoContentDelegate

                Rectangle {
                    id: rectInfoContentCard
                    width: parent.width
                    height: rectInfoContentCardTitle.height + rectInfoContentCardValue.height
                    color: "transparent"

                    Rectangle {
                        id: rectInfoContentCardTitle
                        width: parent.width
                        height: 25 * app.scaleFactor
                        color: "transparent"

                        anchors {
                            top: parent.top
                        }

                        Text {
                            id: rectInfoContentCardTitleText
                            text: title
                            color: appConfigData.themeColorLighterGray
                            font.pixelSize: appConfigData.fontSize10
                            font.family: app.fontSourceSansProReg.name
                            anchors.verticalCenter: parent.verticalCenter
                            wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                            anchors {
                                top: parent.top
                                topMargin: 10 * app.scaleFactor
                                left: parent.left
                                leftMargin: 25 * app.scaleFactor
                            }
                        }
                    }

                    Rectangle {
                        id: rectInfoContentCardValue
                        width: parent.width
                        height: Math.max(40 * app.scaleFactor, (rectInfoContentCardValueText.implicitHeight + (20 * app.scaleFactor)))
                        color: "transparent"

                        anchors {
                            bottom: parent.bottom
                        }

                        Text {
                            id: rectInfoContentCardValueText
                            width: parent.width
                            text: value
                            color: appConfigData.themeColorDarkGray
                            font.pixelSize: appConfigData.fontSize12
                            font.family: app.fontSourceSansProReg.name
                            anchors.verticalCenter: parent.verticalCenter
                            wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere

                            anchors {
                                left: parent.left
                                leftMargin: 25 * app.scaleFactor
                                right: parent.right
                                rightMargin: 25 * app.scaleFactor
                            }

                            onLinkActivated: {
                                Qt.openUrlExternally(link)
                            }
                        }
                    }

                    // Rect as the bottom border
                    Rectangle {
                        width: parent.width
                        height: 1 * app.scaleFactor
                        color: appConfigData.themeColorLighterGray

                        anchors {
                            bottom: parent.bottom
                        }
                    }

                }
            }
        }

        Rectangle {
            id: esriIconWrapper
            width: parent.width
            height: esriIconButton.height
            anchors {
                right: parent.right
                left: parent.left
                bottom: parent.bottom
                bottomMargin: 5 * app.scaleFactor
                leftMargin: 80 * app.scaleFactor
                rightMargin: 80 * app.scaleFactor
            }

            color: "transparent"

            Image {
                id: esriIconButton
                width: parent.width * 0.9
                height: width * 0.44
                source: "assets/images/esri-dark.png"
                anchors.centerIn: parent
            }
        }
    }

}
