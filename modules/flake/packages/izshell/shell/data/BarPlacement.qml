pragma Singleton

import QtQuick
import Quickshell
import "Placement.js" as Rules

// Where the bar is: the screen edge it sits on, attached or floating, and the
// strip of screen it reserves. Popups ask where to go beside it instead of
// working it out per side (Placement.js has the geometry).
Singleton {
  id: root

  readonly property string side: Settings.bar.side
  readonly property bool vertical: Rules.isVertical(side)
  readonly property bool onRight: side === "right"
  readonly property bool onBottom: side === "bottom"
  // floating: cards and sheets hover with gaps; attached: one strip flush to the edge
  readonly property bool floating: Settings.bar.style === "floating"
  readonly property int reserved: Rules.reserved(floating)
  // the edge popups should open towards, away from the bar
  readonly property int awayEdge: edges([Rules.awayEdge(side)])

  readonly property var _edge: ({ left: Edges.Left, right: Edges.Right, top: Edges.Top, bottom: Edges.Bottom })

  function edges(names: var): int {
    return names.reduce((flags, name) => flags | _edge[name], 0);
  }

  // margins for a window anchored to the bar's edge ({ left, right, top, bottom })
  function windowMargins(inset: real): var {
    return Rules.windowMargins(side, reserved, inset);
  }

  // offset { x, y } to start from, to slide in from the bar
  function slide(distance: real): var {
    return Rules.slide(side, distance);
  }

  // the anchor for a PopupWindow on `item` ({ width, height }): { x, y, width,
  // height, edges, gravity }. Pass `across` to place it, or omit it to centre on the item.
  function popupAnchor(item: var, across: var, startAligned: bool): var {
    const a = Rules.popupAnchor(side, reserved, item, across ?? Rules.centeredAcross(side, reserved, item), startAligned);
    return Object.assign(a, { edges: edges(a.edges), gravity: edges(a.gravity) });
  }

  // a line along the edge of a w x h box that faces the bar, or away from it
  function edgeLine(w: real, h: real, thickness: real, towardBar: bool): var {
    return Rules.edgeLine(side, w, h, thickness, towardBar);
  }
}
