import QtQuick 2.5
import QtQuick.LocalStorage 2.0

Item {
    id: _root
    property var db : null

    function initalizeDatabase(dataBaseName) {
        db = LocalStorage.openDatabaseSync(dataBaseName, "0.1", "SQLite database", 100000);
        console.log("Database ", databaseName , " is Ready!");
    }

    function createTable(tableName) {
        try {
            db.transaction(function(tx){
                tx.executeSql('CREATE TABLE IF NOT EXISTS ' + tableName + '(
                    station_id TEXT UNIQUE,
                    stream_name TEXT,
                    stream_order TEXT,
                    flow_rate TEXT,
                    anomaly TEXT,
                    avg_flow TEXT,
                    q_out TEXT,
                    q_diff TEXT,
                    alert_1 TEXT,
                    alert_2 TEXT,
                    alert_3 TEXT,
                    alert_4 TEXT,
                    x TEXT,
                    y TEXT
                )');
            });
        } catch (err) {
            console.log("Error creating table in database: " + err);
        };
    }

    function createTableForAlerts(tableName) {
        try {
            db.transaction(function(tx){
                tx.executeSql('CREATE TABLE IF NOT EXISTS ' + tableName + '(
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    station_id TEXT,
                    value TEXT,
                    alert_type TEXT,
                    alert_status TEXT,
                    send_notification TEXT NOT NULL DEFAULT "yes",
                    notification_time TEXT NOT NULL DEFAULT "0"
                )');
            });
        } catch (err) {
            console.log("Error creating table in database: " + err);
        };
    }

    function createFolderInfoTable(tableName) {
        try {
            db.transaction(function(tx){
                tx.executeSql('CREATE TABLE IF NOT EXISTS ' + tableName + '(
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    path TEXT
                )');
            });
        } catch (err) {
            console.log("Error creating table in database: " + err);
        };
    }

    function removeTable(tableName){
        db.transaction(function(tx) {
            tx.executeSql('DROP TABLE ' + tableName);
        });
    }

    function remove(tableName, stationID) {
        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM ' + tableName + ' WHERE station_id = ' + stationID + ';');
        });
    }

    function removeAll(tableName) {
        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM ' + tableName);
        });
    }

    function insert(tableName, data) {
        var station_id = data["station_id"];
        var stream_name = data["stream_name"];
        var stream_order = data["stream_order"];
        var flow_rate = data["flow_rate"];
        var anomaly = data["anomaly"];
        var avg_flow = data["avg_flow"];
        var q_out = data["q_out"];
        var q_diff = data["q_diff"];
        var alert_1 = data["alert_1"] || 0;
        var alert_2 = data["alert_2"] || 0;
        var alert_3 = data["alert_3"] || 0;
        var alert_4 = data["alert_4"] || 0;
        var x = data["x"];
        var y = data["y"];

        var values = [station_id, stream_name, stream_order, flow_rate, anomaly, avg_flow, q_out, q_diff, alert_1, alert_2, alert_3, alert_4, x, y];

        db.transaction( function(tx){
            var queryStr = 'INSERT OR REPLACE INTO ' + tableName +
                           '(station_id, stream_name, stream_order, flow_rate, anomaly, avg_flow, q_out, q_diff, alert_1, alert_2, alert_3, alert_4, x, y)' +
                           'VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
            tx.executeSql(queryStr, values);
        });
    }

    function insertToAlerts(tableName, data){
        var fields = [];
        var values = [];
        var valuePlaceholders = [];
        var queryStr = "";

        for(var i = 0; i < data.length; i++) {
            fields.push(data[i].field);
            valuePlaceholders.push("?");
            values.push(data[i].value);
        }

        queryStr = 'INSERT OR REPLACE INTO ' + tableName + ' (' + fields.join(", ") + ') ' + 'VALUES ( ' + valuePlaceholders.join(", ") + ')';

        db.transaction( function(tx){
            tx.executeSql(queryStr, values);
        });
    }

    function removeAlertByKey(tableName, id){
        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM ' + tableName + ' WHERE id = ' + id + ';');
        });
    }

    function removeAlertByStationID(tableName, stationID){
        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM ' + tableName + ' WHERE station_id = ' + stationID + ';');
        });
    }

    function updateAlertByKey(tableName, id, value, status, type){
        var values = [value, status, type];

        var queryStr = "UPDATE " + tableName + " SET value = ?, alert_status = ? , alert_type = ? WHERE id = " + id + "; ";

        db.transaction( function(tx){
            tx.executeSql(queryStr, values);
        });
    }

    function updateAlertSendNotificationStatusByKey(tableName, id, sendNotificationStatus, notificationTime){
        var values = [sendNotificationStatus, notificationTime];

        var queryStr = "UPDATE " + tableName + " SET send_notification = ?, notification_time = ? WHERE id = " + id + "; ";

        db.transaction( function(tx){
            tx.executeSql(queryStr, values);
        });
    }

    function queryAllValues(tableName) {
        var rs = null;
        db.transaction(function(tx) {
            var queryStr = 'SELECT * FROM ' + tableName + ';'
            rs = tx.executeSql(queryStr)
        });
        return rs;
    }

    function queryAllValuesByKey(tableName, station_id) {
        var rs = null;
        db.transaction(function(tx) {
            var queryStr = 'SELECT * FROM ' + tableName + ' WHERE station_id = ?;';
            rs = tx.executeSql(queryStr, [station_id])
        });
        return rs;
    }

    function queryAllAlertsByKey(tableName, station_id) {
        var rs = null;
        db.transaction(function(tx) {
            var queryStr = 'SELECT * FROM ' + tableName + ' WHERE alert_status = "active" AND station_id = ?;';
            rs = tx.executeSql(queryStr, [station_id])
        });
        return rs;
    }

    function queryByKey(tableName, station_id) {
        var res = null;
        db.transaction(function(tx) {
            var queryStr = 'SELECT * FROM ' + tableName + ' WHERE station_id = ?;';
            var rs = tx.executeSql(queryStr, [station_id]);
            res = rs.rows.item(0);
        });
        return res;
    }

    function getCountOfItems(tableName){
        var res = null;
        db.transaction(function(tx) {
            var queryStr = 'SELECT Count(*) as count FROM ' + tableName + ';';
            var rs = tx.executeSql(queryStr);
            res = rs.rows.item(0).count;
        });
        return res;
    }
}
