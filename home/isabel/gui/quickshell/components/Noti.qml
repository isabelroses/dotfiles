import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications as QsNotifications
import "root:/data"
import "root:/services"

Item {
    id: root

    property bool hasNotifications: Notifications.list.length > 0

    // Expose function to toggle popup (for Clock)
    function togglePopup() {
        notificationLoader.item.visible = !notificationLoader.item.visible;
    }

    visible: hasNotifications

    Layout.alignment: Qt.AlignCenter
    implicitWidth: 24
    implicitHeight: 24

    IconButton {
        anchors.centerIn: parent
        icon: "preferences-system-notifications-symbolic"
        size: 18
        onClicked: root.togglePopup()
    }

    LazyLoader {
        id: notificationLoader
        loading: true

        PopupWindow {
            id: popup
            anchor.window: root.QsWindow.window
            anchor.rect.x: parentWindow.width * 1.2
            visible: false
            color: "transparent"

            implicitWidth: 400
            implicitHeight: root.QsWindow.window.height

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: Settings.colors.background

                ColumnLayout {
                    spacing: 12
                    anchors {
                        fill: parent
                        margins: 16
                    }

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Notifications"
                            color: Settings.colors.foreground
                            font {
                                pixelSize: 18
                                weight: Font.Bold
                            }
                        }

                        Item { Layout.fillWidth: true }

                        IconButton {
                            icon: "edit-clear-all-symbolic"
                            size: 16
                            onClicked: {
                                for (const n of Notifications.list) {
                                    n.dismiss();
                                }
                                popup.visible = false;
                            }
                        }
                    }

                    // Notifications List
                    ListView {
                        id: notiList
                        model: Notifications.list
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        delegate: Rectangle {
                            required property QsNotifications.Notification modelData
                            width: ListView.view.width
                            height: 72
                            radius: 8
                            color: Settings.colors.backgroundLighter

                            RowLayout {
                                anchors {
                                    fill: parent
                                    margins: 10
                                }
                                spacing: 10

                                IconImage {
                                    source: Quickshell.iconPath(modelData.appIcon)
                                    implicitSize: 40
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 2

                                    Text {
                                        text: modelData.appName
                                        color: Settings.colors.foreground
                                        font {
                                            pixelSize: 13
                                            weight: Font.Medium
                                        }
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.body
                                        color: Settings.colors.foreground
                                        opacity: 0.8
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                        maximumLineCount: 2
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }

                                IconButton {
                                    icon: "window-close-symbolic"
                                    size: 14
                                    Layout.alignment: Qt.AlignTop
                                    onClicked: {
                                        modelData.dismiss();
                                        if (Notifications.list.length <= 0) {
                                            popup.visible = false;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Separator before Media
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Settings.colors.backgroundLightest
                        visible: Media.players.length > 0
                    }

                    // Media Players Section
                    MediaPlayers {}

                    // Separator
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Settings.colors.backgroundLightest
                    }

                    // Quick Settings Section
                    QuickSettings {}
                }
            }
        }
    }
}
