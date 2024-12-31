import options from "options";

const { sleep, reboot, logout, shutdown } = options.powermenu;

export type Action = "sleep" | "reboot" | "logout" | "shutdown";

class PowerMenu extends Service {
  static {
    Service.register(
      this,
      {},
      {
        title: ["string"],
        cmd: ["string"],
      },
    );
  }

  #title = "";
  #cmd = "";

  get title() {
    return this.#title;
  }

  action(action: Action) {
    [this.#cmd, this.#title] = {
      sleep: [sleep.value, "Sleep"],
      reboot: [reboot.value, "Reboot"],
      logout: [logout.value, "Log Out"],
      shutdown: [shutdown.value, "Shutdown"],
    }[action];

    Utils.exec(this.#cmd);
  }

  readonly shutdown = () => {
    this.action("shutdown");
  };
}

const powermenu = new PowerMenu();
Object.assign(globalThis, { powermenu });
export default powermenu;
