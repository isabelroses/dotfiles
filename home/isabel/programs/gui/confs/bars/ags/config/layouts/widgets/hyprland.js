import * as hyprland from '../../modules/hyprland.js';
const { Box, EventBox, Button } = ags.Widget;
const { execAsync } = ags.Utils;

export const Workspaces = ({ props, vertical }) => Box({
    ...props,
    className: 'workspaces panel-button',
    children: [Box({
        children: [EventBox({
            className: 'eventbox',
            child: hyprland.Workspaces({
                vertical,
                indicator: () => Box({
                    className: 'indicator',
                    valign: 'center',
                    children: [Box({ className: 'fill' })],
                }),
            }),
        })],
    })],
});
