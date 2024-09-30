import lowBattery from "./battery";
import notifications from "./notifications";
import { initWallpaper } from "./wallpaper";

export default function init() {
  try {
    lowBattery();
    notifications();
    initWallpaper();
  } catch (error) {
    logError(error);
  }
}
