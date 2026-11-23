.pragma library

// The screenshot journey as a pure transition function: step(state, event,
// config) -> { state, effects }. Screenshot.qml holds the state, feeds events in
// and carries out the effects (screencopy, clipboard, tesseract, notifications,
// timers, files); everything about what happens when, and who may delete which
// temp file, is decided here.
//
//  phase      what is going on
//  idle       nothing
//  freezing   screens are being captured behind hidden overlays
//  picking    the picker is up (frozen screens, a toolbar)
//  region     choosing a region on the frozen screens
//  settling   the overlay is going away before an all-screens grab
//  grabbing   a direct capture (window, screen, every screen) is being taken
//  recognising  tesseract is reading the capture
//  editing    the capture is open in the editor
//
// events (from the windows and Screenshot.qml)
//  { type: "request", kind: "menu"|"region"|"window"|"output"|"all"|"text" }  from IPC or a binding
//  { type: "choose", key }          a picker button or key: region, text, window, output, all
//  { type: "toggleEdit" }  { type: "cancel" }
//  { type: "screenFrozen" }  { type: "freezeTimeout" }  { type: "settled" }
//  { type: "grabbed" }  { type: "grabFailed", message }
//  { type: "copied", ok }  { type: "ocrFinished", text }  { type: "ocrTimeout" }
//  { type: "editRequested", path }  { type: "editorClosed", copy }
//  { type: "released", path }       a notification holding a capture's file closed
//  { type: "fail", message }
//
// config (read when an event arrives)
//  { save, notify, editor: "never"|"picker"|"always", dir, tmpDir, stamp,
//    screenCount, focused: { name, width, height } }
//
// effects
//  refreshToplevels  startTimer { name, ms }  stopTimer { name }
//  copyImage { path }  copyText { text }  runTesseract { path, sparse }  stopTesseract
//  notify { kind: "copied", path, saved } | { kind: "ocr", found } | { kind: "failed", message }
//  closeNotification { path }  removeFile { path }

const freezeTimeoutMs = 2000;
// no freeze spans every screen: wait for the overlay to unmap, then grab live
const settleMs = 120;
// tesseract normally takes a second or two; one that hangs or never starts must not block screenshots
const ocrTimeoutMs = 30000;

function initial() {
  return {
    phase: "idle",
    // which overlay phase a freeze ends in: "picking" or "region"
    next: "",
    frozen: 0,
    // open the capture in the editor rather than copying it straight away
    edit: false,
    // copy the text in the region rather than the image
    ocr: false,
    // where the capture in progress is written
    path: "",
    // a crop of the frozen screen to grab: { output, x, y, w, h }
    crop: null,
    // a direct capture to take: { kind, screen? }
    job: null,
    // the capture open in the editor, or ""
    editing: "",
    // the editor closed with a copy: its hold on this file ends once the copy is done
    pendingRelease: "",
    // the last file name stamp used, and how many captures took it: a second
    // capture within the same second gets "_2" and so on, instead of the same file
    lastStamp: "",
    stampUses: 0,
    // tesseract is on its second, sparse pass
    sparse: false,
    // capture files not yet gone: path -> { saved, holders }. An unsaved one is
    // removed when the last holder lets go; a saved one is kept.
    files: {},
  };
}

function busy(s) {
  return s.phase !== "idle";
}

function overlayShown(s) {
  return s.phase === "picking" || s.phase === "region";
}

function copy(s, changes) {
  return Object.assign({}, s, changes);
}

// a new capture's file -> { state, path }
function claimPath(s, config, ocr) {
  // unsaved captures still need a file for the editor or tesseract to read
  const folder = config.save && !ocr ? config.dir : config.tmpDir;
  const uses = config.stamp === s.lastStamp ? s.stampUses + 1 : 1;
  const suffix = uses > 1 ? `_${uses}` : "";
  return { state: copy(s, { lastStamp: config.stamp, stampUses: uses }), path: `${folder}/Screenshot_${config.stamp}${suffix}.png` };
}


// ---- files

function track(s, path, saved) {
  const holders = s.files[path] ? s.files[path].holders : 0;
  return copy(s, { files: Object.assign({}, s.files, { [path]: { saved, holders } }) });
}

function forget(s, path) {
  const files = Object.assign({}, s.files);
  delete files[path];
  return copy(s, { files });
}

function retain(s, path) {
  const f = s.files[path];
  if (!f) return s;
  return copy(s, { files: Object.assign({}, s.files, { [path]: { saved: f.saved, holders: f.holders + 1 } }) });
}

