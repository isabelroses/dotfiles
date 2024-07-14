# pretty much ripped from https://github.com/K900/vscode-remote-workaround/blob/main/vscode.nix
# not taking it as an input bceaucse its archived and so It won't be updated
{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.vscode-remote-workaround;
in
{
  options.vscode-remote-workaround = {
    enable = mkEnableOption "automatic VSCode remote server patch" // {
      default = true;
    };

    package = mkPackageOption pkgs "nodejs_18" {
      extraDescription = "This is usually doesn't need to be changed";
    };
  };

  config = mkIf cfg.enable {
    systemd.user = {
      paths.vscode-remote-workaround = {
        wantedBy = [ "default.target" ];
        pathConfig.PathChanged = "%h/.vscode-server/bin";
      };

      services.vscode-remote-workaround.script = ''
        for i in ~/.vscode-server/bin/*; do
          echo "Fixing vscode-server in $i..."
          ln -sf ${cfg.package}/bin/node $i/node
        done
      '';
    };
  };
}
