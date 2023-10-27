import { Service, Utils } from "../imports.js";

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

    _screen = 0;

    get screen() {
        return this._screen;
    }

    set screen(percent) {
        if (percent < 0) percent = 0;

        if (percent > 1) percent = 1;

        Utils.execAsync(`brightnessctl s ${percent * 100}% -q`)
            .then(() => {
                this._screen = percent;
                this.changed("screen");
            })
            .catch(console.error);
    }

    constructor() {
        super();
        try {
            this._screen =
                Number(Utils.exec("brightnessctl g")) /
                Number(Utils.exec("brightnessctl m"));
        } catch (error) {
            console.error("missing dependancy: brightnessctl");
        }
    }
}

export default new Brightness();
