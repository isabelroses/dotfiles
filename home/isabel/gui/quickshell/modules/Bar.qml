import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/data"
import "root:/components"

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            implicitWidth: 48
            color: "transparent"

            anchors {
                top: true
                left: true
                bottom: true
            }

            margins {
                left: 10
                top: 10
                bottom: 10
            }

            Rectangle {
                id: bar
                anchors.fill: parent
                radius: 12
                color: Settings.colors.background

                // Top section - Launcher & Workspaces
                ColumnLayout {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        topMargin: 12
                    }
                    spacing: 16

                    Launcher {}

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 20
                        height: 1
                        color: Settings.colors.foreground
                        opacity: 0.2
                    }

                    Workspaces {}
                }

                // Center section - Clock & Notifications
                ColumnLayout {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 16

                    Clock {
                        onClicked: notiPanel.togglePopup()
                    }
                    Noti {
                        id: notiPanel
                    }
                }

                // Bottom section - System tray, Volume, Network
                ColumnLayout {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: 12
                    }
                    spacing: 12

                    SysTray {}

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 20
                        height: 1
                        color: Settings.colors.foreground
                        opacity: 0.2
                    }

                    Volume {}
                    Network {}
                }
            }
        }
    }
}
