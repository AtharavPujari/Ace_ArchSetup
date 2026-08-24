pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.services
import qs.modules.nexus

VerticalFadeFlickable {
    id: root

    required property NexusState nState

    topMargin: Tokens.padding.large
    bottomMargin: Tokens.padding.large
    contentHeight: content.implicitHeight

    TapHandler {
        onTapped: root.focus = true
    }

    ColumnLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spacing.extraSmall

        // Primary categories
        Repeater {
            id: list

            model: PageRegistry.pages.filter(p => !p.isSecondary)

            NavItemDelegate {
                nState: root.nState
            }
        }

        // Separator
        StyledRect {
            Layout.fillWidth: true
            Layout.topMargin: Tokens.spacing.medium
            Layout.bottomMargin: Tokens.spacing.medium
            implicitHeight: 1
            color: Colours.palette.m3outlineVariant
        }

        // Secondary bottom item (About)
        Repeater {
            id: secondaryList

            model: PageRegistry.pages.filter(p => p.isSecondary)

            NavItemDelegate {
                nState: root.nState
            }
        }
    }

    component NavItemDelegate: StyledRect {
        id: item

        required property var modelData
        required property NexusState nState

        readonly property int actualIndex: modelData.pageIndex ?? 0
        readonly property bool isCurrentPage: actualIndex === nState.currentPageIdx

        Layout.fillWidth: true
        implicitHeight: {
            const h = layout.implicitHeight + layout.anchors.margins * 2;
            return h % 2 === 0 ? h : h + 1;
        }

        color: isCurrentPage ? Colours.palette.m3secondaryContainer : Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
        radius: Tokens.rounding.medium

        StateLayer {
            id: stateLayer

            anchors.fill: parent
            radius: parent.radius

            onClicked: item.nState.currentPageIdx = item.actualIndex
        }

        RowLayout {
            id: layout

            anchors.fill: parent
            anchors.margins: Tokens.padding.large
            spacing: Tokens.spacing.medium

            StyledRect {
                Layout.fillHeight: true
                Layout.topMargin: -1
                Layout.bottomMargin: -1
                implicitWidth: height

                radius: Tokens.rounding.full
                color: item.isCurrentPage ? Colours.palette.m3primary : Colours.palette.m3secondaryContainer

                MaterialIcon {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 1

                    text: item.modelData.icon
                    color: item.isCurrentPage ? Colours.palette.m3onPrimary : Colours.palette.m3onSecondaryContainer
                    fontStyle: Tokens.font.icon.builders.medium.weight(Font.Medium).build()
                    grade: 25
                    fill: item.modelData.noFill ? 0 : 1
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: item.modelData.label
                    font: Tokens.font.body.medium
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: item.modelData.description
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.label.small
                    elide: Text.ElideRight
                }
            }
        }
    }

    component RadiusBehavior: Behavior {
        Anim {
            type: Anim.DefaultEffects
        }
    }
}
