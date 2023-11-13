import Variable from "resource:///com/github/Aylur/ags/variable.js";
import GLib from "gi://GLib";
import options from "./options.js";

const interval = options.systemFetchInterval;

export const uptime = Variable("", {
    poll: [
        60_000,
        "cat /proc/uptime",
        (line) => {
            const uptime = Number.parseInt(line.split(".")[0]) / 60;
            const h = Math.floor(uptime / 60);
            const s = Math.floor(uptime % 60);
            return `${h}:${s < 10 ? "0" + s : s}`;
        },
    ],
});

export const distro = GLib.get_os_info("ID");

export const distroIcon = (() => {
    switch (distro) {
        case "fedora":
            return "";
        case "arch":
            return "";
        case "nixos":
            return "";
        case "debian":
            return "";
        case "opensuse-tumbleweed":
            return "";
        case "ubuntu":
            return "";
        case "endeavouros":
            return "";
        default:
            return "";
    }
})();

/** @type {function([string, string] | string[]): number} */
const divide = ([total, free]) => free / total;

export const cpu = Variable(0, {
    poll: [
        interval,
        "top -b -n 1",
        (out) =>
            divide([
                100,
                out
                    .split("\n")
                    .find((line) => line.includes("Cpu(s)"))
                    ?.split(/\s+/)[1]
                    .replace(",", "."),
            ]),
    ],
});

export const ram = Variable(0, {
    poll: [
        interval,
        "free",
        (out) =>
            divide(
                out
                    .split("\n")
                    .find((line) => line.includes("Mem:"))
                    ?.split(/\s+/)
                    .splice(1, 2),
            ),
    ],
});

export const temp = Variable(0, {
    poll: [interval, "cat " + options.temperature, (n) => n / 100_000],
});
