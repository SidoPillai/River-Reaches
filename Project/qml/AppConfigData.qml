import QtQuick 2.5

Item {
    // App Variables
    property color themeColor: "#196fa6"
    property color themeColorGreen: "#5a9359"
    property color themeColorLightestGray: "#efefef"
    property color themeColorLighterGray: "#a9a9a9"
    property color themeColorLightGray: "#f8f8f8"
    property color themeColorGray: "#959595"
    property color themeColorDarkGray: "#828282"
    property color themeColorDarkerGray: "#6e6e6e"
    property color themeColorDarkestGray: "#595959"
    property color themeColorOffBlack: "#4c4c4c"

    property color toggleOnColor: "#0066ff"
    property color toggleOffColor: "#808080"
    property color toggleHandleColor: "white"
    property color toggleHandleBorderColor: "#959595"

    property string crowdsourceStoryMapURL: "https://services6.arcgis.com/TAVvcHO9Uf3mGozE/arcgis/rest/services/streamAppUserFootprints/FeatureServer/0"

    //font size
    property double fontSize8: 8 * app.scaleFactor
    property double fontSize10: 10 * app.scaleFactor
    property double fontSize11: 11 * app.scaleFactor
    property double fontSize12: 12 * app.scaleFactor
    property double fontSize14: 14 * app.scaleFactor
    property double fontSize16: 16 * app.scaleFactor
    property double fontSize18: 18 * app.scaleFactor
    property double fontSize20: 20 * app.scaleFactor
    property double fontSize22: 22 * app.scaleFactor
    property double fontSize24: 24 * app.scaleFactor
    property double fontSize28: 28 * app.scaleFactor

    property real topNavBarHeight: 50 * app.scaleFactor
    property real bottomBorderHeight: 1 * app.scaleFactor
    property color bottomBorderColor: "#efefef"
    property real defaultAppBtnHeight: 50 * app.scaleFactor
    property real defaultAppBtnHorizontalMargin: 5 * app.scaleFactor

    property string databaseName: "RiverReachesComponent"
    property string tableName: "river_reaches_2"

    property string stationIDFieldName: "egdb.DBO.LargeScale.station_id"
    property string anomalyFieldName: "egdb.dbo.short_term_current.anomaly"
    property string qOutFieldName: "egdb.dbo.short_term_current.qout"
    property string qDiffFieldName: "egdb.dbo.short_term_current.qdiff"
    property string timeValueFieldName: "egdb.dbo.short_term_current.timevalue"
    
    property int numOfItemsInShortTerm: 15
    property color riverChartItemOver14HoursColor: "#c7c7c7"

    //Top Nav Bar Variables
    property double navBarTitleTextFont: 16 * app.scaleFactor
    property real navBarClosePageBtnWidth: 50 * app.scaleFactor
    property real navBarClosePageBtnLeftMargin: 5 * app.scaleFactor


    // Welcome Page Config Data
    property color welcomePageWrapperBgColor: '#4a4a4a'

    property real bgImageOpacity: 0.8
    property string bgImageSource: "assets/images/river.png"

    property real appTitleTopMargin: 100 * app.scaleFactor
    property real appTitleHeight: 55 * app.scaleFactor
    property string appTitleText: "Stream Monitor"
    property double appTitleTextFont: 22 * app.scaleFactor
    property color appTitleTextColor: "white"

    property real startBtnHorizontalMargin: 80 * app.scaleFactor
    property real startBtnHeight: 55 * app.scaleFactor
    property color startBtnBorderColor: "white"
    property int startBtnRadius: 6
    property double startBtnFont: 18
    property string startBtnText: "GET STARTED"

    property real esriIconHorizontalMargin: 80 * app.scaleFactor
    property real esriIconBottomMargin: 90 * app.scaleFactor
    property real esriIconImgHeightRatio: 0.44
    property string esriIconImgSource: "assets/images/esri-transparent.png"


    // Add Item Page Config Data
    property color welcomeDialogGlowEffectColor: "#d7d7d7"

    property string addItemPageTitleText: "Choose a River"
//    property int addItemPageTitleTextFont: 16

    property real closeAddItemPageBtnWidth: 50 * app.scaleFactor
    property real closeAddItemPageBtnLeftMargin: 5 * app.scaleFactor
    property real closeAddItemPageBtnIconWidth: 20 * app.scaleFactor
    property real closeAddItemPageBtnIconHeight: 20 * app.scaleFactor
    property string closeAddItemPageBtnIconSource: "assets/images/close.png"

    property real addItemDialogHeight: 280 * app.scaleFactor
    property color addItemDialogColor: "#efefef"

    property real rectRiverReachInfoComponentDefaultHeight: 33 * app.scaleFactor
    property real rectRiverReachInfoComponentHeightOffset: 10 * app.scaleFactor
    property color riverInfoTitleTextColor: '#808080'
    property double riverInfoTitleTextFont: 12 * app.scaleFactor
    property real riverInfoTitleTextLeftMargin: 12 * app.scaleFactor

    property color riverInfoValueTextColor: '#636363'
    property color riverInfoValueEditTextColor: '#FF3232'
    property double riverInfoValueTextFont: 12 * app.scaleFactor

    property color saveItemBtnColor: 'black'
    property string saveItemBtnText: 'SAVE'
    property color saveItemBtnTextColor: '#efefef'
    property double saveItemBtnTextFont: 12 * app.scaleFactor

    property color editItemDialogColor: 'white'
    property real editItemDialogHeight: 80 * app.scaleFactor
    property real editItemDialogNavBarHeight: 30 * app.scaleFactor

    property color editItemTitleTextColor: '#636363'
    property double editItemTitleTextFont: 12 * app.scaleFactor

    property real editItemBtnHorizontalMargin: 5 * app.scaleFactor
    property color editItemBtnTextColor: '#636363'
    property double editItemBtnTextFont: 10 * app.scaleFactor
    property string closeEditItemDialogText: 'close'
    property string saveEditItemDialogText: 'done'

    property real editItemTextInputWrapperWidthOffset: 50 * app.scaleFactor
    property real editItemTextInputWrapperHeightOffset: 30 * app.scaleFactor
    property color editItemTextInputWrapperColor: "#efefef"
    property real editItemTextInputWrapperHeightRatio: 0.6
    property color editItemTextInputColor: "#151515"
    property double editItemTextInputFont: 12 * app.scaleFactor
    property real editItemTextInputWidthRatio: 0.9


    // Items Overview Page Config Data
    property string itemOverviewPageTitleText: "River Reaches"
    property double itemOverviewPageTitleTextFont: 18 * app.scaleFactor

    property real imgAddRiverReachBtnImgSize: 20 * app.scaleFactor
    property string imgAddRiverReachBtnImgSource: "assets/images/plus.png"

    property string openInfoPageBtnText: "info"
    property double openInfoPageBtnTextFont: 12 * app.scaleFactor

    property double sortBtnsTextFont: 12 * app.scaleFactor

    property real itemOverviewPageBottomBarHeight: 50 * app.scaleFactor
    property real itemOverviewPageBottomBarOpacity: 0.8
    property color itemOverviewPageBottomBarColor: "#000"
    property real bottomBarButtonUnderlineWidthRatio: 0.6
    property real bottomBarButtonUnderlineHeight: 2 * app.scaleFactor
    property real bottomBarButtonUnderlineBottomMargin: 6 * app.scaleFactor

    property real itemOverviewPageRiverReachNameLeftMargin: 10 * app.scaleFactor
    property real itemOverviewPageRiverReachStationIDRightMargin: 10 * app.scaleFactor

    property real imgShowDetailedInfoButtonSize: 20 * app.scaleFactor
    property string imgShowDetailedInfoButtonSource: "assets/images/arrow-right-light.png"

    property string removeItemButtonText: "remove"

    property real itemOverviewPageBottomBorder: 2 * app.scaleFactor

    // Set-Up Alert Page
    property string setUpAlertPageTitleText: "Set-Up Alert"

    //chart
    property double avgFlowIndicatorLineLabelTextFont: 9 * app.scaleFactor
    property double vRefLineTextFont: 8 * app.scaleFactor
}
