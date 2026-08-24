pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Shell")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: qsTr("Panels & Drawers")
        }

        NavRow {
            first: true
            icon: "dock_to_bottom"
            label: qsTr("Top Bar & Taskbar")
            status: Config.bar.persistent ? qsTr("Always visible") : Config.bar.showOnHover ? qsTr("Reveal on hover") : qsTr("Reveal on drag")
            onClicked: root.nState.openSubPage(2) // TaskbarPanel
        }

        NavRow {
            icon: "dashboard"
            label: qsTr("Dashboard Tray")
            status: Config.dashboard.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(1) // DashboardPanel
        }

        NavRow {
            icon: "apps"
            label: qsTr("App Launcher")
            status: Config.launcher.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(3) // LauncherPanel
        }

        NavRow {
            last: true
            icon: "dock_to_right"
            label: qsTr("Sidebar Drawer")
            status: Config.sidebar.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(4) // SidebarPanel
        }

        SectionHeader {
            text: qsTr("Workspace Navigation")
        }

        NavRow {
            first: true
            last: true
            icon: "workspaces"
            label: qsTr("Workspaces & Active Window")
            status: qsTr("Configure workspace buttons and window title indicators")
            onClicked: root.nState.openSubPage(5) // BarWorkspaces
        }
    }
}
