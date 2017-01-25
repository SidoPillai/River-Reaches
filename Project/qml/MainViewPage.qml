import QtQuick 2.5
//import QtQuick.Window 2.2

import "Components" as Components

Item {

    id: _root
    anchors.fill: parent

    Component.onCompleted: {
        localStorage.initalizeDatabase(app.databaseName);
        localStorage.createTable(app.tableName);
        localStorage.createTableForAlerts(app.tableNameForAlerts);
        localStorage.createFolderInfoTable(app.tableNameForFolderInfo);

        jsonFileManager.readFile();

        itemsOverviewPage.show();
    }

    ItemsOverviewPage {
        id: itemsOverviewPage

        onShowDetailedPageClicked: {
            itemsOverviewPage.hide();
            itemDetailedInfoPage.show(itemData);
        }

        onAddNewItemButtonClicked: {
            itemsOverviewPage.hide();
            addItemPage.show();
        }

        onOpenInfoPageButtonClicked: {
            itemsOverviewPage.hide();
            infoPage.show();
        }

        onOpenAddRiverReachTriggered: {
            itemsOverviewPage.hide();
            addItemPage.init();
        }
    }

    AddItemPage {
        id: addItemPage

        onCloseButtonClicked: {
            itemsOverviewPage.show();
        }

        onOpenReviewItemClicked: {
            addItemPage.hide();
            itemDetailedInfoPage.show(itemData);
        }
    }

    ItemDetailedInfoPage {
        id: itemDetailedInfoPage

        onCloseButtonClicked: {
            addItemPage.hide();
            itemsOverviewPage.show();
        }

        onBackToAddItemPage: {
            addItemPage.show();
        }

        onBackToOverviewPage: {
            itemsOverviewPage.show();
        }

        onEditAlertButtonClicked: {
            itemDetailedInfoPage.hide();
            alertEditPage.show(itemData);
        }

        onAddAlertButtonClicked: {
            itemDetailedInfoPage.hide();
            alertEditPage.show(itemData);
        }
    }

    AlertEditPage {
        id: alertEditPage

        onCloseButtonClicked: {
            itemDetailedInfoPage.show();
            alertEditPage.hide();
        }
    }

    PhotoPage {
        id: photoPage
    }

    InfoPage {
        id: infoPage

        onCloseButtonClicked: {
            itemsOverviewPage.show();
        }
    }

    Components.BusyDialog{
        id: busyDialog
        isDebug: false
        backgroundColor: appConfigData.themeColorLightGray
        busyTextColor: appConfigData.themeColorGreen
        busyTextSize: appConfigData.fontSize10
        aspectRatio: 1
        busyText: "Loading..."
        indicatorImageName: "loading.gif"
    }
}
