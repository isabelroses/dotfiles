import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Services.Notifications
import "root:/data"
import "root:/components"

Scope {
    id: root

    // OSD State
    property string osdType: ""
    property real progress: 0
    property string iconSource: ""
    property string osdText: ""
    property bool osdVisible: false

    // Notification State
    property var currentNotification: null
    property bool notificationVisible: false

    // Pipewire
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property PwNode sink: Pipewire.defaultAudioSink
    property real volume: sink?.audio?.volume ?? 0
    property bool muted: sink?.audio?.muted ?? false

    onVolumeChanged: showVolumeOsd()
    onMutedChanged: showVolumeOsd()

    function showVolumeOsd(): void {
        root.osdType = "volume";
        root.progress = root.volume;
        if (root.muted) {
            root.iconSource = "audio-volume-muted-symbolic";
        } else if (root.volume > 0.66) {
            root.iconSource = "audio-volume-high-symbolic";
        } else if (root.volume > 0.33) {
            root.iconSource = "audio-volume-medium-symbolic";
        } else if (root.volume > 0) {
            root.iconSource = "audio-volume-low-symbolic";
        } else {
            root.iconSource = "audio-volume-muted-symbolic";
        }
        root.osdText = Math.round(root.volume * 100) + "%";
        root.osdVisible = true;
        osdHideTimer.restart();
    }

    function showNotification(notification: Notification): void {
        root.currentNotification = notification;
        root.notificationVisible = true;
        notificationHideTimer.restart();
    }

    Timer {
        id: osdHideTimer
        interval: 1500
        onTriggered: root.osdVisible = false
    }

    Timer {
        id: notificationHideTimer
        interval: 4000
        onTriggered: root.notificationVisible = false
    }

    // Notification Server
    NotificationServer {
        id: notificationServer
        onNotification: (notification) => {
            notification.tracked = true;
            root.showNotification(notification);
        }
        actionsSupported: true
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: osdWindow
            property var modelData
            screen: modelData

            visible: root.osdVisible
            color: "transparent"

            WlrLayershell.namespace: "osd"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore

            anchors {
                bottom: true
            }

            implicitWidth: 320
            implicitHeight: 80

            margins {
                bottom: 80
            }

            Rectangle {
                id: osdContainer
                anchors.centerIn: parent
                width: 300
                height: 56
                radius: 14
                color: Settings.colors.background

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 18
                        rightMargin: 18
                    }
                    spacing: 14

                    MyIcon {
                        icon: root.iconSource
                        size: 22
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        Layout.alignment: Qt.AlignVCenter
                        radius: 3
                        color: Settings.colors.backgroundLighter

                        Rectangle {
                            width: parent.width * Math.min(root.progress, 1.0)
                            height: parent.height
                            radius: 3
                            color: root.muted ? Settings.colors.error : Settings.colors.accent

                            Behavior on width {
                                SmoothedAnimation { velocity: 600 }
                            }
                        }
                    }

                    Text {
                        text: root.osdText
                        color: Settings.colors.foreground
                        font {
                            pixelSize: 13
                            weight: Font.Medium
                        }
                        Layout.preferredWidth: 40
                        Layout.alignment: Qt.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }

    // Notification Popup
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: notificationWindow
            property var modelData
            screen: modelData

            visible: root.notificationVisible && root.currentNotification !== null
            color: "transparent"

            WlrLayershell.namespace: "notification"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore

            anchors {
                top: true
            }

            implicitWidth: 420
            implicitHeight: 100

            margins {
                top: 16
            }

            Rectangle {
                id: notificationContainer
                anchors {
                    fill: parent
                    margins: 8
                }
                radius: 12
                color: Settings.colors.background

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 14
                    }
                    spacing: 12

                    IconImage {
                        source: Quickshell.iconPath(root.currentNotification.appIcon)
                        implicitSize: 40
                        Layout.alignment: Qt.AlignTop
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 4

                        Text {
                            text: root.currentNotification?.appName ?? ""
                            color: Settings.colors.foreground
                            font {
                                pixelSize: 13
                                weight: Font.Bold
                            }
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.currentNotification?.summary ?? ""
                            color: Settings.colors.foreground
                            font {
                                pixelSize: 12
                                weight: Font.Medium
                            }
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            visible: text !== ""
                        }

                        Text {
                            text: root.currentNotification?.body ?? ""
                            color: Settings.colors.foreground
                            opacity: 0.8
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            Layout.fillWidth: true
                        }
                    }

                    IconButton {
                        icon: "window-close-symbolic"
                        size: 14
                        Layout.alignment: Qt.AlignTop
                        onClicked: {
                            root.currentNotification?.dismiss();
                            root.notificationVisible = false;
                        }
                    }
                }

                // Click to dismiss
                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: root.notificationVisible = false
                }
            }
        }
    }
}
