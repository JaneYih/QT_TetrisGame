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

    Component.onCompleted: {
        initViewArray();
        switchView(Tetris.PageViewType.LoginView);
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
        id: loginViewComponent
        LoginView {
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
        if (curViewObject !== null) {
            //curViewObject.visible = false;
        }

        curViewObject = viewObjectArray[viewType];
        curViewIndex = viewType;
        //curViewObject.visible = true;

        stackView.clear();
        stackView.push(curViewObject);
    }

    function initViewArray() {
        viewObjectArray = new Array(Tetris.PageViewType.PageViewCount);
        viewObjectArray[Tetris.PageViewType.LoginView] = createViewObject(Tetris.PageViewType.LoginView);
        viewObjectArray[Tetris.PageViewType.GameView] = createViewObject(Tetris.PageViewType.GameView);
        viewObjectArray[Tetris.PageViewType.ScoreView] = createViewObject(Tetris.PageViewType.ScoreView);
        viewObjectArray[Tetris.PageViewType.SettingView] = createViewObject(Tetris.PageViewType.SettingView);
    }

    function createViewObject(viewType) {
        var curComponent = null;
        switch (viewType) {
        case Tetris.PageViewType.LoginView:
            curComponent = loginViewComponent;
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
