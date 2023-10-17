const { Label } = ags.Widget;
const { execAsync } = ags.Utils;
const { DateTime } = imports.gi.GLib;

export const Clock = ({
    format = '%I:%M:%S | %d/%m/%y',
    interval = 1000,
    ...props
} = {}) => Label({
    className: 'clock',
    ...props,
    connections: [[interval, label =>
        label.label = DateTime.new_now_local().format(format),
    ]],
});

export const Uptime = ({
    interval = 100_000,
    ...props
} = {}) => Label({
    ...props,
    connections: [[interval, label => {
        execAsync(['bash', '-c', "uptime | awk '{print $3}' | tr ',' ' '"])
            .then(time => label.label = time)
            .catch(print);
    }]],
});


