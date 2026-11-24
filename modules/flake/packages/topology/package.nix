# nix build .#topology
{
  lib,
  inputs,
  runCommand,
  writeText,
  fetchurl,
  graphviz,
  imagemagick,
  librsvg,
  makeFontsConf,
  fraunces,
  inter,
  jetbrains-mono,
}:
let
  inherit (lib.attrsets)
    attrNames
    filterAttrs
    mapAttrs
    mapAttrsToList
    recursiveUpdate
    ;
  inherit (lib.lists)
    imap0
    optional
    unique
    ;
  inherit (lib.strings)
    concatMapStrings
    concatStrings
    concatStringsSep
    optionalString
    toUpper
    ;

  extra = import ./extra.nix;

  # oledpuccin, from the shared palette
  c = {
    inherit (inputs.self.lib.palette)
      base
      surface
      border
      borderStrong
      text
      accent
      ;
    raised = inputs.self.lib.palette.surfaceRaised;
    muted = inputs.self.lib.palette.textMuted;
    subtle = inputs.self.lib.palette.textSubtle;
  };

  catalog = import ./catalog.nix { inherit fetchurl; };

  label = id: catalog.${id}.name or id;
  dotted = concatStringsSep "  ·  ";

  fleet = lib.trivial.importTOML "${inputs.self}/systems/fleet.toml";

  hosts = mapAttrs describe (
    filterAttrs (_: h: (h.class or "nixos") != "iso") (recursiveUpdate fleet extra.hosts)
  );

  describe =
    name: h:
    let
      class = h.class or "nixos";
    in
    {
      inherit name;
      where = h.location or "cloud";
      ipv4 = h.ipv4 or null;
      relay = h.relay or null;

      tailnetIp = h.tailnetIp or null;
      profiles = attrNames (filterAttrs (_: p: p.enable or false) (h.profiles or { }));

      os = h.os or (if class == "darwin" then "apple" else "nixos");
      kind =
        h.kind
          or (concatStringsSep " · " (optional (class == "darwin") "macos" ++ [ (h.arch or "x86_64") ]));
      services =
        if builtins.isList (h.services or null) then
          h.services
        else
          attrNames (filterAttrs (_: s: s.enable or false) (h.services or { }));
    };

  router = {
    name = extra.router.name;
    kind = "router · ${extra.router.info}";
    os = "router";
  };

  nodes = builtins.attrValues hosts ++ [
    router
    offsite
  ];
  wanted = unique (lib.lists.concatMap (h: h.services or [ ] ++ [ "os-${h.os}" ]) nodes);
  monogram =
    id:
    writeText "${id}.svg" ''
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
        <rect x="2" y="2" width="60" height="60" rx="16" fill="${c.raised}" stroke="${c.borderStrong}" stroke-width="3"/>
        <text x="32" y="43" text-anchor="middle" font-family="Fraunces 72pt" font-size="32" fill="${c.text}">${
          toUpper (builtins.substring 0 1 (label (lib.strings.removePrefix "os-" id)))
        }</text>
      </svg>
    '';
  routerIcon = writeText "os-router.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none" stroke="${c.muted}" stroke-width="4" stroke-linecap="round">
      <rect x="6" y="34" width="52" height="20" rx="8"/>
      <path d="M20 34 L14 12 M44 34 L50 12"/>
      <circle cx="18" cy="44" r="1.5" fill="${c.accent}" stroke="${c.accent}"/>
      <circle cx="28" cy="44" r="1.5" fill="${c.muted}"/>
    </svg>
  '';
  storageIcon = writeText "os-storage.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" fill="none" stroke="${c.muted}" stroke-width="4" stroke-linecap="round">
      <ellipse cx="32" cy="14" rx="22" ry="7"/>
      <path d="M10 14 V50 C10 54 20 57 32 57 C44 57 54 54 54 50 V14"/>
      <path d="M10 32 C10 36 20 39 32 39 C44 39 54 36 54 32"/>
      <circle cx="44" cy="47" r="1.5" fill="${c.accent}" stroke="${c.accent}"/>
    </svg>
  '';
  glyphs = {
    os-router = routerIcon;
    os-storage = storageIcon;
  };
  icons = lib.genAttrs wanted (id: catalog.${id}.icon or glyphs.${id} or (monogram id));

  # the jobs service modules add to garden.backups.jobs
  backupJobs = [
    "forgejo"
    "immich"
    "postgresql"
    "vaultwarden"
  ];
  backups =
    h: lib.optionals (builtins.elem "borgbackup" h.services) (lib.intersectLists backupJobs h.services);

  offsite = {
    name = "rsync.net";
    os = "storage";
    kind = "offsite borg repos";
    # from modules/nixos/services/borgbackup.nix
    note = "nightly at 02:30  ·  keeps 7 daily, 4 weekly, 3 monthly";
    # edge labels drift off their arrows once the arrows shape the layout
    rows = mapAttrsToList (n: h: {
      label = n;
      text = dotted (map label (backups h));
    }) (filterAttrs (_: h: backups h != [ ]) hosts);
  };

  # graphviz draws images one pixel per output pixel
  dpi = 160;
  iconPx = id: (if lib.strings.hasPrefix "os-" id then 26 else 13) * dpi / 72;
  img = id: ''<IMG SRC="icons/${id}.png"/>'';

  font =
    face: size: colour: text:
    ''<FONT FACE="${face}" POINT-SIZE="${toString size}" COLOR="${colour}">${text}</FONT>'';

  # one flat table, since nested tables spread slack over every column
  # columns: pad | icon | name | gap | icon | name | pad
  pad = ''<TD WIDTH="8"></TD>'';
  spacer = height: ''<TR><TD COLSPAN="7" HEIGHT="${toString height}"></TD></TR>'';

  service =
    id:
    ''<TD FIXEDSIZE="TRUE" WIDTH="20" HEIGHT="18" ALIGN="RIGHT">${img id}</TD><TD ALIGN="LEFT">${
      font "Inter" 10 c.text (label id)
    }</TD>'';

  grid =
    services:
    let
      half = (builtins.length services + 1) / 2;
      right = lib.lists.drop half services;
    in
    concatStrings (
      imap0 (
        i: id:
        "<TR>${pad}${service id}<TD WIDTH=\"18\"></TD>"
        + (if i < builtins.length right then service (builtins.elemAt right i) else "<TD></TD><TD></TD>")
        + "${pad}</TR>"
      ) (lib.lists.take half services)
    );

  card =
    h:
    let
      mono = font "JetBrains Mono" 9 c.subtle;
      profiles = h.profiles or [ ];
      services = h.services or [ ];

      summary =
        if profiles != [ ] then
          font "Inter" 10 c.text (dotted profiles)
        else
          font "Inter" 10 c.muted h.kind;

      facts = concatStringsSep "    " (
        optional (profiles != [ ]) (font "Inter" 9 c.muted h.kind)
        ++ optional (h.ipv4 or null != null) (mono h.ipv4)
        ++ optional (h.tailnetIp or null != null) (font "Inter" 9 c.accent "●" + "  " + mono h.tailnetIp)
        ++ optional (h ? note) (font "Inter" 9 c.muted h.note)
      );
    in
    concatStrings [
      ''<<TABLE BORDER="1" STYLE="rounded" COLOR="${c.border}" BGCOLOR="${c.surface}" CELLBORDER="0" CELLSPACING="0" CELLPADDING="3">''
      (spacer 4)
      ''<TR>${pad}<TD COLSPAN="4" ALIGN="LEFT">${
        font "Fraunces 72pt" 20 c.text h.name
      }</TD><TD ROWSPAN="2" ALIGN="RIGHT" VALIGN="TOP">${img "os-${h.os}"}</TD>${pad}</TR>''
      ''<TR>${pad}<TD COLSPAN="4" ALIGN="LEFT">${summary}</TD>${pad}</TR>''
      (optionalString (facts != "") ''<TR>${pad}<TD COLSPAN="5" ALIGN="LEFT">${facts}</TD>${pad}</TR>'')
      (spacer 2)
      (optionalString (services != [ ]) ("<HR/>" + spacer 4 + grid services))
      (optionalString (h ? rows) (
        "<HR/>"
        + spacer 4
        + concatMapStrings (
          r:
          ''<TR>${pad}<TD COLSPAN="2" ALIGN="LEFT">${font "Inter" 10 c.text r.label}</TD><TD COLSPAN="3" ALIGN="LEFT">${font "Inter" 10 c.muted r.text}</TD>${pad}</TR>''
        ) h.rows
      ))
      (spacer 4)
      "</TABLE>>"
    ];

  node = id: h: ''"${id}" [label=${card h}];'';

  hostsIn = where: filterAttrs (_: h: h.where == where) hosts;
  hostNodes = where: concatStringsSep "\n" (mapAttrsToList node (hostsIn where));

  cluster = id: label: body: ''
    subgraph "cluster_${id}" {
      label=<${font "Fraunces 72pt" 16 c.muted label}>;
      labeljust=l; labelloc=b;
      style=rounded; color="${c.border}"; penwidth=1.2; margin=22;
      ${body}
    }
  '';

  edge =
    a: b: attrs:
    ''"${a}" -> "${b}" [${attrs}];'';

  edges = pred: f: concatStringsSep "\n" (mapAttrsToList f (filterAttrs (_: pred) hosts));

  legendItem = mark: colour: text: ''
    <TD>${font "Inter" 10 colour mark}</TD><TD WIDTH="6"></TD><TD>${font "Inter" 10 c.muted text}</TD><TD WIDTH="28"></TD>
  '';

  dot = ''
    digraph topology {
      graph [
        rankdir=TB, bgcolor="${c.base}", pad=0.5, nodesep=0.45, ranksep=0.8,
        fontname="Inter", newrank=true
      ];
      node [shape=plain, fontname="Inter"];
      edge [arrowhead=none, color="${c.borderStrong}", penwidth=1.3];

      internet [label=<<TABLE BORDER="1" STYLE="rounded" COLOR="${c.border}" BGCOLOR="${c.surface}" CELLPADDING="10"><TR><TD>${
        font "Fraunces 72pt" 18 c.muted "internet"
      }</TD></TR></TABLE>>];
      ${cluster "cloud" "cloud" ''
        ${hostNodes "cloud"}
        # else the backup arrow drags its host down a rank
        { rank=same; ${concatMapStrings (n: ''"${n}"; '') (attrNames (hostsIn "cloud"))}}
      ''}

      ${cluster "home" "home  ·  ${extra.router.cidr}" ''
        ${node router.name router}
        ${hostNodes "home"}
      ''}

      ${cluster "roaming" "roaming" (hostNodes "roaming")}

      # after the clusters, so it doesn't reorder them
      ${node offsite.name offsite}
      { rank=sink; "${offsite.name}"; }

      ${edges (h: h.where != "home") (
        n: h: edge "internet" n (optionalString (h.where == "roaming") "style=dotted")
      )}
      ${edge "internet" router.name ""}

      ${edges (h: h.where == "home") (n: _: edge router.name n "")}

      ${edges (h: h.relay != null) (
        n: h:
        edge h.relay.via n
          ''color="${c.accent}", style=dashed, constraint=false, label=<${
            font "Inter" 9 c.accent (dotted (map label h.relay.services))
          }>''
      )}

      ${edges (h: backups h != [ ]) (
        n: _h: edge n offsite.name ''color="${c.subtle}", arrowhead=normal, arrowsize=0.6''
      )}

      label=<<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="4"><TR>
        ${legendItem "●" c.accent "on the tailnet, ${extra.tailnet}"}
        ${legendItem "- - -" c.accent "relayed over the tailnet"}
        ${legendItem "──▸" c.subtle "backed up offsite"}
        ${legendItem "· · ·" c.borderStrong "wifi or mobile"}
      </TR></TABLE>>;
      labelloc=b; labeljust=l;
    }
  '';
in
runCommand "topology"
  {
    nativeBuildInputs = [
      graphviz
      imagemagick
      librsvg
    ];
    FONTCONFIG_FILE = makeFontsConf {
      fontDirectories = [
        fraunces
        inter
        jetbrains-mono
      ];
    };
    passAsFile = [ "dot" ];
    inherit dot;
  }
  ''
    export HOME=$TMPDIR
    mkdir -p $out icons

    ${concatMapStrings (
      id:
      let
        px = toString (iconPx id);
      in
      ''
        src=${icons.${id}}
        case $src in
          *.svg) rsvg-convert -w ${px} -h ${px} --keep-aspect-ratio "$src" -o "icons/${id}.png" ;;
          *) magick "$src" -resize ${px}x${px} "icons/${id}.png" ;;
        esac
        magick "icons/${id}.png" -background none -gravity center -extent ${px}x${px} "icons/${id}.png"
      ''
    ) (attrNames icons)}

    cp $dotPath $out/topology.dot
    dot -Tpng:cairo -Gdpi=${toString dpi} $dotPath -o $out/topology.png
    magick $out/topology.png -quality 90 $out/topology.webp
  ''
