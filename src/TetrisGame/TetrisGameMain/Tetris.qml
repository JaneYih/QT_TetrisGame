import QtQuick 2.3

Item {
    id: tetrisItem
    enum GameState {
        Ready = 0,
        Start,
        Running,
        Pause,
        Over
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
