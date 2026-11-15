{ lib, python3Packages }:
let
  inherit (lib.lists) any filter;
  inherit (lib.strings) hasPrefix;

  dropped = [
    "chip_project_config_include_dirs="
    "chip_python_"
    "enable_rtti="
  ];
in
python3Packages.home-assistant-chip-wheels.overrideAttrs (oa: {
  pname = "chip-ota-provider-app";

  preConfigure = ''
    cd examples/ota-provider-app/linux
  '';

  gnFlags = filter (flag: !any (prefix: hasPrefix prefix flag) dropped) oa.gnFlags ++ [
    "chip_config_network_layer_ble=false"
    "chip_enable_wifi=false"
    "chip_enable_openthread=false"
    "chip_exchange_node_id_logging=true"
  ];

  ninjaFlags = [ "chip-ota-provider-app" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 chip-ota-provider-app -t $out/bin

    runHook postInstall
  '';

  meta = oa.meta // {
    description = "Matter OTA provider, used by matter-server to update devices";
    homepage = "https://github.com/home-assistant-libs/matter-linux-ota-provider";
    mainProgram = "chip-ota-provider-app";
  };
})
