import options from "options";
import { dependencies, sh } from "./utils";

const { scheme, dark, light } = options.theme;

export function initWallpaper() {
  if (dependencies("swww")) {
    scheme.connect("changed", wallpaper);
  }
}

export function wallpaper() {
  let wp =
    scheme.value === "dark" ? dark.wallpaper.value : light.wallpaper.value;

  sh(["swww", "img", wp]).catch((err) => console.error(err));
}
