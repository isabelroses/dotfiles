import PopupWindow, { Padding } from "widget/popupwindow";
import { AppItem } from "./app";
import icons from "lib/icons";
import options from "options";
import { launchApp } from "lib/utils";

const apps = await Service.import("applications");
const { query } = apps;
const { width, margin } = options.launcher;

const SeparatedAppItem = (app: Parameters<typeof AppItem>[0]) =>
  Widget.Revealer(
    { attribute: { app } },
    Widget.Box({ vertical: true }, Widget.Separator(), AppItem(app)),
  );

const Applauncher = () => {
  const applist = Variable(query(""));
  let first = applist.value[0];

  const list = Widget.Box({
    vertical: true,
    children: applist.bind().as((list) => list.map(SeparatedAppItem)),
  });

  list.hook(apps, () => (applist.value = query("")), "notify::frequents");

  const entry = Widget.Entry({
    hexpand: true,
    primary_icon_name: icons.ui.search,
    on_accept: () => {
      entry.text !== "" && launchApp(first);
      App.toggleWindow("launcher");
    },
    on_change: ({ text }) => {
      first = query(text || "")[0];
      list.children.reduce((i, item) => {
        if (!text || i >= 6) {
          item.reveal_child = false;
          return i;
        }
        if (item.attribute.app.match(text)) {
          item.reveal_child = true;
          return ++i;
        }
        item.reveal_child = false;
        return i;
      }, 0);
    },
  });

  function focus() {
    entry.text = "Search";
    entry.set_position(-1);
    entry.select_region(0, -1);
    entry.grab_focus();
  }

  const layout = Widget.Box({
    css: width.bind().as((v) => `min-width: ${v}pt;`),
    class_name: "launcher",
    vertical: true,
    vpack: "start",
    setup: (self) =>
      self.hook(App, (_, win, visible) => {
        if (win !== "launcher") return;

        entry.text = "";
        if (visible) focus();
      }),
    children: [entry, list],
  });

  return Widget.Box(
    { vertical: true, css: "padding: 1px" },
    Padding("launcher", {
      css: margin.bind().as((v) => `min-height: ${v}pt;`),
      vexpand: false,
    }),
    layout,
  );
};

export default () =>
  PopupWindow({
    name: "launcher",
    layout: "top",
    child: Applauncher(),
  });
