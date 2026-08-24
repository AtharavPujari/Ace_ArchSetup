pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Components
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.images
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Appearance")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        // Section: Theme & Mode
        SectionHeader {
            first: true
            text: qsTr("Theme & Accent")
        }

        ToggleRow {
            first: true
            text: qsTr("Obsidian Theme")
            subtext: qsTr("Ultra-dark obsidian color palette with high contrast")
            checked: !Colours.light
            onToggled: Colours.setMode(checked ? "dark" : "light")
        }

        ToggleRow {
            text: qsTr("Smart wallpaper accent")
            subtext: qsTr("Derive color palette dynamically from active wallpaper")
            checked: GlobalConfig.services.smartScheme
            onToggled: GlobalConfig.services.smartScheme = checked
        }

        ToggleRow {
            last: true
            text: qsTr("Shell transparency")
            subtext: qsTr("Enable acrylic blur and window surface transparency")
            checked: Colours.transparency.enabled
            onToggled: GlobalConfig.appearance.transparency.enabled = checked
        }

        // Section: Wallpaper
        SectionHeader {
            text: qsTr("Wallpaper")
        }

        StyledClippingRect {
            id: wallWrapper

            Layout.alignment: Qt.AlignHCenter
            implicitWidth: {
                const screen = root.nState.screen;
                return implicitHeight / screen.height * screen.width;
            }
            implicitHeight: {
                const screen = root.nState.screen;
                const cWidth = root.cappedWidth;
                return Math.min(Math.round(cWidth * 0.4), cWidth / screen.width * screen.height);
            }

            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.large

            FadeImage {
                anchors.fill: parent
                source: Wallpapers.current
                fadeOutAnim: Anim.DefaultEffects
                fadeInAnim: Anim.SlowEffects
            }
        }

        ButtonRow {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Tokens.spacing.small
            Layout.bottomMargin: Tokens.spacing.small
            spacing: Tokens.spacing.small

            IconTextButton {
                icon: "wallpaper"
                text: qsTr("Choose Wallpaper")
                font: Tokens.font.body.large
                isRound: true
                shapeMorph: true
                type: IconTextButton.Tonal
                horizontalPadding: Tokens.padding.extraLarge
                verticalPadding: Tokens.padding.medium
                disabled: !Config.background.wallpaperEnabled
                onClicked: root.nState.openSubPage(1) // WallpaperSelect
            }

            IconTextButton {
                icon: "palette"
                text: qsTr("Color Palette")
                font: Tokens.font.body.large
                isRound: true
                shapeMorph: true
                type: IconTextButton.Tonal
                horizontalPadding: Tokens.padding.extraLarge
                verticalPadding: Tokens.padding.medium
                onClicked: root.nState.openSubPage(3) // ColourSelect
            }
        }

        ToggleRow {
            first: true
            last: true
            text: qsTr("Display wallpaper")
            subtext: qsTr("Show background desktop wallpaper image")
            checked: Config.background.wallpaperEnabled
            onToggled: GlobalConfig.background.wallpaperEnabled = checked
        }

        // Section: Geometry & Shape
        SectionHeader {
            text: qsTr("Corners & Geometry")
        }

        StepperRow {
            first: true
            last: true
            label: qsTr("Corner radius scale")
            subtext: qsTr("Adjust overall UI corner rounding (0 = sharp, 1 = default, 2 = extra rounded)")
            value: GlobalConfig.appearance.rounding.scale
            from: 0
            to: 2
            stepSize: 0.25
            onMoved: v => GlobalConfig.appearance.rounding.scale = v
        }
    }
}
