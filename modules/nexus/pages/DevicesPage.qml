pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import Caelestia.Config
import qs.components
import qs.services
import qs.utils
import qs.modules.nexus.common

PageBase {
    id: root

    title: qsTr("Devices")

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: qsTr("Connectivity & Hardware")
        }

        NavRow {
            first: true
            icon: "volume_up"
            label: qsTr("Audio")
            status: Audio.muted ? qsTr("Muted") : qsTr("Volume %1%").arg(Math.round(Audio.volume * 100))
            onClicked: root.nState.openSubPage(1) // AudioPage
        }

        NavRow {
            icon: "bluetooth"
            label: qsTr("Bluetooth")
            status: Bluetooth.defaultAdapter?.enabled ? qsTr("Enabled") : qsTr("Disabled")
            onClicked: root.nState.openSubPage(2) // BluetoothPage
        }

        NavRow {
            icon: "wifi"
            label: qsTr("Network")
            status: Nmcli.wifiEnabled ? (Nmcli.connectingSsid() ? qsTr("Connecting to %1...").arg(Nmcli.connectingSsid()) : qsTr("Wi-Fi Enabled")) : qsTr("Disabled")
            onClicked: root.nState.openSubPage(3) // NetworkPage
        }

        // Power & Battery section
        SectionHeader {
            text: qsTr("Power & Battery")
        }

        ConnectedRect {
            Layout.fillWidth: true
            first: true
            last: true
            implicitHeight: powerLayout.implicitHeight + powerLayout.anchors.margins * 2

            RowLayout {
                id: powerLayout

                anchors.fill: parent
                anchors.margins: Tokens.padding.large
                spacing: Tokens.spacing.medium

                MaterialIcon {
                    text: [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged].includes(UPower.displayDevice.state) ? "battery_charging_full" : "battery_full"
                    color: Colours.palette.m3primary
                    fontStyle: Tokens.font.icon.medium
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: UPower.displayDevice.isLaptopBattery ? qsTr("Battery %1%").arg(Math.round(UPower.displayDevice.percentage * 100)) : qsTr("AC Power")
                        font: Tokens.font.body.small
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: PowerProfile.toString(PowerProfiles.profile)
                        color: Colours.palette.m3outline
                        font: Tokens.font.label.small
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
