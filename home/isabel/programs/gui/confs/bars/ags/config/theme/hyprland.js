const { Service, App } = ags;
const { execAsync } = ags.Utils;

/* exported setupHyprland */
function setupHyprland() {
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
        print(error);
    }
}
