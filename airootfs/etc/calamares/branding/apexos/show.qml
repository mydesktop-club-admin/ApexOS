import QtQuick 2.0
import calamares.slideshow 1.0

Presentation {
    id: presentation

    function nextSlide() {
        presentation.goToNextSlide();
    }

    Timer {
        id: advanceTimer
        interval: 9000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: nextSlide()
    }

    // Slide 1: Speed & Arch x86-64-v3 Core
    Slide {
        anchors.fill: parent

        Image {
            anchors.fill: parent
            source: "slide1.jpg"
            fillMode: Image.PreserveAspectCrop
            smooth: true
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#E6080B12" }
                GradientStop { position: 0.52; color: "#B8080B12" }
                GradientStop { position: 1.0; color: "#1A080B12" }
            }
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 44
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.50
            spacing: 14

            Text {
                text: "ARCH x86-64-v3 GAMING CORE"
                color: "#38BDF8"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1.8
            }

            Text {
                width: parent.width
                text: "Welcome to ApexOS"
                color: "#FFFFFF"
                font.pixelSize: 30
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width
                text: "Built on Arch Linux with x86-64-v3 optimized packages, a BORE low-latency gaming kernel, scx_lavd CPU scheduling, ananicy-cpp game priorities, and instant ZRAM memory compression."
                color: "#CBD5E1"
                font.pixelSize: 14
                lineHeight: 1.45
                wrapMode: Text.WordWrap
            }
        }
    }

    // Slide 2: NVIDIA Open + Steam / Proton Gaming
    Slide {
        anchors.fill: parent

        Image {
            anchors.fill: parent
            source: "slide2.jpg"
            fillMode: Image.PreserveAspectCrop
            smooth: true
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#E6080B12" }
                GradientStop { position: 0.52; color: "#B8080B12" }
                GradientStop { position: 1.0; color: "#1A080B12" }
            }
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 44
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.50
            spacing: 14

            Text {
                text: "NVIDIA WAYLAND & STEAM PROTON"
                color: "#34D399"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1.8
            }

            Text {
                width: parent.width
                text: "Tuned for Windows Games Out of the Box"
                color: "#FFFFFF"
                font.pixelSize: 30
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width
                text: "Preconfigured with NVIDIA Open Kernel Modules, KDE Plasma 6 Wayland, Steam, Proton, Gamescope, GameMode, MangoHud, NTSYNC, 10 GB shader caching, and low-latency kernel tweaks — ready to play on first boot."
                color: "#CBD5E1"
                font.pixelSize: 14
                lineHeight: 1.45
                wrapMode: Text.WordWrap
            }
        }
    }

    // Slide 3: Preinstalled App Suite
    Slide {
        anchors.fill: parent

        Image {
            anchors.fill: parent
            source: "slide3.jpg"
            fillMode: Image.PreserveAspectCrop
            smooth: true
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#E6080B12" }
                GradientStop { position: 0.52; color: "#B8080B12" }
                GradientStop { position: 1.0; color: "#1A080B12" }
            }
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 44
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.50
            spacing: 14

            Text {
                text: "CURATED DAILY & CREATOR SUITE"
                color: "#38BDF8"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1.8
            }

            Text {
                width: parent.width
                text: "Everything You Need, Zero Bloat"
                color: "#FFFFFF"
                font.pixelSize: 30
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width
                text: "Ships preloaded with Brave Browser, Shelly Package Manager (Arch, AUR & Flatpak in one place), Krita, VLC Media Player, ProtonVPN, and LibreOffice Fresh — ready from day one."
                color: "#CBD5E1"
                font.pixelSize: 14
                lineHeight: 1.45
                wrapMode: Text.WordWrap
            }
        }
    }

    // Slide 4: mydesktop.club Community & Studio
    Slide {
        anchors.fill: parent

        Image {
            anchors.fill: parent
            source: "slide4.jpg"
            fillMode: Image.PreserveAspectCrop
            smooth: true
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#E6080B12" }
                GradientStop { position: 0.52; color: "#B8080B12" }
                GradientStop { position: 1.0; color: "#1A080B12" }
            }
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 44
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.50
            spacing: 14

            Text {
                text: "MYDESKTOP.CLUB INTEGRATED"
                color: "#34D399"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1.8
            }

            Text {
                width: parent.width
                text: "Make Your Desktop Yours"
                color: "#FFFFFF"
                font.pixelSize: 30
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width
                text: "Launch the built-in MyDesktop Club desktop app anytime to browse uncompressed 4K & 8K community wallpapers, customize images in MyDesktop Studio, and connect in the Clubhouse."
                color: "#CBD5E1"
                font.pixelSize: 14
                lineHeight: 1.45
                wrapMode: Text.WordWrap
            }
        }
    }
}
