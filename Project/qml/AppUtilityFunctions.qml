import QtQuick 2.5

Item {
    function getColorByAnomaly(anomaly){
        var color = {
            "5": "#003CAA",
            "4": "#7489B3",
            "3": "#909090",
            "2": "#be622d",
            "1": "#b40000"
        }
        return color[anomaly];
    }

    function getAnomalyIcon(anomaly){

        var anomalyIcon = "";

        if(anomaly > 3){
            anomalyIcon = 'fa_caret_up';
        } else if (anomaly < 3){
            anomalyIcon = 'fa_caret_down';
        } else {
            anomalyIcon = 'fa_circle';
        }

        return anomalyIcon;
    }

    function getAnomalyLabel(anomaly){
        var label = '';

        if(anomaly > 3){
            label = 'Above Normal';
        } else if (anomaly < 3){
            label = 'Below Normal';
        } else {
            label = 'Normal';
        }
        return label;
    }

    function formatTimeData(timevalue){
        var date = new Date(timevalue);

        function addZero(i) {
            if (i < 10) {
                i = "0" + i;
            }
            return i;
        }

        var day = date.getDate();
        var monthIndex = date.getMonth() + 1;
        var year = date.getFullYear();
        var hours = date.getHours();
        var minutes = date.getMinutes().toString().substring(0, 2);
        var dayDivider = (hours < 12) ? ' AM' : ' PM';

        return addZero(hours) + ':' + addZero(minutes);

//        return monthIndex + '/'+ day + '/' + year + ' ' + addZero(hours) + ':' + addZero(minutes);
    }

    function numberWithCommas(num) {

        var locale = Qt.locale("en_US");

        num = parseFloat(num).toLocaleString(locale);

        var numParts = num.split(".");

        if(!numParts[1]){
            num = numParts[0];
        } else {
            if(numParts[1] === "00") {
                num = numParts[0];
            } else {
                num = numParts[0] + "." + numParts[1].replace(/^0+|0+$/g, "");
            }
        }

        return num;
    }

    function getDayDiff(startDate, endDate){
        var date1 = new Date(startDate);
        var date2 = new Date(endDate);
        var timeDiff = Math.abs(date2.getTime() - date1.getTime());
        var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));

        return diffDays;
    }

    function getHourDiff(fromTime, toTime){
        fromTime = new Date(fromTime).getTime();
        var diff = toTime - fromTime;
        diff = diff / 60 / 60 / 1000;

        return diff;
    }

    function formatAlertTime(alertTimeInHours){

        var formattedAlertTime = "";
        var numOfDay;
        var formattedDayTxt;
        var numOfHrs;
        var formattedHrsTxt;

        if(+alertTimeInHours <= 24) {
            formattedHrsTxt = (alertTimeInHours === 1) ? "hr" : "hrs";
            formattedAlertTime = alertTimeInHours + " " + formattedHrsTxt;
        } else {
            numOfDay = Math.floor(alertTimeInHours/24);
            formattedDayTxt = (numOfDay === 1) ? "day" : "days";
            numOfHrs = (alertTimeInHours % 24);
            numOfHrs = (numOfHrs < 0) ? 0 : numOfHrs;
            formattedHrsTxt = (numOfHrs === 1 || numOfHrs === 0 ) ? "hr" : "hrs";
            formattedAlertTime = [numOfDay, formattedDayTxt, numOfHrs, formattedHrsTxt].join(" ");
        }

        return formattedAlertTime;
    }
}
