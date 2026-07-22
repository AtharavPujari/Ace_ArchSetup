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

StyledRect {
    id: root

    property color colour: Colours.palette.m3secondary
    readonly property alias items: iconRow

    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.full

    clip: true
    implicitWidth: iconRow.implicitWidth + Tokens.padding.medium
    implicitHeight: iconRow.implicitHeight + Tokens.padding.small

    RowLayout {
        id: iconRow

        anchors.centerIn: parent
        spacing: Tokens.spacing.small

        // Lock keys status
        WrappedLoader {
            name: "lockstatus"
            active: Config.bar.status.showLockStatus

            sourceComponent: RowLayout {
                spacing: 4

                Item {
                    implicitWidth: Hypr.capsLock ? capslockIcon.implicitWidth : 0
                    implicitHeight: capslockIcon.implicitHeight

                    MaterialIcon {
                        id: capslockIcon
                        anchors.centerIn: parent
                        scale: Hypr.capsLock ? 1 : 0.5
                        opacity: Hypr.capsLock ? 1 : 0
                        text: "keyboard_capslock_badge"
                        color: root.colour
                    }
                }

                Item {
                    implicitWidth: Hypr.numLock ? numlockIcon.implicitWidth : 0
                    implicitHeight: numlockIcon.implicitHeight

                    MaterialIcon {
                        id: numlockIcon
                        anchors.centerIn: parent
                        scale: Hypr.numLock ? 1 : 0.5
                        opacity: Hypr.numLock ? 1 : 0
                        text: "looks_one"
                        color: root.colour
                    }
                }
            }
        }

        // Audio icon
        WrappedLoader {
            name: "audio"
            active: Config.bar.status.showAudio

            sourceComponent: MaterialIcon {
                animate: true
                text: Icons.getVolumeIcon(Audio.volume, Audio.muted)
                color: root.colour
            }
        }

        // Microphone icon
        WrappedLoader {
            name: "audio"
            active: Config.bar.status.showMicrophone

            sourceComponent: MaterialIcon {
                animate: true
                text: Icons.getMicVolumeIcon(Audio.sourceVolume, Audio.sourceMuted)
                color: root.colour
            }
        }

        // Keyboard layout icon
        WrappedLoader {
            name: "kblayout"
            active: Config.bar.status.showKbLayout

            sourceComponent: StyledText {
                animate: true
                text: Hypr.kbLayout
                color: root.colour
                font: Tokens.font.mono.medium
            }
        }

        // Network icon
        WrappedLoader {
            name: "network"
            active: Config.bar.status.showNetwork && (!Nmcli.activeEthernet || Config.bar.status.showWifi)

            sourceComponent: MaterialIcon {
                animate: true
                text: Nmcli.active ? Icons.getNetworkIcon(Nmcli.active.strength ?? 0) : "wifi_off"
                color: root.colour
            }
        }

        // Ethernet icon
        WrappedLoader {
            name: "ethernet"
            active: Config.bar.status.showNetwork && Nmcli.activeEthernet

            sourceComponent: MaterialIcon {
                animate: true
                text: "cable"
                color: root.colour
            }
        }

        // Bluetooth section
        WrappedLoader {
            name: "bluetooth"
            active: Config.bar.status.showBluetooth

            sourceComponent: RowLayout {
                spacing: Tokens.spacing.extraSmall

                MaterialIcon {
                    animate: true
                    text: {
                        if (!Bluetooth.defaultAdapter?.enabled) // qmllint disable unresolved-type
                            return "bluetooth_disabled";
                        if (Bluetooth.devices.values.some(d => d.connected)) // qmllint disable unresolved-type
                            return "bluetooth_connected";
                        return "bluetooth";
                    }
                    color: root.colour
                }

                Repeater {
                    model: ScriptModel {
                        values: Bluetooth.devices.values.filter(d => d.state !== BluetoothDeviceState.Disconnected) // qmllint disable unresolved-type
                    }

                    MaterialIcon {
                        id: device
                        required property BluetoothDevice modelData

                        animate: true
                        text: Icons.getBluetoothIcon(modelData?.icon)
                        color: root.colour
                        fill: 1
                    }
                }
            }
        }

        // Battery icon
        WrappedLoader {
            name: "battery"
            active: Config.bar.status.showBattery

            sourceComponent: MaterialIcon {
                animate: true
                text: {
                    if (!UPower.displayDevice.isLaptopBattery) {
                        if (PowerProfiles.profile === PowerProfile.PowerSaver)
                            return "energy_savings_leaf";
                        if (PowerProfiles.profile === PowerProfile.Performance)
                            return "rocket_launch";
                        return "balance";
                    }
                    return Icons.getBatteryIcon(UPower.displayDevice.percentage, [UPowerDeviceState.Charging, UPowerDeviceState.FullyCharged, UPowerDeviceState.PendingCharge].includes(UPower.displayDevice.state));
                }
                color: !UPower.onBattery || UPower.displayDevice.percentage > 0.2 ? root.colour : Colours.palette.m3error
                fill: 1
            }
        }
    }

    component WrappedLoader: Loader {
        required property string name
        asynchronous: true
        Layout.alignment: Qt.AlignVCenter
        visible: active
    }
}
