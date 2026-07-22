pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components
import qs.modules.bar.popouts // Need to import this module so the Wrapper type is the same as others

Item {
    id: root

    required property ShellScreen screen
    required property real borderThickness

    readonly property alias content: content
    property real offsetScale: content.isDetached || content.hasCurrent ? 0 : 1

    visible: width > 0 && height > 0
    clip: true

    implicitWidth: content.isTop ? content.implicitWidth : content.implicitWidth * (1 - offsetScale)
    implicitHeight: content.isTop ? content.implicitHeight * (1 - offsetScale) : content.implicitHeight

    x: {
        if (content.isDetached)
            return (parent.width - content.nonAnimWidth) / 2;
        if (content.isTop) {
            const edgeMargin = 8;
            const off = content.currentCenter - content.nonAnimWidth / 2;
            const diff = (parent.width - edgeMargin) - Math.floor(off + content.nonAnimWidth);
            if (diff < 0)
                return off + diff;
            return Math.max(off, edgeMargin);
        }
        return 0;
    }
    y: {
        if (content.isDetached)
            return (parent.height - content.nonAnimHeight) / 2;
        if (content.isTop) {
            const comps = ShellState.componentsFor(screen);
            const topBarHeight = comps.topBar ? comps.topBar.implicitHeight : 48;
            return topBarHeight - borderThickness + 6;
        }

        const off = content.currentCenter - borderThickness - content.nonAnimHeight / 2;
        const diff = parent.height - Math.floor(off + content.nonAnimHeight);
        if (diff < 0)
            return off + diff;
        return Math.max(off, 0);
    }

    Behavior on offsetScale {
        Anim {}
    }

    Behavior on x {
        Anim {
            duration: content.animLength
            easing: content.animCurve
        }
    }

    Behavior on y {
        enabled: root.offsetScale < 1

        Anim {
            duration: content.animLength
            easing: content.animCurve
        }
    }

    Wrapper {
        id: content

        screen: root.screen
        offsetScale: root.offsetScale

        anchors.left: content.isTop ? undefined : parent.left
        anchors.leftMargin: content.isTop ? 0 : (-implicitWidth - 5) * root.offsetScale
        anchors.verticalCenter: content.isTop ? undefined : parent.verticalCenter

        anchors.top: content.isTop ? parent.top : undefined
        anchors.topMargin: content.isTop ? (-implicitHeight - 5) * root.offsetScale : 0
    }
}
