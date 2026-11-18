import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Services.Notifications as QsNotifications
import qs.data

Clickable {
    id: root

    required property QsNotifications.Notification notification
    property bool elevated: false
    readonly property bool critical: notification?.urgency === QsNotifications.NotificationUrgency.Critical
    readonly property bool replyFocused: replyField.input.activeFocus
    readonly property bool cardHovered: hover.hovered

    signal dismissed()
    signal replied()
    signal actionInvoked()

    implicitHeight: column.implicitHeight + 24
    radius: elevated ? Settings.sheetRadius : Settings.radiusMd
    color: elevated ? "transparent" : Settings.colors.surface
    border.color: critical ? Settings.colors.error : Settings.colors.border
    border.width: elevated && !critical ? 0 : 1


    readonly property QsNotifications.NotificationAction defaultAction: notification?.actions.find(a => a.identifier === "default") ?? null
    readonly property var extraActions: (notification?.actions ?? [])
        .filter(a => a.identifier !== "default" && a.text !== "")
        .map(a => ({ kind: "action", text: a.text, action: a }))
    // clicking the card already views it, so the chip is only worth showing beside other actions
    readonly property var chips: extraActions.length > 0
        ? [{ kind: "view", text: defaultAction?.text || "View" }, ...extraActions]
        : []

    // as a toast it floats like the other popups
    CardSurface {
        visible: root.elevated
        radius: root.radius
        raised: true
        z: -1
    }

    HoverHandler { id: hover }

    onClicked: view()

    function view(): void {
        const n = notification;
        if (!n) return;
        defaultAction?.invoke();
        const entry = DesktopEntries.heuristicLookup(n.desktopEntry || n.appName);
        const ids = [n.desktopEntry, n.appName, entry?.id, entry?.startupClass].filter(s => s).map(s => s.toLowerCase());
        ToplevelManager.toplevels.values.find(t => ids.includes(t.appId.toLowerCase()))?.activate();
        Runtime.closePanels();
        n.dismiss();
        root.actionInvoked();
    }

    function sendReply(): void {
        if (replyField.text.length === 0) return;
        notification.sendInlineReply(replyField.text);
        replyField.text = "";
        root.replied();
    }

    ColumnLayout {
        id: column
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ClippingWrapperRectangle {
                Layout.alignment: Qt.AlignTop
                implicitWidth: 36
                implicitHeight: 36
                radius: Settings.radiusSm
                color: "transparent"

                Item {
                    implicitWidth: 36
                    implicitHeight: 36

                    Image {
                        id: image
                        anchors.fill: parent
                        source: root.notification?.image ?? ""
                        sourceSize: Qt.size(72, 72)
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                        asynchronous: true
                    }

                    IconImage {
                        asynchronous: true
                        anchors.centerIn: parent
                        visible: !image.visible
                        implicitSize: 22
                        source: Quickshell.iconPath(Utils.getIcon(root.notification?.appIcon ?? ""), "application-x-executable")
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: Utils.appName(root.notification?.appName ?? "")
                    color: root.critical ? Settings.colors.error : Settings.colors.textMuted
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.notification?.summary ?? ""
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    visible: text !== ""
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.notification?.body ?? ""
                    color: Settings.colors.textMuted
                    font.pixelSize: 12
                    textFormat: Text.PlainText
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    visible: text !== ""
                }
            }

            IconButton {
                Layout.alignment: Qt.AlignTop
                icon: "window-close-symbolic"
                size: 12
                color: Settings.colors.textMuted
                opacity: hover.hovered || root.elevated ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Settings.animFast } }
                onClicked: {
                    root.notification?.dismiss();
                    root.dismissed();
                }
            }
        }

        Flow {
            visible: root.chips.length > 0
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: root.chips

                BoxButton {
                    required property var modelData
                    implicitHeight: 28
                    fontSize: 11
                    text: modelData.text
                    filled: modelData.kind === "view"
                    onClicked: {
                        if (modelData.kind === "view") return root.view();
                        modelData.action.invoke();
                        root.actionInvoked();
                    }
                }
            }
        }

        InputField {
            id: replyField
            Layout.fillWidth: true
            visible: root.notification?.hasInlineReply ?? false
            implicitHeight: 34
            fontSize: 12
            placeholder: root.notification?.inlineReplyPlaceholder || "Reply…"
            onAccepted: root.sendReply()

            IconButton {
                icon: "mail-send-symbolic"
                size: 13
                color: replyField.text.length > 0 ? Settings.colors.accent : Settings.colors.textSubtle
                onClicked: root.sendReply()
            }
        }
    }
}
