const { Window, CenterBox, Box, Button } = ags.Widget;
import { Corner } from '../modules/corner.js';
import { OnScreenIndicator } from '../modules/onscreenindicator.js';
import { Applauncher } from '../modules/applauncher.js';
import { PopupLayout } from './widgets/popuplayout.js';
import { Desktop as DesktopWidget } from './widgets/desktop.js';
import * as dashboard from './widgets/dashboard.js';
import * as quicksettings from './widgets/quicksettings.js';
import * as powermenu from './widgets/powermenu.js';
import * as notifications from '../modules/notifications.js';

// bar
export const Launcher = ({ child }) => Button({
    className: 'launcher panel-button',
    connections: [[ags.App, (btn, win, visible) => {
        btn.toggleClassName('active', win === 'applauncher' && visible);
    }]],
    onClicked: () => ags.App.toggleWindow('applauncher'),
    child: Box({ children: [child] }),
});

export const Bar = ({ vertical, start, center, end, anchor, monitor }) => Window({
    name: `bar${monitor}`,
    exclusive: true,
    monitor,
    anchor,
    child: CenterBox({
        className: 'panel',
        vertical,
        startWidget: Box({ children: start, vertical, className: 'start' }),
        centerWidget: Box({ children: center, vertical, className: 'center' }),
        endWidget: Box({ children: end, vertical, className: 'end', valign: 'end' }),
    }),
});

// static
export const Notifications = (monitor, transition, anchor) => Window({
    monitor,
    name: `notifications${monitor}`,
    anchor,
    child: notifications.PopupList({ transition }),
});


export const Desktop = monitor => Window({
    monitor,
    name: `desktop${monitor}`,
    className: 'desktop',
    anchor: ['top', 'bottom', 'left', 'right'],
    child: DesktopWidget(),
    layer: 'background',
});

export const Corners = (
    monitor,
    places = ['topleft', 'topright', 'bottomleft', 'bottomright'],
) => places.map(place => Window({
    name: `corner${monitor}${place}`,
    monitor,
    className: 'corner',
    anchor: [place.includes('top') ? 'top' : 'bottom', place.includes('right') ? 'right' : 'left'],
    child: Corner(place),
}));

export const OSDIndicator = monitor => Window({
    name: `indicator${monitor}`,
    monitor,
    className: 'indicator',
    layer: 'overlay',
    anchor: ['right'],
    child: OnScreenIndicator(),
});

//popups
const Popup = (name, child) => Window({
    name,
    popup: true,
    focusable: false,
    layer: 'overlay',
    child: PopupLayout({
        layout: 'center',
        window: name,
        child: child(),
    }),
});

export const ApplauncherPopup = () => Popup('applauncher', Applauncher);
export const PowermenuPopup = () => Popup('powermenu', powermenu.PopupContent);
export const VerificationPopup = () => Popup('verification', powermenu.Verification);

export const Dashboard = ({ position }) => Window({
    name: 'dashboard',
    popup: true,
    focusable: false,
    anchor: position,
    child: PopupLayout({
        layout: position,
        window: 'dashboard',
        child: dashboard.PopupContent(),
    }),
});

export const Quicksettings = ({ position }) => Window({
    name: 'quicksettings',
    popup: true,
    focusable: false,
    anchor: position,
    child: PopupLayout({
        layout: position,
        window: 'quicksettings',
        child: quicksettings.PopupContent(),
    }),
});
