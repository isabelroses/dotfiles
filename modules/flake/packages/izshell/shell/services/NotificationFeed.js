.pragma library

// How notification times read, and how the sheet's feed groups them. Pure: `now`
// is passed in.

const day = 86400000;

// the heading a time falls under: "Just now", "Earlier today", "Yesterday", a
// weekday for the rest of the week, then "Older"
function ageGroup(time, now) {
  const mins = (now.getTime() - time) / 60000;
  if (mins < 10) return "Just now";
  const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
  if (time >= startOfToday) return "Earlier today";
  if (time >= startOfToday - day) return "Yesterday";
  if (time >= startOfToday - 6 * day) return Qt.formatDate(new Date(time), "dddd");
  return "Older";
}

// "now", "5m", "3h", then a date
function relativeTime(time, now) {
  const mins = Math.floor((now.getTime() - time) / 60000);
  if (mins < 1) return "now";
  if (mins < 60) return `${mins}m`;
  if (mins < 1440) return `${Math.floor(mins / 60)}h`;
  return Qt.formatDate(new Date(time), "MMM d");
}

// items, newest group first as given -> a flat list of { kind: "header", label }
// and { kind: "item", item, index } rows, a header wherever the age group changes
function groupFeed(items, timeOf, now) {
  const out = [];
  let group = "";
  items.forEach((item, index) => {
    const g = ageGroup(timeOf(item), now);
    if (g !== group) { out.push({ kind: "header", label: g }); group = g; }
    out.push({ kind: "item", item, index });
  });
  return out;
}
