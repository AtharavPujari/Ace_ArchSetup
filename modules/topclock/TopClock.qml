pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services

Variants {
    model: Quickshell.screens

    delegate: StyledWindow {
        id: win

        required property ShellScreen modelData
        screen: modelData
        name: "top-clock"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"

        anchors {
            top: true
        }

        implicitWidth: screen.width
        implicitHeight: clockPill.implicitHeight + 20

        mask: Region {
            item: clockPill
        }

        StyledRect {
            id: clockPill

            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter

            implicitWidth: layout.implicitWidth + Tokens.padding.large * 2
            implicitHeight: layout.implicitHeight + Tokens.padding.small * 2

            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.full

            RowLayout {
                id: layout

                anchors.centerIn: parent
                spacing: Tokens.spacing.small

                StyledText {
                    text: Time.hourStr + ":" + Time.minuteStr
                    font: Tokens.font.body.builders.medium.bold(true).build()
                    color: Colours.palette.m3onSurface
                }
            }
        }
    }
}
