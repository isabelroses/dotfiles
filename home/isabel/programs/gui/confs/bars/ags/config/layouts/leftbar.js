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
const separator = { type: 'separator', valign: 'center' };

const panel = bar({
    anchor: ['top', 'left', 'bottom'],
    orientation: 'vertical',
    start: [
        launcher(),
        { type: 'workspaces', className: 'workspaces panel-button' },
        { type: 'media/panel-indicator', className: 'media panel-button', hexpand: true, halign: 'end' },
    ],
    center: [
        { type: 'dashboard/panel-button', format: '%I\n%M' },
    ],
    end: [
        { type: 'notifications/panel-indicator', direction: 'right', className: 'notifications panel-button', hexpand: true },
        { type: 'box', hexpand: true },
        { type: 'colorpicker', className: 'colorpicker panel-button' },
        separator,
        { type: 'quicksettings/panel-button' },
        separator,
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
