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
        name: "top-workspaces"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"

        anchors {
            top: true
            left: true
        }

        implicitWidth: layout.implicitWidth + 30
        implicitHeight: layout.implicitHeight + 20

        mask: Region {
            item: layout
        }

        RowLayout {
            id: layout

            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            spacing: Tokens.spacing.small

            StyledRect {
                implicitWidth: logoIcon.implicitWidth + Tokens.padding.medium * 2
                implicitHeight: logoIcon.implicitHeight + Tokens.padding.small * 2
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.full

                OsIcon {
                    id: logoIcon
                    anchors.centerIn: parent
                }
            }

            StyledRect {
                id: wsPill

                implicitWidth: wsRow.implicitWidth + Tokens.padding.large * 2
                implicitHeight: wsRow.implicitHeight + Tokens.padding.small * 2
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
                                color: isCurrent ? Colours.palette.m3onPrimary : (isOccupied ? Colours.palette.m3onSurface : Colours.palette.m3outlineVariant)
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
        }
    }
}
