pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire as QsPipewire

// Sound cards, their profiles and ports. Quickshell's Pipewire service only
// sees nodes, so this reads devices from pw-dump and changes them with wpctl.
// Nothing runs until something sets `watching`.
Singleton {
  id: root

  property bool watching: false
  // [{ id, name, profile, profiles: [{ index, description }], enumRoutes, routes }]
  property var cards: []

  function refresh(): void {
    if (watching) settle.restart();
  }

  function setProfile(card: var, index: int): void {
    Quickshell.execDetached(["wpctl", "set-profile", String(card.id), String(index)]);
    settle.restart();
  }

  // the ports a sink or source can switch between, and the one in use
  function portsFor(node: QsPipewire.PwNode): var {
    const props = node?.properties ?? {};
    const card = cards.find(c => String(c.id) === String(props["device.id"]));
    const device = Number(props["card.profile.device"]);
    if (!card || isNaN(device)) return { options: [], current: -1 };
    const direction = node.isSink ? "Output" : "Input";
    const options = card.enumRoutes
      .filter(r => r.direction === direction && r.available !== "no" && (r.devices ?? []).includes(device))
      .map(r => ({ index: r.index, description: r.description }));
    const current = card.routes.find(r => r.device === device)?.index ?? -1;
    return { options, current };
  }

  function setPort(node: QsPipewire.PwNode, index: int): void {
    Quickshell.execDetached(["wpctl", "set-route", String(node.id), String(index)]);
    settle.restart();
  }

  onWatchingChanged: refresh()

  Connections {
    target: QsPipewire.Pipewire.nodes
    function onValuesChanged() { root.refresh(); }
  }

  // wpctl returns before the device has switched; read back once it settles
  Timer {
    id: settle
    interval: 400
    onTriggered: dump.running = true
  }

  Process {
    id: dump
    command: ["pw-dump"]
    stdout: StdioCollector {
      onStreamFinished: {
        let objects;
        try { objects = JSON.parse(text); } catch (e) { return; }
        root.cards = objects
          .filter(o => o.type === "PipeWire:Interface:Device" && o.info?.props?.["media.class"] === "Audio/Device")
          .map(o => {
            const p = o.info.params ?? {};
            return {
              id: o.id,
              name: o.info.props["device.description"] ?? o.info.props["device.name"] ?? `Card ${o.id}`,
              profile: p.Profile?.[0]?.index ?? -1,
              profiles: (p.EnumProfile ?? [])
                .filter(x => x.available !== "no" || x.index === p.Profile?.[0]?.index)
                .map(x => ({ index: x.index, description: x.description })),
              enumRoutes: p.EnumRoute ?? [],
              routes: p.Route ?? [],
            };
          })
          .sort((a, b) => a.name.localeCompare(b.name));
      }
    }
  }
}
