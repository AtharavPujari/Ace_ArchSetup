pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia
import Caelestia.Config
import qs.components
import qs.components.effects
import qs.services
import qs.utils

Item {
    id: root

    required property ScreenState screenState
    readonly property var topBar: ShellState.componentsFor(screenState.modelData)?.topBar

    readonly property real screenCenterX: {
        if (topBar && topBar.clockPill) {
            return topBar.clockPill.mapToItem(null, topBar.clockPill.width / 2, 0).x;
        }
        return (parent ? parent.width / 2 : 0);
    }

    readonly property real screenBottomY: {
        if (topBar && topBar.clockPill) {
            return topBar.clockPill.mapToItem(null, 0, topBar.clockPill.height).y;
        }
        return 0;
    }

    readonly property point localPos: {
        if (parent) {
            return parent.mapFromItem(null, screenCenterX, screenBottomY);
        }
        return Qt.point(screenCenterX, screenBottomY);
    }

    x: Math.round(localPos.x - width / 2)
    y: Math.round(localPos.y + Tokens.spacing.small + animOffsetY)

    property var notifData: null
    property bool shown: false

    property real animOffsetY: shown ? 0 : -10
    property real animOpacity: shown ? 1 : 0

    visible: animOpacity > 0
    implicitWidth: Math.min(380, Math.max(260, layout.implicitWidth + Tokens.padding.medium * 2))
    implicitHeight: layout.implicitHeight + Tokens.padding.small * 2

    Behavior on animOffsetY {
        Anim {
            duration: root.shown ? 200 : 160
            easing.type: Easing.OutCubic
        }
    }

    Behavior on animOpacity {
        Anim {
            duration: root.shown ? 200 : 160
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        id: dismissTimer

        interval: 4000
        repeat: false
        onTriggered: root.shown = false
    }

    Connections {
        target: Notifs

        function onNewNotification(notif): void {
            if (Notifs.dnd)
                return;
            root.notifData = notif;
            root.shown = true;
            dismissTimer.restart();
        }
    }

    StyledRect {
        id: card

        anchors.fill: parent
        opacity: root.animOpacity

        color: Colours.tPalette.m3surfaceContainer
        radius: Tokens.rounding.medium
        border.color: Colours.palette.m3outlineVariant
        border.width: 1

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: dismissTimer.stop()
            onExited: {
                if (root.shown)
                    dismissTimer.restart();
            }

            onClicked: {
                root.shown = false;
                const notifIndex = Config.dashboard.showDashboard ? 1 : 0;
                root.screenState.dashboardTab = notifIndex;
                root.screenState.dashboard = true;
            }

            RowLayout {
                id: layout

                anchors.fill: parent
                anchors.margins: Tokens.padding.medium
                spacing: Tokens.spacing.small

                // App Icon / Category Badge
                Loader {
                    asynchronous: true
                    active: root.notifData !== null
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: 2
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24

                    sourceComponent: Item {
                        width: 24
                        height: 24

                        Loader {
                            active: (root.notifData?.resolvedAppIcon?.length ?? 0) > 0
                            anchors.centerIn: parent
                            width: 16
                            height: 16

                            sourceComponent: ColouredIcon {
                                anchors.fill: parent
                                source: root.notifData?.resolvedAppIcon ?? ""
                                colour: Colours.palette.m3primary
                            }
                        }

                        Loader {
                            active: (root.notifData?.resolvedAppIcon?.length ?? 0) === 0
                            anchors.fill: parent

                            sourceComponent: MaterialIcon {
                                anchors.centerIn: parent
                                text: Icons.getNotifIcon(root.notifData?.summary ?? "", root.notifData?.urgency ?? 0)
                                color: Colours.palette.m3primary
                                fontStyle: Tokens.font.icon.small
                            }
                        }
                    }
                }

                // Notification Header & Text Body
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            text: root.notifData?.appName ?? qsTr("Notification")
                            font: Tokens.font.label.small
                            color: Colours.palette.m3onSurfaceVariant
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: root.notifData?.timeStr ?? ""
                            font: Tokens.font.label.small
                            color: Colours.palette.m3outline
                        }
                    }

                    StyledText {
                        text: root.notifData?.summary ?? ""
                        font: Tokens.font.body.builders.medium.weight(Font.Bold).build()
                        color: Colours.palette.m3onSurface
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        visible: text.length > 0
                    }

                    StyledText {
                        text: root.notifData?.body ?? ""
                        font: Tokens.font.body.small
                        color: Colours.palette.m3onSurfaceVariant
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        visible: text.length > 0
                    }
                }
            }
        }
    }
}
