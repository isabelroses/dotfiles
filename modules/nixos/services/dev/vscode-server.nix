{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [inputs.vscode-server.nixosModules.default];

  # enable the vscode server
  config.services.vscode-server = lib.mkIf config.modules.services.dev.vscode-server.enable {
    enable = true;
    nodejsPackage = pkgs.nodejs_21;
  };
}
