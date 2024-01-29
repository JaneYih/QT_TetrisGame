import QtQuick 2.9
import QtQuick.Controls 2.13
import Yih.Tetris.Business 1.0

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
            idleStateOpacity: 0.9
            imageSource: "qrc:/img/BtnBk.png"
            property alias btnText: btnText
            property var skipTargePage: TetrisBusiness.HomeView
            Text {
                id: btnText
                anchors.centerIn: parent
                font.family: "Arial"
                font.pointSize: 21
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
        spacing: 30

        Loader {
            id: gameViewBtnLoader
            sourceComponent: btnComponent
            onLoaded: {
                //item.btnText.text = qsTr("开始游戏");
                //item.btnText.color = "red"
                item.skipTargePage = TetrisBusiness.GameView;
                item.imageSource = "qrc:/img/StartGameBtn.png";
            }
        }

        Loader {
            id: scoreViewBtnLoader
            sourceComponent: btnComponent
            onLoaded: {
                item.btnText.text = qsTr("历史分数");
                item.btnText.color = "mediumblue"
                item.skipTargePage = TetrisBusiness.ScoreView;
            }
        }

        Loader {
            id: settingViewBtnLoader
            sourceComponent: btnComponent
            onLoaded: {
                item.btnText.text = qsTr("设置");
                item.btnText.color = "mediumblue"
                item.skipTargePage = TetrisBusiness.SettingView;
            }
        }
    }
}
