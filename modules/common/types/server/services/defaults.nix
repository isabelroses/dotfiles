{lib, ...}: let
  inherit (lib) mkDefault;
in {
  config.modules.services = {
    vscode-server.enable = mkDefault true;
    nginx.enable = mkDefault true;
    # cloudflared.enable = true;
  };
}
