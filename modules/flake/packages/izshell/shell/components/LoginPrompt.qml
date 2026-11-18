import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.data
import qs.services

// The lock screen and greeter's centre: clock, avatar, name and the password
// sigil. The owner keeps the typed text: `edited` reports each change, to be
// fed back through `buffer`; enter emits `submitted`.
ColumnLayout {
  id: root

  property string buffer: ""
  property bool busy: false
  property bool failed: false
  property string message: ""
  property string hint: "Type to unlock"
  // shown between the input and the message line
  default property alias extras: extrasSlot.data

  signal edited(text: string)
  signal submitted()

  function focusInput(): void { field.takeFocus(); }

  spacing: 18

  opacity: 0
  Component.onCompleted: opacity = 1
  Behavior on opacity { NumberAnimation { duration: Settings.animNormal * 2 } }

  ColumnLayout {
    Layout.alignment: Qt.AlignHCenter
    spacing: 0

    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: 14

      StyledText { text: Time.hours; serif: true; font.pixelSize: 104 }
      StyledText { text: Time.minutes; serif: true; font.italic: true; font.pixelSize: 104; color: Settings.colors.textMuted }
    }

    StyledText {
      Layout.alignment: Qt.AlignHCenter
      text: Time.longDate + (Time.period ? ` · ${Time.period}` : "")
      color: Settings.colors.textMuted
      font.pixelSize: 16
    }
  }

  Item { implicitHeight: 24 }

  ClippingWrapperRectangle {
    Layout.alignment: Qt.AlignHCenter
    implicitWidth: 80
    implicitHeight: 80
    radius: Settings.radiusRound
    color: Settings.colors.overlay
    border.color: root.failed ? Settings.colors.red : Settings.colors.accent
    border.width: 2

    Image {
      source: Settings.profilePicture
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      mipmap: true
      sourceSize: Qt.size(160, 160)
    }
  }

  StyledText {
    Layout.alignment: Qt.AlignHCenter
    text: Settings.username
    font.pixelSize: 15
    font.weight: Font.DemiBold
  }

  LockSigil {
    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: count > 0 ? 6 : 0
    Layout.bottomMargin: count > 0 ? 6 : 0
    count: root.buffer.length
    failed: root.failed
  }

  // where the sigil will grow, until there's something to show
  StyledText {
    Layout.alignment: Qt.AlignHCenter
    visible: root.buffer === "" || root.busy
    text: root.busy ? "Checking…" : root.hint
    color: Settings.colors.textMuted
    font.pixelSize: 13
  }

  // the sigil is the only visible input: this field just holds focus and
  // the typed text, at zero size and opacity; enter submits
  InputField {
    id: field
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredHeight: 0
    implicitWidth: 300
    opacity: 0
    password: true
    revealable: false
    error: root.failed
    enabled: !root.busy
    text: root.buffer
    onTextChanged: {
      if (text !== root.buffer) root.edited(text);
    }
    onAccepted: if (root.buffer !== "" && !root.busy) root.submitted()
    onEscaped: root.edited("")
    Component.onCompleted: takeFocus()

    Connections {
      target: root
      function onFailedChanged() {
        if (root.failed) field.takeFocus();
      }
    }
  }

  ColumnLayout {
    id: extrasSlot
    Layout.alignment: Qt.AlignHCenter
    // never hidden (a hidden parent hides its children too, so it could not
    // tell when they want to show); when empty, give back its layout gap
    Layout.bottomMargin: implicitHeight > 0 ? 0 : -root.spacing
    spacing: root.spacing
  }

  StyledText {
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredHeight: 16
    text: root.message
    color: root.failed ? Settings.colors.red : Settings.colors.textMuted
    font.pixelSize: 12
  }
}
