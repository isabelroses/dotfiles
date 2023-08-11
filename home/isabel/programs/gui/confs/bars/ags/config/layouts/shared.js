/* exported notifications, desktop, corners, indicator, dock, separator,
            launcher bar applauncher, powermenu, verification*/

// static
var notifications = (monitor, transition, anchor) => ({
    monitor,
    name: `notifications${monitor}`,
    anchor,
    child: { type: 'notifications/popup-list', transition },
});

var desktop = monitor => ({
    monitor,
    name: `desktop${monitor}`,
    anchor: ['top', 'bottom', 'left', 'right'],
    child: { type: 'desktop' },
    layer: 'background',
});

var corners = (monitor, places = ['topleft', 'topright', 'bottomleft', 'bottomright']) => places.map(place => ({
    monitor,
    name: `corner${monitor}${place}`,
    className: 'corners',
    anchor: [place.includes('top') ? 'top' : 'bottom', place.includes('right') ? 'right' : 'left'],
    child: { type: 'corner', place },
}));

var indicator = monitor => ({
    monitor,
    name: `indicator${monitor}`,
    className: 'indicator',
    layer: 'overlay',
    anchor: ['right'],
    child: { type: 'on-screen-indicator' },
});

// bar
var launcher = (size = ags.Utils.getConfig()?.baseIconSize || 16) => ({
    type: 'button',
    className: 'launcher panel-button',
    connections: [[ags.App, (btn, win, visible) => {
        btn.toggleClassName('active', win === 'applauncher' && visible);
    }]],
    onClick: () => ags.App.toggleWindow('applauncher'),
    child: { type: 'distro-icon', size },
});

var bar = ({ anchor, orientation, start, center, end }) => monitor => ({
    name: `bar${monitor}`,
    monitor,
    anchor,
    exclusive: true,
    child: {
        type: 'centerbox',
        className: 'panel',
        orientation,
        children: [
            { className: 'start', type: 'box', orientation, children: start },
            { className: 'center', type: 'box', orientation, children: center },
            { className: 'end', type: 'box', orientation, children: end },
        ],
    },
});

//popups
const popup = (name, child) => ({
    name,
    popup: true,
    focusable: true,
    child: {
        type: 'layout',
        layout: 'center',
        window: name,
        child,
    },
});

var applauncher = popup('applauncher', {
    type: 'applauncher',
    className: 'applauncher',
});

var powermenu = popup('powermenu', {
    type: 'powermenu/popup-content',
});

var verification = popup('verification', {
    type: 'powermenu/verification',
});
