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
        switchView(Tetris.PageViewType.HomeView);
    }

    StackView {
        id: stackView
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var newIndex = curViewIndex + 1;
                if (newIndex >= Tetris.PageViewType.PageViewCount) {
                    newIndex = 0;
                }
                switchView(newIndex);
            }
        }
    }

    Component {
        id: homeViewComponent
        HomeView {
        }
    }

    Component {
        id: gameViewComponent
        GameView {
        }
    }

    Component {
        id: scoreViewComponent
        ScoreView {
        }
    }

    Component {
        id: settingViewComponent
        SettingView {
        }
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
        return curComponent.createObject(mainWin, {visible: false});
    }
}
