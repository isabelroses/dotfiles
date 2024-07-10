import PanelButton from "../panelbutton";
import icons from "lib/icons";
import options from "options";
import { Box } from "resource:///com/github/Aylur/ags/widgets/box.js";
import { Revealer } from "resource:///com/github/Aylur/ags/widgets/revealer.js";
import Gtk from "types/@girs/gtk-3.0/gtk-3.0";

const Arrow = (
  revealer: Revealer<Box<Gtk.Widget, unknown>, unknown>,
  direction: string,
) => {
  let deg = 0;

  const icon = Widget.Icon({
    icon: icons.ui.arrow[direction],
  });

  const animate = () => {
    const t = options.transition.value / 20;
    const step = revealer.reveal_child ? 10 : -10;
    for (let i = 0; i < 18; ++i) {
      Utils.timeout(t * i, () => {
        deg += step;
        icon.setCss(`-gtk-icon-transform: rotate(${deg}deg);`);
      });
    }
  };

  return PanelButton({
    on_clicked: () => {
      animate();
      revealer.reveal_child = !revealer.reveal_child;
    },
    child: icon,
  });
};

export default ({ children, direction = "left" }) => {
  const posStart = direction === "up" || direction === "left";
  const posEnd = direction === "down" || direction === "right";
  const revealer = Widget.Revealer({
    transition: `slide_${direction}`,
    child: Widget.Box({
      children,
    }),
  });

  return Widget.Box({
    vertical: direction === "up" || direction === "down",
    children: [
      posStart && revealer,
      Arrow(revealer, direction),
      posEnd && revealer,
    ],
  });
};
