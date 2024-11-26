import { clock } from "lib/variables";
import options from "options";

const { format } = options.bar.date;
const time = Utils.derive([clock, format], (c, f) => c.format(f) || "");

export default () =>
  Widget.Label({
    justification: "center",
    label: time.bind(),
  });
