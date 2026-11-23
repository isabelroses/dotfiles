pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.data
import "Session.js" as Rules

// The login session's lock, idle policy and suspend. Callers lock, unlock or
// suspend and read `locked` and `warning`; when the lock comes up on its own, how
// long the warning before it lasts, and that suspend waits for the lock are here.
Singleton {
  id: root

  // holds off the idle lock and the warning before it
  property bool keepAwake: false

  // The lock outlives a shell restart (a crash mid-lock must come back locked),
  // but not the compositor (see Session.js isLockedIn).
  readonly property string lockKey: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || "1"
  property bool locked: Rules.isLockedIn(lockState.text(), lockKey)
  onLockedChanged: lockState.setText(Rules.lockFileText(locked, lockKey))

  // the compositor has confirmed the lock is up; LockScreen reports it
  property bool lockConfirmed: false
  onLockConfirmedChanged: if (lockConfirmed && suspendPending) suspendNow()

  // the idle warning: the screen is fading to black ahead of the lock
  readonly property bool warning: warnMonitor.enabled && warnMonitor.isIdle
  readonly property int warnFor: times.warnFor
  readonly property var times: Rules.idleTimes(Settings.lock.idle_minutes)
  readonly property bool idleEnabled: Rules.idleEnabled(Settings.lock.idle_minutes, locked, keepAwake)

  function lock(): void {
    Surfaces.closeAll();
    locked = true;
  }

  function unlock(): void {
    locked = false;
  }

  // lock first, so the machine never wakes unlocked, and suspend once the
  // compositor confirms the lock (or after a moment if it never does)
  function suspend(): void {
    lock();
    if (lockConfirmed) return suspendNow();
    suspendPending = true;
    suspendFallback.restart();
  }

  property bool suspendPending: false

  function suspendNow(): void {
    suspendPending = false;
    suspendFallback.stop();
    System.power("Suspend");
  }

  Timer {
    id: suspendFallback
    interval: 2000
    onTriggered: root.suspendNow()
  }

  FileView {
    id: lockState
    path: Quickshell.statePath("locked")
    blockLoading: true
    blockWrites: true
    printErrors: false
  }

  Binding {
    target: Quickshell
    property: "watchFiles"
    value: !root.locked
  }

  // two monitors, so that an inhibitor (a video playing) starting during the
  // warning still holds the lock off
  IdleMonitor {
    id: warnMonitor
    enabled: root.idleEnabled
    timeout: root.times.warnAfter
    respectInhibitors: true
  }

  IdleMonitor {
    enabled: root.idleEnabled
    timeout: root.times.lockAfter
    respectInhibitors: true
    onIsIdleChanged: if (isIdle) root.lock()
  }
}
