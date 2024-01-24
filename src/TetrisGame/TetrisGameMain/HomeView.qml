import QtQuick 2.9
import QtQuick.Controls 2.13

Rectangle {
    id: homeView
    color: "transparent"
    signal skipPage(var viewType);

    Image {
        id: backgroundImage
        anchors.fill: parent
        z: 0
        opacity: 1
        source: "qrc:/img/background.png"
    }

    Component {
        id: btnComponent
        ImageButton {
            id: btn
            width: 200
            height: 50
            idleStateOpacity: 0.7
            property alias btnText: btnText
            property var skipTargePage: Tetris.PageViewType.HomeView
            Text {
                id: btnText
                anchors.centerIn: parent
                font.family: "Arial"
                font.pointSize: 30
                font.weight: Font.Bold
                color: "red"
            }

            mouseArea.onClicked: {
                homeView.skipPage(skipTargePage);
            }
        }
    }

    Column {
        id: btnList
        anchors.centerIn: parent

        Loader {
            id: gameViewBtnLoader
            sourceComponent: btnComponent
            onLoaded: {
                item.btnText.text = qsTr("开始游戏");
                item.btnText.color = "red"
                item.skipTargePage = Tetris.PageViewType.GameView;
            }
        }

        Loader {
            id: scoreViewBtnLoader
            sourceComponent: btnComponent
            onLoaded: {
                item.btnText.text = qsTr("历史分数");
                item.btnText.color = "blueviolet"
                item.skipTargePage = Tetris.PageViewType.ScoreView;
            }
        }

        Loader {
            id: settingViewBtnLoader
            sourceComponent: btnComponent
            onLoaded: {
                item.btnText.text = qsTr("设置");
                item.btnText.color = "blue"
                item.skipTargePage = Tetris.PageViewType.SettingView;
            }
        }
    }
}
