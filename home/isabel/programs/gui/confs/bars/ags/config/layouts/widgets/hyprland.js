const { Widget } = ags;
const { execAsync } = ags.Utils;

Widget.widgets['workspaces'] = ({ orientation, ...props }) => Widget({
    ...props,
    type: 'box',
    children: [{
        type: 'box',
        children: [{
            type: 'eventbox',
            className: 'eventbox',
            child: {
                type: 'hyprland/workspaces',
                fixed: 7,
                orientation,
                child: {
                    type: 'box',
                    className: 'indicator',
                    valign: 'center',
                    children: [{
                        type: 'box',
                        className: 'fill',
                    }],
                },
            },
        }],
    }],
});