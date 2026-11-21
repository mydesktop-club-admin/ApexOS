import QtQuick

Rectangle {
    id: root
    color: "#05070D"

    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true;
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.65
        height: width
        radius: width / 2
        color: "#0A84FF"
        opacity: 0.08
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

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "file:///usr/share/pixmaps/apexos-launcher-white.svg"
                sourceSize.width: 96
                sourceSize.height: 96
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "ApexOS"
                color: "#F5F5F7"
                font.pixelSize: 24
                font.weight: Font.DemiBold
                font.letterSpacing: 1.4
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 220
                height: 4
                radius: 2
                color: "#172238"
                clip: true

                Rectangle {
                    height: parent.height
                    radius: 2
                    color: "#0A84FF"
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
