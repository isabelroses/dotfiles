import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.data
import qs.services
import qs.components

// Annotates a capture before it goes to the clipboard. Annotations live in the
// image's own pixels on `canvas`, which is grabbed at full size on copy and
// written over the capture. Esc closes without copying. Built fresh for each
// capture, so nothing carries over between them.
LazyLoader {
  active: Screenshot.editing !== ""

  PanelWindow {
    id: win

    readonly property string path: Screenshot.editing
    // the screen focused when the capture arrived; read once, not followed
    property ShellScreen target
    Component.onCompleted: target = Screenshot.focusedScreen()

    // "pen" | "arrow" | "rect" | "text" | "pixelate"
    property string tool: "arrow"
    property int colourIndex: 0
    readonly property list<color> colours: [
      Settings.colors.red, Settings.colors.yellow, Settings.colors.green,
      Settings.colors.blue, Settings.colors.mauve, Settings.colors.text, Settings.colors.base,
    ]
    readonly property color colour: colours[colourIndex]

    // committed annotations, oldest first; reassigned (never mutated) so bindings update
    property var shapes: []
    property var undone: []
    // the annotation being dragged out, or null
    property var draft: null
    // where a text annotation is being typed, or null
    property var typing: null
    readonly property bool pixelating: draft?.type === "pixelate" || shapes.some(s => s.type === "pixelate")

    // sizes in image pixels, so they look the same whatever the capture's size
    readonly property real stroke: Math.max(3, Math.round(canvas.width / 400))
    readonly property real textSize: Math.max(16, Math.round(canvas.width / 60))
    readonly property real block: Math.max(8, Math.round(canvas.width / 120))

    readonly property var tools: [
      { key: "arrow", hint: "A", icon: "go-up-symbolic", rotation: 45 },
      { key: "rect", hint: "R", icon: "checkbox-symbolic" },
      { key: "pen", hint: "P", icon: "document-edit-symbolic" },
      { key: "text", hint: "T", icon: "insert-text-symbolic" },
      { key: "pixelate", hint: "H", icon: "view-conceal-symbolic" },
    ]

    screen: target ?? Quickshell.screens[0]
    color: Utils.withAlpha("#000000", 0.6)

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "screenshot-editor"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }

    function commit(shape: var): void {
      shapes = shapes.concat([shape]);
      undone = [];
    }

    function undo(): void {
      if (shapes.length === 0) return;
      undone = undone.concat([shapes[shapes.length - 1]]);
      shapes = shapes.slice(0, -1);
    }

    function redo(): void {
      if (undone.length === 0) return;
      shapes = shapes.concat([undone[undone.length - 1]]);
      undone = undone.slice(0, -1);
    }

    function finishTyping(): void {
      if (typing && textInput.text.trim() !== "")
        commit({ type: "text", x: typing.x, y: typing.y, text: textInput.text, colour: colour, size: textSize });
      typing = null;
    }

    function copy(): void {
      finishTyping();
      canvas.grabToImage(result => {
        if (result?.saveToFile(path)) return Screenshot.editorClosed(true);
        Screenshot.editorClosed(false);
        Screenshot.fail("Could not save the edited capture");
      }, Qt.size(canvas.width, canvas.height));
    }

    // normalised box from a drag
    function box(s: var): rect {
      return Qt.rect(Math.min(s.x1, s.x2), Math.min(s.y1, s.y2), Math.abs(s.x2 - s.x1), Math.abs(s.y2 - s.y1));
    }

    Item {
      id: stage
      anchors { fill: parent; margins: 48; bottomMargin: toolbar.height + 80 }
    }

    Item {
      id: frame
      // shown at 1:1 physical pixels when it fits, otherwise scaled down to fit
      readonly property real fit: canvas.width > 0
        ? Math.min(1 / (win.target?.devicePixelRatio ?? 1), stage.width / canvas.width, stage.height / canvas.height)
        : 1
      width: canvas.width * fit
      height: canvas.height * fit
      x: stage.x + (stage.width - width) / 2
      y: stage.y + (stage.height - height) / 2

      Item {
        id: canvas
        width: img.implicitWidth
        height: img.implicitHeight
        scale: frame.fit
        transformOrigin: Item.TopLeft

        Image {
          id: img
          source: "file://" + win.path
          cache: false
        }

        // the capture decoded once at a coarse resolution, for every pixelate box
        // to show a piece of; never drawn itself
        Item {
          opacity: 0
          Image {
            id: coarse
            width: canvas.width
            height: canvas.height
            source: win.pixelating ? img.source : ""
            sourceSize: Qt.size(Math.max(1, Math.round(canvas.width / win.block)), Math.max(1, Math.round(canvas.height / win.block)))
            smooth: false
            cache: false
          }
        }

        Repeater {
          model: win.shapes
          Annotation { required property var modelData; shape: modelData }
        }

        Annotation { shape: win.draft; visible: win.draft !== null }

        TextInput {
          id: textInput
          visible: win.typing !== null
          x: win.typing?.x ?? 0
          y: win.typing?.y ?? 0
          focus: visible
          color: win.colour
          font.family: Settings.fonts.sans
          font.weight: Font.DemiBold
          font.pixelSize: win.textSize
          cursorVisible: visible
          onVisibleChanged: if (visible) { text = ""; forceActiveFocus(); } else keys.forceActiveFocus()
          Keys.onReturnPressed: win.finishTyping()
          Keys.onEscapePressed: win.typing = null
        }
      }

      Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        color: "transparent"
        border.color: Settings.colors.borderStrong
        border.width: 1
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: win.tool === "text" ? Qt.IBeamCursor : Qt.CrossCursor

        function at(mouse: var): point {
          return Qt.point(Math.round(mouse.x / frame.fit), Math.round(mouse.y / frame.fit));
        }

        onPressed: mouse => {
          const p = at(mouse);
          win.finishTyping();
          if (win.tool === "text") { win.typing = { x: p.x, y: p.y - win.textSize / 2 }; return; }
          win.draft = win.tool === "pen"
            ? { type: "pen", points: [p], colour: win.colour, width: win.stroke }
            : { type: win.tool, x1: p.x, y1: p.y, x2: p.x, y2: p.y, colour: win.colour, width: win.stroke };
        }
        onPositionChanged: mouse => {
          if (!win.draft) return;
          const p = at(mouse);
          win.draft = win.draft.type === "pen"
            ? Object.assign({}, win.draft, { points: win.draft.points.concat([p]) })
            : Object.assign({}, win.draft, { x2: p.x, y2: p.y });
        }
        onReleased: {
          const d = win.draft;
          win.draft = null;
          if (!d) return;
          const big = d.type === "pen" ? d.points.length > 1 : Math.hypot(d.x2 - d.x1, d.y2 - d.y1) > 4;
          if (big) win.commit(d);
        }
      }
    }

    // one annotation, drawn in canvas pixels; only its own type is built
    component Annotation: Loader {
      id: a
      property var shape: null
      readonly property rect b: shape && shape.type !== "pen" ? win.box(shape) : Qt.rect(0, 0, 0, 0)
      sourceComponent: ({ pen: stroke, arrow: stroke, rect: frameBox, pixelate: pixelBox, text: label })[shape?.type] ?? null

      Component {
        id: stroke
        Shape {
          // the curve renderer re-triangulates the whole path on each change, which a
          // pen stroke growing every mouse move can't afford
          preferredRendererType: a.shape.type === "arrow" ? Shape.CurveRenderer : Shape.GeometryRenderer
          ShapePath {
            strokeColor: a.shape.colour
            strokeWidth: a.shape.width
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathPolyline {
              path: {
                const s = a.shape;
                if (s.type === "pen") return s.points;
                // shaft, then back out along one wing and across to the other
                const angle = Math.atan2(s.y2 - s.y1, s.x2 - s.x1);
                const len = Math.max(18, s.width * 7);
                const wing = d => Qt.point(s.x2 - len * Math.cos(angle + d), s.y2 - len * Math.sin(angle + d));
                return [Qt.point(s.x1, s.y1), Qt.point(s.x2, s.y2), wing(0.5), Qt.point(s.x2, s.y2), wing(-0.5)];
              }
            }
          }
        }
      }

      Component {
        id: frameBox
        Rectangle {
          x: a.b.x; y: a.b.y; width: a.b.width; height: a.b.height
          color: "transparent"
          border.color: a.shape.colour
          border.width: a.shape.width
        }
      }

      Component {
        id: pixelBox
        ShaderEffectSource {
          x: a.b.x; y: a.b.y; width: a.b.width; height: a.b.height
          sourceItem: coarse
          sourceRect: a.b
          smooth: false
        }
      }

      Component {
        id: label
        Text {
          x: a.shape.x
          y: a.shape.y
          text: a.shape.text
          color: a.shape.colour
          font.family: Settings.fonts.sans
          font.weight: Font.DemiBold
          font.pixelSize: a.shape.size
        }
      }
    }

    FloatingToolbar {
      id: toolbar
      anchors.bottomMargin: 48

      Repeater {
        model: win.tools
        ToolbarButton {
          required property var modelData
          icon: modelData.icon
          iconRotation: modelData.rotation ?? 0
          active: win.tool === modelData.key
          onClicked: win.tool = modelData.key
        }
      }

      FloatingToolbar.Separator {}

      Repeater {
        model: win.colours

        Clickable {
          id: swatch
          required property color modelData
          required property int index
          readonly property bool current: win.colourIndex === index
          anchors.verticalCenter: parent.verticalCenter
          implicitWidth: 28
          implicitHeight: 44
          onClicked: win.colourIndex = index

          Rectangle {
            anchors.centerIn: parent
            width: swatch.current ? 20 : swatch.hovered ? 18 : 14
            height: width
            radius: Settings.pill(width)
            color: swatch.modelData
            border.width: swatch.current ? 2 : 1
            border.color: swatch.current ? Settings.colors.text : Settings.colors.borderStrong
            Behavior on width { Anim { duration: Settings.animFast } }
          }
        }
      }

      FloatingToolbar.Separator {}

      IconButton {
        anchors.verticalCenter: parent.verticalCenter
        icon: "edit-undo-symbolic"
        size: 16
        padding: 14
        enabled: win.shapes.length > 0
        onClicked: win.undo()
      }
      IconButton {
        anchors.verticalCenter: parent.verticalCenter
        icon: "edit-redo-symbolic"
        size: 16
        padding: 14
        enabled: win.undone.length > 0
        onClicked: win.redo()
      }

      FloatingToolbar.Separator {}

      ToolbarButton { icon: "edit-copy-symbolic"; label: "Copy"; hint: "↵"; active: true; onClicked: win.copy() }
      FloatingToolbar.Close { onClicked: Screenshot.editorClosed(false) }
    }

    Item {
      id: keys
      focus: win.typing === null

      Keys.onPressed: event => {
        const ctrl = event.modifiers & Qt.ControlModifier;
        const shift = event.modifiers & Qt.ShiftModifier;
        if (ctrl && event.key === Qt.Key_Z) shift ? win.redo() : win.undo();
        else if (ctrl && event.key === Qt.Key_Y) win.redo();
        else if (ctrl && event.key === Qt.Key_C) win.copy();
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) win.copy();
        else if (event.key === Qt.Key_Escape) Screenshot.editorClosed(false);
        else if (event.key >= Qt.Key_1 && event.key < Qt.Key_1 + win.colours.length) win.colourIndex = event.key - Qt.Key_1;
        else {
          const t = win.tools.find(t => t.hint === event.text.toUpperCase());
          if (!t) return;
          win.tool = t.key;
        }
        event.accepted = true;
      }
    }
  }
}
