.pragma library

function parse(text) {
  const out = {};
  let table = out;
  const lines = text.split(/\r?\n/);

  for (let i = 0; i < lines.length; i++) {
    const line = stripComment(lines[i]).trim();
    if (line === "") continue;

    const header = line.match(/^\[\s*([A-Za-z0-9_.-]+)\s*\]$/);
    if (header) {
      table = out;
      for (const part of header[1].split(".")) {
        if (typeof table[part] !== "object" || table[part] === null || Array.isArray(table[part]))
          table[part] = {};
        table = table[part];
      }
      continue;
    }

    if (line.startsWith("[")) throw new Error(`line ${i + 1}: bad table header "${line}"`);

    const eq = line.indexOf("=");
    if (eq < 0) throw new Error(`line ${i + 1}: expected "key = value"`);
    const key = line.slice(0, eq).trim().replace(/^"(.*)"$/, "$1");
    if (!/^[A-Za-z0-9_-]+$/.test(key)) throw new Error(`line ${i + 1}: bad key "${key}"`);

    const state = { s: line.slice(eq + 1).trim(), i: 0 };
    const value = parseValue(state, i + 1);
    if (state.s.slice(state.i).trim() !== "")
      throw new Error(`line ${i + 1}: unexpected text after value`);
    table[key] = value;
  }

  return out;
}

function stripComment(line) {
  let quote = null;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (quote) {
      if (c === "\\" && quote === '"') i++;
      else if (c === quote) quote = null;
    } else if (c === '"' || c === "'") {
      quote = c;
    } else if (c === "#") {
      return line.slice(0, i);
    }
  }
  return line;
}

function skipWs(st) {
  while (st.i < st.s.length && /\s/.test(st.s[st.i])) st.i++;
}

function parseValue(st, lineNo) {
  skipWs(st);
  const c = st.s[st.i];

  if (c === '"') {
    let res = "";
    st.i++;
    while (st.i < st.s.length && st.s[st.i] !== '"') {
      let ch = st.s[st.i++];
      if (ch === "\\") {
        const esc = st.s[st.i++];
        ch = { n: "\n", t: "\t", r: "\r", '"': '"', "\\": "\\" }[esc];
        if (ch === undefined) throw new Error(`line ${lineNo}: unknown escape \\${esc}`);
      }
      res += ch;
    }
    if (st.s[st.i] !== '"') throw new Error(`line ${lineNo}: unterminated string`);
    st.i++;
    return res;
  }

  if (c === "'") {
    const end = st.s.indexOf("'", st.i + 1);
    if (end < 0) throw new Error(`line ${lineNo}: unterminated string`);
    const res = st.s.slice(st.i + 1, end);
    st.i = end + 1;
    return res;
  }

  if (c === "[") {
    const arr = [];
    st.i++;
    skipWs(st);
    while (st.s[st.i] !== "]") {
      if (st.i >= st.s.length) throw new Error(`line ${lineNo}: unterminated array (arrays must be on one line)`);
      arr.push(parseValue(st, lineNo));
      skipWs(st);
      if (st.s[st.i] === ",") { st.i++; skipWs(st); }
      else if (st.s[st.i] !== "]") throw new Error(`line ${lineNo}: expected , or ] in array`);
    }
    st.i++;
    return arr;
  }

  const m = st.s.slice(st.i).match(/^(true|false|[+-]?\d[\d_]*(\.\d+)?([eE][+-]?\d+)?)/);
  if (!m) throw new Error(`line ${lineNo}: can't read value "${st.s.slice(st.i)}"`);
  st.i += m[0].length;
  if (m[0] === "true") return true;
  if (m[0] === "false") return false;
  return Number(m[0].replace(/_/g, ""));
}

function formatValue(v) {
  if (typeof v === "boolean") return v ? "true" : "false";
  if (typeof v === "number") return Number.isInteger(v) ? String(v) : String(Math.round(v * 1000) / 1000);
  if (Array.isArray(v)) return "[" + v.map(formatValue).join(", ") + "]";
  return '"' + String(v).replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n").replace(/\t/g, "\\t") + '"';
}

function stringify(sections, header) {
  let out = header ? header.split("\n").map(l => "# " + l).join("\n") + "\n" : "";
  for (const sec of sections) {
    out += `\n[${sec.name}]\n`;
    for (const e of sec.entries) {
      if (e.comment) out += `# ${e.comment}\n`;
      out += `${e.key} = ${formatValue(e.value)}\n`;
    }
  }
  return out;
}
