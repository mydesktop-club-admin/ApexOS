import QtQuick

Rectangle {
    id: root
    color: "#B9C8DF"

    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true;
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.7
        height: width
        radius: width / 2
        color: "#D5E0F0"
        opacity: 0.7
    }

    Item {
        id: content
        anchors.centerIn: parent
        width: 320
        height: 210
        opacity: 0

        Column {
            anchors.centerIn: parent
            spacing: 20

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 96
                height: 96
                radius: 24
                color: "#3B5BDB"

                Image {
                    anchors.centerIn: parent
                    source: "file:///usr/share/pixmaps/apexos-launcher-white.svg"
                    sourceSize.width: 60
                    sourceSize.height: 60
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "ApexOS"
                color: "#13203A"
                font.pixelSize: 24
                font.weight: Font.DemiBold
                font.letterSpacing: 1.4
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 220
                height: 4
                radius: 2
                color: "#96ACD0"
                clip: true

                Rectangle {
                    height: parent.height
                    radius: 2
                    color: "#3B5BDB"
                    width: Math.min(parent.width, (parent.width / 6) * Math.max(1, root.stage))

                    Behavior on width {
                        NumberAnimation {
                            duration: 280
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        target: content
        from: 0
        to: 1
        duration: 450
        easing.type: Easing.OutCubic
    }
}
