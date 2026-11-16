import QtQuick
import QtQuick.Layouts
import qs.data

Rectangle {
    Layout.alignment: Qt.AlignCenter
    implicitWidth: Settings.barVertical ? 16 : 1
    implicitHeight: Settings.barVertical ? 1 : 16
    radius: 0
    color: Settings.colors.borderStrong
}
