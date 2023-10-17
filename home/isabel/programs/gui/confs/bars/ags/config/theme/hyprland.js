import App from 'resource:///com/github/Aylur/ags/app.js';
import Service from 'resource:///com/github/Aylur/ags/service/service.js';
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';

export function setupHyprland() {
    try {
        App.instance.connect('config-parsed', () => {
            for (const [name] of App.windows) {
                if (!name.includes('desktop') && name !== 'verification' && name !== 'powermenu') {
                    execAsync(['hyprctl', 'keyword', 'layerrule', `unset, ${name}`]).then(() => {
                        execAsync(['hyprctl', 'keyword', 'layerrule', `blur, ${name}`]);
                        execAsync(['hyprctl', 'keyword', 'layerrule', `ignorealpha 0.6, ${name}`]);
                    });
                }
            }

            for (const name of ['verification', 'powermenu'])
                execAsync(['hyprctl', 'keyword', 'layerrule', `blur, ${name}`]);
        });
    } catch (error) {
        logError(error);
    }
}
