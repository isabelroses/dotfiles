import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Networking as Net
import "root:/data"
import "root:/components"

LazyLoader {
  id: loader
  active: Runtime.wifiPasswordTarget !== null

  PanelWindow {
    id: win
    color: "transparent"

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "network-password"
    // Exclusive so the password field reliably receives keystrokes.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    function submit(): void {
      const t = Runtime.wifiPasswordTarget;
      if (!t || pwField.text.length === 0) return;
      Runtime.wifiPasswordError = "";
      t.connectWithPsk(pwField.text);
    }

    Rectangle {
      anchors.fill: parent
      color: "#80000000"
      MouseArea {
        anchors.fill: parent
        onClicked: Runtime.closeWifiPassword()
      }
    }

    Rectangle {
      anchors.centerIn: parent
      width: 360
      implicitHeight: col.implicitHeight + 40
      radius: Settings.rounding
      color: Settings.colors.background
      border.color: Settings.colors.border
      border.width: 1

      // Swallow clicks so they don't fall through to the backdrop.
      MouseArea { anchors.fill: parent }

      ColumnLayout {
        id: col
        anchors {
          fill: parent
          margins: 20
        }
        spacing: 12

        Text {
          text: "Connect to " + (Runtime.wifiPasswordTarget?.name ?? "")
          color: Settings.colors.foreground
          font {
            pixelSize: 15
            weight: Font.Bold
          }
          elide: Text.ElideRight
          Layout.fillWidth: true
        }

        TextField {
          id: pwField
          Layout.fillWidth: true
          echoMode: TextInput.Password
          placeholderText: "Password"
          placeholderTextColor: Qt.rgba(Settings.colors.foreground.r, Settings.colors.foreground.g, Settings.colors.foreground.b, 0.4)
          color: Settings.colors.foreground
          focus: true
          onAccepted: win.submit()
          background: Rectangle {
            radius: 8
            color: Settings.colors.backgroundLighter
            border.color: pwField.activeFocus ? Settings.colors.accent : Settings.colors.border
            border.width: 1
          }
        }

        Text {
          text: Runtime.wifiPasswordError
          color: Settings.colors.error
          font.pixelSize: 11
          visible: text !== ""
          wrapMode: Text.WordWrap
          Layout.fillWidth: true
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 8

          Item { Layout.fillWidth: true }

          DialogButton {
            label: "Cancel"
            onClicked: Runtime.closeWifiPassword()
          }

          DialogButton {
            label: "Connect"
            accent: true
            onClicked: win.submit()
          }
        }
      }
    }

    Connections {
      target: Runtime.wifiPasswordTarget
      ignoreUnknownSignals: true
      function onConnectedChanged() {
        if (Runtime.wifiPasswordTarget?.connected) Runtime.closeWifiPassword();
      }
      function onConnectionFailed(reason) {
        Runtime.wifiPasswordError = "Connection failed: " + Net.ConnectionFailReason.toString(reason);
      }
    }

    component DialogButton: Rectangle {
      id: btn
      property string label: ""
      property bool accent: false
      signal clicked()

      implicitWidth: btnText.implicitWidth + 28
      implicitHeight: 34
      radius: 8
      color: accent ? Settings.colors.accent : Settings.colors.backgroundLighter
      border.color: Settings.colors.border
      border.width: 1

      Text {
        id: btnText
        anchors.centerIn: parent
        text: btn.label
        color: btn.accent ? Settings.colors.background : Settings.colors.foreground
        font.pixelSize: 12
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
      }
    }
  }
}
