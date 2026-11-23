.pragma library

// Where things go relative to the bar, for every screen edge it can sit on. Pure
// (the side comes in as an argument) so each side is testable; BarPlacement.qml
// binds these to the current Settings.

const away = { left: "right", right: "left", top: "bottom", bottom: "top" };

function isVertical(side) {
  return side === "left" || side === "right";
}

// the edge a popup opens towards: away from the bar
function awayEdge(side) {
  return away[side] ?? "right";
}

// the strip of screen the bar reserves. Floating: an 8px margin, the 44px card,
// then a gap before windows.
function reserved(floating) {
  return floating ? 56 : 52;
}

// margins for a layer-shell window anchored to the bar's edge, so it sits beside
// the bar. `inset` is extra space beside the bar (a gap, minus any padding).
function windowMargins(side, reservedWidth, inset) {
  const m = { left: 0, right: 0, top: 0, bottom: 0 };
  if (side in m) m[side] = reservedWidth + inset;
  return m;
}

// how far a window starts from its resting place so that it slides in from the bar
function slide(side, distance) {
  if (isVertical(side)) return { x: side === "right" ? distance : -distance, y: 0 };
  return { x: 0, y: side === "top" ? -distance : distance };
}

// Anchor for a PopupWindow on an item in the bar: a rect across the bar's
// thickness beside the item, edges and gravity opening away from the bar.
// `item` is { width, height }; `across` is the rect's offset across the bar's
// thickness. `startAligned` lines the popup's start up with the item's, instead
// of centring it on the item.
function popupAnchor(side, reservedWidth, item, across, startAligned) {
  const vertical = isVertical(side);
  const edges = [awayEdge(side)];
  const gravity = [awayEdge(side)];
  if (startAligned) {
    edges.push(vertical ? "top" : "left");
    gravity.push(vertical ? "bottom" : "right");
  }
  return {
    x: vertical ? across : 0,
    y: vertical ? 0 : across,
    width: vertical ? reservedWidth : item.width,
    height: vertical ? item.height : reservedWidth,
    edges,
    gravity,
  };
}

// `across` that centres an item of this size within the bar's reserved strip
function centeredAcross(side, reservedWidth, item) {
  return -(reservedWidth - (isVertical(side) ? item.width : item.height)) / 2;
}

// A line along one edge of a w x h box: the edge facing the bar, or the one
// facing away from it.
function edgeLine(side, w, h, thickness, towardBar) {
  const edge = towardBar ? side : awayEdge(side);
  switch (edge) {
  case "left":   return { x: 0, y: 0, width: thickness, height: h };
  case "right":  return { x: w - thickness, y: 0, width: thickness, height: h };
  case "top":    return { x: 0, y: 0, width: w, height: thickness };
  default:       return { x: 0, y: h - thickness, width: w, height: thickness };
  }
}
