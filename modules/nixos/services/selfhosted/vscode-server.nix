{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.services) mkServiceOption;
in
{
  imports = [ inputs.vscode-server.nixosModules.default ];

  options.garden.services.vscode-server = mkServiceOption "vscode-server" { };

  # enable the vscode server
  config.services.vscode-server = mkIf config.garden.services.vscode-server.enable {
    enable = true;
    nodejsPackage = pkgs.nodejs_22;
  };
}