// one holder lets go; with none left an unsaved file is removed
function release(r, path) {
  const f = r.state.files[path];
  if (!f) return r;
  const holders = f.holders - 1;
  if (holders > 0) return { state: copy(r.state, { files: Object.assign({}, r.state.files, { [path]: { saved: f.saved, holders } }) }), effects: r.effects };
  const effects = f.saved ? r.effects : [...r.effects, { type: "removeFile", path }];
  return { state: forget(r.state, path), effects };
}

// nothing holds the file any more: an unsaved one goes
function drop(r, path) {
  const f = r.state.files[path];
  if (!f) return r;
  return { state: forget(r.state, path), effects: f.saved ? r.effects : [...r.effects, { type: "removeFile", path }] };
}

// ---- journeys

function reset(s) {
  return copy(s, { phase: "idle", next: "", frozen: 0, path: "", crop: null, job: null, edit: false, ocr: false, sparse: false });
}

function stopTimers() {
  return [{ type: "stopTimer", name: "freeze" }, { type: "stopTimer", name: "settle" }, { type: "stopTimer", name: "ocr" }];
}

// an unfinished capture is dropped; a file nothing holds yet was never written
function abandon(s) {
  const f = s.files[s.path];
  const forgotten = s.path !== "" && f && f.holders === 0 ? forget(s, s.path) : s;
  return reset(forgotten);
}

function fail(s, message) {
  return { state: abandon(s), effects: [...stopTimers(), { type: "notify", kind: "failed", message }] };
}

function openOverlay(s, mode, config) {
  if (busy(s)) return { state: s, effects: [] };
  const c = claimPath(s, config, s.ocr);
  return {
    state: copy(track(c.state, c.path, config.save && !s.ocr), { phase: "freezing", next: mode === "picker" ? "picking" : "region", frozen: 0, path: c.path }),
    effects: [{ type: "refreshToplevels" }, { type: "startTimer", name: "freeze", ms: freezeTimeoutMs }],
  };
}

// a region whose text is copied instead of its image; from the picker too
function text(s, config) {
  if (busy(s) && !overlayShown(s)) return { state: s, effects: [] };
  const ocr = copy(s, { ocr: true });
  if (!overlayShown(s)) return openOverlay(ocr, "region", config);
  // the path moves: text is never saved to the folder
  const old = forget(ocr, s.path);
  const c = claimPath(old, config, true);
  return { state: copy(track(c.state, c.path, false), { phase: "region", path: c.path }), effects: [] };
}

function capture(s, kind, config) {
  if (!overlayShown(s)) {
    if (busy(s)) return { state: s, effects: [] };
    const c = claimPath(s, config, s.ocr);
    return {
      state: copy(track(c.state, c.path, config.save && !s.ocr), { phase: "grabbing", path: c.path, job: { kind, screen: config.focused.name } }),
      effects: [],
    };
  }
  if (kind === "output") {
    // crop the clean freeze: the overlay is up, so a live grab would include it
    const f = config.focused;
    return { state: copy(s, { crop: { output: f.name, x: 0, y: 0, w: f.width, h: f.height } }), effects: [] };
  }
  if (kind === "window") {
    // a window is captured from its own buffer, so the overlay never shows up in it
    return { state: copy(s, { phase: "grabbing", job: { kind: "window" } }), effects: [] };
  }
  return { state: copy(s, { phase: "settling" }), effects: [{ type: "startTimer", name: "settle", ms: settleMs }] };
}

// the capture is in the file at s.path
function captured(s) {
  const path = s.path;
  const edit = s.edit;
  const ocr = s.ocr;
  const done = reset(s);
  if (ocr) {
    return { state: copy(retain(done, path), { phase: "recognising", path, sparse: false }), effects: [{ type: "runTesseract", path, sparse: false }, { type: "startTimer", name: "ocr", ms: ocrTimeoutMs }] };
  }
  if (edit) return { state: copy(retain(done, path), { phase: "editing", editing: path }), effects: [] };
  return deliver({ state: done, effects: [] }, path);
}

// copy the image to the clipboard; `copied` says whether that worked
function deliver(r, path) {
  return { state: r.state, effects: [...r.effects, { type: "copyImage", path }] };
}

function ocrFinished(s, found, config) {
  const text = found.trim();
  if (text === "" && !s.sparse) {
    return { state: copy(s, { sparse: true }), effects: [{ type: "runTesseract", path: s.path, sparse: true }, { type: "startTimer", name: "ocr", ms: ocrTimeoutMs }] };
  }
  const path = s.path;
  let r = release({ state: copy(s, { phase: "idle", path: "", sparse: false }), effects: [] }, path);
  const effects = [{ type: "stopTimer", name: "ocr" }, ...r.effects];
  if (text !== "") effects.push({ type: "copyText", text });
  if (config.notify || text === "") effects.push({ type: "notify", kind: "ocr", found: text });
  return { state: r.state, effects };
}

