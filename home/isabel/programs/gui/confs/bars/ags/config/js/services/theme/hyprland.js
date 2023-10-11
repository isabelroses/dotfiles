import { App, Utils } from '../../imports.js';

const noAlphaignore = ['verification', 'powermenu'];

export default function () {
    try {
        App.connect('config-parsed', () => {
            for (const [name] of App.windows) {
                Utils.execAsync(['hyprctl', 'keyword', 'layerrule', `unset, ${name}`]).then(() => {
                    Utils.execAsync(['hyprctl', 'keyword', 'layerrule', `blur, ${name}`]);
                    if (!noAlphaignore.every(skip => !name.includes(skip)))
                        return;

                    Utils.execAsync(['hyprctl', 'keyword', 'layerrule', `ignorealpha 0.6, ${name}`]);
                });
            }
        });
    } catch (error) {
        console.error(error);
    }
}
