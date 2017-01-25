import QtQuick 2.2


Item {
    id: _root

    // Configurable variables


    Component.onCompleted: {
//        startUp();
    }

    function startUp(){
        itemsOverviewPage.getAllRiverReachItems(getRiverDataOnSuccessHandler);
    }

    function getRiverDataOnSuccessHandler(result){

        var streamName = result.riverData.streamName;

        var response = JSON.parse(result.responseText);

        var alerts = itemsOverviewPage.getAlertsDataFromDB(result.riverData.stationID);

        response = itemsOverviewPage.arrangeRiverDataByTime(response.features);

        for(var i = 0, len = alerts.length; i < len; i++){

            var id = alerts[i].id;
            var stationID = alerts[i].station_id;
            var alertValue = alerts[i].value;
            var alertStatus = alerts[i].status;
            var alertType = alerts[i].type;
            var sendNotification = alerts[i].send_notification;
            var notificationTime = alerts[i].notification_time;

            checkAlertValue(response, alertValue, alertType, streamName, id, sendNotification, notificationTime);
        }
    }

    function checkAlertValue(riverWaterFlowData, alertValue, alertType, streamName, OID, sendNotificationStatus, notificationTime){

        //if "send_notification" equals "yes", check response to see if notification needs to be sent
        if(sendNotificationStatus === "yes") {

            var previousQout = 0;

            for(var i = 0, len = parseInt(appConfigData.numOfItemsInShortTerm); i < len; i++){

                var qOut = riverWaterFlowData[i].attributes[appConfigData.qOutFieldName];

                var timeValue = riverWaterFlowData[i].attributes[appConfigData.timeValueFieldName];

                if(previousQout){

                    if(qOut > previousQout && qOut >= parseFloat(alertValue) && parseFloat(alertValue) > previousQout && alertType === "increase"){
                        triggerNotification(streamName, alertValue, alertType, timeValue);
                        toggleSendNotificationStatus(OID, timeValue, false);
                        break;
                    }

                    if(previousQout > qOut && parseFloat(alertValue) >= qOut && parseFloat(alertValue) < previousQout && alertType === "decrease"){
                        triggerNotification(streamName, alertValue, alertType, timeValue);
                        toggleSendNotificationStatus(OID, timeValue, false);
                        break;
                    }
                }

                previousQout = qOut;
            }

        }

        //if "send_notification" equals "no", check response to see if "send_notification" can be reset to "yes" when value drops below or increases above the alert value
        if(sendNotificationStatus === "no") {

            var epochTimeForNow = parseInt(new Date().getTime());

            notificationTime = parseInt(notificationTime);

            if(epochTimeForNow > notificationTime) {

                if(alertType === "increase" && riverWaterFlowData[0].attributes[appConfigData.qOutFieldName] < alertValue){
                    toggleSendNotificationStatus(OID, "0", true);
                }

                if(alertType === "decrease" && riverWaterFlowData[0].attributes[appConfigData.qOutFieldName] > alertValue){
                    toggleSendNotificationStatus(OID, "0", true);
                }
            }
        }
    }

    function triggerNotification(streamName, alertValue, alertType, alertTime){
        var message = streamName + " " + alertType + " to " + alertValue;

        //trigger the notification
        console.log("triggerNotification", message);
    }

    function toggleSendNotificationStatus(OID, notificationTime, status){
        var sendNotificationStatus = (status) ? "yes" :  "no";
//        console.log("toggleSendNotificationStatus", OID);
        localStorage.updateAlertSendNotificationStatusByKey(app.tableNameForAlerts, OID, sendNotificationStatus, notificationTime);
    }

}
