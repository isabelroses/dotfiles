import { lightColors, Theme, WP } from "./settings/theme.js";

export default [
  Theme({
    name: "Mocha",
    icon: "",
    "desktop.wallpaper.img": WP + "catgirl.jpeg",
  }),
  Theme({
    name: "Latte",
    icon: "",
    "desktop.wallpaper.img": WP + "card_after_training.png",
    ...lightColors,
  }),
];
