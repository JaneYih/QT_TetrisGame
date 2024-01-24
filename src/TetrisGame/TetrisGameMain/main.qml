import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.13

Window {
    id: mainWin
    visible: true
    height:480
    width:640
    title: "TetrisGameMain"
    property var viewObjectArray: null
    property var curViewObject: null
    property var curViewIndex: 0
    property var nextViewIndex: 0

    Component.onCompleted: {
        initViewObjectArray();
        backHomePage();
    }

    ImageButton {
        id: btnBackHome
        visible: curViewIndex !== Tetris.PageViewType.HomeView
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        imageSource: "qrc:/img/HomeIcon.png"
        mouseArea.onClicked: {
            backHomePage();
        }
    }

   ImageButton {
        id: btnPageDown
        //visible: curViewIndex < Tetris.PageViewType.PageViewCount-1
        visible: false
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        imageSource: "qrc:/img/PageDownIcon.png"
        mouseArea.onClicked: {
            pageDown();
        }
    }

    ImageButton {
        id: btnPageUp
        //visible: curViewIndex > 0
        visible: false
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        imageSource: "qrc:/img/PageUpIcon.png"
        mouseArea.onClicked: {
            pageUp();
        }
    }

    StackView {
        id: stackView
        z: 0
        anchors.fill: parent
    }

    Component {
        id: connectionsComponent
        Connections {
            onSkipPage: {
              switchView(viewType);
            }
        }
    }

    Component {
        id: homeViewComponent
        HomeView {
            id: homeView
            Component.onCompleted: {
                connectionsComponent.createObject(mainWin, {target: homeView});
            }
        }
    }

    Component {
        id: gameViewComponent
        GameView {
            id: gameView
            Component.onCompleted: {
                connectionsComponent.createObject(mainWin, {target: gameView});
            }
        }
    }

    Component {
        id: scoreViewComponent
        ScoreView {
            id: scoreView
            Component.onCompleted: {
                connectionsComponent.createObject(mainWin, {target: scoreView});
            }
        }
    }

    Component {
        id: settingViewComponent
        SettingView {
            id: settingView
            Component.onCompleted: {
                connectionsComponent.createObject(mainWin, {target: settingView});
            }
        }
    }

    function backHomePage() {
        switchView(Tetris.PageViewType.HomeView);
    }

    function pageUp() {
        var newIndex = curViewIndex - 1;
        if (newIndex < 0) {
            return;
        }
        switchView(newIndex);
    }

    function pageDown() {
        var newIndex = curViewIndex + 1;
        if (newIndex >= Tetris.PageViewType.PageViewCount) {
            return;
        }
        switchView(newIndex);
    }

    function switchView(viewType) {
        if ((viewType === curViewIndex && curViewObject !== null)
            || viewType >= viewObjectArray.length) {
            return;
        }

        var nextViewObject = viewObjectArray[viewType];
        if (nextViewObject === null) {
            return;
        }

        //滑动页面跳转
        nextViewIndex = viewType;
        var nextItem = stackView.find(function (item, index) {
                                        return item === viewObjectArray[nextViewIndex];
                                        //return index === nextViewIndex;
                                      });
        if (nextItem !== null) {
             stackView.pop(nextItem, StackView.PopTransition);
        }
        else {
            for (var i = stackView.depth; i <= viewType; i++) {
                stackView.push(viewObjectArray[i], StackView.PushTransition);
            }
        }

        curViewObject = nextViewObject;
        curViewIndex = viewType;
    }

    function initViewObjectArray() {
        viewObjectArray = new Array(Tetris.PageViewType.PageViewCount);
        viewObjectArray[Tetris.PageViewType.HomeView] = createViewObject(Tetris.PageViewType.HomeView);
        viewObjectArray[Tetris.PageViewType.GameView] = createViewObject(Tetris.PageViewType.GameView);
        viewObjectArray[Tetris.PageViewType.ScoreView] = createViewObject(Tetris.PageViewType.ScoreView);
        viewObjectArray[Tetris.PageViewType.SettingView] = createViewObject(Tetris.PageViewType.SettingView);
    }

    function createViewObject(viewType) {
        var curComponent = null;
        switch (viewType) {
        case Tetris.PageViewType.HomeView:
            curComponent = homeViewComponent;
            break;
        case Tetris.PageViewType.GameView:
            curComponent = gameViewComponent;
            break;
        case Tetris.PageViewType.ScoreView:
            curComponent = scoreViewComponent;
            break;
        case Tetris.PageViewType.SettingView:
            curComponent = settingViewComponent;
            break;
        default:
            return null;
        }
        var obj = curComponent.createObject(mainWin, {visible: false});
        /*if (obj !== null) {
            connectionsComponent.createObject(mainWin, {target: obj});
        }*/
        return obj;
    }
}
