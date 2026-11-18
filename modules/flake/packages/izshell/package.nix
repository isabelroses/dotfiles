{
  lib,
  stdenvNoCC,
  makeWrapper,
  quickshell,
  kdePackages,
  adwaita-icon-theme,
  networkmanager,
  glib,
  systemd,
  wireplumber,
  pipewire,
}:
let
  # tools the shell runs itself; the rest (hyprctl, grim, ...) come from the session
  runtimePath = lib.makeBinPath [
    networkmanager
    glib # gdbus
    systemd # busctl, systemctl
    wireplumber
    pipewire
  ];
in
stdenvNoCC.mkDerivation {
  pname = "izshell";
  version = "0";

  src = lib.fileset.toSource {
    root = ./shell;
    fileset = lib.fileset.fileFilter (f: f.hasExt "qml" || f.hasExt "js") ./shell;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/izshell $out/bin
    cp -r . $out/share/izshell

    makeWrapper ${lib.getExe quickshell} $out/libexec/quickshell \
      --suffix PATH : ${runtimePath} \
      --prefix QT_PLUGIN_PATH : ${kdePackages.qtimageformats}/${kdePackages.qtbase.qtPluginPrefix} \
      --prefix XDG_DATA_DIRS : ${adwaita-icon-theme}/share

    # `izshell ipc ...` talks to the running shell; IZSHELL_DIR runs a checkout instead
    cat > $out/bin/izshell <<EOF
    #!${stdenvNoCC.shell}
    config="\''${IZSHELL_DIR:-$out/share/izshell}/shell.qml"
    mkdir -p "\''${XDG_CONFIG_HOME:-\$HOME/.config}/izshell"
    if [ "\$1" = ipc ]; then shift; exec $out/libexec/quickshell ipc -p "\$config" "\$@"; fi
    exec $out/libexec/quickshell -p "\$config" "\$@"
    EOF

    # runs as the greetd user, with no settings of its own: the defaults
    cat > $out/bin/izshell-greeter <<EOF
    #!${stdenvNoCC.shell}
    export IZSHELL_SETTINGS=/dev/null
    exec $out/libexec/quickshell -p $out/share/izshell/greeter.qml "\$@"
    EOF

    chmod +x $out/bin/*

    runHook postInstall
  '';

  meta = {
    description = "isabel's quickshell desktop shell and greeter";
    mainProgram = "izshell";
    platforms = lib.platforms.linux;
  };
}
