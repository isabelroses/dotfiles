import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import qs.data

Rectangle {
  id: root

  property alias text: field.text
  property alias placeholder: field.placeholderText
  property alias input: field
  property bool password: false
  property bool revealable: password
  property bool mono: false
  property bool error: false
  property bool clearOnEscape: false
  property string icon: ""
  property int fontSize: 13
  default property alias trailing: extras.data

  signal accepted()
  signal escaped()
  signal editingFinished()

  function takeFocus(): void { field.forceActiveFocus(); }
  function shake(): void { shakeAnim.restart(); }

  property real shakeOffset: 0
  transform: Translate { x: root.shakeOffset }

  SequentialAnimation {
    id: shakeAnim
    NumberAnimation { target: root; property: "shakeOffset"; to: -10; duration: 50 }
    NumberAnimation { target: root; property: "shakeOffset"; to: 10; duration: 70 }
    NumberAnimation { target: root; property: "shakeOffset"; to: -6; duration: 60 }
    NumberAnimation { target: root; property: "shakeOffset"; to: 0; duration: 50 }
  }

  implicitHeight: 40
  radius: Settings.radiusSm
  color: Settings.colors.surfaceRaised
  border.width: 1
  border.color: error ? Settings.colors.error
              : field.activeFocus ? Settings.colors.accent
              : Settings.colors.borderStrong
  opacity: enabled ? 1 : 0.5

  RowLayout {
    anchors { fill: parent; leftMargin: 12; rightMargin: 4 }
    spacing: 6

    MyIcon {
      visible: root.icon !== ""
      icon: root.icon
      size: 12
      color: Settings.colors.textSubtle
    }

    TextField {
      id: field
      Layout.fillWidth: true
      echoMode: root.password && !reveal.revealed ? TextInput.Password : TextInput.Normal
      placeholderTextColor: Settings.colors.textSubtle
      color: Settings.colors.text
      selectByMouse: true
      selectionColor: Settings.colors.accent
      selectedTextColor: Settings.colors.textOnAccent
      font { family: root.mono ? Settings.fonts.mono : Settings.fonts.sans; pixelSize: root.fontSize }
      background: null
      padding: 0
      verticalAlignment: TextInput.AlignVCenter
      onAccepted: root.accepted()
      onEditingFinished: root.editingFinished()
      Keys.onEscapePressed: (e) => {
        e.accepted = root.clearOnEscape && text !== "";
        if (e.accepted) text = "";
        else root.escaped();
      }
    }

    IconButton {
      id: reveal
      property bool revealed: false
      visible: root.revealable
      icon: revealed ? "view-conceal-symbolic" : "view-reveal-symbolic"
      size: 14
      color: Settings.colors.textMuted
      onClicked: revealed = !revealed
    }

    RowLayout {
      id: extras
      spacing: 4
    }
  }
}
