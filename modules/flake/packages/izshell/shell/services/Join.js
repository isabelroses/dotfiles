.pragma library

// Joining a Wi-Fi network: one attempt at a time. State in, event in, new state
// and what to do about it out; Networking.qml holds the state and does the
// connecting. Pure, so each path is testable.
//
//  idle           nothing in progress
//  needsPassword  waiting for a password; `error` is why the last one failed, or ""
//  connecting     asked NetworkManager to connect
//  failed         an open or saved network failed to connect; `error` says why

function initial() {
  return { state: "idle", error: "", withPassword: false };
}

// the attempt didn't work: a password attempt asks again, anything else fails.
// Whether a password was used is remembered from `submit`: by the time a
// failure arrives NetworkManager has saved a profile, so the network already
// reads as known.
function failed(s, reason) {
  return { state: { state: s.withPassword ? "needsPassword" : "failed", error: reason, withPassword: s.withPassword }, effect: null };
}

// events: { type: "join", needsPassword } | { type: "submit", password } |
//         { type: "cancel" } | { type: "connected" } | { type: "failed", reason } |
//         { type: "timeout" } (no answer from NetworkManager) |
//         { type: "lost" } (the network went away, e.g. out of the scan)
// -> { state, effect } where effect is "connect", "connectWithPsk" or null
function step(s, event) {
  switch (event.type) {
  case "join":
    if (s.state === "connecting") return { state: s, effect: null };
    return event.needsPassword
      ? { state: { state: "needsPassword", error: "", withPassword: false }, effect: null }
      : { state: { state: "connecting", error: "", withPassword: false }, effect: "connect" };
  case "submit":
    if (s.state !== "needsPassword" || event.password === "") return { state: s, effect: null };
    return { state: { state: "connecting", error: "", withPassword: true }, effect: "connectWithPsk" };
  case "cancel":
    return { state: initial(), effect: null };
  case "connected":
    return { state: s.state === "connecting" ? initial() : s, effect: null };
  case "failed":
    return s.state === "connecting" ? failed(s, event.reason) : { state: s, effect: null };
  case "timeout":
    return s.state === "connecting" ? failed(s, "No answer from the network") : { state: s, effect: null };
  case "lost":
    return { state: s.state === "idle" ? s : initial(), effect: null };
  default:
    return { state: s, effect: null };
  }
}
