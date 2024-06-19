{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.vscode-server.nixosModules.default ];

  options.modules.services.dev.vscode-server = lib.mkServiceOption "vscode-server" { };

  # enable the vscode server
  config.services.vscode-server = lib.mkIf config.modules.services.dev.vscode-server.enable {
    enable = true;
    nodejsPackage = pkgs.nodejs_22;
  };
}
