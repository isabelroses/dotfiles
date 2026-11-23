.pragma library

// The rules for which Surfaces are open. State in, new state out, so they run
// under qmltestrunner; Surfaces.qml holds the state and the clock.
//
//  - popups share one slot: opening the quick settings sheet closes the
//    calendar and the other way round. A detail card stacks on the sheet.
//  - windows (settings, power menu, cheatsheet) are independent of each other.
//    The settings window and power menu take the popup slot's surfaces away
//    when they open.
//  - the wifi password prompt stacks on the sheet, or stands alone as a modal.

const popups = ["quickSettings", "calendar"];
// surfaces that are just on or off
const flags = ["settings", "powerMenu", "cheatsheet", "wifiPassword"];
// windows that clear the popups away when they open
const takesOver = ["settings", "powerMenu"];
// a click that dismissed a popup also lands on whatever opens it again, and
// must not reopen it straight away
const reopenGuardMs = 300;

function initial() {
  return {
    popup: "",
    // detail card on the quick settings sheet ("network", "bluetooth", "output", "audio", "input"), or ""
    card: "",
    settings: false,
    powerMenu: false,
    cheatsheet: false,
    wifiPassword: false,
    focusLostAt: {},
  };
}

function isOpen(s, id) {
  return popups.includes(id) ? s.popup === id : s[id] === true;
}

function copy(s, changes) {
  return Object.assign({}, s, changes);
}

function closePopups(s) {
  return copy(s, { popup: "", card: "" });
}

function open(s, id) {
  if (popups.includes(id)) return id === s.popup ? s : copy(s, { popup: id, card: "" });
  if (!flags.includes(id)) return s;
  const next = takesOver.includes(id) ? closePopups(s) : s;
  return copy(next, { [id]: true });
}

function close(s, id) {
  if (popups.includes(id)) return s.popup === id ? closePopups(s) : s;
  return flags.includes(id) ? copy(s, { [id]: false }) : s;
}

// `now` (ms) is only needed to guard a popup against reopening
function toggle(s, id, now) {
  if (isOpen(s, id)) return close(s, id);
  if (popups.includes(id) && now - (s.focusLostAt[id] ?? -Infinity) < reopenGuardMs) return s;
  return open(s, id);
}

// a popup that lost focus (a click elsewhere) closed itself
function dismissedByFocusLoss(s, id, now) {
  return copy(close(s, id), { focusLostAt: copy(s.focusLostAt, { [id]: now }) });
}

// escape, or the sheet's close button: take the top layer off
function dismiss(s) {
  if (s.wifiPassword) return close(s, "wifiPassword");
  if (s.card !== "") return copy(s, { card: "" });
  if (s.popup !== "") return closePopups(s);
  return s;
}

// before the lock covers the screen
function closeAll(s) {
  return copy(closePopups(s), { settings: false, powerMenu: false, cheatsheet: false, wifiPassword: false });
}

function setCard(s, name) {
  return s.popup === "quickSettings" ? copy(s, { card: name }) : s;
}

function toggleCard(s, name) {
  return setCard(s, s.card === name ? "" : name);
}
