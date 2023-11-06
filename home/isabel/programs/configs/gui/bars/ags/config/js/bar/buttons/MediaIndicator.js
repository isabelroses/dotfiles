import HoverRevealer from "../../misc/HoverRevealer.js";
import * as mpris from "../../misc/mpris.js";
import options from "../../options.js";
import { Widget, Mpris, Utils } from "../../imports.js";

export const getPlayer = (name = options.preferredMpris) =>
    Mpris.getPlayer(name) || Mpris.players[0] || null;

const Indicator = ({ player, direction = "right" } = {}) =>
    HoverRevealer({
        class_name: `media panel-button ${player.name}`,
        direction,
        onPrimaryClick: () => player.playPause(),
        onScrollUp: () => player.next(),
        onScrollDown: () => player.previous(),
        onSecondaryClick: () => player.playPause(),
        indicator: mpris.PlayerIcon(player),
        child: Widget.Label({
            vexpand: true,
            truncate: "end",
            max_width_chars: 40,
            connections: [
                [
                    player,
                    (label) => {
                        label.label = `${player.trackArtists.join(", ")} - ${
                            player.trackTitle
                        }`;
                    },
                ],
            ],
        }),
        connections: [
            [
                player,
                (revealer) => {
                    if (revealer._current === player.trackTitle) return;

                    revealer._current = player.trackTitle;
                    revealer.reveal_child = true;
                    Utils.timeout(3000, () => {
                        revealer.reveal_child = false;
                    });
                },
            ],
        ],
    });

export default ({ direction } = {}) =>
    Widget.Box({
        connections: [
            [
                Mpris,
                (box) => {
                    const player = getPlayer();
                    box.visible = !!player;

                    if (!player) {
                        box._player = null;
                        return;
                    }

                    if (box._player === player) return;

                    box._player = player;
                    box.children = [Indicator({ player, direction })];
                },
                "notify::players",
            ],
        ],
    });
