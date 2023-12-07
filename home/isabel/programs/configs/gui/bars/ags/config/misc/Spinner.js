import Widget from "resource:///com/github/Aylur/ags/widget.js";

export default (props) =>
    Widget.Spinner({
        ...props,
        active: true,
    });
