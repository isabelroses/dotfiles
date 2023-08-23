import * as shared from './shared.js';
import { Launcher } from './shared.js';
import { Workspaces } from './widgets/hyprland.js';
import { Separator } from '../modules/misc.js';
import { PanelIndicator as MediaIndicator } from './widgets/media.js';
import { PanelIndicator as NotificationIndicator } from './widgets/notifications.js';
import { DistroIcon } from '../modules/misc.js';
import { PanelButton as ColorPicker } from '../modules/colorpicker.js';
import { PanelButton as PowerMenu } from './widgets/powermenu.js';
import { PanelButton as DashBoard } from './widgets/dashboard.js';
import { PanelButton as QuickSettings } from './widgets/quicksettings.js';

const Bar = monitor => shared.Bar({
    anchor: 'top left right',
    monitor,
    start: [
        Launcher({ child: DistroIcon() }),
        Workspaces(),
        MediaIndicator({ hexpand: true, halign: 'end' }),
    ],
    center: [
        DashBoard(),
    ],
    end: [
        NotificationIndicator({ direction: 'right', hexpand: true, halign: 'start' }),
        ags.Widget.Box({ hexpand: true }),
        ColorPicker(),
        Separator({ valign: 'center' }),
        QuickSettings(),
        Separator({ valign: 'center' }),
        PowerMenu(),
    ],
});

export default monitors => ([
    ...monitors.map(monitor => [
        Bar(monitor),
        shared.Notifications(monitor, 'slide_down', 'top'),
        shared.Desktop(monitor),
        ...shared.Corners(monitor),
        shared.OSDIndicator(monitor),
    ]),
    shared.Quicksettings({ position: 'top right' }),
    shared.Dashboard({ position: 'top' }),
]).flat(2);
