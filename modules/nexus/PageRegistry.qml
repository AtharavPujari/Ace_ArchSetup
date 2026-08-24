pragma Singleton

import QtQuick

QtObject {
    id: root

    readonly property list<var> pages: [
        // 1. Appearance
        {
            pageIndex: 0,
            label: qsTr("Appearance"),
            icon: "palette",
            description: qsTr("Theme, wallpaper, style & layout"),
            category: "primary"
        },

        // 2. Shell
        {
            pageIndex: 1,
            label: qsTr("Shell"),
            icon: "dock_to_bottom",
            description: qsTr("Top bar, dashboard, launcher, sidebar"),
            category: "primary"
        },

        // 3. Notifications
        {
            pageIndex: 2,
            label: qsTr("Notifications"),
            icon: "notifications",
            description: qsTr("Popups, tray, do not disturb, app rules"),
            category: "primary"
        },

        // 4. Devices
        {
            pageIndex: 3,
            label: qsTr("Devices"),
            icon: "devices_other",
            description: qsTr("Audio, bluetooth, network & power"),
            category: "primary",
            noFill: true
        },

        // 5. System
        {
            pageIndex: 4,
            label: qsTr("System"),
            icon: "tune",
            description: qsTr("Default apps, clock format, temperature units"),
            category: "primary"
        },

        // 6. Secondary / Bottom
        {
            pageIndex: 5,
            label: qsTr("About"),
            icon: "info",
            description: qsTr("System specifications & shell version"),
            category: "secondary",
            isSecondary: true
        }
    ]
}
