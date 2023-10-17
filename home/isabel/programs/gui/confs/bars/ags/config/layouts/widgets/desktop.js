import { Separator } from '../../modules/misc.js';
const { Theme, System } = ags.Service;
const { MenuItem, Menu, Box, Label, Icon, EventBox, CenterBox } = ags.Widget;

export const Desktop = props => EventBox({
    ...props,
    onSecondaryClick: (_, event) => Menu({
        className: 'desktop',
        children: [
            MenuItem({
                child: Box({
                    children: [
                        Icon('system-shutdown-symbolic'),
                        Label({
                            label: 'System',
                            hexpand: true,
                            xalign: 0,
                        }),
                    ],
                }),
                submenu: Menu({
                    children: [
                        Item('Shutdown', 'system-shutdown-symbolic', () => System.action('Shutdown')),
                        Item('Log Out', 'system-log-out-symbolic', () => System.action('Log Out')),
                        Item('Reboot', 'system-reboot-symbolic', () => System.action('Log Out')),
                        Item('Sleep', 'weather-clear-night-symbolic', () => System.action('Log Out')),
                    ],
                }),
            }),
            MenuItem({ className: 'separator' }),
            Item('Settings', 'org.gnome.Settings-symbolic', Theme.openSettings),
        ],
    }).popup_at_pointer(event),
    onMiddleClick: print,
    child: Box({
        vertical: true,
        vexpand: true,
        hexpand: true,
        connections: [[Theme, box => {
            const [halign = 'center', valign = 'center', offset = 64] =
                Theme.getSetting('desktop_clock')?.split(' ') || [];

            box.halign = imports.gi.Gtk.Align[halign.toUpperCase()];
            box.valign = imports.gi.Gtk.Align[valign.toUpperCase()];
            box.setStyle(`margin: ${Number(offset)}px;`);
        }]],
    }),
});
