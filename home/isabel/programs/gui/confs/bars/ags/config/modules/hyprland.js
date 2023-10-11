const { App } = ags;
const { Hyprland, Applications } = ags.Service;
const { execAsync, lookUpIcon } = ags.Utils;
const { Box, Button, Label, Icon } = ags.Widget;

export const Workspaces = ({
    fixed = 7,
    vertical,
    indicator,
    ...props
} = {}) => Box({
    ...props,
    vertical,
    children: Array.from({ length: fixed }, (_, i) => i + 1).map(i => Button({
        onClicked: () => execAsync(`hyprctl dispatch workspace ${i}`).catch(print),
        child: indicator ? indicator() : Label(`${i}`),
        connections: [[Hyprland, btn => {
            const { workspaces, active } = Hyprland;
            const occupied = workspaces.has(i) && workspaces.get(i).windows > 0;
            btn.toggleClassName('active', active.workspace.id === i);
            btn.toggleClassName('occupied', occupied);
            btn.toggleClassName('empty', !occupied);
        }]],
    })),
});
