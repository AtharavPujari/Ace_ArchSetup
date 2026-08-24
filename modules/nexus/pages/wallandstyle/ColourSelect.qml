pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common

PageBase {
    id: root

    readonly property list<MenuItem> variantItems: [
        MenuItem { text: qsTr("Tonal Spot") },
        MenuItem { text: qsTr("Vibrant") },
        MenuItem { text: qsTr("Expressive") },
        MenuItem { text: qsTr("Neutral") },
        MenuItem { text: qsTr("Monochrome") },
        MenuItem { text: qsTr("Fruit Salad") },
        MenuItem { text: qsTr("Rainbow") }
    ]
    readonly property list<string> variantValues: ["tonalSpot", "vibrant", "expressive", "neutral", "monochrome", "fruitSalad", "rainbow"]

    title: qsTr("Colour palette & style")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: qsTr("Theme Mode")
        }

        ToggleRow {
            first: true
            text: qsTr("Dark theme")
            subtext: qsTr("Use dark mode palette across Caelestia shell")
            checked: !Colours.light
            onToggled: Colours.setMode(checked ? "dark" : "light")
        }

        ToggleRow {
            last: true
            text: qsTr("Smart scheme")
            subtext: qsTr("Automatically derive colors from active desktop wallpaper")
            checked: GlobalConfig.services.smartScheme
            onToggled: GlobalConfig.services.smartScheme = checked
        }

        SectionHeader {
            text: qsTr("Material 3 Variant")
        }

        SelectRow {
            first: true
            last: true
            label: qsTr("Color palette variant")
            subtext: qsTr("Style generator for Material Design 3 theme colors")
            menuItems: root.variantItems
            active: root.variantItems[Math.max(0, root.variantValues.indexOf(GlobalConfig.appearance.variant))]
            onSelected: item => GlobalConfig.appearance.variant = root.variantValues[root.variantItems.indexOf(item)]
        }
    }
}
