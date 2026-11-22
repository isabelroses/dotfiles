{
  lib,
  stdenv,
  stdenvNoCC,
  makeWrapper,
  cmake,
  ninja,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
  quickshell,
  kdePackages,
  adwaita-icon-theme,
  networkmanager,
  wireplumber,
  pipewire,
  tesseract,
}:
let
  # tools the shell runs itself; the rest (vicinae, ...) come from the session
  runtimePath = lib.makeBinPath [
    networkmanager # nmcli
    wireplumber # wpctl
    pipewire # pw-dump, pw-metadata
    (tesseract.override { enableLanguages = [ "eng" ]; }) # screenshot text recognition
  ];

  # the `Izshell` QML module: what neither Quickshell nor Qt's QML types can do
  # (image clipboard, D-Bus calls, file removal). Built against the same Qt as
  # quickshell, which it is loaded into.
  plugin = stdenv.mkDerivation {
    pname = "izshell-plugin";
    version = "0";
    src = ./plugin;
    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
      wayland-scanner
    ];
    buildInputs = [
      kdePackages.qtbase
      kdePackages.qtdeclarative
      wayland
      wayland-protocols
    ];
    dontWrapQtApps = true;
  };
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
      --prefix XDG_DATA_DIRS : ${adwaita-icon-theme}/share \
      --prefix QML_IMPORT_PATH : ${plugin}/lib/qt-6/qml

    # `izshell ipc ...` talks to the running shell; IZSHELL_DIR runs a checkout instead
    cat > $out/bin/izshell <<EOF
    #!${stdenvNoCC.shell}
    config="\''${IZSHELL_DIR:-$out/share/izshell}/shell.qml"
    mkdir -p "\''${XDG_CONFIG_HOME:-\$HOME/.config}/izshell"
    if [ "\$1" = ipc ]; then shift; exec $out/libexec/quickshell ipc -p "\$config" "\$@"; fi
    exec $out/libexec/quickshell -p "\$config" "\$@"
    EOF

    chmod +x $out/bin/*

    runHook postInstall
  '';

  passthru = { inherit plugin; };

  meta = {
    description = "isabel's quickshell desktop shell";
    mainProgram = "izshell";
    platforms = lib.platforms.linux;
  };
}
