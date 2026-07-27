import QtQuick
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property Props props
    required property ScreenState screenState

    readonly property real neededHeight: notifDock.neededHeight

    NotifDock {
        id: notifDock
        objectName: "sidebarNotifications"

        props: root.props
        screenState: root.screenState
        anchors.fill: parent
    }
}
