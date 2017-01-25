import QtQuick 2.5

Item {
    property var container
//    property bool showAlertLine: false

    property real absQDiffPctMaxValue: 0
    property real qDiffPctTempValue: 0
    property real avgFlowValue: 0
    property int avgAnomaly: 0

    property real alertValuePct: 0
    property real alertValueNum: 0

    property real chartWidthRatio: 0.95
    property color chartLineColor: "#efefef"

    property int numOfItems: 85

    property var riverReachPreviewChartModel: riverReachPreviewChartModel
    ListModel {
        id: riverReachPreviewChartModel
    }

    Component.onCompleted: {
//        console.log(container);
    }

    Rectangle {
        id: chartWrapper
        height: container.height
        width: container.width
        color: "transparent"
//        color: "#123456"

        // Rect as left border
        Rectangle {
            id: leftBorderLine
            width: 1 * app.scaleFactor
            height: parent.height
            color: chartLineColor
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: parent.width * ((1 - chartWidthRatio) * 0.7)
            }

            Text {
                id: leftBorderLineTxt
                text: ""
                color: appConfigData.themeColorLighterGray
                font.pixelSize: appConfigData.vRefLineTextFont
                font.family: app.fontSourceSansProReg.name
                maximumLineCount: 1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    top: parent.bottom
                }
            }
        }

        Text {
            id: chartLabelTop
            color: appConfigData.themeColorLighterGray
            font.pixelSize: appConfigData.fontSize8
            font.family: awesome.family
            text: awesome.loaded ? awesome.icons.fa_plus : ""
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
            anchors {
                top: parent.top
                right: leftBorderLine.left
                rightMargin: 3 * app.scaleFactor
            }
        }

        Text {
            id: chartLabelBottom
            color: appConfigData.themeColorLighterGray
            font.pixelSize: appConfigData.fontSize8
            font.family: awesome.family
            text: awesome.loaded ? awesome.icons.fa_minus : ""
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 1
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
            anchors {
                bottom: parent.bottom
                right: leftBorderLine.left
                rightMargin: 3 * app.scaleFactor
            }
        }

        // Rect as avgFlow indicator
        Rectangle {
            id: avgFlowIndicatorLine
            width: parent.width  * chartWidthRatio
            height: 1 * app.scaleFactor
            color: chartLineColor
            z: 999

            anchors {
                verticalCenter: parent.verticalCenter
                left: leftBorderLine.right
            }
        }

        Rectangle {
            id: avgFlowIndicatorLineLabel
            height: 10 * app.scaleFactor
            width: 100 * app.scaleFactor
            z: 999
            color: "transparent"

            anchors {
                left: parent.left
                leftMargin: parent.width * (1 - chartWidthRatio)
            }

            Text {
                id: avgFlowIndicatorLineLabelText
                color: appConfigData.themeColorLighterGray
                font.pixelSize: appConfigData.avgFlowIndicatorLineLabelTextFont
                font.family: app.fontSourceSansProReg.name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
            }
        }

        ListView {
            id: listRiverReachPreviewChart
            width: parent.width * (chartWidthRatio * 0.99)
            height: parent.height
            z: 999
            anchors {
                verticalCenter: parent.verticalCenter
                left: avgFlowIndicatorLine.left
//                rightMargin: 1 * app.scaleFactor
            }
            orientation: ListView.Horizontal
            clip: true
            delegate: riverReachPreviewChartDelegate
            model: riverReachPreviewChartModel
        }

        Component {
            id: riverReachPreviewChartDelegate

            Rectangle {
                id: barChartItem
                width: (isActiveAlertIndicator === false) ? (listRiverReachPreviewChart.width / numOfItems) - 10 * app.scaleFactor : (10 * app.scaleFactor)
                height: barChartItem.width
                radius: width * 0.5
                anchors {
                    left: parent.left
                    leftMargin: index * (listRiverReachPreviewChart.width / numOfItems)

                    bottom: (qdiff < 0) ? parent.bottom : undefined
                    bottomMargin: (qdiff < 0) ? (parent.height / 2 - height) * getChartItemMargin(qdiffpct) : undefined

                    top: (qdiff > 0) ? parent.top : undefined
                    topMargin: (qdiff > 0) ? (parent.height / 2  - height) * getChartItemMargin(qdiffpct) : undefined
                }
                opacity: 1
                color: (modelType == "shortTerm") ? appUtilityFunctions.getColorByAnomaly(anomaly) : appConfigData.riverChartItemOver14HoursColor
            }
        }

        // vertical reference line: 15 hours
        Rectangle {
            id: vRefLine2
            width: 1 * app.scaleFactor
            height: parent.height
            color: chartLineColor
            anchors {
                verticalCenter: parent.verticalCenter
                left: listRiverReachPreviewChart.left
                leftMargin: listRiverReachPreviewChart.width
            }

            Text {
                id: vRefLine2Txt
                text: "+15 Hrs"
                color: appConfigData.themeColorLighterGray
                font.pixelSize: appConfigData.vRefLineTextFont
                font.family: app.fontSourceSansProReg.name
                maximumLineCount: 1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    top: parent.bottom
                }
            }
        }
    }

    function createChart(data) {
        getRiverDataOnSuccessHandler(data);
    }

    function addAvgFlowIndicationLineLabel(value, isBelowAverage){

        avgFlowIndicatorLineLabelText.text = "Monthly Normal: " + value + " (cfs)";

//        alertAdjustTextInputNum.text = value;

        if(isBelowAverage){
            avgFlowIndicatorLineLabel.anchors.top = undefined;
            avgFlowIndicatorLineLabel.anchors.bottom = avgFlowIndicatorLine.top;

        } else {
            avgFlowIndicatorLineLabel.anchors.bottom = undefined;
            avgFlowIndicatorLineLabel.anchors.top = avgFlowIndicatorLine.bottom;
        }
    }

    function getChartItemMargin(qDiffPct){
        var marginRatio = ((Math.abs(absQDiffPctMaxValue) - Math.abs(qDiffPct)) / Math.abs(absQDiffPctMaxValue));
        return marginRatio;
    }

    function getRiverDataOnSuccessHandler(response) {

        var avgDiffPct = 0;
        var isBelowAverage = false;
        var shortTermDataStartTime = 0;

        absQDiffPctMaxValue = 0;
        qDiffPctTempValue = 0;
        avgFlowValue = 0;
        avgAnomaly = 0;

        riverReachPreviewChartModel.clear();

        numOfItems = response.length;

        for(var i = 0; i < response.length; i++) {

            var timeValue = response[i].attributes[appConfigData.timeValueFieldName];
            var qDiffPct = response[i].attributes[appConfigData.qDiffFieldName] / (response[i].attributes[appConfigData.qOutFieldName] - response[i].attributes[appConfigData.qDiffFieldName].toFixed(2));

            riverReachPreviewChartModel.append({
                "index": i + 1,
                "anomaly": response[i].attributes[appConfigData.anomalyFieldName],
                "qout": response[i].attributes[appConfigData.qOutFieldName].toFixed(2),
                "qdiff": response[i].attributes[appConfigData.qDiffFieldName].toFixed(2),
                "qdiffpct": qDiffPct.toFixed(3),
                "isActiveAlertIndicator": false,
                "modelType": (i < 15) ? "shortTerm" : "mediumTerm"
            });

            if(absQDiffPctMaxValue < Math.abs(qDiffPct)){
                absQDiffPctMaxValue = Math.abs(qDiffPct);
            }

            avgAnomaly += response[i].attributes[appConfigData.anomalyFieldName];

            if(!avgFlowValue){
                avgFlowValue = (response[i].attributes[appConfigData.qOutFieldName] - response[i].attributes[appConfigData.qDiffFieldName]);
            }

            if(!shortTermDataStartTime){
                shortTermDataStartTime = timeValue;
                leftBorderLineTxt.text = appUtilityFunctions.formatTimeData(shortTermDataStartTime);
            }

//            //populate values for the text labels along x-axis
//            if(i > 14 && i % 15 === 0) {
//                var dayDiff = appUtilityFunctions.getDayDiff(shortTermDataStartTime, timeValue);

//                var n = i/15;

//                switch(n) {
//                    case 2:
//                        vRefLine2Txt.text = "+" + dayDiff + " days";
//                        break;
//                    case 3:
//                        vRefLine3Txt.text = "+" + dayDiff + " days";
//                        break;
//                    case 4:
//                        vRefLine4Txt.text = "+" + dayDiff + " days";
//                        break;
//                    case 5:
//                        vRefLine5Txt.text = "+" + dayDiff + " days";
//                        break;
//                }
//            }

            avgDiffPct += qDiffPct;
        }

        avgAnomaly = avgAnomaly / numOfItems;

        if(absQDiffPctMaxValue < 2){
            absQDiffPctMaxValue = 2;
        } else {
            absQDiffPctMaxValue = absQDiffPctMaxValue * 1.5;
        }

        isBelowAverage = (avgDiffPct / numOfItems < 0) ? true : false;

        addAvgFlowIndicationLineLabel(Math.round(avgFlowValue), isBelowAverage);

    }

}
