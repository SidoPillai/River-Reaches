import QtQuick 2.5

Item {
    id: _root
    property var riverReachDataCollection: null
//    property url jsonFileUrl: "assets/river-reaches.json"
    property url jsonFileUrl: "file:///storage/emulated/0/DCIM/river-reaches.json"


    function createNewFeatureCollection() {
        var featureCollection = {
            "features": []
        };
        riverReachDataCollection = featureCollection;
    }

    function _createNewFeature(properties){
        var feature = {
            "type": "feature",
            "properties": properties
        };
        return feature;
    }

    function addNewFeature(stationID){

        if(!stationID){
            console.log("station ID is reqired to add new item to riverReachDataCollection");
            return;
        }

        var properties = {
            "stationID": stationID,
            "alerts": []
        };

        var item = _createNewFeature(properties);

        riverReachDataCollection.features.push(item);
    }

    function updateAlerts(stationID, alerts){
        for(var i = 0, len = riverReachDataCollection.features.length; i < len; i++){
            var feature = riverReachDataCollection.features[i];
            if(feature.properties.stationID === stationID) {
                feature.properties.alerts = alerts;
                break;
            }
        }
    }

    function removeFeature(stationID){
        for(var i = 0, len = riverReachDataCollection.features.length; i < len; i++){
            if(riverReachDataCollection.features[i].properties.stationID === stationID) {
                riverReachDataCollection.features.splice(i, 1);
                break;
            }
        }
    }

    function readFile(){
        var xmlhttp = new XMLHttpRequest();

        xmlhttp.onreadystatechange = function() {

            if (xmlhttp.readyState === XMLHttpRequest.DONE) {

                if(xmlhttp.status == 200){

                    var response = JSON.parse(xmlhttp.responseText);

                    for (var i = 0, len = response.features.length; i < len; i++) {

                        var alertsArray = response.features[i].properties.alerts;

                        for (var k = 0, alertsArrayLen = alertsArray.length; k < alertsArrayLen; k++) {

                            var alertObj = alertsArray[k];

                            console.log("alert info from json:", alertObj.notification_time);

                            if(!alertObj.notification_time) {
                               alertObj.notification_time = "0";
                            }

                            localStorage.updateAlertSendNotificationStatusByKey(app.tableNameForAlerts, alertObj.id, alertObj.send_notification, alertObj.notification_time);
                        }
                    }

                } else {
                    console.log("error when loads the jsonFile");
                }
            }
        }
        xmlhttp.open("GET", jsonFileUrl, true);
        xmlhttp.send();
    }

    function saveFile() {
        var text = JSON.stringify(riverReachDataCollection);
        var request = new XMLHttpRequest();
        request.open("PUT", jsonFileUrl, false);
        request.send(text);
        return request.status;
    }

}
