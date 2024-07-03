{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.vscode-server.nixosModules.default ];

  options.garden.services.dev.vscode-server = lib.mkServiceOption "vscode-server" { };

  # enable the vscode server
  config.services.vscode-server = lib.mkIf config.garden.services.dev.vscode-server.enable {
    enable = true;
    nodejsPackage = pkgs.nodejs_22;
  };
}
