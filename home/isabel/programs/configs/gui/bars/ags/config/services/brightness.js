import * as Utils from "resource:///com/github/Aylur/ags/utils.js";
import Service from "resource:///com/github/Aylur/ags/service.js";
import { dependencies } from "../utils.js";

class Brightness extends Service {
  static {
    Service.register(
      this,
      {},
      {
        screen: ["float", "rw"],
      },
    );
  }

  #screen = 0;

  get screen() {
    return this.#screen;
  }

  set screen(percent) {
    if (!dependencies(["brightnessctl"])) return;

    if (percent < 0) percent = 0;

    if (percent > 1) percent = 1;

    Utils.execAsync(`brightnessctl s ${percent * 100}% -q`)
      .then(() => {
        this.#screen = percent;
        this.changed("screen");
      })
      .catch(console.error);
  }

  constructor() {
    super();
    if (dependencies(["brightnessctl"])) {
      this.#screen =
        Number(Utils.exec("brightnessctl g")) /
        Number(Utils.exec("brightnessctl m"));
    }
  }
}

export default new Brightness();
