import { Theme, WP, lightColors } from "./settings/theme.js";

export default [
  Theme({
    name: "Mocha",
    icon: "",
    "desktop.wallpaper.img": WP + "walking.png",
  }),
  Theme({
    name: "Latte",
    icon: "",
    "desktop.wallpaper.img": WP + "card_after_training.png",
    ...lightColors,
  }),
];
