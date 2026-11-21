// ApexOS Light — Non-Floating Bottom Taskbar with Left-Aligned Launcher & Ordered Icon-Only Task Manager
var plasma = getApiVersion(1);

var layout = {
    "desktops": [
        {
            "applets": [],
            "config": {
                "/": {
                    "ItemGeometriesHorizontal": "",
                    "formfactor": "0",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                },
                "/Wallpaper/org.kde.image/General": {
                    "Image": "/usr/share/wallpapers/ApexOSLight/contents/images/3840x2160.jpg"
                }
            },
            "wallpaperPlugin": "org.kde.image"
        }
    ],
    "panels": [
        {
            "alignment": "left",
            "applets": [
                {
                    "config": {
                        "/General": {
                            "favorites": [
                                "org.kde.dolphin.desktop",
                                "brave-browser.desktop",
                                "steam.desktop",
                                "gimp.desktop",
                                "org.kde.krita.desktop",
                                "vlc.desktop",
                                "org.kde.discover.desktop",
                                "systemsettings.desktop",
                                "org.kde.konsole.desktop",
                                "apexos-welcome.desktop",
                                "proton.vpn.app.gtk.desktop",
                                "mydesktop-club.desktop",
                                "apexos-updater.desktop",
                                "system-config-printer.desktop"
                            ],
                            "favoritesPortedToKAstats": false,
                            "icon": "/usr/share/pixmaps/apexos-launcher-white.svg"
                        }
                    },
                    "plugin": "org.kde.plasma.kickoff"
                },
                {
                    "config": {
                        "/General": {
                            "launchers": [
                                "applications:org.kde.dolphin.desktop",
                                "applications:brave-browser.desktop",
                                "applications:steam.desktop",
                                "applications:gimp.desktop",
                                "applications:org.kde.krita.desktop",
                                "applications:vlc.desktop",
                                "applications:org.kde.discover.desktop",
                                "applications:systemsettings.desktop"
                            ]
                        }
                    },
                    "plugin": "org.kde.plasma.icontasks"
                },
                { "plugin": "org.kde.plasma.panelspacer" },
                { "plugin": "org.kde.plasma.systemtray" },
                { "plugin": "org.kde.plasma.digitalclock" },
                { "plugin": "org.kde.plasma.showdesktop" }
            ],
            "floating": false,
            "height": 2.4,
            "hiding": "normal",
            "location": "bottom",
            "screen": 0
        }
    ],
    "serializationFormatVersion": "1"
};

plasma.loadSerializedLayout(layout);
