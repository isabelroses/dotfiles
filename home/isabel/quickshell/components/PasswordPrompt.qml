import QtQuick
import QtQuick.Layouts
import qs.data

Rectangle {
  id: root

  property string icon: "dialog-password-symbolic"
  property string title: ""
  property string subtitle: ""
  property string detail: ""
  property alias placeholder: input.placeholder
  property alias revealable: input.revealable
  property string message: ""
  property bool error: false
  property bool busy: false
  property string confirmText: "Confirm"
  property string busyText: "Checking…"

  signal submitted(string password)
  signal cancelled()

  function takeFocus(): void { input.takeFocus(); }

  function shake(): void { input.shake(); }

  function submit(): void {
    if (input.text === "" || !input.enabled) return;
    root.submitted(input.text);
    input.text = "";
  }

  implicitWidth: 380
  implicitHeight: column.implicitHeight + 40
  radius: Settings.rounding
  color: Settings.colors.base
  border.color: Settings.colors.borderStrong
  border.width: 1

  ColumnLayout {
    id: column
    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 20 }
    spacing: 14

    RowLayout {
      Layout.fillWidth: true
      spacing: 12

      IconChip {
        Layout.alignment: Qt.AlignTop
        size: 40
        color: Settings.colors.accentSoft
        icon: root.icon
        iconSize: 18
        iconColor: Settings.colors.accent
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        StyledText {
          Layout.fillWidth: true
          text: root.title
          font.pixelSize: 15
          font.weight: Font.DemiBold
          elide: Text.ElideRight
        }

        StyledText {
          Layout.fillWidth: true
          visible: text !== ""
          text: root.subtitle
          color: Settings.colors.textMuted
          font.pixelSize: 12
          wrapMode: Text.Wrap
        }

        StyledText {
          Layout.fillWidth: true
          visible: text !== ""
          text: root.detail
          mono: true
          color: Settings.colors.textSubtle
          font.pixelSize: 10
          elide: Text.ElideMiddle
        }
      }
    }

    InputField {
      id: input
      Layout.fillWidth: true
      password: true
      enabled: !root.busy
      error: root.error
      placeholder: "Password"
      onAccepted: root.submit()
      onEscaped: root.cancelled()
      Component.onCompleted: takeFocus()
    }

    StyledText {
      Layout.fillWidth: true
      visible: text !== ""
      text: root.message
      color: root.error ? Settings.colors.error : Settings.colors.textMuted
      font.pixelSize: 11
      wrapMode: Text.Wrap
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      Item { Layout.fillWidth: true }

      BoxButton {
        text: "Cancel"
        onClicked: root.cancelled()
      }

      BoxButton {
        text: root.busy ? root.busyText : root.confirmText
        filled: true
        onClicked: root.submit()
      }
    }
  }
}
