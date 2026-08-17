pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services
import "../bar/components"

Variants {
    model: Quickshell.screens

    delegate: StyledWindow {
        id: win

        required property ShellScreen modelData
        screen: modelData
        name: "top-bar"

        readonly property ScreenState screenState: ShellState.forScreen(screen)
        property bool isHovered: hoverArea.containsMouse
        property bool shown: true

        readonly property alias clockPill: clockPill
        readonly property real statusPillCenterX: statusPillWrapper.mapToItem(null, statusPillWrapper.width / 2, 0).x
        readonly property real clockPillCenterX: clockPill.mapToItem(null, clockPill.width / 2, 0).x
        readonly property real clockPillBottomY: clockPill.mapToItem(null, 0, clockPill.height).y
        property real activeTriggerCenterX: statusPillCenterX

        readonly property bool isPopoutOpen: comps && comps.panels && comps.panels.popouts && comps.panels.popouts.hasCurrent && comps.panels.popouts.isTop

        Timer {
            id: hideTimer
            interval: 3000
            repeat: false
            onTriggered: win.shown = false
        }

        function updateShownState(): void {
            if (isHovered || isPopoutOpen) {
                hideTimer.stop();
                win.shown = true;
            } else {
                if (fullscreen) {
                    win.shown = false;
                } else {
                    hideTimer.restart();
                }
            }
        }

        onIsHoveredChanged: updateShownState()
        onIsPopoutOpenChanged: updateShownState()

        onFullscreenChanged: {
            if (fullscreen) {
                hideTimer.stop();
                if (!isHovered && !isPopoutOpen) {
                    win.shown = false;
                }
            } else {
                win.shown = true;
                hideTimer.restart();
            }
        }

        Component.onCompleted: {
            if (fullscreen && !isHovered && !isPopoutOpen) {
                win.shown = false;
            } else {
                hideTimer.restart();
            }
        }

        ShellState.ComponentRef {
            screen: win.screen
            slot: "topBar"
            component: win
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }

        WlrLayershell.layer: WlrLayer.Overlay
        readonly property var comps: ShellState.componentsFor(win.screen)
        readonly property bool fullscreen: comps && comps.rootWindow && comps.rootWindow.hasFullscreen

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }
        margins.top: win.shown ? 0 : -win.height + 2

        Behavior on margins.top {
            Anim {}
        }

        implicitWidth: screen.width
        implicitHeight: barRow.implicitHeight + 1

        mask: Region {
            Region {
                x: logoPill.x
                y: logoPill.y + barRow.y
                width: win.shown ? logoPill.width : 0
                height: win.shown ? logoPill.height : 0
            }
            Region {
                x: wsPill.x
                y: wsPill.y + barRow.y
                width: win.shown ? wsPill.width : 0
                height: win.shown ? wsPill.height : 0
            }
            Region {
                x: clockPill.x
                y: clockPill.y
                width: win.shown ? clockPill.width : 0
                height: win.shown ? clockPill.height : 0
            }
            Region {
                x: statusPillWrapper.x
                y: statusPillWrapper.y + barRow.y
                width: win.shown ? statusPillWrapper.width : 0
                height: win.shown ? statusPillWrapper.height : 0
            }
            Region {
                x: powerPill.x
                y: powerPill.y + barRow.y
                width: win.shown ? powerPill.width : 0
                height: win.shown ? powerPill.height : 0
            }
            Region {
                x: 0
                y: win.height - 2
                width: win.width
                height: !win.shown ? 2 : 0
            }
        }

        RowLayout {
            id: barRow

            y: 6

            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0

            spacing: Tokens.spacing.medium

            // 1. Arch Logo Pill
            StyledRect {
                id: logoPill
                implicitWidth: logoIcon.implicitWidth + Tokens.padding.medium
                implicitHeight: logoIcon.implicitHeight + Tokens.padding.small
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.full

                OsIcon {
                    id: logoIcon
                    anchors.centerIn: parent
                }
            }

            // 2. Workspaces Switcher Pill
            StyledRect {
                id: wsPill

                implicitWidth: wsRow.implicitWidth + Tokens.padding.large
                implicitHeight: wsRow.implicitHeight + Tokens.padding.small
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.full

                readonly property int activeWsId: GlobalConfig.bar.workspaces.perMonitorWorkspaces ? (Hypr.monitorFor(win.screen)?.activeWorkspace?.id ?? 1) : Hypr.activeWsId

                RowLayout {
                    id: wsRow

                    anchors.centerIn: parent
                    spacing: Tokens.spacing.medium

                    Repeater {
                        model: Config.bar.workspaces.shown

                        Item {
                            required property int index
                            readonly property int wsId: index + 1
                            readonly property bool isCurrent: wsPill.activeWsId === wsId
                            readonly property var workspace: Hypr.workspaces.values.find(w => w.id === wsId)
                            readonly property bool isOccupied: (workspace?.toplevels?.values?.length > 0) || (workspace?.lastIpcObject?.windows > 0)

                            visible: isOccupied || isCurrent

                            implicitWidth: visible ? 28 : 0
                            implicitHeight: visible ? 28 : 0

                            Rectangle {
                                anchors.fill: parent
                                radius: Tokens.rounding.full
                                color: isCurrent ? Colours.palette.m3primary : "transparent"
                            }

                            StyledText {
                                anchors.centerIn: parent
                                text: {
                                    const label = Config.bar.workspaces.label || wsId.toString();
                                    const occupiedLabel = Config.bar.workspaces.occupiedLabel || label;
                                    const activeLabel = Config.bar.workspaces.activeLabel || (isOccupied ? occupiedLabel : label);
                                    return isCurrent ? activeLabel : isOccupied ? occupiedLabel : label;
                                }
                                font.family: Tokens.font.workspaces
                                color: isCurrent ? Colours.palette.m3onPrimary : (isOccupied ? Colours.palette.m3onSurface : Qt.alpha(Colours.palette.m3outline, 0.4))
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (Hypr.activeWsId !== parent.wsId)
                                        Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ workspace = "${parent.wsId}" })` : `workspace ${parent.wsId}`);
                                }
                            }
                        }
                    }
                }
            }

            // Middle Spacer
            Item {
                Layout.fillWidth: true
            }

            // 4. Status Icons Pill (with hover / click drawer trigger)
            Item {
                id: statusPillWrapper
                implicitWidth: statusPill.implicitWidth
                implicitHeight: statusPill.implicitHeight

                StatusIcons {
                    id: statusPill
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    function checkPopout(mx: real, my: real): void {
                        if (!Config.bar.popouts.statusIcons)
                            return;

                        const items = statusPill.items;
                        const localPoint = mapToItem(items, mx, my);
                        const icon = items.childAt(localPoint.x, items.height / 2);
                        const comps = ShellState.componentsFor(win.screen);
                        if (comps && comps.panels) {
                            const popouts = comps.panels.popouts;
                            if (icon && icon.visible && icon.name) {
                                popouts.isTop = true;
                                popouts.currentName = icon.name;
                                const barWidth = comps.bar ? comps.bar.implicitWidth :0;
                                popouts.currentCenter = icon.mapToItem(null, icon.implicitWidth / 2, 0).x - barWidth;
                                popouts.hasCurrent = true;
                            } else {
                                popouts.hasCurrent = false;
                            }
                        }
                    }

                    onPositionChanged: event => checkPopout(event.x, event.y)
                    onEntered: event => checkPopout(mouseX, mouseY)
                    onClicked: {
                        if (win.screenState) {
                            win.screenState.utilities = !win.screenState.utilities;
                            const comps = ShellState.componentsFor(win.screen);
                            if (comps && comps.panels) {
                                comps.panels.popouts.hasCurrent = false;
                            }
                        }
                    }
                }
            }

            // 5. Power Button Pill
            StyledRect {
                id: powerPill
                implicitWidth: powerBtn.implicitWidth + Tokens.padding.medium
                implicitHeight: powerBtn.implicitHeight + Tokens.padding.small
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.full

                Power {
                    id: powerBtn
                    anchors.centerIn: parent
                    screenState: win.screenState
                }
            }
        }

        // 3. Centered Time Pill
        StyledRect {
            id: clockPill

            anchors.horizontalCenter: parent.horizontalCenter
            y: 0

            implicitWidth: clockLayout.implicitWidth + Tokens.padding.large
            implicitHeight: clockLayout.implicitHeight + Tokens.padding.small

            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.full

            RowLayout {
                id: clockLayout

                anchors.centerIn: parent
                spacing: Tokens.spacing.small

                StyledText {
                    text: Time.hourStr + ":" + Time.minuteStr
                    font: Tokens.font.body.builders.medium.build()
                    color: Colours.palette.m3onSurface
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    if (win.screenState)
                        win.screenState.dashboard = true;
                }
                onClicked: {
                    if (win.screenState)
                        win.screenState.dashboard = !win.screenState.dashboard;
                }
            }
        }
    }
}
