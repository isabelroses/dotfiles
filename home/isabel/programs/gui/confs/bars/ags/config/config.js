/* exported config */
import { Theme } from './theme/theme.js';
import topbar from './layouts/topbar.js';
import leftbar from './layouts/leftbar.js';
import * as shared from './layouts/shared.js';

const layouts = {
    topbar,
    leftbar,
};

const monitors = ags.Service.Hyprland.HyprctlGet('monitors')
    .map(mon => mon.id);

export default {
    closeWindowDelay: {
        'quicksettings': 300,
        'dashboard': 300,
    },
    windows: [
        ...layouts[Theme.getSetting('layout')](monitors),
        shared.ApplauncherPopup(),
        shared.PowermenuPopup(),
        shared.VerificationPopup(),
    ],
};
