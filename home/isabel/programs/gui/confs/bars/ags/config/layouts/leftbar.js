const Shared = imports.layouts.shared;

// static windows
const notifications = monitor => Shared.notifications(monitor, 'slide_right', ['left']);
const desktop = Shared.desktop;
const corners = Shared.corners;

// popups
const dashboard = {
    name: 'dashboard',
    popup: true,
    focusable: true,
    anchor: ['left'],
    child: {
        type: 'layout',
        layout: 'left',
        window: 'dashboard',
        child: { type: 'dashboard/popup-content' },
    },
};

const quicksettings = {
    name: 'quicksettings',
    popup: true,
    focusable: true,
    anchor: ['bottom', 'left'],
    child: {
        type: 'layout',
        layout: 'bottomleft',
        window: 'quicksettings',
        child: { type: 'quicksettings/popup-content' },
    },
};

// bar
const { launcher, bar } = imports.layouts.shared;
const separator = { type: 'separator' };

const panel = bar({
    anchor: ['top', 'left', 'bottom'],
    orientation: 'vertical',
    start: [
        launcher(20),
        { type: 'workspaces', className: 'workspaces panel-button', orientation: 'vertical' },
        { type: 'media/panel-indicator', className: 'media panel-button', hexpand: true, halign: 'end' },
    ],
    center: [
        { type: 'dashboard/panel-button', format: '%I\n܅\n%M' },
    ],
    end: [
        { type: 'colorpicker', className: 'colorpicker panel-button' },
        { type: 'quicksettings/panel-button', orientation: 'vertical' },
        { type: 'powermenu/panel-button' },
    ],
});

/* exported windows */
var windows = [
    ...ags.Service.Hyprland.HyprctlGet('monitors').map(({ id }) => ([
        notifications(id),
        desktop(id),
        panel(id),
        ...corners(id),
    ])).flat(),
    dashboard,
    quicksettings,
];
