import Theme from '../services/theme/theme.js';
import DesktopMenu from './DesktopMenu.js';
import { Widget } from '../imports.js';

const Desktop = () => Widget.EventBox({
    onSecondaryClick: (_, event) => DesktopMenu().popup_at_pointer(event),
    onMiddleClick: print,
    child: Widget.Box({
        vertical: true,
        vexpand: true,
        hexpand: true,
        connections: [[Theme, box => {
            box.halign = imports.gi.Gtk.Align[halign.toUpperCase()];
            box.valign = imports.gi.Gtk.Align[valign.toUpperCase()];
            box.setStyle(`margin: ${Number(offset)}px;`);
        }]],
    }),
});

export default monitor => Widget.Window({
    monitor,
    name: `desktop${monitor}`,
    layer: 'background',
    className: 'desktop',
    anchor: ['top', 'bottom', 'left', 'right'],
    child: Desktop(),
});
