import QtQuick 2.5

Item {
    id: _root

    function getData(data, callback, errorHandler) {
        var xmlhttp = new XMLHttpRequest();
        var url = "http://livefeeds2.arcgis.com/arcgis/rest/services/NFIE/NationalWaterModel_Short_Anomaly/MapServer/4/query?where=egdb.DBO.LargeScale.station_id='" + data.stationID + "'&outFields=*&returnGeometry=false&resultRecordCount=100&f=pjson";

        xmlhttp.onreadystatechange = function() {
            if (xmlhttp.readyState === XMLHttpRequest.DONE) {

                if(xmlhttp.status == 200){

                    var responseObj = {
                        "riverData": data,
                        "responseText": xmlhttp.responseText
                    };
                    callback(responseObj);

                } else {
                    if(errorHandler){
                        errorHandler();
                    }
                }
            }
        }
        xmlhttp.open("GET", url, true);
        xmlhttp.send();
    }
}
