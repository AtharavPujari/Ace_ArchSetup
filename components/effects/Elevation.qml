import QtQuick
import QtQuick.Effects
import qs.components
import qs.services

RectangularShadow {
    property int level
    property real dp: [0, 1, 3, 6, 8, 12][level]

    color: Qt.alpha(Colours.palette.m3shadow, 0.08)
    blur: dp * 4 + 10
    spread: 0
    offset.y: dp * 0.6

    Behavior on dp {
        Anim {
            type: Anim.SlowEffects
        }
    }
}
