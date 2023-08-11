const { Widget, App } = ags;
const { Hyprland, Applications } = ags.Service;
const { execAsync, lookUpIcon, warning } = ags.Utils;

Widget.widgets['hyprland/workspaces'] = ({
    fixed = 7,
    child,
    orientation,
    ...props
}) => Widget({
    ...props,
    type: 'box',
    orientation,
    children: Array.from({ length: fixed }, (_, i) => i + 1).map(i => ({
        type: 'button',
        onClick: () => execAsync(`hyprctl dispatch workspace ${i}`).catch(print),
        child: child ? Widget(child) : `${i}`,
        connections: [[Hyprland, btn => {
            const { workspaces, active } = Hyprland;
            const occupied = workspaces.has(i) && workspaces.get(i).windows > 0;
            btn.toggleClassName('active', active.workspace.id === i);
            btn.toggleClassName('occupied', occupied);
            btn.toggleClassName('empty', !occupied);
        }]],
    })),
});