function copied(s, ok, path, config) {
  // an editor that closed with a copy still holds the file until now
  const editorHolds = s.pendingRelease === path;
  let r = { state: editorHolds ? copy(s, { pendingRelease: "" }) : s, effects: [] };
  if (!ok) {
    if (editorHolds) r = release(r, path);
    // the clipboard never got it, so nothing needs the file; an unsaved one goes
    r = drop(r, path);
    const f = fail(r.state, "Could not copy the capture");
    return { state: f.state, effects: [...r.effects, ...f.effects] };
  }
  // the clipboard keeps its own copy, so the file is free to go
  if (!config.notify) return drop(r, path);
  const file = r.state.files[path];
  r = { state: retain(r.state, path), effects: [{ type: "notify", kind: "copied", path, saved: file ? file.saved : config.save }] };
  return editorHolds ? release(r, path) : r;
}

function step(s, event, config) {
  switch (event.type) {
  case "request": {
    // the picker opens the editor unless screenshot.editor says never; direct
    // captures only when it says always
    const edit = event.kind === "menu" ? config.editor !== "never" : config.editor === "always";
    const s2 = !busy(s) && event.kind !== "text" ? copy(s, { edit }) : s;
    switch (event.kind) {
    case "menu":   return openOverlay(s2, "picker", config);
    case "region": return openOverlay(s2, "region", config);
    case "text":   return text(s2, config);
    default:       return capture(s2, event.kind, config);
    }
  }

  case "choose":
    if (!overlayShown(s)) return { state: s, effects: [] };
    if (event.key === "region") return { state: copy(s, { phase: "region" }), effects: [] };
    if (event.key === "text") return text(s, config);
    return capture(s, event.key, config);

  case "toggleEdit":
    return { state: copy(s, { edit: !s.edit }), effects: [] };

  case "cancel":
    // only an unfinished capture can be cancelled; one in the editor or being read is not
    if (!busy(s) || s.phase === "editing" || s.phase === "recognising") return { state: s, effects: [] };
    return { state: abandon(s), effects: stopTimers() };

  case "screenFrozen": {
    if (s.phase !== "freezing") return { state: s, effects: [] };
    const frozen = s.frozen + 1;
    if (frozen < config.screenCount) return { state: copy(s, { frozen }), effects: [] };
    return { state: copy(s, { phase: s.next, next: "", frozen }), effects: [{ type: "stopTimer", name: "freeze" }] };
  }

  case "freezeTimeout":
    return s.phase === "freezing" ? fail(s, "Could not capture the screen") : { state: s, effects: [] };

  case "settled":
    return s.phase === "settling" ? { state: copy(s, { phase: "grabbing", job: { kind: "all" } }), effects: [] } : { state: s, effects: [] };

  case "grabbed":
    return s.phase === "idle" ? { state: s, effects: [] } : captured(s);

  case "grabFailed":
    if (!busy(s)) return { state: s, effects: [] };
    return fail(s, event.message);

  case "fail":
    return fail(s, event.message);

  case "copied":
    return copied(s, event.ok, event.path, config);

  case "ocrTimeout": {
    if (s.phase !== "recognising") return { state: s, effects: [] };
    const r = release({ state: copy(s, { phase: "idle", path: "", sparse: false }), effects: [{ type: "stopTesseract" }] }, s.path);
    return { state: r.state, effects: [...r.effects, { type: "notify", kind: "failed", message: "Reading the text took too long" }] };
  }

  case "ocrFinished":
    return s.phase === "recognising" ? ocrFinished(s, event.text, config) : { state: s, effects: [] };

  case "editRequested": {
    // the notification's Edit action; ignored while another capture is under way
    if (busy(s) || !s.files[event.path]) return { state: s, effects: [] };
    return { state: copy(retain(s, event.path), { phase: "editing", editing: event.path }), effects: [{ type: "closeNotification", path: event.path }] };
  }

  case "editorClosed": {
    if (s.phase !== "editing") return { state: s, effects: [] };
    const path = s.editing;
    const idle = copy(s, { phase: "idle", editing: "" });
    // a copy is delivered first; the editor lets go once that is done (see copied)
    if (event.copy) return { state: copy(idle, { pendingRelease: path }), effects: [{ type: "copyImage", path }] };
    return release({ state: idle, effects: [] }, path);
  }

  case "released":
    return release({ state: s, effects: [] }, event.path);

  default:
    return { state: s, effects: [] };
  }
}
