import options from "./options.js";
import { Variable, Utils } from "./imports.js";

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

export const distro = Utils.exec("cat /etc/os-release")
    .split("\n")
    .find((line) => line.startsWith("ID"))
    .split("=")[1];

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

const divide = ([total, free]) => free / total;
export const cpu = Variable(0, {
    poll: [
        options.systemFetchInterval,
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
        options.systemFetchInterval,
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
    poll: [
        options.systemFetchInterval,
        "cat " + options.temperature,
        (n) => n / 100_000,
    ],
});
