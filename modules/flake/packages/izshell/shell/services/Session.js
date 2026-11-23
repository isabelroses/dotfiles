.pragma library

// The numbers and rules behind Session.qml, kept free of Quickshell types so
// they run under qmltestrunner.

// the idle warning lasts 20 s, or the last third of a very short timeout
const maxWarningSeconds = 20;

// minutes of idleness before the lock -> when the lock and the warning start
function idleTimes(minutes) {
  const lockAfter = minutes * 60;
  const warnFor = Math.min(maxWarningSeconds, Math.floor(lockAfter / 3));
  return { lockAfter, warnFor, warnAfter: lockAfter - warnFor };
}

// 0 minutes never locks; neither does a lock already up or keep-awake
function idleEnabled(minutes, locked, keepAwake) {
  return minutes > 0 && !locked && !keepAwake;
}

// The lock file holds the Hyprland instance that was locked, so a fresh login
// never inherits a lock from a session that ended locked.
function isLockedIn(fileText, key) {
  return fileText.trim() === key;
}

function lockFileText(locked, key) {
  return locked ? key : "";
}
