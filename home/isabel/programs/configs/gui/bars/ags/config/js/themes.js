import { Theme, WP, lightColors } from "./settings/theme.js";

export default [
    Theme({
        name: "Mocha",
        icon: "",
    }),
    Theme({
        name: "Latte",
        icon: "",
        "desktop.wallpaper": WP + "card_after_training.png",
        ...lightColors,
    }),
];
