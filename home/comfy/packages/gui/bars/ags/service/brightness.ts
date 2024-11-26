import { bash, dependencies, sh } from "lib/utils";

if (!dependencies("brightnessctl")) App.quit();

const get = (args: string) => Number(Utils.exec(`brightnessctl ${args}`));
const screen = await bash`ls -w1 /sys/class/backlight | head -1`;

class Brightness extends Service {
  static {
    Service.register(
      this,
      {},
      {
        screen: ["float", "rw"],
        available: ["boolean", "r"],
      },
    );
  }

  #available = false;

  get available() {
    return this.#available;
  }

  #screenMax = get("max");
  #screen = get("get") / (get("max") || 1);

  get screen() {
    return this.#screen;
  }

  set screen(percent) {
    if (percent < 0) percent = 0;

    if (percent > 1) percent = 1;

    sh(`brightnessctl set ${Math.floor(percent * 100)}% -q`).then(() => {
      this.#screen = percent;
      this.changed("screen");
    });
  }

  constructor() {
    super();

    const screenPath = `/sys/class/backlight/${screen}/brightness`;

    this.#available = screen.length == 0 ? false : true;

    Utils.monitorFile(screenPath, async (f) => {
      const v = await Utils.readFileAsync(f);
      this.#screen = Number(v) / this.#screenMax;
      this.changed("screen");
    });
  }
}

export default new Brightness();
