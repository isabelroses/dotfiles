const { Widget } = ags;
const { Theme } = ags.Service;

Widget.widgets['desktop'] = props => Widget({
    ...props,
    type: 'box',
    className: 'desktop',
});